<template>
  <div class="app">
    <div v-if="isLoading" class="app-loading">
      <div class="loading-spinner"></div>
      <p>Carregando...</p>
    </div>
    
    <div v-else-if="shouldShowLayout" class="app-with-layout">
      <AppLayout>
        <RouterView />
      </AppLayout>
    </div>
    
    <div v-else class="app-no-layout">
      <RouterView />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import AppLayout from '@/components/AppLayout.vue'

const route = useRoute()
const { isAuthenticated, isLoading, initialize } = useAuth()

// Routes that don't need the main layout
const noLayoutRoutes = ['login', 'register', 'not-found', 'home']

const shouldShowLayout = computed(() => {
  // Show layout only for sistema routes when authenticated
  return isAuthenticated.value && 
         route.path.startsWith('/sistema/') && 
         !noLayoutRoutes.includes(route.name as string) &&
         route.meta?.layout !== 'none'
})

onMounted(async () => {
  await initialize()
})
</script>

<style>
/* Global styles */
* {
  box-sizing: border-box;
}

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f8fafc;
}

.app {
  min-height: 100vh;
}

.app-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  color: #6b7280;
}

.loading-spinner {
  width: 32px;
  height: 32px;
  border: 2px solid #f3f4f6;
  border-top: 2px solid #2563eb;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.app-with-layout,
.app-no-layout {
  min-height: 100vh;
}

/* Utility classes */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

/* Form elements */
.form-group {
  margin-bottom: 1rem;
}

.form-label {
  display: block;
  font-weight: 500;
  color: #374151;
  margin-bottom: 0.5rem;
  font-size: 0.875rem;
}

.form-input,
.form-select,
.form-textarea {
  display: block;
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  line-height: 1.5;
  color: #1f2937;
  background-color: white;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.form-input:focus,
.form-select:focus,
.form-textarea:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-input:disabled,
.form-select:disabled,
.form-textarea:disabled {
  background-color: #f9fafb;
  color: #6b7280;
  cursor: not-allowed;
}

/* Buttons */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.5rem 1rem;
  border: 1px solid transparent;
  border-radius: 0.375rem;
  font-weight: 500;
  font-size: 0.875rem;
  line-height: 1.5;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.15s ease-in-out;
  gap: 0.5rem;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-primary {
  color: white;
  background-color: #3b82f6;
  border-color: #3b82f6;
}

.btn-primary:hover:not(:disabled) {
  background-color: #2563eb;
  border-color: #2563eb;
}

.btn-secondary {
  color: #374151;
  background-color: white;
  border-color: #d1d5db;
}

.btn-secondary:hover:not(:disabled) {
  background-color: #f9fafb;
  border-color: #9ca3af;
}

.btn-success {
  color: white;
  background-color: #10b981;
  border-color: #10b981;
}

.btn-success:hover:not(:disabled) {
  background-color: #059669;
  border-color: #059669;
}

.btn-warning {
  color: white;
  background-color: #f59e0b;
  border-color: #f59e0b;
}

.btn-warning:hover:not(:disabled) {
  background-color: #d97706;
  border-color: #d97706;
}

.btn-danger {
  color: white;
  background-color: #ef4444;
  border-color: #ef4444;
}

.btn-danger:hover:not(:disabled) {
  background-color: #dc2626;
  border-color: #dc2626;
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.75rem;
}

.btn-lg {
  padding: 0.75rem 1.5rem;
  font-size: 1rem;
}

/* Cards */
.card {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.card-header {
  padding: 1rem 1.5rem;
  border-bottom: 1px solid #e5e7eb;
}

.card-body {
  padding: 1.5rem;
}

.card-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid #e5e7eb;
  background-color: #f9fafb;
}

/* Alerts */
.alert {
  padding: 0.75rem 1rem;
  border: 1px solid;
  border-radius: 0.375rem;
  margin-bottom: 1rem;
}

.alert-success {
  color: #065f46;
  background-color: #d1fae5;
  border-color: #a7f3d0;
}

.alert-warning {
  color: #92400e;
  background-color: #fef3c7;
  border-color: #fcd34d;
}

.alert-danger {
  color: #991b1b;
  background-color: #fee2e2;
  border-color: #fca5a5;
}

.alert-info {
  color: #1e40af;
  background-color: #dbeafe;
  border-color: #93c5fd;
}

/* Responsive utilities */
@media (max-width: 640px) {
  .hidden-sm {
    display: none !important;
  }
}

@media (max-width: 768px) {
  .hidden-md {
    display: none !important;
  }
}

@media (max-width: 1024px) {
  .hidden-lg {
    display: none !important;
  }
}
</style>