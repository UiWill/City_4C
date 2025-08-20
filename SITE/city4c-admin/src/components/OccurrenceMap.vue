<template>
  <div class="occurrence-map" :class="{ 'small': size === 'small' }">
    <div ref="mapContainer" class="leaflet-map"></div>
    
    <!-- Address overlay for small maps -->
    <div v-if="size === 'small' && occurrence?.address" class="address-overlay">
      <div class="address-content">
        <svg class="location-icon" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
        </svg>
        <span>{{ occurrence.address }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, watch, nextTick } from 'vue'
import L from 'leaflet'
import type { Occurrence } from '@/types'

// Import Leaflet CSS
import 'leaflet/dist/leaflet.css'

// Fix for default markers
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

interface Props {
  occurrence?: Occurrence
  size?: 'small' | 'large'
  zoom?: number
  showPopup?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  size: 'large',
  zoom: 15,
  showPopup: false
})

const mapContainer = ref<HTMLElement | null>(null)
let map: L.Map | null = null
let marker: L.Marker | null = null

const initializeMap = async () => {
  if (!mapContainer.value || !props.occurrence) return
  
  try {
    const { latitude, longitude } = props.occurrence
    
    if (!latitude || !longitude) {
      console.warn('⚠️ Coordenadas não disponíveis para o mapa')
      return
    }

    // Initialize map
    map = L.map(mapContainer.value, {
      zoomControl: props.size === 'large',
      attributionControl: false,
      dragging: props.size === 'large',
      touchZoom: props.size === 'large',
      doubleClickZoom: props.size === 'large',
      scrollWheelZoom: props.size === 'large',
      boxZoom: props.size === 'large',
      keyboard: props.size === 'large'
    }).setView([latitude, longitude], props.zoom)

    // Add tile layer
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '',
      maxZoom: 18
    }).addTo(map)

    // Create custom marker
    const statusColor = getStatusColor(props.occurrence.status)
    const customIcon = L.divIcon({
      className: 'custom-occurrence-marker',
      html: `
        <div class="occurrence-marker-pin" style="background-color: ${statusColor};">
          <div class="marker-pulse"></div>
        </div>
      `,
      iconSize: [24, 24],
      iconAnchor: [12, 12]
    })

    // Add marker
    marker = L.marker([latitude, longitude], {
      icon: customIcon
    }).addTo(map)

    // Add popup if requested
    if (props.showPopup) {
      const popupContent = createPopupContent(props.occurrence)
      marker.bindPopup(popupContent, {
        maxWidth: 300,
        className: 'custom-popup'
      }).openPopup()
    }

    console.log('✅ Mapa de ocorrência inicializado')
  } catch (error) {
    console.error('❌ Erro ao inicializar mapa de ocorrência:', error)
  }
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

const getStatusLabel = (status: string) => {
  const labels: Record<string, string> = {
    pending: 'Pendente',
    in_progress: 'Em Andamento',
    resolved: 'Resolvido',
    rejected: 'Rejeitado'
  }
  return labels[status] || status
}

const createPopupContent = (occurrence: Occurrence) => {
  return `
    <div class="occurrence-popup">
      <h4>${occurrence.title || 'Ocorrência sem título'}</h4>
      ${occurrence.tags ? `<p class="popup-tag"><strong>Categoria:</strong> ${occurrence.tags.name}</p>` : ''}
      <p class="popup-status"><strong>Status:</strong> ${getStatusLabel(occurrence.status)}</p>
      ${occurrence.address ? `<p class="popup-address"><strong>Endereço:</strong> ${occurrence.address}</p>` : ''}
      <p class="popup-coords">
        <strong>Coordenadas:</strong> ${occurrence.latitude.toFixed(6)}, ${occurrence.longitude.toFixed(6)}
      </p>
    </div>
  `
}

watch(() => props.occurrence, async () => {
  if (map) {
    map.remove()
    map = null
    marker = null
  }
  await nextTick()
  await initializeMap()
})

onMounted(async () => {
  await nextTick()
  await initializeMap()
})

onBeforeUnmount(() => {
  if (map) {
    map.remove()
    map = null
  }
  marker = null
})
</script>

<style scoped>
.occurrence-map {
  width: 100%;
  height: 350px;
  position: relative;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.occurrence-map.small {
  height: 200px;
}

.leaflet-map {
  width: 100%;
  height: 100%;
}

.address-overlay {
  position: absolute;
  bottom: 12px;
  left: 12px;
  right: 12px;
  z-index: 1000;
  pointer-events: none;
}

.address-content {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(8px);
  padding: 8px 12px;
  border-radius: 8px;
  border: 1px solid rgba(0, 0, 0, 0.1);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.875rem;
  color: #374151;
  font-weight: 500;
}

.location-icon {
  width: 16px;
  height: 16px;
  color: #6b7280;
  flex-shrink: 0;
}

/* Custom Marker Styles */
:global(.custom-occurrence-marker) {
  background: transparent !important;
  border: none !important;
  margin: 0 !important;
}

:global(.occurrence-marker-pin) {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  position: relative;
  border: 2px solid white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
  cursor: pointer;
  transition: transform 0.2s;
}

:global(.occurrence-marker-pin:hover) {
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

/* Popup Styles */
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

:global(.popup-coords) {
  font-family: monospace;
  font-size: 0.75rem !important;
}
</style>