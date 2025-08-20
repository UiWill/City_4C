import { MockApiService } from './mock-api'
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

// Use Mock API for MVP demonstration
export class ApiService {
  // Dashboard Stats
  static async getDashboardStats(): Promise<DashboardStats> {
    return MockApiService.getDashboardStats()
  }

  // Occurrences
  static async getOccurrences(filters?: {
    status?: OccurrenceStatus
    tag_id?: number
    limit?: number
    offset?: number
  }): Promise<Occurrence[]> {
    return MockApiService.getOccurrences(filters)
  }

  static async getOccurrenceById(id: string): Promise<Occurrence> {
    return MockApiService.getOccurrenceById(id)
  }

  static async updateOccurrenceStatus(
    id: string, 
    status: OccurrenceStatus, 
    assignedTo?: string
  ) {
    return MockApiService.updateOccurrenceStatus(id, status, assignedTo)
  }

  static async updateOccurrencePriority(id: string, priority: number) {
    return MockApiService.updateOccurrencePriority(id, priority)
  }

  // Tags
  static async getTags(): Promise<Tag[]> {
    return MockApiService.getTags()
  }

  static async createTag(tag: Omit<Tag, 'id' | 'created_at'>) {
    return MockApiService.createTag(tag)
  }

  static async updateTag(id: number, updates: Partial<Tag>) {
    return MockApiService.updateTag(id, updates)
  }

  static async deleteTag(id: number) {
    return MockApiService.deleteTag(id)
  }

  // Agents
  static async getAgents(): Promise<Profile[]> {
    return MockApiService.getAgents()
  }

  // Video URLs
  static getVideoUrl(filename: string): string {
    return MockApiService.getVideoUrl(filename)
  }

  // Nearby occurrences
  static async getNearbyOccurrences(
    latitude: number, 
    longitude: number, 
    radiusKm: number = 5
  ) {
    return MockApiService.getNearbyOccurrences(latitude, longitude, radiusKm)
  }

  // Service Orders
  static async getServiceOrders(filters?: any): Promise<ServiceOrder[]> {
    return MockApiService.getServiceOrders()
  }

  static async getServiceOrderById(id: string): Promise<ServiceOrder> {
    return MockApiService.getServiceOrderById(id)
  }

  static async getServiceOrderStats(): Promise<ServiceOrderStats> {
    return MockApiService.getServiceOrderStats()
  }

  // Authentication (disabled for MVP)
  static async signIn(email: string, password: string) {
    return MockApiService.signIn(email, password)
  }

  static async signUp(email: string, password: string, userData: any) {
    return MockApiService.signUp(email, password, userData)
  }

  static async signOut() {
    return MockApiService.signOut()
  }

  static async getCurrentUser() {
    return MockApiService.getCurrentUser()
  }

  static async getCurrentProfile(): Promise<Profile | null> {
    return MockApiService.getCurrentProfile()
  }

  // Occurrence Updates
  static async getOccurrenceUpdates(occurrenceId: string) {
    return MockApiService.getOccurrenceUpdates(occurrenceId)
  }

  static async addOccurrenceUpdate(
    occurrenceId: string, 
    comment: string, 
    statusChange?: string
  ) {
    return MockApiService.addOccurrenceUpdate(occurrenceId, comment, statusChange)
  }
}