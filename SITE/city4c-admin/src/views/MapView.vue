<template>
  <div class="map-view">
    <!-- Map Controls -->
    <div class="map-controls">
      <div class="controls-left">
        <div class="filter-group">
          <label for="map-status-filter" class="filter-label">Status</label>
          <select id="map-status-filter" v-model="filters.status" class="form-select">
            <option value="">Todos</option>
            <option value="pending">Pendente</option>
            <option value="in_progress">Em Andamento</option>
            <option value="resolved">Resolvido</option>
            <option value="rejected">Rejeitado</option>
          </select>
        </div>

        <div class="filter-group">
          <label for="map-tag-filter" class="filter-label">Categoria</label>
          <select id="map-tag-filter" v-model="filters.tag_id" class="form-select">
            <option value="">Todas</option>
            <option v-for="tag in tags" :key="tag.id" :value="tag.id">
              {{ tag.name }}
            </option>
          </select>
        </div>

        <button @click="clearFilters" class="btn btn-secondary">
          Limpar Filtros
        </button>
      </div>

      <div class="controls-right">
        <div class="occurrence-count">
          {{ filteredOccurrences.length }} ocorrência{{ filteredOccurrences.length !== 1 ? 's' : '' }} no mapa
        </div>
      </div>
    </div>

    <!-- Map Container -->
    <div class="map-container">
      <!-- Map Placeholder -->
      <div class="map-placeholder">
        <div class="map-content">
          <svg class="map-icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M20.5 3l-.16.03L15 5.1 9 3 3.36 4.9c-.21.07-.36.25-.36.48V20.5c0 .28.22.5.5.5l.16-.03L9 18.9l6 2.1 5.64-1.9c.21-.07.36-.25.36-.48V3.5c0-.28-.22-.5-.5-.5z"/>
          </svg>
          <h3>Mapa Interativo</h3>
          <p>Esta funcionalidade será implementada com Leaflet/OpenStreetMap na versão completa.</p>
          <p>As ocorrências aparecerão como marcadores coloridos baseados no status.</p>
        </div>

        <!-- Mock markers for visualization -->
        <div class="mock-markers">
          <div 
            v-for="(occurrence, index) in filteredOccurrences.slice(0, 10)" 
            :key="occurrence.id"
            class="mock-marker"
            :class="`marker--${occurrence.status.replace('_', '-')}`"
            :style="getMockMarkerPosition(index)"
            @click="selectOccurrence(occurrence)"
          >
            <div class="marker-icon">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
              </svg>
            </div>
            <div class="marker-tooltip">
              <div class="tooltip-content">
                <h4>{{ occurrence.title || 'Ocorrência sem título' }}</h4>
                <p v-if="occurrence.tags">{{ occurrence.tags.name }}</p>
                <p class="coordinates">
                  {{ occurrence.latitude.toFixed(4) }}, {{ occurrence.longitude.toFixed(4) }}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Legend -->
      <div class="map-legend">
        <h4>Legenda</h4>
        <div class="legend-items">
          <div class="legend-item">
            <div class="legend-marker marker--pending"></div>
            <span>Pendente</span>
          </div>
          <div class="legend-item">
            <div class="legend-marker marker--in-progress"></div>
            <span>Em Andamento</span>
          </div>
          <div class="legend-item">
            <div class="legend-marker marker--resolved"></div>
            <span>Resolvido</span>
          </div>
          <div class="legend-item">
            <div class="legend-marker marker--rejected"></div>
            <span>Rejeitado</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Selected Occurrence Panel -->
    <div v-if="selectedOccurrence" class="occurrence-panel">
      <div class="panel-header">
        <h3>{{ selectedOccurrence.title || 'Ocorrência sem título' }}</h3>
        <button @click="selectedOccurrence = null" class="close-button">
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
          </svg>
        </button>
      </div>

      <div class="panel-content">
        <div class="occurrence-info">
          <div class="info-item">
            <span class="label">Status:</span>
            <span 
              class="status-badge"
              :class="`status-badge--${selectedOccurrence.status.replace('_', '-')}`"
            >
              {{ getStatusLabel(selectedOccurrence.status) }}
            </span>
          </div>

          <div v-if="selectedOccurrence.tags" class="info-item">
            <span class="label">Categoria:</span>
            <span 
              class="tag-badge"
              :style="{ 
                backgroundColor: selectedOccurrence.tags.color + '20', 
                color: selectedOccurrence.tags.color 
              }"
            >
              {{ selectedOccurrence.tags.name }}
            </span>
          </div>

          <div class="info-item">
            <span class="label">Localização:</span>
            <span class="coordinates">
              {{ selectedOccurrence.latitude.toFixed(6) }}, {{ selectedOccurrence.longitude.toFixed(6) }}
            </span>
          </div>

          <div v-if="selectedOccurrence.address" class="info-item">
            <span class="label">Endereço:</span>
            <span>{{ selectedOccurrence.address }}</span>
          </div>

          <div class="info-item">
            <span class="label">Data:</span>
            <span>{{ formatDate(selectedOccurrence.created_at) }}</span>
          </div>

          <div v-if="selectedOccurrence.description" class="info-item description">
            <span class="label">Descrição:</span>
            <p>{{ selectedOccurrence.description }}</p>
          </div>
        </div>

        <div class="panel-actions">
          <button 
            @click="goToOccurrence(selectedOccurrence.id)"
            class="btn btn-primary"
          >
            Ver Detalhes
          </button>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="loading-overlay">
      <div class="spinner"></div>
      <p>Carregando ocorrências...</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import { ApiService } from '@/services/api'
import type { Occurrence, Tag, OccurrenceStatus } from '@/types'

const router = useRouter()

const occurrences = ref<Occurrence[]>([])
const tags = ref<Tag[]>([])
const selectedOccurrence = ref<Occurrence | null>(null)
const isLoading = ref(false)

const filters = reactive({
  status: '' as OccurrenceStatus | '',
  tag_id: '' as number | ''
})

const filteredOccurrences = computed(() => {
  let filtered = occurrences.value

  if (filters.status) {
    filtered = filtered.filter(o => o.status === filters.status)
  }

  if (filters.tag_id) {
    filtered = filtered.filter(o => o.tag_id === Number(filters.tag_id))
  }

  return filtered
})

const loadOccurrences = async () => {
  isLoading.value = true
  try {
    occurrences.value = await ApiService.getOccurrences({ limit: 100 })
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

const clearFilters = () => {
  filters.status = ''
  filters.tag_id = ''
}

const selectOccurrence = (occurrence: Occurrence) => {
  selectedOccurrence.value = occurrence
}

const goToOccurrence = (id: string) => {
  router.push(`/occurrences/${id}`)
}

const getMockMarkerPosition = (index: number) => {
  // Generate pseudo-random positions for demo
  const positions = [
    { top: '20%', left: '30%' },
    { top: '40%', left: '60%' },
    { top: '60%', left: '25%' },
    { top: '35%', left: '80%' },
    { top: '70%', left: '50%' },
    { top: '25%', left: '70%' },
    { top: '55%', left: '40%' },
    { top: '80%', left: '35%' },
    { top: '15%', left: '55%' },
    { top: '45%', left: '15%' }
  ]
  
  return positions[index % positions.length]
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

watch(filters, () => {
  selectedOccurrence.value = null
}, { deep: true })

onMounted(() => {
  loadTags()
  loadOccurrences()
})
</script>

<style scoped>
.map-view {
  height: calc(100vh - 140px);
  display: flex;
  flex-direction: column;
  position: relative;
}

/* Controls */
.map-controls {
  background: white;
  border-radius: 12px;
  padding: 1rem;
  margin-bottom: 1rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.controls-left {
  display: flex;
  gap: 1rem;
  align-items: end;
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

.occurrence-count {
  color: #6b7280;
  font-weight: 500;
}

/* Map Container */
.map-container {
  flex: 1;
  position: relative;
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.map-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 100%);
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.map-content {
  text-align: center;
  color: #6b7280;
  z-index: 1;
}

.map-icon {
  width: 64px;
  height: 64px;
  margin: 0 auto 1rem;
  display: block;
  color: #9ca3af;
}

.map-content h3 {
  font-size: 1.5rem;
  font-weight: 600;
  color: #374151;
  margin: 0 0 1rem 0;
}

.map-content p {
  max-width: 400px;
  line-height: 1.6;
  margin: 0 0 0.5rem 0;
}

/* Mock Markers */
.mock-markers {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.mock-marker {
  position: absolute;
  pointer-events: all;
  cursor: pointer;
  transform: translate(-50%, -100%);
  z-index: 10;
}

.marker-icon {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
  transition: transform 0.2s;
}

.mock-marker:hover .marker-icon {
  transform: scale(1.2);
}

.marker-icon svg {
  width: 16px;
  height: 16px;
  color: white;
}

.marker--pending .marker-icon {
  background: #f59e0b;
}

.marker--in-progress .marker-icon {
  background: #3b82f6;
}

.marker--resolved .marker-icon {
  background: #10b981;
}

.marker--rejected .marker-icon {
  background: #ef4444;
}

/* Marker Tooltips */
.marker-tooltip {
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  margin-bottom: 0.5rem;
  opacity: 0;
  visibility: hidden;
  transition: all 0.2s;
  pointer-events: none;
}

.mock-marker:hover .marker-tooltip {
  opacity: 1;
  visibility: visible;
}

.tooltip-content {
  background: white;
  border-radius: 6px;
  padding: 0.75rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  white-space: nowrap;
  border: 1px solid #e5e7eb;
}

.tooltip-content h4 {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 0.25rem 0;
}

.tooltip-content p {
  font-size: 0.75rem;
  color: #6b7280;
  margin: 0;
}

.coordinates {
  font-family: monospace;
  font-size: 0.7rem;
}

/* Legend */
.map-legend {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: white;
  border-radius: 8px;
  padding: 1rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  border: 1px solid #e5e7eb;
}

.map-legend h4 {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 0.75rem 0;
}

.legend-items {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.legend-marker {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  flex-shrink: 0;
}

.legend-item span {
  font-size: 0.75rem;
  color: #374151;
}

/* Occurrence Panel */
.occurrence-panel {
  position: absolute;
  bottom: 1rem;
  left: 1rem;
  width: 300px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  border: 1px solid #e5e7eb;
  z-index: 20;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.panel-header h3 {
  font-size: 1rem;
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
  width: 16px;
  height: 16px;
}

.panel-content {
  padding: 1rem;
}

.occurrence-info {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.info-item {
  display: flex;
  align-items: start;
  gap: 0.5rem;
}

.info-item.description {
  flex-direction: column;
  align-items: start;
}

.label {
  font-weight: 500;
  color: #6b7280;
  font-size: 0.875rem;
  min-width: 80px;
  flex-shrink: 0;
}

.status-badge {
  padding: 0.125rem 0.5rem;
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

.tag-badge {
  padding: 0.125rem 0.5rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 500;
}

.description p {
  margin: 0.25rem 0 0 0;
  color: #374151;
  font-size: 0.875rem;
  line-height: 1.4;
}

/* Loading Overlay */
.loading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(255, 255, 255, 0.8);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 50;
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

@media (max-width: 768px) {
  .map-controls {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }
  
  .controls-left {
    flex-direction: column;
    align-items: stretch;
  }
  
  .occurrence-panel {
    position: relative;
    bottom: auto;
    left: auto;
    width: 100%;
    margin-top: 1rem;
  }
  
  .map-legend {
    position: relative;
    top: auto;
    right: auto;
    margin: 1rem;
  }
}
</style>