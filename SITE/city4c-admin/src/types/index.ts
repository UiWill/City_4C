export interface Tag {
  id: number
  name: string
  description?: string
  color: string
  is_active: boolean
  created_at: string
  created_by?: string
}

export enum OccurrenceStatus {
  PENDING = 'pending',
  IN_PROGRESS = 'in_progress',
  RESOLVED = 'resolved',
  REJECTED = 'rejected'
}

export enum ReporterType {
  AGENT = 'agent',
  CITIZEN = 'citizen'
}

export interface Occurrence {
  id: string
  title?: string
  description?: string
  video_url: string
  video_filename: string
  video_duration?: number
  latitude: number
  longitude: number
  location_accuracy?: number
  address?: string
  status: OccurrenceStatus
  priority: number
  tag_id?: number
  reported_by?: string
  reporter_type: ReporterType
  assigned_to?: string
  metadata?: Record<string, any>
  created_at: string
  updated_at: string
  resolved_at?: string
  // Relations
  tags?: Tag
  profiles?: Profile
  assigned_agent?: Profile
}

export interface Profile {
  id: string
  full_name?: string
  role: 'agent' | 'admin'
  phone?: string
  department?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface OccurrenceUpdate {
  id: string
  occurrence_id: string
  user_id: string
  comment: string
  status_change?: string
  created_at: string
  profiles?: Profile
}

export interface DashboardStats {
  total_occurrences: number
  pending_occurrences: number
  in_progress_occurrences: number
  resolved_occurrences: number
  total_agents: number
  occurrences_today: number
  by_tag: Array<{
    tag_name: string
    count: number
    color: string
  }>
}

export enum ServiceOrderStatus {
  CREATED = 'created',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}

export interface ServiceOrder {
  id: string
  occurrence_id: string
  protocol_number: string
  title: string
  description: string
  priority: number
  estimated_duration_hours?: number
  due_date?: string
  status: ServiceOrderStatus
  assigned_to?: string
  created_by?: string
  created_at: string
  updated_at: string
  completed_at?: string
  // Relations
  occurrence?: Occurrence
  assigned_agent?: Profile
  created_by_profile?: Profile
}

export interface ServiceOrderStats {
  total_orders: number
  pending_orders: number
  in_progress_orders: number
  completed_orders: number
  overdue_orders: number
}