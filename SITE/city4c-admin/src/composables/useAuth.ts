import { ref, computed } from 'vue'
import type { User } from '@supabase/supabase-js'
import { supabase } from '@/config/supabase'
import { ApiService } from '@/services/api'
import type { Profile } from '@/types'

const user = ref<User | null>(null)
const profile = ref<Profile | null>(null)
const isLoading = ref(false)

export function useAuth() {
  const isAuthenticated = computed(() => !!user.value)
  const isAdmin = computed(() => profile.value?.role === 'admin')
  const isAgent = computed(() => profile.value?.role === 'agent')

  const initialize = async () => {
    isLoading.value = true
    try {
      const { data: { user: currentUser } } = await supabase.auth.getUser()
      user.value = currentUser

      if (currentUser) {
        profile.value = await ApiService.getCurrentProfile()
      }
    } catch (error) {
      console.error('Auth initialization error:', error)
    } finally {
      isLoading.value = false
    }
  }

  const signIn = async (email: string, password: string) => {
    isLoading.value = true
    try {
      const { user: authUser } = await ApiService.signIn(email, password)
      user.value = authUser
      profile.value = await ApiService.getCurrentProfile()
    } catch (error) {
      throw error
    } finally {
      isLoading.value = false
    }
  }

  const signOut = async () => {
    isLoading.value = true
    try {
      await ApiService.signOut()
      user.value = null
      profile.value = null
    } catch (error) {
      throw error
    } finally {
      isLoading.value = false
    }
  }

  // Listen to auth changes
  supabase.auth.onAuthStateChange(async (event, session) => {
    if (event === 'SIGNED_IN' && session?.user) {
      user.value = session.user
      try {
        profile.value = await ApiService.getCurrentProfile()
      } catch (error) {
        console.error('Error loading profile:', error)
      }
    } else if (event === 'SIGNED_OUT') {
      user.value = null
      profile.value = null
    }
  })

  return {
    user: computed(() => user.value),
    profile: computed(() => profile.value),
    isAuthenticated,
    isAdmin,
    isAgent,
    isLoading: computed(() => isLoading.value),
    initialize,
    signIn,
    signOut
  }
}