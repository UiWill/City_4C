<template>
  <div class="tags-view">
    <!-- Header -->
    <div class="tags-header">
      <div class="header-content">
        <h1>Gerenciar Categorias</h1>
        <p>Configure as categorias disponíveis para classificação das ocorrências.</p>
      </div>
      <button @click="showCreateModal = true" class="btn btn-primary">
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
        </svg>
        Nova Categoria
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="loading-state">
      <div class="spinner"></div>
      <p>Carregando categorias...</p>
    </div>

    <!-- Tags List -->
    <div v-else class="tags-grid">
      <div 
        v-for="tag in tags" 
        :key="tag.id"
        class="tag-card"
      >
        <div class="tag-header">
          <div class="tag-color" :style="{ backgroundColor: tag.color }"></div>
          <div class="tag-info">
            <h3>{{ tag.name }}</h3>
            <p v-if="tag.description">{{ tag.description }}</p>
          </div>
        </div>

        <div class="tag-stats">
          <div class="stat-item">
            <span class="stat-label">Ocorrências:</span>
            <span class="stat-value">{{ getTagUsageCount(tag.id) }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">Status:</span>
            <span 
              class="status-badge"
              :class="tag.is_active ? 'status-active' : 'status-inactive'"
            >
              {{ tag.is_active ? 'Ativa' : 'Inativa' }}
            </span>
          </div>
        </div>

        <div class="tag-actions">
          <button 
            @click="editTag(tag)" 
            class="action-btn action-btn--edit"
            title="Editar categoria"
          >
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
            </svg>
          </button>
          
          <button 
            @click="toggleTagStatus(tag)" 
            class="action-btn"
            :class="tag.is_active ? 'action-btn--deactivate' : 'action-btn--activate'"
            :title="tag.is_active ? 'Desativar categoria' : 'Ativar categoria'"
          >
            <svg v-if="tag.is_active" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
            </svg>
            <svg v-else viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm5 11H7v-2h10v2z"/>
            </svg>
          </button>
          
          <button 
            @click="deleteTag(tag)" 
            class="action-btn action-btn--delete"
            title="Excluir categoria"
            :disabled="getTagUsageCount(tag.id) > 0"
          >
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/>
            </svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-if="!isLoading && tags.length === 0" class="empty-state">
      <svg class="empty-icon" viewBox="0 0 24 24" fill="currentColor">
        <path d="M17.63 5.84C17.27 5.33 16.67 5 16 5L5 5.01C3.9 5.01 3 5.9 3 7v10c0 1.1.9 2 2 2h11c.67 0 1.27-.33 1.63-.84L22 12l-4.37-6.16z"/>
      </svg>
      <h3>Nenhuma categoria criada</h3>
      <p>Crie sua primeira categoria para começar a organizar as ocorrências.</p>
      <button @click="showCreateModal = true" class="btn btn-primary">
        Criar Primeira Categoria
      </button>
    </div>

    <!-- Create/Edit Modal -->
    <div v-if="showCreateModal || editingTag" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>{{ editingTag ? 'Editar Categoria' : 'Nova Categoria' }}</h2>
          <button @click="closeModal" class="close-button">
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
            </svg>
          </button>
        </div>

        <form @submit.prevent="saveTag" class="modal-form">
          <div class="form-group">
            <label for="tag-name" class="form-label">Nome *</label>
            <input
              id="tag-name"
              v-model="tagForm.name"
              type="text"
              class="form-input"
              placeholder="Ex: Lixo, Iluminação, Pavimentação..."
              required
              maxlength="50"
            />
          </div>

          <div class="form-group">
            <label for="tag-description" class="form-label">Descrição</label>
            <textarea
              id="tag-description"
              v-model="tagForm.description"
              class="form-textarea"
              placeholder="Descrição detalhada da categoria..."
              rows="3"
              maxlength="200"
            ></textarea>
          </div>

          <div class="form-group">
            <label for="tag-color" class="form-label">Cor *</label>
            <div class="color-input-group">
              <input
                id="tag-color"
                v-model="tagForm.color"
                type="color"
                class="color-input"
                required
              />
              <input
                v-model="tagForm.color"
                type="text"
                class="form-input color-text"
                placeholder="#3B82F6"
                pattern="^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
              />
            </div>
            <small class="form-help">Escolha uma cor que represente bem esta categoria</small>
          </div>

          <div class="color-presets">
            <span class="presets-label">Cores sugeridas:</span>
            <div class="preset-colors">
              <button
                v-for="color in colorPresets"
                :key="color"
                type="button"
                class="preset-color"
                :style="{ backgroundColor: color }"
                @click="tagForm.color = color"
                :class="{ active: tagForm.color === color }"
              ></button>
            </div>
          </div>

          <div class="modal-actions">
            <button type="button" @click="closeModal" class="btn btn-secondary">
              Cancelar
            </button>
            <button 
              type="submit" 
              class="btn btn-primary"
              :disabled="isSaving || !tagForm.name || !tagForm.color"
            >
              {{ isSaving ? 'Salvando...' : (editingTag ? 'Salvar Alterações' : 'Criar Categoria') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="deletingTag" class="modal-overlay" @click="deletingTag = null">
      <div class="modal-content modal-content--small" @click.stop>
        <div class="modal-header">
          <h2>Confirmar Exclusão</h2>
        </div>
        
        <div class="modal-body">
          <p>
            Tem certeza que deseja excluir a categoria 
            <strong>"{{ deletingTag.name }}"</strong>?
          </p>
          <p class="warning-text">
            Esta ação não pode ser desfeita.
          </p>
        </div>

        <div class="modal-actions">
          <button @click="deletingTag = null" class="btn btn-secondary">
            Cancelar
          </button>
          <button 
            @click="confirmDelete" 
            class="btn btn-danger"
            :disabled="isSaving"
          >
            {{ isSaving ? 'Excluindo...' : 'Excluir' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ApiService } from '@/services/api'
import type { Tag } from '@/types'

const tags = ref<Tag[]>([])
const isLoading = ref(false)
const isSaving = ref(false)

const showCreateModal = ref(false)
const editingTag = ref<Tag | null>(null)
const deletingTag = ref<Tag | null>(null)

const tagForm = reactive({
  name: '',
  description: '',
  color: '#3B82F6'
})

const colorPresets = [
  '#EF4444', // Red
  '#F59E0B', // Amber
  '#10B981', // Emerald
  '#3B82F6', // Blue
  '#8B5CF6', // Violet
  '#EC4899', // Pink
  '#6B7280', // Gray
  '#84CC16', // Lime
  '#06B6D4', // Cyan
  '#F97316'  // Orange
]

// Mock data for tag usage count (would come from API)
const tagUsageCount = ref<Record<number, number>>({})

const loadTags = async () => {
  isLoading.value = true
  try {
    tags.value = await ApiService.getTags()
    // Load usage counts (mock data)
    tags.value.forEach(tag => {
      tagUsageCount.value[tag.id] = Math.floor(Math.random() * 25)
    })
  } catch (error) {
    console.error('Error loading tags:', error)
  } finally {
    isLoading.value = false
  }
}

const editTag = (tag: Tag) => {
  editingTag.value = tag
  tagForm.name = tag.name
  tagForm.description = tag.description || ''
  tagForm.color = tag.color
}

const deleteTag = (tag: Tag) => {
  if (getTagUsageCount(tag.id) > 0) {
    alert('Não é possível excluir uma categoria que possui ocorrências associadas.')
    return
  }
  deletingTag.value = tag
}

const closeModal = () => {
  showCreateModal.value = false
  editingTag.value = null
  resetForm()
}

const resetForm = () => {
  tagForm.name = ''
  tagForm.description = ''
  tagForm.color = '#3B82F6'
}

const saveTag = async () => {
  isSaving.value = true
  try {
    const tagData = {
      name: tagForm.name.trim(),
      description: tagForm.description.trim() || undefined,
      color: tagForm.color,
      is_active: true
    }

    if (editingTag.value) {
      await ApiService.updateTag(editingTag.value.id, tagData)
    } else {
      await ApiService.createTag(tagData)
    }

    await loadTags()
    closeModal()
  } catch (error) {
    console.error('Error saving tag:', error)
    alert('Erro ao salvar categoria. Tente novamente.')
  } finally {
    isSaving.value = false
  }
}

const toggleTagStatus = async (tag: Tag) => {
  try {
    await ApiService.updateTag(tag.id, { is_active: !tag.is_active })
    await loadTags()
  } catch (error) {
    console.error('Error toggling tag status:', error)
    alert('Erro ao alterar status da categoria.')
  }
}

const confirmDelete = async () => {
  if (!deletingTag.value) return
  
  isSaving.value = true
  try {
    await ApiService.deleteTag(deletingTag.value.id)
    await loadTags()
    deletingTag.value = null
  } catch (error) {
    console.error('Error deleting tag:', error)
    alert('Erro ao excluir categoria.')
  } finally {
    isSaving.value = false
  }
}

const getTagUsageCount = (tagId: number): number => {
  return tagUsageCount.value[tagId] || 0
}

onMounted(() => {
  loadTags()
})
</script>

<style scoped>
.tags-view {
  max-width: 1200px;
  margin: 0 auto;
}

/* Header */
.tags-header {
  display: flex;
  justify-content: space-between;
  align-items: end;
  margin-bottom: 2rem;
  gap: 2rem;
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

.btn svg {
  width: 16px;
  height: 16px;
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

/* Tags Grid */
.tags-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1.5rem;
}

.tag-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  border: 1px solid #f3f4f6;
  transition: all 0.2s;
}

.tag-card:hover {
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  border-color: #e5e7eb;
}

.tag-header {
  display: flex;
  align-items: start;
  gap: 1rem;
  margin-bottom: 1rem;
}

.tag-color {
  width: 24px;
  height: 24px;
  border-radius: 6px;
  flex-shrink: 0;
  border: 2px solid rgba(255, 255, 255, 0.8);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.tag-info h3 {
  font-size: 1.125rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 0.25rem 0;
}

.tag-info p {
  color: #6b7280;
  font-size: 0.875rem;
  margin: 0;
  line-height: 1.4;
}

.tag-stats {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1rem;
  padding: 1rem;
  background: #f9fafb;
  border-radius: 8px;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stat-label {
  color: #6b7280;
  font-size: 0.875rem;
}

.stat-value {
  font-weight: 600;
  color: #1f2937;
}

.status-badge {
  padding: 0.125rem 0.5rem;
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

.tag-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: end;
}

.action-btn {
  padding: 0.5rem;
  border-radius: 6px;
  border: 1px solid;
  background: white;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.action-btn svg {
  width: 16px;
  height: 16px;
}

.action-btn--edit {
  border-color: #3b82f6;
  color: #3b82f6;
}

.action-btn--edit:hover {
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

.action-btn--delete {
  border-color: #ef4444;
  color: #ef4444;
}

.action-btn--delete:hover:not(:disabled) {
  background: #ef4444;
  color: white;
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
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
  max-width: 500px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 25px rgba(0, 0, 0, 0.2);
}

.modal-content--small {
  max-width: 400px;
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

.modal-form {
  padding: 1.5rem;
}

.modal-body {
  padding: 1.5rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.color-input-group {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.color-input {
  width: 60px;
  height: 40px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  cursor: pointer;
  background: none;
}

.color-text {
  flex: 1;
  font-family: monospace;
}

.form-help {
  color: #6b7280;
  font-size: 0.875rem;
  margin-top: 0.25rem;
  display: block;
}

.color-presets {
  margin: 1rem 0;
}

.presets-label {
  color: #6b7280;
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
  display: block;
}

.preset-colors {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.preset-color {
  width: 32px;
  height: 32px;
  border-radius: 6px;
  border: 2px solid transparent;
  cursor: pointer;
  transition: all 0.2s;
}

.preset-color:hover {
  transform: scale(1.1);
}

.preset-color.active {
  border-color: #1f2937;
  transform: scale(1.1);
}

.modal-actions {
  display: flex;
  gap: 0.75rem;
  justify-content: end;
  padding-top: 1rem;
  border-top: 1px solid #f3f4f6;
}

.warning-text {
  color: #dc2626;
  font-size: 0.875rem;
  margin: 0.5rem 0 0 0;
}

@media (max-width: 768px) {
  .tags-header {
    flex-direction: column;
    align-items: start;
  }
  
  .tags-grid {
    grid-template-columns: 1fr;
  }
  
  .modal-content {
    margin: 1rem;
    max-width: none;
  }
  
  .modal-actions {
    flex-direction: column;
  }
}
</style>