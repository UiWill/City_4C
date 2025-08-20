<template>
  <div class="occurrence-detail">
    <!-- Loading State -->
    <div v-if="isLoading" class="loading-state">
      <div class="spinner"></div>
      <p>Carregando detalhes da ocorrência...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-state">
      <div class="error-icon">⚠️</div>
      <h3>Erro ao carregar ocorrência</h3>
      <p>{{ error }}</p>
      <button @click="$router.go(-1)" class="btn btn-secondary">
        Voltar
      </button>
    </div>

    <!-- Content -->
    <div v-else-if="occurrence" class="occurrence-content">
      <!-- Header -->
      <div class="occurrence-header">
        <div class="header-main">
          <button @click="$router.go(-1)" class="back-button">
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/>
            </svg>
            Voltar
          </button>
          
          <div class="header-info">
            <h1>{{ occurrence.title || 'Ocorrência sem título' }}</h1>
            <div class="header-meta">
              <span 
                v-if="occurrence.tags" 
                class="occurrence-tag"
                :style="{ 
                  backgroundColor: occurrence.tags.color + '20', 
                  color: occurrence.tags.color 
                }"
              >
                {{ occurrence.tags.name }}
              </span>
              <span class="occurrence-id">ID: {{ occurrence.id.substring(0, 8) }}...</span>
              <span class="occurrence-date">{{ formatDate(occurrence.created_at) }}</span>
            </div>
          </div>
        </div>

        <div class="header-actions">
          <div class="status-controls">
            <label for="status-select" class="control-label">Status:</label>
            <select 
              id="status-select"
              v-model="currentStatus" 
              @change="updateStatus"
              class="form-select"
            >
              <option value="pending">Pendente</option>
              <option value="in_progress">Em Andamento</option>
              <option value="resolved">Resolvido</option>
              <option value="rejected">Rejeitado</option>
            </select>
          </div>

          <div class="priority-controls">
            <label for="priority-select" class="control-label">Prioridade:</label>
            <select 
              id="priority-select"
              v-model="currentPriority" 
              @change="updatePriority"
              class="form-select"
            >
              <option value="1">Mínima</option>
              <option value="2">Baixa</option>
              <option value="3">Média</option>
              <option value="4">Alta</option>
              <option value="5">Crítica</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Main Content -->
      <div class="main-content">
        <!-- Left Column -->
        <div class="left-column">
          <!-- Video Player -->
          <div class="video-section">
            <h2>Vídeo da Ocorrência</h2>
            <div class="video-container">
              <video 
                ref="videoPlayer"
                :src="occurrence.video_url" 
                controls 
                preload="metadata"
                class="video-player"
                @loadedmetadata="onVideoLoaded"
                @error="onVideoError"
              >
                Seu navegador não suporta o elemento de vídeo.
              </video>
              <div v-if="videoError" class="video-error">
                <p>⚠️ Erro ao carregar vídeo. Usando vídeo de demonstração.</p>
                <button @click="loadDemoVideo" class="btn btn-primary">Carregar Vídeo Demo</button>
              </div>
              
              <div class="video-info">
                <div class="video-meta">
                  <span class="video-duration">
                    Duração: {{ occurrence.video_duration || videoDuration }}s
                  </span>
                  <span class="video-filename">
                    Arquivo: {{ occurrence.video_filename }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Description -->
          <div v-if="occurrence.description" class="description-section">
            <h2>Descrição</h2>
            <div class="description-content">
              <p>{{ occurrence.description }}</p>
            </div>
          </div>

          <!-- Comments/Updates -->
          <div class="updates-section">
            <h2>Atualizações</h2>
            
            <!-- Add Comment Form -->
            <div class="add-comment">
              <form @submit.prevent="addComment" class="comment-form">
                <textarea
                  v-model="newComment"
                  placeholder="Adicione uma atualização ou comentário..."
                  class="form-textarea"
                  rows="3"
                  required
                ></textarea>
                <button 
                  type="submit" 
                  class="btn btn-primary"
                  :disabled="!newComment.trim() || isAddingComment"
                >
                  {{ isAddingComment ? 'Adicionando...' : 'Adicionar Comentário' }}
                </button>
              </form>
            </div>

            <!-- Updates List -->
            <div v-if="updates.length > 0" class="updates-list">
              <div 
                v-for="update in updates" 
                :key="update.id"
                class="update-item"
              >
                <div class="update-header">
                  <div class="update-author">
                    <div class="author-avatar">
                      {{ update.profiles?.full_name?.[0] || 'U' }}
                    </div>
                    <div class="author-info">
                      <span class="author-name">
                        {{ update.profiles?.full_name || 'Usuário' }}
                      </span>
                      <span class="update-date">
                        {{ formatDate(update.created_at) }}
                      </span>
                    </div>
                  </div>
                  <div v-if="update.status_change" class="status-change">
                    Status alterado para: <strong>{{ getStatusLabel(update.status_change) }}</strong>
                  </div>
                </div>
                <div class="update-content">
                  <p>{{ update.comment }}</p>
                </div>
              </div>
            </div>
            
            <div v-else class="no-updates">
              <p>Nenhuma atualização ainda. Seja o primeiro a comentar!</p>
            </div>
          </div>
        </div>

        <!-- Right Column -->
        <div class="right-column">
          <!-- Location Info -->
          <div class="location-section">
            <h3>Localização</h3>
            <div class="location-content">
              <!-- Map Placeholder -->
              <div class="map-placeholder">
                <div class="map-content">
                  <svg class="map-icon" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                  </svg>
                  <p>Mapa Interativo</p>
                  <small>{{ occurrence.latitude.toFixed(6) }}, {{ occurrence.longitude.toFixed(6) }}</small>
                </div>
              </div>

              <div class="location-details">
                <div class="detail-item">
                  <span class="label">Coordenadas:</span>
                  <span class="value coordinates">
                    {{ occurrence.latitude.toFixed(6) }}, {{ occurrence.longitude.toFixed(6) }}
                  </span>
                </div>
                
                <div v-if="occurrence.address" class="detail-item">
                  <span class="label">Endereço:</span>
                  <span class="value">{{ occurrence.address }}</span>
                </div>
                
                <div v-if="occurrence.location_accuracy" class="detail-item">
                  <span class="label">Precisão:</span>
                  <span class="value">{{ occurrence.location_accuracy.toFixed(1) }}m</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Reporter Info -->
          <div class="reporter-section">
            <h3>Informações do Relator</h3>
            <div class="reporter-content">
              <div class="reporter-info">
                <div class="reporter-avatar">
                  <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                  </svg>
                </div>
                <div class="reporter-details">
                  <div class="detail-item">
                    <span class="label">Nome:</span>
                    <span class="value">
                      {{ occurrence.profiles?.full_name || 'Anônimo' }}
                    </span>
                  </div>
                  
                  <div class="detail-item">
                    <span class="label">Tipo:</span>
                    <span class="value">
                      {{ occurrence.reporter_type === 'agent' ? 'Agente Público' : 'Cidadão' }}
                    </span>
                  </div>
                  
                  <div v-if="occurrence.profiles?.department" class="detail-item">
                    <span class="label">Departamento:</span>
                    <span class="value">{{ occurrence.profiles.department }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Assignment -->
          <div class="assignment-section">
            <h3>Responsável</h3>
            <div class="assignment-content">
              <select 
                v-model="assignedTo"
                @change="updateAssignment"
                class="form-select"
              >
                <option value="">Não atribuído</option>
                <option 
                  v-for="agent in agents" 
                  :key="agent.id" 
                  :value="agent.id"
                >
                  {{ agent.full_name || agent.id }}
                </option>
              </select>
              
              <div v-if="occurrence.assigned_agent" class="assigned-info">
                <div class="agent-info">
                  <div class="agent-avatar">
                    {{ occurrence.assigned_agent.full_name?.[0] || 'A' }}
                  </div>
                  <div class="agent-details">
                    <span class="agent-name">
                      {{ occurrence.assigned_agent.full_name || 'Agente' }}
                    </span>
                    <span class="agent-role">
                      {{ occurrence.assigned_agent.department || occurrence.assigned_agent.role }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Service Order -->
          <div v-if="serviceOrder" class="service-order-section">
            <h3>
              <svg viewBox="0 0 24 24" fill="currentColor" class="section-icon">
                <path d="M14,2H6A2,2 0 0,0 4,4V20A2,2 0 0,0 6,22H18A2,2 0 0,0 20,20V8L14,2M18,20H6V4H13V9H18V20Z"/>
              </svg>
              Ordem de Serviço
            </h3>
            <div class="service-order-content">
              <div class="os-header">
                <div class="protocol-number">
                  <span class="label">Protocolo:</span>
                  <span class="value protocol">{{ serviceOrder.protocol_number }}</span>
                </div>
                <div 
                  class="os-status"
                  :class="'os-status--' + serviceOrder.status"
                >
                  {{ getServiceOrderStatusLabel(serviceOrder.status) }}
                </div>
              </div>

              <div class="os-details">
                <div class="detail-item">
                  <span class="label">Título:</span>
                  <span class="value">{{ serviceOrder.title }}</span>
                </div>
                
                <div v-if="serviceOrder.estimated_duration_hours" class="detail-item">
                  <span class="label">Prazo Estimado:</span>
                  <span class="value">{{ serviceOrder.estimated_duration_hours }}h</span>
                </div>
                
                <div v-if="serviceOrder.due_date" class="detail-item">
                  <span class="label">Data Limite:</span>
                  <span 
                    class="value due-date"
                    :class="{ 'overdue': isOverdue(serviceOrder.due_date) }"
                  >
                    {{ formatDate(serviceOrder.due_date) }}
                  </span>
                </div>

                <div v-if="serviceOrder.assigned_agent" class="detail-item">
                  <span class="label">Responsável:</span>
                  <span class="value">{{ serviceOrder.assigned_agent.full_name }}</span>
                </div>

                <div class="detail-item">
                  <span class="label">Criada em:</span>
                  <span class="value">{{ formatDate(serviceOrder.created_at) }}</span>
                </div>

                <div v-if="serviceOrder.completed_at" class="detail-item">
                  <span class="label">Concluída em:</span>
                  <span class="value">{{ formatDate(serviceOrder.completed_at) }}</span>
                </div>
              </div>

              <div class="os-actions">
                <select 
                  v-model="serviceOrderStatus"
                  @change="updateServiceOrderStatus"
                  class="form-select"
                >
                  <option value="created">Criada</option>
                  <option value="in_progress">Em Andamento</option>
                  <option value="completed">Concluída</option>
                  <option value="cancelled">Cancelada</option>
                </select>
                
                <button 
                  @click="exportServiceOrder" 
                  class="btn btn-secondary btn-sm"
                  :disabled="isExporting"
                >
                  <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M14,2H6A2,2 0 0,0 4,4V20A2,2 0 0,0 6,22H18A2,2 0 0,0 20,20V8L14,2M18,20H6V4H13V9H18V20Z"/>
                  </svg>
                  {{ isExporting ? 'Exportando...' : 'Exportar OS' }}
                </button>
              </div>
            </div>
          </div>

          <!-- Metadata -->
          <div class="metadata-section">
            <h3>Metadados</h3>
            <div class="metadata-content">
              <div class="detail-item">
                <span class="label">Criado em:</span>
                <span class="value">{{ formatDate(occurrence.created_at) }}</span>
              </div>
              
              <div class="detail-item">
                <span class="label">Atualizado em:</span>
                <span class="value">{{ formatDate(occurrence.updated_at) }}</span>
              </div>
              
              <div v-if="occurrence.resolved_at" class="detail-item">
                <span class="label">Resolvido em:</span>
                <span class="value">{{ formatDate(occurrence.resolved_at) }}</span>
              </div>
              
              <div v-if="occurrence.metadata" class="detail-item">
                <span class="label">Dispositivo:</span>
                <span class="value">{{ occurrence.metadata.device_info?.platform || 'N/A' }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import { ApiService } from '@/services/api'
import type { 
  Occurrence, 
  OccurrenceUpdate, 
  Profile, 
  OccurrenceStatus, 
  ServiceOrder, 
  ServiceOrderStatus 
} from '@/types'

const route = useRoute()
const occurrenceId = route.params.id as string

const occurrence = ref<Occurrence | null>(null)
const updates = ref<OccurrenceUpdate[]>([])
const agents = ref<Profile[]>([])
const serviceOrder = ref<ServiceOrder | null>(null)

const isLoading = ref(false)
const error = ref('')
const isAddingComment = ref(false)
const newComment = ref('')
const videoDuration = ref('')
const isExporting = ref(false)

const currentStatus = ref<OccurrenceStatus>('pending' as OccurrenceStatus)
const currentPriority = ref(1)
const assignedTo = ref('')
const serviceOrderStatus = ref<ServiceOrderStatus>('created' as ServiceOrderStatus)

const videoPlayer = ref<HTMLVideoElement>()
const videoError = ref(false)

const loadOccurrence = async () => {
  isLoading.value = true
  error.value = ''
  
  try {
    const data = await ApiService.getOccurrenceById(occurrenceId)
    occurrence.value = data
    currentStatus.value = data.status
    currentPriority.value = data.priority
    assignedTo.value = data.assigned_to || ''
  } catch (err: any) {
    error.value = err.message || 'Erro ao carregar ocorrência'
  } finally {
    isLoading.value = false
  }
}

const loadUpdates = async () => {
  try {
    updates.value = await ApiService.getOccurrenceUpdates(occurrenceId)
  } catch (err) {
    console.error('Error loading updates:', err)
  }
}

const loadAgents = async () => {
  try {
    agents.value = await ApiService.getAgents()
  } catch (err) {
    console.error('Error loading agents:', err)
  }
}

const loadServiceOrder = async () => {
  try {
    const data = await ApiService.getServiceOrderByOccurrenceId(occurrenceId)
    serviceOrder.value = data
    if (data) {
      serviceOrderStatus.value = data.status
    }
  } catch (err) {
    console.error('Error loading service order:', err)
  }
}

const updateStatus = async () => {
  try {
    await ApiService.updateOccurrenceStatus(occurrenceId, currentStatus.value)
    await loadOccurrence()
    await loadUpdates()
    await loadServiceOrder() // Reload service order as it might be created
  } catch (err) {
    console.error('Error updating status:', err)
  }
}

const updatePriority = async () => {
  try {
    await ApiService.updateOccurrencePriority(occurrenceId, currentPriority.value)
    await loadOccurrence()
  } catch (err) {
    console.error('Error updating priority:', err)
  }
}

const updateAssignment = async () => {
  try {
    await ApiService.updateOccurrenceStatus(occurrenceId, currentStatus.value, assignedTo.value)
    await loadOccurrence()
  } catch (err) {
    console.error('Error updating assignment:', err)
  }
}

const addComment = async () => {
  if (!newComment.value.trim()) return
  
  isAddingComment.value = true
  try {
    await ApiService.addOccurrenceUpdate(occurrenceId, newComment.value.trim())
    newComment.value = ''
    await loadUpdates()
  } catch (err) {
    console.error('Error adding comment:', err)
  } finally {
    isAddingComment.value = false
  }
}

const onVideoLoaded = () => {
  if (videoPlayer.value) {
    videoDuration.value = Math.round(videoPlayer.value.duration).toString()
    videoError.value = false
  }
}

const onVideoError = () => {
  videoError.value = true
  console.log('Video loading error - this is expected for demo purposes')
}

const loadDemoVideo = () => {
  if (videoPlayer.value && occurrence.value) {
    // Use a working demo video URL
    videoPlayer.value.src = 'https://sample-videos.com/zip/10/mp4/720/SampleVideo_720x480_1mb.mp4'
    videoError.value = false
  }
}

const formatDate = (dateString: string) => {
  return format(new Date(dateString), 'dd/MM/yyyy HH:mm', { locale: ptBR })
}

const updateServiceOrderStatus = async () => {
  if (!serviceOrder.value) return
  
  try {
    const completedAt = serviceOrderStatus.value === 'completed' ? new Date().toISOString() : undefined
    await ApiService.updateServiceOrderStatus(serviceOrder.value.id, serviceOrderStatus.value, completedAt)
    await loadServiceOrder()
  } catch (err) {
    console.error('Error updating service order status:', err)
  }
}

const exportServiceOrder = async () => {
  if (!serviceOrder.value) return
  
  isExporting.value = true
  try {
    // Create a simple text export for now
    const content = `
ORDEM DE SERVIÇO - ${serviceOrder.value.protocol_number}

Título: ${serviceOrder.value.title}
Status: ${getServiceOrderStatusLabel(serviceOrder.value.status)}
Prioridade: ${serviceOrder.value.priority}/5
${serviceOrder.value.due_date ? `Data Limite: ${formatDate(serviceOrder.value.due_date)}` : ''}

Descrição:
${serviceOrder.value.description}

${serviceOrder.value.assigned_agent ? `Responsável: ${serviceOrder.value.assigned_agent.full_name}` : ''}

Criada em: ${formatDate(serviceOrder.value.created_at)}
${serviceOrder.value.completed_at ? `Concluída em: ${formatDate(serviceOrder.value.completed_at)}` : ''}

Sistema CITY 4C - Gerado automaticamente
    `.trim()

    const blob = new Blob([content], { type: 'text/plain' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `OS_${serviceOrder.value.protocol_number}.txt`
    a.click()
    window.URL.revokeObjectURL(url)
  } catch (err) {
    console.error('Error exporting service order:', err)
  } finally {
    isExporting.value = false
  }
}

const isOverdue = (dueDate: string) => {
  return new Date(dueDate) < new Date()
}

const getServiceOrderStatusLabel = (status: ServiceOrderStatus) => {
  const labels: Record<ServiceOrderStatus, string> = {
    created: 'Criada',
    in_progress: 'Em Andamento',
    completed: 'Concluída',
    cancelled: 'Cancelada'
  }
  return labels[status] || status
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
  loadOccurrence()
  loadUpdates()
  loadAgents()
  loadServiceOrder()
})
</script>

<style scoped>
.occurrence-detail {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 1rem;
}

/* Loading and Error States */
.loading-state, .error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
  text-align: center;
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

.error-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

/* Header */
.occurrence-header {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  display: flex;
  justify-content: space-between;
  align-items: start;
  gap: 2rem;
}

.back-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: none;
  border: 1px solid #d1d5db;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.2s;
  margin-bottom: 1rem;
}

.back-button:hover {
  background: #f9fafb;
  color: #374151;
}

.back-button svg {
  width: 16px;
  height: 16px;
}

.header-info h1 {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 0.5rem 0;
}

.header-meta {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}

.occurrence-tag {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 500;
}

.occurrence-id {
  font-family: monospace;
  background: #f3f4f6;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  color: #6b7280;
}

.occurrence-date {
  color: #6b7280;
  font-size: 0.875rem;
}

.header-actions {
  display: flex;
  gap: 1rem;
  align-items: end;
}

.status-controls,
.priority-controls {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.control-label {
  font-size: 0.875rem;
  font-weight: 500;
  color: #374151;
}

/* Main Content */
.main-content {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 1.5rem;
}

.left-column,
.right-column {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

/* Sections */
.video-section,
.description-section,
.updates-section,
.location-section,
.reporter-section,
.assignment-section,
.metadata-section {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.video-section h2,
.description-section h2,
.updates-section h2 {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 1rem 0;
}

.location-section h3,
.reporter-section h3,
.assignment-section h3,
.service-order-section h3,
.metadata-section h3 {
  font-size: 1.125rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 1rem 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.section-icon {
  width: 20px;
  height: 20px;
  color: #6b7280;
}

/* Video Section */
.video-container {
  width: 100%;
}

.video-player {
  width: 100%;
  height: auto;
  border-radius: 8px;
  background: #000;
}

.video-info {
  margin-top: 0.75rem;
}

.video-meta {
  display: flex;
  gap: 1rem;
  font-size: 0.875rem;
  color: #6b7280;
}

/* Description */
.description-content p {
  color: #374151;
  line-height: 1.6;
  margin: 0;
}

/* Updates */
.comment-form {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.updates-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.update-item {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 1rem;
}

.update-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.update-author {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.author-avatar {
  width: 32px;
  height: 32px;
  background: #3b82f6;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 0.875rem;
}

.author-info {
  display: flex;
  flex-direction: column;
}

.author-name {
  font-weight: 500;
  color: #1f2937;
  font-size: 0.875rem;
}

.update-date {
  font-size: 0.75rem;
  color: #6b7280;
}

.status-change {
  font-size: 0.75rem;
  color: #059669;
  background: #d1fae5;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
}

.update-content p {
  margin: 0;
  color: #374151;
  line-height: 1.5;
}

.no-updates {
  text-align: center;
  color: #6b7280;
  padding: 2rem;
}

/* Location */
.map-placeholder {
  width: 100%;
  height: 200px;
  background: #f3f4f6;
  border: 2px dashed #d1d5db;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1rem;
}

.map-content {
  text-align: center;
  color: #6b7280;
}

.map-icon {
  width: 32px;
  height: 32px;
  margin: 0 auto 0.5rem;
  display: block;
}

.location-details,
.metadata-content {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: start;
  gap: 0.5rem;
}

.label {
  font-weight: 500;
  color: #6b7280;
  font-size: 0.875rem;
  flex-shrink: 0;
}

.value {
  color: #1f2937;
  font-size: 0.875rem;
  text-align: right;
}

.coordinates {
  font-family: monospace;
  font-size: 0.8rem;
}

/* Reporter */
.reporter-info {
  display: flex;
  gap: 1rem;
}

.reporter-avatar {
  width: 48px;
  height: 48px;
  background: #e5e7eb;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #6b7280;
  flex-shrink: 0;
}

.reporter-avatar svg {
  width: 24px;
  height: 24px;
}

.reporter-details {
  flex: 1;
}

/* Assignment */
.assigned-info {
  margin-top: 1rem;
}

.agent-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  background: #f9fafb;
  border-radius: 6px;
}

.agent-avatar {
  width: 32px;
  height: 32px;
  background: #10b981;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 0.875rem;
}

.agent-details {
  display: flex;
  flex-direction: column;
}

.agent-name {
  font-weight: 500;
  color: #1f2937;
  font-size: 0.875rem;
}

.agent-role {
  font-size: 0.75rem;
  color: #6b7280;
}

@media (max-width: 1024px) {
  .main-content {
    grid-template-columns: 1fr;
  }
  
  .occurrence-header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .header-actions {
    justify-content: stretch;
  }
}

@media (max-width: 640px) {
  .header-meta {
    flex-direction: column;
    align-items: start;
  }
  
  .header-actions {
    flex-direction: column;
  }
  
  .update-header {
    flex-direction: column;
    align-items: start;
    gap: 0.5rem;
  }
  
  .detail-item {
    flex-direction: column;
    align-items: start;
  }
  
  .value {
    text-align: left;
  }
}

/* Service Order Section */
.service-order-section {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  border: 2px solid #e5e7eb;
}

.service-order-content {
  space-y: 1rem;
}

.os-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.protocol-number {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.protocol-number .value.protocol {
  font-weight: 700;
  color: #1f2937;
  background: #f3f4f6;
  padding: 0.25rem 0.75rem;
  border-radius: 6px;
  font-family: monospace;
}

.os-status {
  padding: 0.25rem 0.75rem;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 600;
  text-transform: capitalize;
}

.os-status--created {
  background: #dbeafe;
  color: #1e40af;
}

.os-status--in_progress {
  background: #fef3c7;
  color: #92400e;
}

.os-status--completed {
  background: #dcfce7;
  color: #166534;
}

.os-status--cancelled {
  background: #fecaca;
  color: #dc2626;
}

.os-details {
  margin-bottom: 1rem;
}

.due-date.overdue {
  color: #dc2626;
  font-weight: 600;
}

.os-actions {
  display: flex;
  gap: 0.75rem;
  align-items: center;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.btn-sm {
  padding: 0.5rem 0.75rem;
  font-size: 0.875rem;
}

.btn-sm svg {
  width: 16px;
  height: 16px;
  margin-right: 0.25rem;
}

@media (max-width: 768px) {
  .os-header {
    flex-direction: column;
    align-items: start;
    gap: 0.5rem;
  }
  
  .os-actions {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>