<template>
  <div class="dashboard">
    <!-- Stats Cards -->
    <div class="stats-grid">
      <div class="stat-card stat-card--primary">
        <div class="stat-card__icon">
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
          </svg>
        </div>
        <div class="stat-card__content">
          <h3>{{ stats?.total_occurrences || 0 }}</h3>
          <p>Total de Ocorrências</p>
        </div>
      </div>

      <div class="stat-card stat-card--warning">
        <div class="stat-card__icon">
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
          </svg>
        </div>
        <div class="stat-card__content">
          <h3>{{ stats?.pending_occurrences || 0 }}</h3>
          <p>Pendentes</p>
        </div>
      </div>

      <div class="stat-card stat-card--info">
        <div class="stat-card__icon">
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/>
          </svg>
        </div>
        <div class="stat-card__content">
          <h3>{{ stats?.in_progress_occurrences || 0 }}</h3>
          <p>Em Andamento</p>
        </div>
      </div>

      <div class="stat-card stat-card--success">
        <div class="stat-card__icon">
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z"/>
          </svg>
        </div>
        <div class="stat-card__content">
          <h3>{{ stats?.resolved_occurrences || 0 }}</h3>
          <p>Resolvidas</p>
        </div>
      </div>
    </div>

    <div class="dashboard-content">
      <!-- Left Column -->
      <div class="dashboard-column">
        <!-- Recent Occurrences -->
        <div class="dashboard-card">
          <div class="card-header">
            <h2>Ocorrências Recentes</h2>
            <RouterLink to="/occurrences" class="view-all-link">
              Ver todas
            </RouterLink>
          </div>
          
          <div v-if="loadingOccurrences" class="loading-state">
            <div class="spinner"></div>
            <p>Carregando ocorrências...</p>
          </div>
          
          <div v-else-if="recentOccurrences.length === 0" class="empty-state">
            <svg class="empty-icon" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
            </svg>
            <p>Nenhuma ocorrência encontrada</p>
          </div>
          
          <div v-else class="occurrence-list">
            <div 
              v-for="occurrence in recentOccurrences" 
              :key="occurrence.id"
              class="occurrence-item"
              @click="goToOccurrence(occurrence.id)"
            >
              <div class="occurrence-item__status" :class="`status--${occurrence.status.replace('_', '-')}`">
                <div class="status-dot"></div>
                <span class="status-text">{{ getStatusLabel(occurrence.status) }}</span>
              </div>
              
              <div class="occurrence-item__content">
                <h4>{{ occurrence.title || 'Ocorrência sem título' }}</h4>
                <div class="occurrence-meta">
                  <span v-if="occurrence.tags" class="tag" :style="{ backgroundColor: occurrence.tags.color + '20', color: occurrence.tags.color }">
                    {{ occurrence.tags.name }}
                  </span>
                  <span class="date">{{ formatDate(occurrence.created_at) }}</span>
                </div>
                <p v-if="occurrence.address" class="address">{{ occurrence.address }}</p>
              </div>

              <div class="occurrence-item__actions">
                <button class="action-button" :title="`Prioridade ${occurrence.priority}`">
                  <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                  </svg>
                  {{ occurrence.priority }}
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="dashboard-card">
          <h2>Ações Rápidas</h2>
          <div class="quick-actions">
            <RouterLink to="/occurrences" class="quick-action">
              <div class="quick-action__icon">
                <svg viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                </svg>
              </div>
              <div class="quick-action__content">
                <h3>Gerenciar Ocorrências</h3>
                <p>Visualizar e atualizar status das ocorrências</p>
              </div>
            </RouterLink>

            <RouterLink to="/map" class="quick-action">
              <div class="quick-action__icon">
                <svg viewBox="0 0 24 24" fill="currentColor">
                  <path d="M20.5 3l-.16.03L15 5.1 9 3 3.36 4.9c-.21.07-.36.25-.36.48V20.5c0 .28.22.5.5.5l.16-.03L9 18.9l6 2.1 5.64-1.9c.21-.07.36-.25.36-.48V3.5c0-.28-.22-.5-.5-.5z"/>
                </svg>
              </div>
              <div class="quick-action__content">
                <h3>Ver no Mapa</h3>
                <p>Visualizar ocorrências georreferenciadas</p>
              </div>
            </RouterLink>

            <RouterLink v-if="profile?.role === 'admin'" to="/tags" class="quick-action">
              <div class="quick-action__icon">
                <svg viewBox="0 0 24 24" fill="currentColor">
                  <path d="M17.63 5.84C17.27 5.33 16.67 5 16 5L5 5.01C3.9 5.01 3 5.9 3 7v10c0 1.1.9 2 2 2h11c.67 0 1.27-.33 1.63-.84L22 12l-4.37-6.16z"/>
                </svg>
              </div>
              <div class="quick-action__content">
                <h3>Gerenciar Categorias</h3>
                <p>Adicionar e editar tags das ocorrências</p>
              </div>
            </RouterLink>
          </div>
        </div>
      </div>

      <!-- Right Column -->
      <div class="dashboard-column">
        <!-- Tags Chart -->
        <div class="dashboard-card">
          <h2>Ocorrências por Categoria</h2>
          <div v-if="stats?.by_tag && stats.by_tag.length > 0" class="tags-chart">
            <div 
              v-for="tag in stats.by_tag" 
              :key="tag.tag_name"
              class="tag-item"
            >
              <div class="tag-info">
                <div 
                  class="tag-color" 
                  :style="{ backgroundColor: tag.color }"
                ></div>
                <span class="tag-name">{{ tag.tag_name }}</span>
              </div>
              <div class="tag-count">{{ tag.count }}</div>
            </div>
          </div>
          <div v-else class="empty-state">
            <p>Nenhum dado disponível</p>
          </div>
        </div>

        <!-- System Status -->
        <div class="dashboard-card">
          <h2>Status do Sistema</h2>
          <div class="system-status">
            <div class="status-item status-item--online">
              <div class="status-dot"></div>
              <div class="status-info">
                <h4>Base de Dados</h4>
                <p>Online e funcionando</p>
              </div>
            </div>
            
            <div class="status-item status-item--online">
              <div class="status-dot"></div>
              <div class="status-info">
                <h4>Storage de Vídeos</h4>
                <p>Operacional</p>
              </div>
            </div>

            <div class="status-item status-item--warning">
              <div class="status-dot"></div>
              <div class="status-info">
                <h4>Versão MVP</h4>
                <p>Funcionalidades limitadas</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import { ApiService } from '@/services/api'
import { useAuth } from '@/composables/useAuth'
import type { DashboardStats, Occurrence } from '@/types'

const router = useRouter()
const { profile } = useAuth()

const stats = ref<DashboardStats | null>(null)
const recentOccurrences = ref<Occurrence[]>([])
const loadingStats = ref(false)
const loadingOccurrences = ref(false)

const loadDashboardData = async () => {
  await Promise.all([
    loadStats(),
    loadRecentOccurrences()
  ])
}

const loadStats = async () => {
  loadingStats.value = true
  try {
    stats.value = await ApiService.getDashboardStats()
  } catch (error) {
    console.error('Error loading stats:', error)
  } finally {
    loadingStats.value = false
  }
}

const loadRecentOccurrences = async () => {
  loadingOccurrences.value = true
  try {
    recentOccurrences.value = await ApiService.getOccurrences({ limit: 5 })
  } catch (error) {
    console.error('Error loading occurrences:', error)
  } finally {
    loadingOccurrences.value = false
  }
}

const goToOccurrence = (id: string) => {
  router.push(`/occurrences/${id}`)
}

const formatDate = (dateString: string) => {
  return format(new Date(dateString), 'dd/MM/yyyy HH:mm', { locale: ptBR })
}

const getStatusLabel = (status: string) => {
  const labels: Record<string, string> = {
    pending: 'Pendente',
    in_progress: 'Em Andamento',
    resolved: 'Resolvido',
    rejected: 'Rejeitado'
  }
  return labels[status] || status
}

onMounted(() => {
  loadDashboardData()
})
</script>

<style scoped>
.dashboard {
  width: 100%;
  height: 100%;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 2rem;
  margin-bottom: 3rem;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  border: 1px solid #f3f4f6;
}

.stat-card__icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-card__icon svg {
  width: 24px;
  height: 24px;
}

.stat-card--primary .stat-card__icon {
  background-color: #dbeafe;
  color: #1e40af;
}

.stat-card--warning .stat-card__icon {
  background-color: #fef3c7;
  color: #d97706;
}

.stat-card--info .stat-card__icon {
  background-color: #e0f2fe;
  color: #0369a1;
}

.stat-card--success .stat-card__icon {
  background-color: #dcfce7;
  color: #16a34a;
}

.stat-card__content h3 {
  font-size: 1.875rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 0.25rem 0;
}

.stat-card__content p {
  color: #6b7280;
  margin: 0;
  font-weight: 500;
}

/* Dashboard Layout */
.dashboard-content {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 3rem;
  height: 100%;
}

.dashboard-column {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.dashboard-card {
  background: white;
  border-radius: 16px;
  padding: 2rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  border: 1px solid #e5e7eb;
  height: fit-content;
}

.dashboard-card h2 {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 1rem 0;
}

.card-header {
  display: flex;
  justify-content: between;
  align-items: center;
  margin-bottom: 1rem;
}

.view-all-link {
  color: #2563eb;
  font-weight: 500;
  text-decoration: none;
  font-size: 0.875rem;
}

.view-all-link:hover {
  color: #1d4ed8;
}

/* Loading and Empty States */
.loading-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
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

.empty-icon {
  width: 48px;
  height: 48px;
  color: #d1d5db;
  margin-bottom: 1rem;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Occurrence List */
.occurrence-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.occurrence-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border: 1px solid #f3f4f6;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.occurrence-item:hover {
  background-color: #f9fafb;
  border-color: #e5e7eb;
}

.occurrence-item__status {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  min-width: 120px;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.status--pending .status-dot {
  background-color: #f59e0b;
}

.status--in-progress .status-dot {
  background-color: #3b82f6;
}

.status--resolved .status-dot {
  background-color: #10b981;
}

.status--rejected .status-dot {
  background-color: #ef4444;
}

.status-text {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.status--pending .status-text {
  color: #d97706;
}

.status--in-progress .status-text {
  color: #2563eb;
}

.status--resolved .status-text {
  color: #16a34a;
}

.status--rejected .status-text {
  color: #dc2626;
}

.occurrence-item__content {
  flex: 1;
}

.occurrence-item__content h4 {
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 0.5rem 0;
  font-size: 0.875rem;
}

.occurrence-meta {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.25rem;
}

.tag {
  padding: 0.125rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 500;
}

.date {
  color: #374151;
  font-size: 0.875rem;
  font-weight: 500;
}

.address {
  color: #374151;
  font-size: 0.875rem;
  font-weight: 500;
  margin: 0;
}

.occurrence-item__actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.action-button {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.25rem 0.5rem;
  background: #f3f4f6;
  border: none;
  border-radius: 4px;
  color: #6b7280;
  font-size: 0.75rem;
  cursor: pointer;
}

.action-button svg {
  width: 12px;
  height: 12px;
}

/* Quick Actions */
.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.quick-action {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border: 1px solid #f3f4f6;
  border-radius: 8px;
  text-decoration: none;
  color: inherit;
  transition: all 0.2s;
}

.quick-action:hover {
  background-color: #f9fafb;
  border-color: #e5e7eb;
}

.quick-action__icon {
  width: 40px;
  height: 40px;
  background-color: #eff6ff;
  color: #2563eb;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.quick-action__icon svg {
  width: 20px;
  height: 20px;
}

.quick-action__content h3 {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 0.25rem 0;
}

.quick-action__content p {
  color: #6b7280;
  font-size: 0.75rem;
  margin: 0;
}

/* Tags Chart */
.tags-chart {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.tag-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.tag-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.tag-color {
  width: 12px;
  height: 12px;
  border-radius: 2px;
}

.tag-name {
  font-weight: 500;
  color: #374151;
}

.tag-count {
  font-weight: 600;
  color: #1f2937;
  background-color: #f3f4f6;
  padding: 0.25rem 0.5rem;
  border-radius: 12px;
  font-size: 0.875rem;
}

/* System Status */
.system-status {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.status-item .status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.status-item--online .status-dot {
  background-color: #10b981;
}

.status-item--warning .status-dot {
  background-color: #f59e0b;
}

.status-item--error .status-dot {
  background-color: #ef4444;
}

.status-info h4 {
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 0.25rem 0;
  font-size: 0.875rem;
}

.status-info p {
  color: #6b7280;
  font-size: 0.75rem;
  margin: 0;
}

@media (max-width: 768px) {
  .dashboard-content {
    grid-template-columns: 1fr;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 480px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .dashboard-card {
    padding: 1rem;
  }
}
</style>