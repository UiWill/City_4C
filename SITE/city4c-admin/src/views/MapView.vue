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
      <div ref="mapContainer" class="leaflet-map"></div>
      
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
import { ref, reactive, computed, onMounted, onBeforeUnmount, watch, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import { ApiService } from '@/services/api'
import type { Occurrence, Tag, OccurrenceStatus } from '@/types'
import L from 'leaflet'

// Import Leaflet CSS
import 'leaflet/dist/leaflet.css'

// Fix for default markers
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

const router = useRouter()

const occurrences = ref<Occurrence[]>([])
const tags = ref<Tag[]>([])
const selectedOccurrence = ref<Occurrence | null>(null)
const isLoading = ref(false)
const mapContainer = ref<HTMLElement | null>(null)
let map: L.Map | null = null
let markersLayer: L.LayerGroup | null = null

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

const initializeMap = async () => {
  if (!mapContainer.value) return
  
  try {
    // Initialize map centered on Brazil
    map = L.map(mapContainer.value, {
      zoomControl: true,
      attributionControl: false
    }).setView([-15.7942, -47.8822], 4) // Brasília, Brazil
    
    // Add tile layer (OpenStreetMap)
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '',
      maxZoom: 18
    }).addTo(map)
    
    // Initialize markers layer
    markersLayer = L.layerGroup().addTo(map)
    
    // Add markers for occurrences
    updateMapMarkers()
    
    console.log('✅ Mapa inicializado com sucesso')
  } catch (error) {
    console.error('❌ Erro ao inicializar mapa:', error)
  }
}

const updateMapMarkers = () => {
  if (!map || !markersLayer) return
  
  // Clear existing markers
  markersLayer.clearLayers()
  
  // Add marker for each occurrence
  filteredOccurrences.value.forEach(occurrence => {
    const marker = createMarkerForOccurrence(occurrence)
    if (marker) {
      markersLayer!.addLayer(marker)
    }
  })
  
  // Fit map to show all markers if we have occurrences
  if (filteredOccurrences.value.length > 0) {
    const group = new L.FeatureGroup(markersLayer.getLayers() as L.Layer[])
    if (group.getLayers().length > 0) {
      map.fitBounds(group.getBounds(), { padding: [20, 20] })
    }
  }
}

const createMarkerForOccurrence = (occurrence: Occurrence) => {
  if (!occurrence.latitude || !occurrence.longitude) return null
  
  // Create custom icon based on status
  const iconColor = getStatusColor(occurrence.status)
  const customIcon = L.divIcon({
    className: 'custom-marker',
    html: `
      <div class="marker-pin" style="background-color: ${iconColor};">
        <div class="marker-pulse"></div>
      </div>
    `,
    iconSize: [30, 30],
    iconAnchor: [15, 15]
  })
  
  const marker = L.marker([occurrence.latitude, occurrence.longitude], {
    icon: customIcon
  })
  
  // Create popup content
  const popupContent = `
    <div class="occurrence-popup">
      <h4>${occurrence.title || 'Ocorrência sem título'}</h4>
      ${occurrence.tags ? `<p class="popup-tag"><strong>Categoria:</strong> ${occurrence.tags.name}</p>` : ''}
      <p class="popup-status"><strong>Status:</strong> ${getStatusLabel(occurrence.status)}</p>
      ${occurrence.address ? `<p class="popup-address"><strong>Endereço:</strong> ${occurrence.address}</p>` : ''}
      <p class="popup-coords">
        <strong>Coordenadas:</strong> ${occurrence.latitude.toFixed(6)}, ${occurrence.longitude.toFixed(6)}
      </p>
      <p class="popup-date">
        <strong>Data:</strong> ${formatDate(occurrence.created_at)}
      </p>
      <div class="popup-actions">
        <button 
          onclick="window.location.href='#/occurrences/${occurrence.id}'"
          class="popup-btn"
        >
          Ver Detalhes
        </button>
      </div>
    </div>
  `
  
  marker.bindPopup(popupContent, {
    maxWidth: 300,
    className: 'custom-popup'
  })
  
  return marker
}

const getStatusColor = (status: string) => {
  const colors: Record<string, string> = {
    pending: '#f59e0b',
    in_progress: '#3b82f6',
    resolved: '#10b981',
    rejected: '#ef4444'
  }
  return colors[status] || '#6b7280'
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
  updateMapMarkers()
}, { deep: true })

watch(occurrences, () => {
  updateMapMarkers()
})

onMounted(async () => {
  await loadTags()
  await loadOccurrences()
  
  await nextTick()
  await initializeMap()
})

onBeforeUnmount(() => {
  if (map) {
    map.remove()
    map = null
  }
  markersLayer = null
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

.leaflet-map {
  width: 100%;
  height: 100%;
  border-radius: 12px;
  overflow: hidden;
}

/* Custom Marker Styles */
:global(.custom-marker) {
  background: transparent !important;
  border: none !important;
  margin: 0 !important;
}

:global(.marker-pin) {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  position: relative;
  border: 2px solid white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
  cursor: pointer;
  transition: transform 0.2s;
}

:global(.marker-pin:hover) {
  transform: scale(1.2);
}

:global(.marker-pulse) {
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  border-radius: 50%;
  border: 2px solid currentColor;
  opacity: 0;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% {
    opacity: 1;
    transform: scale(1);
  }
  100% {
    opacity: 0;
    transform: scale(2);
  }
}

/* Custom Popup Styles */
:global(.custom-popup .leaflet-popup-content-wrapper) {
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

:global(.occurrence-popup) {
  padding: 0.5rem 0;
}

:global(.occurrence-popup h4) {
  font-size: 1rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 0.5rem 0;
}

:global(.occurrence-popup p) {
  font-size: 0.875rem;
  color: #6b7280;
  margin: 0.25rem 0;
  line-height: 1.4;
}

:global(.popup-tag) {
  color: #374151 !important;
}

:global(.popup-status) {
  color: #374151 !important;
  font-weight: 500;
}

:global(.popup-coords) {
  font-family: monospace;
  font-size: 0.75rem !important;
  color: #6b7280 !important;
}

:global(.popup-actions) {
  margin-top: 0.75rem;
  text-align: center;
}

:global(.popup-btn) {
  background: #2563eb;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.875rem;
  font-weight: 500;
  transition: background-color 0.2s;
}

:global(.popup-btn:hover) {
  background: #1d4ed8;
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