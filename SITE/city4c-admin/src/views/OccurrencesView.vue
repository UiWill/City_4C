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

    <!-- Occurrences Table -->
    <div v-else class="occurrences-table-container">
      <table class="occurrences-table">
        <thead>
          <tr>
            <th>Status</th>
            <th>Título</th>
            <th>Categoria</th>
            <th>Prioridade</th>
            <th>Localização</th>
            <th>Data</th>
            <th>Ações</th>
          </tr>
        </thead>
        <tbody>
          <tr 
            v-for="occurrence in occurrences" 
            :key="occurrence.id"
            class="occurrence-row"
            @click="goToOccurrence(occurrence.id)"
          >
            <td>
              <span 
                class="status-badge"
                :class="`status-badge--${occurrence.status.replace('_', '-')}`"
              >
                {{ getStatusLabel(occurrence.status) }}
              </span>
            </td>
            <td class="occurrence-title-cell">
              <div class="title-content">
                <h4>{{ occurrence.title || 'Ocorrência sem título' }}</h4>
                <p v-if="occurrence.description" class="description-preview">
                  {{ occurrence.description.substring(0, 80) }}{{ occurrence.description.length > 80 ? '...' : '' }}
                </p>
              </div>
            </td>
            <td>
              <span 
                v-if="occurrence.tags" 
                class="category-tag"
                :style="{ 
                  backgroundColor: occurrence.tags.color + '20', 
                  color: occurrence.tags.color 
                }"
              >
                {{ occurrence.tags.name }}
              </span>
            </td>
            <td>
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
            </td>
            <td class="location-cell">
              <div class="location-info">
                <svg class="location-icon" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                </svg>
                <span v-if="occurrence.address">
                  {{ occurrence.address.length > 40 ? occurrence.address.substring(0, 40) + '...' : occurrence.address }}
                </span>
                <span v-else>
                  {{ occurrence.latitude.toFixed(4) }}, {{ occurrence.longitude.toFixed(4) }}
                </span>
              </div>
            </td>
            <td>{{ formatDate(occurrence.created_at) }}</td>
            <td class="actions-cell">
              <div class="quick-actions" @click.stop>
                <button 
                  v-if="occurrence.status === 'pending'"
                  class="action-btn action-btn--success"
                  @click="updateStatus(occurrence.id, OccurrenceStatus.IN_PROGRESS)"
                  title="Aceitar"
                >
                  <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z"/>
                  </svg>
                </button>
                
                <button 
                  v-if="occurrence.status === 'in_progress'"
                  class="action-btn action-btn--success"
                  @click="updateStatus(occurrence.id, OccurrenceStatus.RESOLVED)"
                  title="Resolver"
                >
                  <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z"/>
                  </svg>
                </button>
                
                <button 
                  class="action-btn action-btn--primary"
                  @click="goToOccurrence(occurrence.id)"
                  title="Ver detalhes"
                >
                  <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/>
                  </svg>
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
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

const getStatusLabel = (status: OccurrenceStatus): string => {
  const labels: Record<OccurrenceStatus, string> = {
    [OccurrenceStatus.PENDING]: 'Pendente',
    [OccurrenceStatus.IN_PROGRESS]: 'Em Andamento',
    [OccurrenceStatus.RESOLVED]: 'Resolvido',
    [OccurrenceStatus.REJECTED]: 'Rejeitado'
  }
  return labels[status] || status
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

// Watch for filter changes
watch(filters, () => {
  currentPage.value = 1
  loadOccurrences()
}, { deep: true })

watch(currentPage, () => {
  loadOccurrences()
})

onMounted(async () => {
  await Promise.all([loadTags(), loadOccurrences()])
})
</script>

<style scoped>
.occurrences-view {
  width: 100%;
  height: 100%;
}

/* Filters Section */
.filters-section {
  background: white;
  padding: 2rem;
  border-radius: 16px;
  margin-bottom: 2rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  border: 1px solid #e5e7eb;
}

.filters-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 2rem;
  align-items: end;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.filter-label {
  font-weight: 600;
  color: #374151;
  font-size: 0.875rem;
}

.form-select {
  padding: 0.75rem 1rem;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  background: white;
  font-size: 0.875rem;
  transition: all 0.2s;
}

.form-select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.filter-actions {
  display: flex;
  gap: 1rem;
}

.btn {
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
  font-size: 0.875rem;
}

.btn-primary {
  background: #3b82f6;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #2563eb;
}

.btn-secondary {
  background: #f3f4f6;
  color: #374151;
  border: 2px solid #e5e7eb;
}

.btn-secondary:hover:not(:disabled) {
  background: #e5e7eb;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn svg {
  width: 16px;
  height: 16px;
}

/* Results Summary */
.results-summary {
  margin-bottom: 1.5rem;
  color: #6b7280;
}

/* States */
.loading-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem 2rem;
  text-align: center;
  color: #6b7280;
  background: white;
  border-radius: 16px;
  border: 1px solid #e5e7eb;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #f3f4f6;
  border-top: 3px solid #3b82f6;
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

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Table */
.occurrences-table-container {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  border: 1px solid #e5e7eb;
}

.occurrences-table {
  width: 100%;
  border-collapse: collapse;
}

.occurrences-table th {
  background: #f9fafb;
  padding: 1rem 1.5rem;
  text-align: left;
  font-weight: 600;
  color: #374151;
  font-size: 0.875rem;
  border-bottom: 2px solid #e5e7eb;
}

.occurrence-row {
  cursor: pointer;
  transition: all 0.2s;
  border-bottom: 1px solid #f3f4f6;
}

.occurrence-row:hover {
  background: #f9fafb;
}

.occurrences-table td {
  padding: 1rem 1.5rem;
  vertical-align: top;
}

/* Status Badge */
.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.status-badge--pending {
  background: #fef3c7;
  color: #d97706;
}

.status-badge--in-progress {
  background: #dbeafe;
  color: #2563eb;
}

.status-badge--resolved {
  background: #dcfce7;
  color: #16a34a;
}

.status-badge--rejected {
  background: #fee2e2;
  color: #dc2626;
}

/* Title Cell */
.occurrence-title-cell {
  min-width: 300px;
}

.title-content h4 {
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 0.25rem 0;
  font-size: 0.875rem;
}

.description-preview {
  color: #6b7280;
  font-size: 0.75rem;
  margin: 0;
  line-height: 1.4;
}

/* Category Tag */
.category-tag {
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 500;
}

/* Priority */
.priority-indicator {
  display: flex;
  gap: 2px;
}

.priority-star {
  width: 14px;
  height: 14px;
  color: #e5e7eb;
}

.priority-star--active {
  color: #f59e0b;
}

/* Location */
.location-cell {
  min-width: 200px;
}

.location-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.location-icon {
  width: 14px;
  height: 14px;
  color: #6b7280;
  flex-shrink: 0;
}

/* Actions */
.actions-cell {
  width: 120px;
}

.quick-actions {
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  padding: 0.5rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.action-btn svg {
  width: 14px;
  height: 14px;
}

.action-btn--success {
  background: #16a34a;
  color: white;
}

.action-btn--success:hover {
  background: #15803d;
}

.action-btn--primary {
  background: #3b82f6;
  color: white;
}

.action-btn--primary:hover {
  background: #2563eb;
}

/* Pagination */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  margin-top: 2rem;
  padding: 2rem;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  border: 1px solid #e5e7eb;
}

.pagination-info {
  color: #6b7280;
  font-weight: 500;
}

/* Animations */
.animate-spin {
  animation: spin 1s linear infinite;
}
</style>