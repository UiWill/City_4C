import { supabase } from '@/config/supabase'
import type { 
  Occurrence, 
  Tag, 
  Profile, 
  OccurrenceUpdate, 
  DashboardStats,
  ServiceOrder,
  ServiceOrderStats
} from '@/types'
import { OccurrenceStatus, ServiceOrderStatus } from '@/types'

export class ApiService {
  // Authentication
  static async signIn(email: string, password: string) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    })
    
    if (error) throw error
    return data
  }

  static async signUp(email: string, password: string, userData: {
    fullName: string
    role: string
    department?: string
    phone?: string
  }) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: userData.fullName,
          role: userData.role
        }
      }
    })
    
    if (error) throw error
    
    // Create profile if user was created
    if (data.user) {
      const { error: profileError } = await supabase
        .from('profiles')
        .insert({
          id: data.user.id,
          full_name: userData.fullName,
          role: userData.role,
          department: userData.department || null,
          phone: userData.phone || null,
          is_active: true
        })
      
      if (profileError) {
        console.error('Profile creation error:', profileError)
        // Don't throw - user was created successfully
      }
    }
    
    return data
  }

  static async signOut() {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  static async getCurrentUser() {
    const { data: { user }, error } = await supabase.auth.getUser()
    if (error) throw error
    return user
  }

  static async getCurrentProfile(): Promise<Profile | null> {
    const user = await this.getCurrentUser()
    if (!user) return null

    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single()

    if (error) throw error
    return data
  }

  // Dashboard Stats
  static async getDashboardStats(): Promise<DashboardStats> {
    const { data, error } = await supabase
      .rpc('get_dashboard_stats')

    if (error) throw error
    return data as DashboardStats
  }

  // Occurrences
  static async getOccurrences(filters?: {
    status?: OccurrenceStatus
    tag_id?: number
    limit?: number
    offset?: number
  }): Promise<Occurrence[]> {
    let query = supabase
      .from('occurrences')
      .select(`
        *,
        tags (
          id,
          name,
          color
        )
      `)
      .order('created_at', { ascending: false })

    if (filters?.status) {
      query = query.eq('status', filters.status)
    }

    if (filters?.tag_id) {
      query = query.eq('tag_id', filters.tag_id)
    }

    if (filters?.limit) {
      query = query.limit(filters.limit)
    }

    if (filters?.offset) {
      query = query.range(filters.offset, (filters.offset + (filters.limit || 10)) - 1)
    }

    const { data, error } = await query

    if (error) throw error
    return data as Occurrence[]
  }

  static async getOccurrenceById(id: string): Promise<Occurrence> {
    const { data, error } = await supabase
      .from('occurrences')
      .select(`
        *,
        tags (
          id,
          name,
          color,
          description
        )
      `)
      .eq('id', id)
      .single()

    if (error) throw error
    return data as Occurrence
  }

  static async updateOccurrenceStatus(
    id: string, 
    status: OccurrenceStatus, 
    assignedTo?: string
  ) {
    const updates: any = { 
      status,
      updated_at: new Date().toISOString()
    }

    if (assignedTo) {
      updates.assigned_to = assignedTo
    }

    if (status === OccurrenceStatus.RESOLVED) {
      updates.resolved_at = new Date().toISOString()
    }

    const { data, error } = await supabase
      .from('occurrences')
      .update(updates)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  static async updateOccurrencePriority(id: string, priority: number) {
    const { data, error } = await supabase
      .from('occurrences')
      .update({ 
        priority,
        updated_at: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  // Occurrence Updates/Comments
  static async getOccurrenceUpdates(occurrenceId: string): Promise<OccurrenceUpdate[]> {
    const { data, error } = await supabase
      .from('occurrence_updates')
      .select(`
        *,
        profiles (
          id,
          full_name,
          role
        )
      `)
      .eq('occurrence_id', occurrenceId)
      .order('created_at', { ascending: true })

    if (error) throw error
    return data as OccurrenceUpdate[]
  }

  static async addOccurrenceUpdate(
    occurrenceId: string, 
    comment: string, 
    statusChange?: string
  ) {
    const { data, error } = await supabase
      .from('occurrence_updates')
      .insert({
        occurrence_id: occurrenceId,
        comment,
        status_change: statusChange
      })
      .select(`
        *,
        profiles (
          id,
          full_name,
          role
        )
      `)
      .single()

    if (error) throw error
    return data
  }

  // Tags
  static async getTags(): Promise<Tag[]> {
    const { data, error } = await supabase
      .from('tags')
      .select('*')
      .eq('is_active', true)
      .order('name')

    if (error) throw error
    return data as Tag[]
  }

  static async createTag(tag: Omit<Tag, 'id' | 'created_at'>) {
    const { data, error } = await supabase
      .from('tags')
      .insert(tag)
      .select()
      .single()

    if (error) throw error
    return data
  }

  static async updateTag(id: number, updates: Partial<Tag>) {
    const { data, error } = await supabase
      .from('tags')
      .update(updates)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  static async deleteTag(id: number) {
    const { data, error } = await supabase
      .from('tags')
      .update({ is_active: false })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  // Agents
  static async getAgents(): Promise<Profile[]> {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .in('role', ['agent', 'admin'])
      .eq('is_active', true)
      .order('full_name')

    if (error) throw error
    return data as Profile[]
  }

  // Video URLs
  static getVideoUrl(filename: string): string {
    return supabase.storage
      .from('occurrence-videos')
      .getPublicUrl(filename).data.publicUrl
  }

  static async getVideoSignedUrl(filename: string): Promise<string> {
    const { data, error } = await supabase.storage
      .from('occurrence-videos')
      .createSignedUrl(filename, 3600) // 1 hour expiry

    if (error) {
      console.error('Error creating signed URL:', error)
      // Fallback to demo video
      return 'https://sample-videos.com/zip/10/mp4/720/SampleVideo_720x480_1mb.mp4'
    }

    return data.signedUrl
  }

  // Nearby occurrences
  static async getNearbyOccurrences(
    latitude: number, 
    longitude: number, 
    radiusKm: number = 5
  ) {
    const { data, error } = await supabase
      .rpc('get_nearby_occurrences', {
        user_lat: latitude,
        user_lng: longitude,
        radius_km: radiusKm
      })

    if (error) throw error
    return data
  }

  // Service Orders
  static async getServiceOrders(filters?: {
    status?: ServiceOrderStatus
    assigned_to?: string
    overdue_only?: boolean
    limit?: number
    offset?: number
  }): Promise<ServiceOrder[]> {
    let query = supabase
      .from('service_orders')
      .select(`
        *,
        occurrence:occurrences!service_orders_occurrence_id_fkey (
          id,
          title,
          description,
          latitude,
          longitude,
          address,
          status,
          priority,
          created_at
        ),
        assigned_agent:profiles!service_orders_assigned_to_fkey (
          id,
          full_name,
          role,
          department
        ),
        created_by_profile:profiles!service_orders_created_by_fkey (
          id,
          full_name,
          role
        )
      `)
      .order('created_at', { ascending: false })

    if (filters?.status) {
      query = query.eq('status', filters.status)
    }

    if (filters?.assigned_to) {
      query = query.eq('assigned_to', filters.assigned_to)
    }

    if (filters?.overdue_only) {
      query = query.in('status', ['created', 'in_progress']).lt('due_date', new Date().toISOString())
    }

    if (filters?.limit) {
      query = query.limit(filters.limit)
    }

    if (filters?.offset) {
      query = query.range(filters.offset, (filters.offset + (filters.limit || 10)) - 1)
    }

    const { data, error } = await query

    if (error) throw error
    return data as ServiceOrder[]
  }

  static async getServiceOrderById(id: string): Promise<ServiceOrder> {
    const { data, error } = await supabase
      .from('service_orders')
      .select(`
        *,
        occurrence:occurrences!service_orders_occurrence_id_fkey (
          id,
          title,
          description,
          video_url,
          video_filename,
          latitude,
          longitude,
          address,
          status,
          priority,
          created_at,
          tags (
            id,
            name,
            color
          )
        ),
        assigned_agent:profiles!service_orders_assigned_to_fkey (
          id,
          full_name,
          role,
          department,
          phone
        ),
        created_by_profile:profiles!service_orders_created_by_fkey (
          id,
          full_name,
          role
        )
      `)
      .eq('id', id)
      .single()

    if (error) throw error
    return data as ServiceOrder
  }

  static async getServiceOrderByOccurrenceId(occurrenceId: string): Promise<ServiceOrder | null> {
    const { data, error } = await supabase
      .from('service_orders')
      .select(`
        *,
        assigned_agent:profiles!service_orders_assigned_to_fkey (
          id,
          full_name,
          role,
          department
        ),
        created_by_profile:profiles!service_orders_created_by_fkey (
          id,
          full_name,
          role
        )
      `)
      .eq('occurrence_id', occurrenceId)
      .single()

    if (error && error.code !== 'PGRST116') throw error
    return data as ServiceOrder | null
  }

  static async updateServiceOrderStatus(
    id: string, 
    status: ServiceOrderStatus,
    completedAt?: string
  ) {
    const updates: any = { 
      status,
      updated_at: new Date().toISOString()
    }

    if (status === ServiceOrderStatus.COMPLETED && completedAt) {
      updates.completed_at = completedAt
    }

    const { data, error } = await supabase
      .from('service_orders')
      .update(updates)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  static async updateServiceOrderAssignment(id: string, assignedTo: string) {
    const { data, error } = await supabase
      .from('service_orders')
      .update({ 
        assigned_to: assignedTo,
        updated_at: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  static async getServiceOrderStats(): Promise<ServiceOrderStats> {
    const { data, error } = await supabase
      .rpc('get_service_orders_stats')

    if (error) throw error
    return data as ServiceOrderStats
  }
}