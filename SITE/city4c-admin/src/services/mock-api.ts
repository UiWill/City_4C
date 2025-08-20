import type { 
  Occurrence, 
  Tag, 
  Profile, 
  DashboardStats,
  ServiceOrder,
  ServiceOrderStats
} from '@/types'
import { OccurrenceStatus, ServiceOrderStatus } from '@/types'
import { 
  mockOccurrences, 
  mockTags, 
  mockProfiles, 
  mockDashboardStats 
} from './mock-data'

// Mock API Service - simulates real API calls with delays
export class MockApiService {
  // Simulate network delay
  private static delay(ms: number = 500) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  // Dashboard Stats
  static async getDashboardStats(): Promise<DashboardStats> {
    await this.delay(300)
    return mockDashboardStats
  }

  // Occurrences
  static async getOccurrences(filters?: {
    status?: OccurrenceStatus
    tag_id?: number
    limit?: number
    offset?: number
  }): Promise<Occurrence[]> {
    await this.delay(400)
    
    let filtered = [...mockOccurrences]
    
    if (filters?.status) {
      filtered = filtered.filter(o => o.status === filters.status)
    }
    
    if (filters?.tag_id) {
      filtered = filtered.filter(o => o.tag_id === filters.tag_id)
    }
    
    if (filters?.offset) {
      filtered = filtered.slice(filters.offset)
    }
    
    if (filters?.limit) {
      filtered = filtered.slice(0, filters.limit)
    }
    
    return filtered
  }

  static async getOccurrenceById(id: string): Promise<Occurrence> {
    await this.delay(300)
    
    const occurrence = mockOccurrences.find(o => o.id === id)
    if (!occurrence) {
      throw new Error('Occurrence not found')
    }
    
    return occurrence
  }

  static async updateOccurrenceStatus(
    id: string, 
    status: OccurrenceStatus, 
    assignedTo?: string
  ) {
    await this.delay(400)
    
    const occurrence = mockOccurrences.find(o => o.id === id)
    if (!occurrence) {
      throw new Error('Occurrence not found')
    }
    
    occurrence.status = status
    occurrence.updated_at = new Date().toISOString()
    
    if (assignedTo) {
      occurrence.assigned_to = assignedTo
      occurrence.assigned_agent = mockProfiles.find(p => p.id === assignedTo) || null
    }
    
    if (status === OccurrenceStatus.RESOLVED) {
      occurrence.resolved_at = new Date().toISOString()
    }
    
    return occurrence
  }

  static async updateOccurrencePriority(id: string, priority: number) {
    await this.delay(300)
    
    const occurrence = mockOccurrences.find(o => o.id === id)
    if (!occurrence) {
      throw new Error('Occurrence not found')
    }
    
    occurrence.priority = priority
    occurrence.updated_at = new Date().toISOString()
    
    return occurrence
  }

  // Tags
  static async getTags(): Promise<Tag[]> {
    await this.delay(200)
    return mockTags.filter(t => t.is_active)
  }

  static async createTag(tag: Omit<Tag, 'id' | 'created_at'>) {
    await this.delay(400)
    
    const newTag: Tag = {
      ...tag,
      id: Math.max(...mockTags.map(t => t.id)) + 1,
      created_at: new Date().toISOString()
    }
    
    mockTags.push(newTag)
    return newTag
  }

  static async updateTag(id: number, updates: Partial<Tag>) {
    await this.delay(400)
    
    const tagIndex = mockTags.findIndex(t => t.id === id)
    if (tagIndex === -1) {
      throw new Error('Tag not found')
    }
    
    mockTags[tagIndex] = { ...mockTags[tagIndex], ...updates }
    return mockTags[tagIndex]
  }

  static async deleteTag(id: number) {
    await this.delay(300)
    
    const tag = mockTags.find(t => t.id === id)
    if (!tag) {
      throw new Error('Tag not found')
    }
    
    tag.is_active = false
    return tag
  }

  // Agents
  static async getAgents(): Promise<Profile[]> {
    await this.delay(200)
    return mockProfiles.filter(p => ['agent', 'admin'].includes(p.role) && p.is_active)
  }

  // Video URLs (for mock purposes, return working demo URLs)
  static getVideoUrl(filename: string): string {
    // Map filenames to working demo videos
    const videoMap: Record<string, string> = {
      'buraco_av_paulista.mp4': 'https://sample-videos.com/zip/10/mp4/720/SampleVideo_720x480_1mb.mp4',
      'lixo_rua_augusta.mp4': 'https://sample-videos.com/zip/10/mp4/720/SampleVideo_720x480_2mb.mp4',
      'poste_consolacao.mp4': 'https://sample-videos.com/zip/10/mp4/720/SampleVideo_720x480_1mb.mp4',
      'placa_transito.mp4': 'https://sample-videos.com/zip/10/mp4/720/SampleVideo_720x480_2mb.mp4',
      'calcada_vila_madalena.mp4': 'https://sample-videos.com/zip/10/mp4/720/SampleVideo_720x480_1mb.mp4'
    }
    
    return videoMap[filename] || 'https://sample-videos.com/zip/10/mp4/720/SampleVideo_720x480_1mb.mp4'
  }

  // Nearby occurrences
  static async getNearbyOccurrences(
    latitude: number, 
    longitude: number, 
    radiusKm: number = 5
  ) {
    await this.delay(300)
    // Return occurrences within São Paulo area for demo
    return mockOccurrences.slice(0, 3)
  }

  // Service Orders (basic mock implementation)
  static async getServiceOrders(): Promise<ServiceOrder[]> {
    await this.delay(400)
    return [] // Empty for now
  }

  static async getServiceOrderById(id: string): Promise<ServiceOrder> {
    await this.delay(300)
    throw new Error('Service order not found')
  }

  static async getServiceOrderStats(): Promise<ServiceOrderStats> {
    await this.delay(200)
    return {
      total_orders: 0,
      pending_orders: 0,
      in_progress_orders: 0,
      completed_orders: 0,
      overdue_orders: 0
    }
  }

  // Authentication (mock - always return null for MVP)
  static async signIn(email: string, password: string) {
    await this.delay(500)
    throw new Error('Authentication not available in MVP mode')
  }

  static async signUp(email: string, password: string, userData: any) {
    await this.delay(500)
    throw new Error('Registration not available in MVP mode')
  }

  static async signOut() {
    await this.delay(200)
    // Do nothing in MVP mode
  }

  static async getCurrentUser() {
    return null
  }

  static async getCurrentProfile(): Promise<Profile | null> {
    return null
  }

  // Occurrence Updates/Comments (basic mock)
  static async getOccurrenceUpdates(occurrenceId: string) {
    await this.delay(300)
    return []
  }

  static async addOccurrenceUpdate(
    occurrenceId: string, 
    comment: string, 
    statusChange?: string
  ) {
    await this.delay(400)
    return {
      id: 'update-1',
      occurrence_id: occurrenceId,
      user_id: 'mock-user',
      comment,
      status_change: statusChange,
      created_at: new Date().toISOString(),
      profiles: null
    }
  }
}