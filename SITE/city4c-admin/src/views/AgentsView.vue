<template>
  <div class="agents-view">
    <!-- Header -->
    <div class="agents-header">
      <div class="header-content">
        <h1>Gerenciar Agentes</h1>
        <p>Visualize e gerencie os agentes públicos que têm acesso ao sistema.</p>
      </div>
    </div>

    <!-- MVP Notice -->
    <div class="mvp-notice">
      <div class="notice-icon">
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
        </svg>
      </div>
      <div class="notice-content">
        <h3>Funcionalidade MVP</h3>
        <p>
          Na versão MVP, a criação de novos agentes é feita diretamente no Supabase Auth. 
          Esta interface mostra apenas os agentes existentes para fins de visualização e atribuição de ocorrências.
        </p>
        <p>
          <strong>Para criar novos agentes:</strong> Acesse o painel do Supabase → Authentication → Users
        </p>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="loading-state">
      <div class="spinner"></div>
      <p>Carregando agentes...</p>
    </div>

    <!-- Agents List -->
    <div v-else-if="agents.length > 0" class="agents-list">
      <div class="list-header">
        <h2>Agentes Cadastrados ({{ agents.length }})</h2>
        <div class="list-filters">
          <select v-model="statusFilter" class="form-select">
            <option value="">Todos os Status</option>
            <option value="active">Ativos</option>
            <option value="inactive">Inativos</option>
          </select>
          
          <select v-model="roleFilter" class="form-select">
            <option value="">Todas as Funções</option>
            <option value="admin">Administradores</option>
            <option value="agent">Agentes</option>
          </select>
        </div>
      </div>

      <div class="agents-grid">
        <div 
          v-for="agent in filteredAgents" 
          :key="agent.id"
          class="agent-card"
        >
          <div class="agent-header">
            <div class="agent-avatar">
              {{ getInitials(agent.full_name || agent.id) }}
            </div>
            <div class="agent-info">
              <h3>{{ agent.full_name || 'Nome não definido' }}</h3>
              <p class="agent-id">ID: {{ agent.id.substring(0, 8) }}...</p>
            </div>
            <div class="agent-status">
              <span 
                class="status-badge"
                :class="agent.is_active ? 'status-active' : 'status-inactive'"
              >
                {{ agent.is_active ? 'Ativo' : 'Inativo' }}
              </span>
            </div>
          </div>

          <div class="agent-details">
            <div class="detail-row">
              <span class="label">Função:</span>
              <span class="value">
                <span class="role-badge" :class="`role-${agent.role}`">
                  {{ agent.role === 'admin' ? 'Administrador' : 'Agente' }}
                </span>
              </span>
            </div>

            <div v-if="agent.department" class="detail-row">
              <span class="label">Departamento:</span>
              <span class="value">{{ agent.department }}</span>
            </div>

            <div v-if="agent.phone" class="detail-row">
              <span class="label">Telefone:</span>
              <span class="value">{{ agent.phone }}</span>
            </div>

            <div class="detail-row">
              <span class="label">Cadastrado em:</span>
              <span class="value">{{ formatDate(agent.created_at) }}</span>
            </div>

            <div class="detail-row">
              <span class="label">Atualizado em:</span>
              <span class="value">{{ formatDate(agent.updated_at) }}</span>
            </div>
          </div>

          <div class="agent-stats">
            <div class="stat-item">
              <span class="stat-value">{{ getAgentOccurrenceCount(agent.id) }}</span>
              <span class="stat-label">Ocorrências Atribuídas</span>
            </div>
            
            <div class="stat-item">
              <span class="stat-value">{{ getAgentReportCount(agent.id) }}</span>
              <span class="stat-label">Relatos Criados</span>
            </div>
          </div>

          <div class="agent-actions">
            <button 
              @click="viewAgentDetails(agent)"
              class="action-btn action-btn--view"
              title="Ver detalhes do agente"
            >
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/>
              </svg>
              Ver Detalhes
            </button>
            
            <button 
              @click="toggleAgentStatus(agent)"
              class="action-btn"
              :class="agent.is_active ? 'action-btn--deactivate' : 'action-btn--activate'"
              :title="agent.is_active ? 'Desativar agente' : 'Ativar agente'"
            >
              <svg v-if="agent.is_active" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm5 11H7v-2h10v2z"/>
              </svg>
              <svg v-else viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
              </svg>
              {{ agent.is_active ? 'Desativar' : 'Ativar' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else-if="!isLoading" class="empty-state">
      <svg class="empty-icon" viewBox="0 0 24 24" fill="currentColor">
        <path d="M16 7c0-2.76-2.24-5-5-5S6 4.24 6 7s2.24 5 5 5 5-2.24 5-5zM1 18c0-2.66 5.33-4 10-4s10 1.34 10 4v1H1v-1z"/>
      </svg>
      <h3>Nenhum agente encontrado</h3>
      <p>Não há agentes cadastrados no sistema ainda.</p>
      <div class="empty-actions">
        <a 
          href="https://supabase.com/dashboard" 
          target="_blank"
          class="btn btn-primary"
        >
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
          </svg>
          Criar Agente no Supabase
        </a>
      </div>
    </div>

    <!-- Agent Details Modal -->
    <div v-if="selectedAgent" class="modal-overlay" @click="selectedAgent = null">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>Detalhes do Agente</h2>
          <button @click="selectedAgent = null" class="close-button">
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
            </svg>
          </button>
        </div>

        <div class="modal-body">
          <div class="agent-profile">
            <div class="profile-avatar">
              {{ getInitials(selectedAgent.full_name || selectedAgent.id) }}
            </div>
            <div class="profile-info">
              <h3>{{ selectedAgent.full_name || 'Nome não definido' }}</h3>
              <p class="profile-role">
                {{ selectedAgent.role === 'admin' ? 'Administrador' : 'Agente' }}
              </p>
            </div>
          </div>

          <div class="profile-details">
            <div class="detail-section">
              <h4>Informações Pessoais</h4>
              <div class="detail-grid">
                <div class="detail-item">
                  <span class="label">ID do Sistema:</span>
                  <span class="value">{{ selectedAgent.id }}</span>
                </div>
                
                <div v-if="selectedAgent.department" class="detail-item">
                  <span class="label">Departamento:</span>
                  <span class="value">{{ selectedAgent.department }}</span>
                </div>
                
                <div v-if="selectedAgent.phone" class="detail-item">
                  <span class="label">Telefone:</span>
                  <span class="value">{{ selectedAgent.phone }}</span>
                </div>
                
                <div class="detail-item">
                  <span class="label">Status:</span>
                  <span class="value">
                    <span 
                      class="status-badge"
                      :class="selectedAgent.is_active ? 'status-active' : 'status-inactive'"
                    >
                      {{ selectedAgent.is_active ? 'Ativo' : 'Inativo' }}
                    </span>
                  </span>
                </div>
              </div>
            </div>

            <div class="detail-section">
              <h4>Estatísticas</h4>
              <div class="stats-grid">
                <div class="stat-card">
                  <div class="stat-number">{{ getAgentOccurrenceCount(selectedAgent.id) }}</div>
                  <div class="stat-description">Ocorrências Atribuídas</div>
                </div>
                
                <div class="stat-card">
                  <div class="stat-number">{{ getAgentReportCount(selectedAgent.id) }}</div>
                  <div class="stat-description">Relatos Criados</div>
                </div>
              </div>
            </div>

            <div class="detail-section">
              <h4>Informações do Sistema</h4>
              <div class="detail-grid">
                <div class="detail-item">
                  <span class="label">Cadastrado em:</span>
                  <span class="value">{{ formatDate(selectedAgent.created_at) }}</span>
                </div>
                
                <div class="detail-item">
                  <span class="label">Última atualização:</span>
                  <span class="value">{{ formatDate(selectedAgent.updated_at) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="modal-actions">
          <button @click="selectedAgent = null" class="btn btn-secondary">
            Fechar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import { ApiService } from '@/services/api'
import type { Profile } from '@/types'

const agents = ref<Profile[]>([])
const selectedAgent = ref<Profile | null>(null)
const isLoading = ref(false)

const statusFilter = ref('')
const roleFilter = ref('')

// Mock data for agent statistics (would come from API)
const agentStats = ref<Record<string, { occurrences: number, reports: number }>>({})

const filteredAgents = computed(() => {
  let filtered = agents.value

  if (statusFilter.value) {
    const isActive = statusFilter.value === 'active'
    filtered = filtered.filter(agent => agent.is_active === isActive)
  }

  if (roleFilter.value) {
    filtered = filtered.filter(agent => agent.role === roleFilter.value)
  }

  return filtered
})

const loadAgents = async () => {
  isLoading.value = true
  try {
    agents.value = await ApiService.getAgents()
    
    // Generate mock statistics for each agent
    agents.value.forEach(agent => {
      agentStats.value[agent.id] = {
        occurrences: Math.floor(Math.random() * 15),
        reports: Math.floor(Math.random() * 8)
      }
    })
  } catch (error) {
    console.error('Error loading agents:', error)
  } finally {
    isLoading.value = false
  }
}

const getInitials = (name: string): string => {
  if (!name) return '?'
  
  return name
    .split(' ')
    .map(word => word[0])
    .join('')
    .substring(0, 2)
    .toUpperCase()
}

const getAgentOccurrenceCount = (agentId: string): number => {
  return agentStats.value[agentId]?.occurrences || 0
}

const getAgentReportCount = (agentId: string): number => {
  return agentStats.value[agentId]?.reports || 0
}

const viewAgentDetails = (agent: Profile) => {
  selectedAgent.value = agent
}

const toggleAgentStatus = async (agent: Profile) => {
  try {
    // This would update the agent status via API
    // For MVP, we'll just show a message
    alert(`Funcionalidade em desenvolvimento. Para alterar o status do agente "${agent.full_name || agent.id}", acesse o painel do Supabase.`)
  } catch (error) {
    console.error('Error toggling agent status:', error)
  }
}

const formatDate = (dateString: string) => {
  return format(new Date(dateString), 'dd/MM/yyyy HH:mm', { locale: ptBR })
}

onMounted(() => {
  loadAgents()
})
</script>

<style scoped>
.agents-view {
  max-width: 1200px;
  margin: 0 auto;
}

/* Header */
.agents-header {
  margin-bottom: 2rem;
}

.header-content h1 {
  font-size: 1.875rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 0.5rem 0;
}

.header-content p {
  color: #6b7280;
  margin: 0;
}

/* MVP Notice */
.mvp-notice {
  background: #fffbeb;
  border: 1px solid #fed7aa;
  border-radius: 12px;
  padding: 1.5rem;
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
}

.notice-icon {
  flex-shrink: 0;
}

.notice-icon svg {
  width: 24px;
  height: 24px;
  color: #d97706;
}

.notice-content h3 {
  font-size: 1rem;
  font-weight: 600;
  color: #92400e;
  margin: 0 0 0.5rem 0;
}

.notice-content p {
  color: #92400e;
  margin: 0 0 0.5rem 0;
  line-height: 1.5;
}

/* Loading State */
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  color: #6b7280;
}

.spinner {
  width: 32px;
  height: 32px;
  border: 2px solid #f3f4f6;
  border-top: 2px solid #2563eb;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* List Header */
.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.list-header h2 {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.list-filters {
  display: flex;
  gap: 1rem;
}

/* Agents Grid */
.agents-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 1.5rem;
}

.agent-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  border: 1px solid #f3f4f6;
  transition: all 0.2s;
}

.agent-card:hover {
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  border-color: #e5e7eb;
}

.agent-header {
  display: flex;
  align-items: start;
  gap: 1rem;
  margin-bottom: 1rem;
}

.agent-avatar {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
  color: white;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 1rem;
  flex-shrink: 0;
}

.agent-info {
  flex: 1;
}

.agent-info h3 {
  font-size: 1.125rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 0.25rem 0;
}

.agent-id {
  color: #6b7280;
  font-size: 0.75rem;
  font-family: monospace;
  margin: 0;
}

.agent-status {
  flex-shrink: 0;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.status-active {
  background: #dcfce7;
  color: #16a34a;
}

.status-inactive {
  background: #fee2e2;
  color: #dc2626;
}

.agent-details {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1rem;
  padding: 1rem;
  background: #f9fafb;
  border-radius: 8px;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.label {
  color: #6b7280;
  font-size: 0.875rem;
  font-weight: 500;
}

.value {
  color: #1f2937;
  font-size: 0.875rem;
  text-align: right;
}

.role-badge {
  padding: 0.125rem 0.5rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.role-admin {
  background: #dbeafe;
  color: #1e40af;
}

.role-agent {
  background: #ecfdf5;
  color: #059669;
}

.agent-stats {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.stat-item {
  flex: 1;
  text-align: center;
  padding: 0.75rem;
  background: #f3f4f6;
  border-radius: 8px;
}

.stat-value {
  display: block;
  font-size: 1.25rem;
  font-weight: 700;
  color: #1f2937;
}

.stat-label {
  font-size: 0.75rem;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  font-weight: 500;
}

.agent-actions {
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  flex: 1;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  border: 1px solid;
  background: white;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  font-size: 0.875rem;
}

.action-btn svg {
  width: 16px;
  height: 16px;
}

.action-btn--view {
  border-color: #3b82f6;
  color: #3b82f6;
}

.action-btn--view:hover {
  background: #3b82f6;
  color: white;
}

.action-btn--activate {
  border-color: #10b981;
  color: #10b981;
}

.action-btn--activate:hover {
  background: #10b981;
  color: white;
}

.action-btn--deactivate {
  border-color: #f59e0b;
  color: #f59e0b;
}

.action-btn--deactivate:hover {
  background: #f59e0b;
  color: white;
}

/* Empty State */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  text-align: center;
  color: #6b7280;
}

.empty-icon {
  width: 64px;
  height: 64px;
  color: #d1d5db;
  margin-bottom: 1rem;
}

.empty-state h3 {
  font-size: 1.25rem;
  font-weight: 600;
  color: #374151;
  margin: 0 0 0.5rem 0;
}

.empty-state p {
  margin: 0 0 1.5rem 0;
}

.empty-actions .btn svg {
  width: 16px;
  height: 16px;
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
}

.modal-content {
  background: white;
  border-radius: 12px;
  max-width: 600px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 25px rgba(0, 0, 0, 0.2);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h2 {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.close-button {
  background: none;
  border: none;
  color: #6b7280;
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 4px;
  transition: color 0.2s;
}

.close-button:hover {
  color: #374151;
}

.close-button svg {
  width: 20px;
  height: 20px;
}

.modal-body {
  padding: 1.5rem;
}

.agent-profile {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #f3f4f6;
}

.profile-avatar {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
  color: white;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 1.5rem;
}

.profile-info h3 {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 0.25rem 0;
}

.profile-role {
  color: #6b7280;
  margin: 0;
}

.detail-section {
  margin-bottom: 2rem;
}

.detail-section h4 {
  font-size: 1rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 1rem 0;
}

.detail-grid {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: start;
  gap: 1rem;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

.stat-card {
  text-align: center;
  padding: 1rem;
  background: #f9fafb;
  border-radius: 8px;
}

.stat-number {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1f2937;
}

.stat-description {
  font-size: 0.875rem;
  color: #6b7280;
  margin-top: 0.25rem;
}

.modal-actions {
  display: flex;
  justify-content: end;
  padding: 1.5rem;
  border-top: 1px solid #e5e7eb;
}

@media (max-width: 768px) {
  .agents-grid {
    grid-template-columns: 1fr;
  }
  
  .list-header {
    flex-direction: column;
    align-items: start;
    gap: 1rem;
  }
  
  .list-filters {
    width: 100%;
    flex-direction: column;
  }
  
  .agent-actions {
    flex-direction: column;
  }
  
  .modal-content {
    margin: 1rem;
    max-width: none;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
}
</style>