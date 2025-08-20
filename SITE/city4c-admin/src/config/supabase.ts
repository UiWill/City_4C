import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://xpljlgvlyxwpoydbglkw.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhwbGpsZ3ZseXh3cG95ZGJnbGt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxMDA4NzEsImV4cCI6MjA3MDY3Njg3MX0.VmgkrssxMnrOt212blinnCnRp_hnw2gCCzI3477vdiQ'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export const STORAGE_BUCKETS = {
  OCCURRENCE_VIDEOS: 'occurrence-videos',
  AVATARS: 'avatars'
} as const