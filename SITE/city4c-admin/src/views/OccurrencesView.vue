<template>
  <div class="occurrences-view">
    <!-- Filters -->
    <div class="filters-section">
      <div class="filters-row">
        <div class="filter-group">
          <label for="status-filter" class="filter-label">Status</label>
          <select id="status-filter" v-model="filters.status" class="form-select">
            <option value="">Todos</option>
            <option value="pending">Pendente</option>
            <option value="in_progress">Em Andamento</option>
            <option value="resolved">Resolvido</option>
            <option value="rejected">Rejeitado</option>
          </select>
        </div>

        <div class="filter-group">
          <label for="tag-filter" class="filter-label">Categoria</label>
          <select id="tag-filter" v-model="filters.tag_id" class="form-select">
            <option value="">Todas</option>
            <option v-for="tag in tags" :key="tag.id" :value="tag.id">
              {{ tag.name }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label for="priority-filter" class="filter-label">Prioridade</label>
          <select id="priority-filter" v-model="filters.priority" class="form-select">
            <option value="">Todas</option>
            <option value="5">Crítica</option>
            <option value="4">Alta</option>
            <option value="3">Média</option>
            <option value="2">Baixa</option>
            <option value="1">Mínima</option>
          </select>
        </div>

        <div class="filter-actions">
          <button @click="clearFilters" class="btn btn-secondary">
            Limpar Filtros
          </button>
          <button @click="exportToCSV" class="btn btn-primary" :disabled="isExporting">
            <svg v-if="isExporting" class="animate-spin" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 4V2A10 10 0 0 0 2 12h2a8 8 0 0 1 8-8z"/>
            </svg>
            <svg v-else viewBox="0 0 24 24" fill="currentColor">
              <path d="M14,2H6A2,2 0 0,0 4,4V20A2,2 0 0,0 6,22H18A2,2 0 0,0 20,20V8L14,2M18,20H6V4H13V9H18V20Z"/>
            </svg>
            {{ isExporting ? 'Exportando...' : 'Exportar CSV' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Results Summary -->
    <div class="results-summary">
      <p>
        <strong>{{ filteredCount }}</strong> ocorrência{{ filteredCount !== 1 ? 's' : '' }} encontrada{{ filteredCount !== 1 ? 's' : '' }}
        <span v-if="hasActiveFilters"> (filtrado de {{ totalCount }} total)</span>
      </p>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="loading-state">
      <div class="spinner"></div>
      <p>Carregando ocorrências...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="occurrences.length === 0" class="empty-state">
      <svg class="empty-icon" viewBox="0 0 24 24" fill="currentColor">
        <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
      </svg>
      <h3>Nenhuma ocorrência encontrada</h3>
      <p v-if="hasActiveFilters">
        Tente ajustar os filtros para ver mais resultados.
      </p>
      <p v-else>
        As ocorrências aparecerão aqui quando forem reportadas através do aplicativo.
      </p>
    </div>

    <!-- Occurrences List -->
    <div v-else class="occurrences-list">
      <div 
        v-for="occurrence in occurrences" 
        :key="occurrence.id"
        class="occurrence-card"
        @click="goToOccurrence(occurrence.id)"
      >
        <!-- Card Header -->
        <div class="occurrence-header">
          <div class="occurrence-info">
            <h3 class="occurrence-title">
              {{ occurrence.title || 'Ocorrência sem título' }}
            </h3>
            <div class="occurrence-meta">
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
              <span class="occurrence-date">
                {{ formatDate(occurrence.created_at) }}
              </span>
            </div>
          </div>

          <div class="occurrence-status">
            <span 
              class="status-badge"
              :class="`status-badge--${occurrence.status.replace('_', '-')}`"
            >
              {{ getStatusLabel(occurrence.status) }}
            </span>
            <div class="priority-indicator">
              <svg 
                v-for="i in 5" 
                :key="i"
                class="priority-star"
                :class="{ 'priority-star--active': i <= occurrence.priority }"
                viewBox="0 0 24 24" 
                fill="currentColor"
              >
                <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
              </svg>
            </div>
          </div>
        </div>

        <!-- Card Content -->
        <div class="occurrence-content">
          <div class="occurrence-details">
            <p v-if="occurrence.description" class="occurrence-description">
              {{ occurrence.description }}
            </p>
            
            <div class="occurrence-location">
              <svg class="location-icon" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
              </svg>
              <span v-if="occurrence.address">
                {{ occurrence.address }}
              </span>
              <span v-else class="coordinates">
                {{ occurrence.latitude.toFixed(6) }}, {{ occurrence.longitude.toFixed(6) }}
              </span>
            </div>

            <div v-if="occurrence.profiles" class="occurrence-reporter">
              <svg class="reporter-icon" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
              </svg>
              <span>{{ occurrence.profiles.full_name || 'Agente' }}</span>
              <span class="reporter-type">({{ occurrence.reporter_type === 'agent' ? 'Agente' : 'Cidadão' }})</span>
            </div>
            <div v-else class="occurrence-reporter">
              <svg class="reporter-icon" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
              </svg>
              <span>Relato Anônimo</span>
              <span class="reporter-type">(Cidadão)</span>
            </div>
          </div>

          <!-- Video Thumbnail -->
          <div class="video-thumbnail">
            <div class="video-placeholder">
              <svg class="play-icon" viewBox="0 0 24 24" fill="currentColor">
                <path d="M8 5v14l11-7z"/>
              </svg>
            </div>
            <span class="video-duration">
              {{ occurrence.video_duration ? `${occurrence.video_duration}s` : '~7s' }}
            </span>
          </div>
        </div>

        <!-- Card Actions -->
        <div class="occurrence-actions">
          <button 
            class="action-btn action-btn--primary"
            @click.stop="goToOccurrence(occurrence.id)"
          >
            Ver Detalhes
          </button>
          
          <div class="quick-actions">
            <button 
              v-if="occurrence.status === 'pending'"
              class="action-btn action-btn--success"
              @click.stop="updateStatus(occurrence.id, OccurrenceStatus.IN_PROGRESS)"
            >
              Aceitar
            </button>
            
            <button 
              v-if="occurrence.status === 'in_progress'"
              class="action-btn action-btn--success"
              @click.stop="updateStatus(occurrence.id, OccurrenceStatus.RESOLVED)"
            >
              Resolver
            </button>
            
            <button 
              class="action-btn action-btn--secondary"
              @click.stop="togglePriority(occurrence)"
            >
              Prioridade {{ occurrence.priority }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="occurrences.length > 0" class="pagination">
      <button 
        :disabled="currentPage === 1"
        @click="previousPage"
        class="btn btn-secondary"
      >
        Anterior
      </button>
      
      <span class="pagination-info">
        Página {{ currentPage }} de {{ totalPages }}
      </span>
      
      <button 
        :disabled="currentPage === totalPages"
        @click="nextPage"
        class="btn btn-secondary"
      >
        Próxima
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import { ApiService } from '@/services/api'
import type { Occurrence, Tag } from '@/types'
import { OccurrenceStatus } from '@/types'

const router = useRouter()

const occurrences = ref<Occurrence[]>([])
const tags = ref<Tag[]>([])
const isLoading = ref(false)
const isExporting = ref(false)

const currentPage = ref(1)
const perPage = 20
const totalCount = ref(0)
const filteredCount = ref(0)

const filters = reactive({
  status: '' as OccurrenceStatus | '',
  tag_id: '' as number | '',
  priority: '' as number | ''
})

const totalPages = computed(() => Math.ceil(filteredCount.value / perPage))

const hasActiveFilters = computed(() => {
  return filters.status || filters.tag_id || filters.priority
})

const loadOccurrences = async () => {
  isLoading.value = true
  try {
    const apiFilters: any = {
      limit: perPage,
      offset: (currentPage.value - 1) * perPage
    }

    if (filters.status) apiFilters.status = filters.status
    if (filters.tag_id) apiFilters.tag_id = Number(filters.tag_id)

    const data = await ApiService.getOccurrences(apiFilters)
    
    // Client-side priority filtering (could be moved to API)
    let filteredData = data
    if (filters.priority) {
      filteredData = data.filter(o => o.priority === Number(filters.priority))
    }

    occurrences.value = filteredData
    filteredCount.value = filteredData.length
    
    // In a real app, this would come from the API
    if (!hasActiveFilters.value) {
      totalCount.value = filteredData.length
    }
  } catch (error) {
    console.error('Error loading occurrences:', error)
  } finally {
    isLoading.value = false
  }
}

const loadTags = async () => {
  try {
    tags.value = await ApiService.getTags()
  } catch (error) {
    console.error('Error loading tags:', error)
  }
}

const goToOccurrence = (id: string) => {
  router.push(`/occurrences/${id}`)
}

const updateStatus = async (id: string, newStatus: OccurrenceStatus) => {
  try {
    await ApiService.updateOccurrenceStatus(id, newStatus)
    await loadOccurrences()
  } catch (error) {
    console.error('Error updating status:', error)
  }
}

const togglePriority = async (occurrence: Occurrence) => {
  const newPriority = occurrence.priority === 5 ? 1 : occurrence.priority + 1
  try {
    await ApiService.updateOccurrencePriority(occurrence.id, newPriority)
    await loadOccurrences()
  } catch (error) {
    console.error('Error updating priority:', error)
  }
}

const clearFilters = () => {
  filters.status = ''
  filters.tag_id = ''
  filters.priority = ''
  currentPage.value = 1
}

const exportToCSV = async () => {
  isExporting.value = true
  try {
    // Get all occurrences for export (remove pagination)
    const allOccurrences = await ApiService.getOccurrences({})
    
    const csvContent = generateCSV(allOccurrences)
    downloadCSV(csvContent, `ocorrencias_${format(new Date(), 'yyyy-MM-dd_HH-mm')}.csv`)
  } catch (error) {
    console.error('Error exporting CSV:', error)
  } finally {
    isExporting.value = false
  }
}

const generateCSV = (data: Occurrence[]): string => {
  const headers = [
    'ID',
    'Título',
    'Descrição',
    'Status',
    'Prioridade',
    'Categoria',
    'Latitude',
    'Longitude',
    'Endereço',
    'Tipo Relator',
    'Relator',
    'Data Criação',
    'Data Resolução'
  ]

  const rows = data.map(occurrence => [
    occurrence.id,
    occurrence.title || '',
    occurrence.description || '',
    getStatusLabel(occurrence.status),
    occurrence.priority.toString(),
    occurrence.tags?.name || '',
    occurrence.latitude.toString(),
    occurrence.longitude.toString(),
    occurrence.address || '',
    occurrence.reporter_type === 'agent' ? 'Agente' : 'Cidadão',
    occurrence.profiles?.full_name || 'Anônimo',
    format(new Date(occurrence.created_at), 'dd/MM/yyyy HH:mm'),
    occurrence.resolved_at ? format(new Date(occurrence.resolved_at), 'dd/MM/yyyy HH:mm') : ''
  ])

  return [headers, ...rows]
    .map(row => row.map(cell => `"${cell}"`).join(','))
    .join('\n')
}

const downloadCSV = (content: string, filename: string) => {
  const blob = new Blob([content], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)
  
  link.setAttribute('href', url)
  link.setAttribute('download', filename)
  link.style.visibility = 'hidden'
  
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

const previousPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
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

// Watch for filter changes
watch([filters, currentPage], () => {
  loadOccurrences()
}, { deep: true })

onMounted(() => {
  loadTags()
  loadOccurrences()
})
</script>

<style scoped>
.occurrences-view {
  max-width: 1200px;
  margin: 0 auto;
}

/* Filters */
.filters-section {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.filters-row {
  display: flex;
  gap: 1rem;
  align-items: end;
  flex-wrap: wrap;
}

.filter-group {
  display: flex;
  flex-direction: column;
  min-width: 120px;
}

.filter-label {
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #374151;
  font-size: 0.875rem;
}

.filter-actions {
  display: flex;
  gap: 0.5rem;
  margin-left: auto;
}

.filter-actions .btn svg {
  width: 16px;
  height: 16px;
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Results */
.results-summary {
  margin-bottom: 1rem;
  color: #6b7280;
}

/* Loading and Empty States */
.loading-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
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

.empty-icon {
  width: 64px;
  height: 64px;
  color: #d1d5db;
  margin-bottom: 1rem;
}

.empty-state h3 {
  margin: 0 0 0.5rem 0;
  color: #374151;
}

/* Occurrences List */
.occurrences-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.occurrence-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  border: 1px solid #f3f4f6;
  cursor: pointer;
  transition: all 0.2s;
}

.occurrence-card:hover {
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  border-color: #e5e7eb;
}

.occurrence-header {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 1rem;
}

.occurrence-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 0.5rem 0;
}

.occurrence-meta {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.occurrence-tag {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 500;
}

.occurrence-date {
  color: #6b7280;
  font-size: 0.875rem;
}

.occurrence-status {
  display: flex;
  flex-direction: column;
  align-items: end;
  gap: 0.5rem;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.status-badge--pending {
  background-color: #fef3c7;
  color: #d97706;
}

.status-badge--in-progress {
  background-color: #dbeafe;
  color: #2563eb;
}

.status-badge--resolved {
  background-color: #dcfce7;
  color: #16a34a;
}

.status-badge--rejected {
  background-color: #fee2e2;
  color: #dc2626;
}

.priority-indicator {
  display: flex;
  gap: 2px;
}

.priority-star {
  width: 12px;
  height: 12px;
  color: #d1d5db;
}

.priority-star--active {
  color: #f59e0b;
}

/* Occurrence Content */
.occurrence-content {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.occurrence-details {
  flex: 1;
}

.occurrence-description {
  color: #374151;
  margin: 0 0 0.75rem 0;
  line-height: 1.5;
}

.occurrence-location,
.occurrence-reporter {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #6b7280;
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
}

.location-icon,
.reporter-icon {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
}

.coordinates {
  font-family: monospace;
  font-size: 0.8rem;
}

.reporter-type {
  color: #9ca3af;
}

/* Video Thumbnail */
.video-thumbnail {
  position: relative;
  width: 120px;
  height: 80px;
  flex-shrink: 0;
}

.video-placeholder {
  width: 100%;
  height: 100%;
  background: #1f2937;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.play-icon {
  width: 24px;
  height: 24px;
  color: white;
}

.video-duration {
  position: absolute;
  bottom: 4px;
  right: 4px;
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 0.75rem;
}

/* Actions */
.occurrence-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #f3f4f6;
}

.quick-actions {
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  padding: 0.5rem 1rem;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 500;
  border: 1px solid;
  cursor: pointer;
  transition: all 0.2s;
}

.action-btn--primary {
  background: #2563eb;
  border-color: #2563eb;
  color: white;
}

.action-btn--primary:hover {
  background: #1d4ed8;
}

.action-btn--success {
  background: #16a34a;
  border-color: #16a34a;
  color: white;
}

.action-btn--success:hover {
  background: #15803d;
}

.action-btn--secondary {
  background: white;
  border-color: #d1d5db;
  color: #374151;
}

.action-btn--secondary:hover {
  background: #f9fafb;
}

/* Pagination */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  margin-top: 2rem;
  padding: 1rem;
}

.pagination-info {
  color: #6b7280;
  font-size: 0.875rem;
}

@media (max-width: 768px) {
  .filters-row {
    flex-direction: column;
    align-items: stretch;
  }
  
  .filter-actions {
    margin-left: 0;
    justify-content: stretch;
  }
  
  .occurrence-content {
    flex-direction: column;
  }
  
  .video-thumbnail {
    width: 100%;
    height: 120px;
  }
  
  .occurrence-actions {
    flex-direction: column;
    align-items: stretch;
  }
  
  .quick-actions {
    justify-content: center;
  }
}
</style>