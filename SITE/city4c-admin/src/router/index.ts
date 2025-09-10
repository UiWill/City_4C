import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    // Vitrine - Página inicial
    {
      path: '/',
      name: 'home',
      component: () => import('@/views/VitrineView.vue'),
      meta: { layout: 'none' }
    },
    
    // Sistema - Rotas administrativas
    {
      path: '/sistema',
      redirect: '/sistema/dashboard'
    },
    {
      path: '/sistema/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
      meta: { layout: 'none' }
    },
    {
      path: '/sistema/register',
      name: 'register',
      component: () => import('@/views/RegisterView.vue'),
      meta: { layout: 'none' }
    },
    {
      path: '/sistema/dashboard',
      name: 'dashboard',
      component: () => import('@/views/DashboardView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/sistema/occurrences',
      name: 'occurrences',
      component: () => import('@/views/OccurrencesView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/sistema/occurrences/:id',
      name: 'occurrence-detail',
      component: () => import('@/views/OccurrenceDetailView.vue'),
      props: true,
      meta: { requiresAuth: true }
    },
    {
      path: '/sistema/map',
      name: 'map',
      component: () => import('@/views/MapView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/sistema/tags',
      name: 'tags',
      component: () => import('@/views/TagsView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/sistema/agents',
      name: 'agents',
      component: () => import('@/views/AgentsView.vue'),
      meta: { requiresAuth: true }
    },
    
    // Rotas legadas (redirecionam para as novas)
    {
      path: '/login',
      redirect: '/sistema/login'
    },
    {
      path: '/register',
      redirect: '/sistema/register'
    },
    {
      path: '/dashboard',
      redirect: '/sistema/dashboard'
    },
    {
      path: '/occurrences',
      redirect: '/sistema/occurrences'
    },
    {
      path: '/map',
      redirect: '/sistema/map'
    },
    {
      path: '/tags',
      redirect: '/sistema/tags'
    },
    {
      path: '/agents',
      redirect: '/sistema/agents'
    },
    
    // 404
    {
      path: '/:pathMatch(.*)*',
      name: 'not-found',
      component: () => import('@/views/NotFoundView.vue'),
      meta: { layout: 'none' }
    }
  ]
})

export default router