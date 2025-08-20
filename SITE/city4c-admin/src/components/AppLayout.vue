<template>
  <div class="app-layout">
    <!-- Sidebar -->
    <aside class="sidebar" :class="{ 'sidebar--collapsed': sidebarCollapsed }">
      <div class="sidebar__header">
        <div class="sidebar__logo">
          <svg class="sidebar__logo-icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M17 10.5V7a1 1 0 00-1-1H4a1 1 0 00-1 1v10a1 1 0 001 1h12a1 1 0 001-1v-3.5l4 2v-7l-4 2z"/>
          </svg>
          <span v-if="!sidebarCollapsed" class="sidebar__logo-text">CITY 4C</span>
        </div>
        <button 
          class="sidebar__toggle"
          @click="toggleSidebar"
          :aria-label="sidebarCollapsed ? 'Expandir menu' : 'Recolher menu'"
        >
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path :d="sidebarCollapsed ? 'M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z' : 'M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z'"/>
          </svg>
        </button>
      </div>

      <nav class="sidebar__nav">
        <RouterLink 
          v-for="item in navigationItems" 
          :key="item.name"
          :to="item.to" 
          class="nav-item"
          :class="{ 'nav-item--active': $route.name === item.name }"
        >
          <svg class="nav-item__icon" viewBox="0 0 24 24" fill="currentColor">
            <path :d="item.iconPath"/>
          </svg>
          <span v-if="!sidebarCollapsed" class="nav-item__text">{{ item.label }}</span>
        </RouterLink>
      </nav>

      <div class="sidebar__footer">
        <div class="user-info" :class="{ 'user-info--collapsed': sidebarCollapsed }">
          <div class="user-info__avatar">
            {{ profile?.full_name?.[0] || 'U' }}
          </div>
          <div v-if="!sidebarCollapsed" class="user-info__details">
            <div class="user-info__name">{{ profile?.full_name || 'Usuário MVP' }}</div>
            <div class="user-info__role">{{ profile ? roleLabels[profile.role] : 'Acesso Direto' }}</div>
          </div>
        </div>
        
        <RouterLink 
          to="/login" 
          class="sidebar__logout"
          :title="sidebarCollapsed ? 'Login' : undefined"
        >
          <svg class="sidebar__logout-icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M11,7L9.6,8.4l2.6,2.6H2v2h10.2l-2.6,2.6L11,17l5-5L11,7z M20,19h-8v2h8c1.1,0,2-0.9,2-2V5c0-1.1-0.9-2-2-2h-8v2h8V19z"/>
          </svg>
          <span v-if="!sidebarCollapsed">Login</span>
        </RouterLink>
      </div>
    </aside>

    <!-- Main content -->
    <main class="main-content">
      <header class="app-header">
        <h1 class="app-title">{{ currentPageTitle }}</h1>
      </header>
      
      <div class="app-content">
        <RouterView />
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'

const router = useRouter()
const { profile, signOut } = useAuth()

const sidebarCollapsed = ref(false)

const navigationItems = computed(() => {
  return [
    {
      name: 'dashboard',
      to: '/',
      label: 'Dashboard',
      iconPath: 'M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z'
    },
    {
      name: 'occurrences',
      to: '/occurrences',
      label: 'Ocorrências',
      iconPath: 'M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z'
    },
    {
      name: 'map',
      to: '/map',
      label: 'Mapa',
      iconPath: 'M20.5 3l-.16.03L15 5.1 9 3 3.36 4.9c-.21.07-.36.25-.36.48V20.5c0 .28.22.5.5.5l.16-.03L9 18.9l6 2.1 5.64-1.9c.21-.07.36-.25.36-.48V3.5c0-.28-.22-.5-.5-.5z'
    },
    {
      name: 'tags',
      to: '/tags',
      label: 'Categorias',
      iconPath: 'M17.63 5.84C17.27 5.33 16.67 5 16 5L5 5.01C3.9 5.01 3 5.9 3 7v10c0 1.1.9 2 2 2h11c.67 0 1.27-.33 1.63-.84L22 12l-4.37-6.16z'
    },
    {
      name: 'agents',
      to: '/agents',
      label: 'Agentes',
      iconPath: 'M16 7c0-2.76-2.24-5-5-5S6 4.24 6 7s2.24 5 5 5 5-2.24 5-5zM1 18c0-2.66 5.33-4 10-4s10 1.34 10 4v1H1v-1z'
    }
  ]
})

const roleLabels = {
  admin: 'Administrador',
  agent: 'Agente'
}

const currentPageTitle = computed(() => {
  const route = router.currentRoute.value
  const item = navigationItems.value.find(item => item.name === route.name)
  return item?.label || 'CITY 4C'
})

const toggleSidebar = () => {
  sidebarCollapsed.value = !sidebarCollapsed.value
}

</script>

<style scoped>
.app-layout {
  display: flex;
  min-height: 100vh;
  background-color: #f8fafc;
}

/* Sidebar */
.sidebar {
  width: 260px;
  background: linear-gradient(180deg, #1e40af 0%, #1e3a8a 100%);
  color: white;
  display: flex;
  flex-direction: column;
  height: 100vh;
  z-index: 100;
  flex-shrink: 0;
  box-shadow: 2px 0 8px rgba(0, 0, 0, 0.1);
}

.sidebar--collapsed {
  width: 70px;
}

.sidebar__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.5rem 1rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.sidebar__logo {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.sidebar__logo-icon {
  width: 32px;
  height: 32px;
  color: #60a5fa;
}

.sidebar__logo-text {
  font-size: 1.5rem;
  font-weight: 700;
}

.sidebar__toggle {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 0.375rem;
  transition: background-color 0.2s;
}

.sidebar__toggle:hover {
  background-color: rgba(255, 255, 255, 0.1);
}

.sidebar__toggle svg {
  width: 20px;
  height: 20px;
}

/* Navigation */
.sidebar__nav {
  flex: 1;
  padding: 1rem 0;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem 1rem;
  color: rgba(255, 255, 255, 0.8);
  text-decoration: none;
  transition: all 0.2s;
  border-left: 3px solid transparent;
}

.nav-item:hover {
  background-color: rgba(255, 255, 255, 0.1);
  color: white;
}

.nav-item--active {
  background-color: rgba(255, 255, 255, 0.15);
  color: white;
  border-left-color: #60a5fa;
}

.nav-item__icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

.nav-item__text {
  font-weight: 500;
}

/* Footer */
.sidebar__footer {
  padding: 1rem;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.user-info--collapsed {
  justify-content: center;
}

.user-info__avatar {
  width: 40px;
  height: 40px;
  background-color: #60a5fa;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  text-transform: uppercase;
}

.user-info__name {
  font-weight: 600;
  font-size: 0.875rem;
}

.user-info__role {
  font-size: 0.75rem;
  color: rgba(255, 255, 255, 0.7);
}

.sidebar__logout {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  width: 100%;
  padding: 0.75rem;
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: white;
  border-radius: 0.375rem;
  cursor: pointer;
  transition: all 0.2s;
}

.sidebar__logout:hover {
  background-color: rgba(255, 255, 255, 0.1);
}

.sidebar__logout-icon {
  width: 18px;
  height: 18px;
}

/* Main content */
.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.app-header {
  background: white;
  padding: 1rem 2rem;
  border-bottom: 1px solid #e5e7eb;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  flex-shrink: 0;
}

.app-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.app-content {
  flex: 1;
  padding: 1.5rem 2rem;
  overflow-y: auto;
  background-color: #f9fafb;
}

/* Desktop-first design - remove mobile transforms */
</style>