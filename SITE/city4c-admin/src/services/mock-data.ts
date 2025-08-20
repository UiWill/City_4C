import type { Occurrence, Tag, Profile, DashboardStats } from '@/types'
import { OccurrenceStatus, ReporterType } from '@/types'

// Mock Tags
export const mockTags: Tag[] = [
  {
    id: 1,
    name: 'Buraco na Rua',
    description: 'Problemas relacionados a buracos e pavimentação',
    color: '#ef4444',
    is_active: true,
    created_at: '2024-01-15T10:00:00Z'
  },
  {
    id: 2,
    name: 'Lixo na Rua',
    description: 'Acúmulo de lixo e problemas de limpeza urbana',
    color: '#f59e0b',
    is_active: true,
    created_at: '2024-01-15T10:00:00Z'
  },
  {
    id: 3,
    name: 'Iluminação',
    description: 'Problemas com iluminação pública',
    color: '#3b82f6',
    is_active: true,
    created_at: '2024-01-15T10:00:00Z'
  },
  {
    id: 4,
    name: 'Sinalização',
    description: 'Placas e sinalizações danificadas ou ausentes',
    color: '#10b981',
    is_active: true,
    created_at: '2024-01-15T10:00:00Z'
  }
]

// Mock Profiles
export const mockProfiles: Profile[] = [
  {
    id: 'agent-1',
    full_name: 'João Silva',
    role: 'agent',
    department: 'Obras Públicas',
    phone: '(11) 99999-0001',
    is_active: true,
    created_at: '2024-01-10T10:00:00Z',
    updated_at: '2024-01-10T10:00:00Z'
  },
  {
    id: 'agent-2',
    full_name: 'Maria Santos',
    role: 'agent',
    department: 'Limpeza Urbana',
    phone: '(11) 99999-0002',
    is_active: true,
    created_at: '2024-01-10T10:00:00Z',
    updated_at: '2024-01-10T10:00:00Z'
  },
  {
    id: 'admin-1',
    full_name: 'Carlos Admin',
    role: 'admin',
    department: 'Administração',
    phone: '(11) 99999-0003',
    is_active: true,
    created_at: '2024-01-10T10:00:00Z',
    updated_at: '2024-01-10T10:00:00Z'
  }
]

// Mock Occurrences with sample video URLs
export const mockOccurrences: Occurrence[] = [
  {
    id: 'occ-1',
    title: 'Grande buraco na Av. Paulista',
    description: 'Buraco profundo causando transtornos ao trânsito',
    video_url: 'https://sample-videos.com/zip/10/mp4/720/SampleVideo_720x480_1mb.mp4',
    video_filename: 'buraco_av_paulista.mp4',
    video_duration: 7,
    latitude: -23.5505,
    longitude: -46.6333,
    location_accuracy: 5,
    address: 'Av. Paulista, 1578 - Bela Vista, São Paulo - SP',
    status: OccurrenceStatus.PENDING,
    priority: 5,
    tag_id: 1,
    reported_by: null,
    reporter_type: ReporterType.CITIZEN,
    assigned_to: null,
    metadata: { device: 'iPhone 13', app_version: '1.0.0' },
    created_at: '2024-08-20T10:30:00Z',
    updated_at: '2024-08-20T10:30:00Z',
    tags: mockTags[0],
    profiles: null,
    assigned_agent: null
  },
  {
    id: 'occ-2',
    title: 'Lixo acumulado na Rua Augusta',
    description: 'Acúmulo de lixo há vários dias sem coleta',
    video_url: 'https://sample-videos.com/zip/10/mp4/720/SampleVideo_720x480_2mb.mp4',
    video_filename: 'lixo_rua_augusta.mp4',
    video_duration: 6,
    latitude: -23.5489,
    longitude: -46.6388,
    location_accuracy: 8,
    address: 'Rua Augusta, 2690 - Jardim Paulista, São Paulo - SP',
    status: OccurrenceStatus.IN_PROGRESS,
    priority: 3,
    tag_id: 2,
    reported_by: 'agent-1',
    reporter_type: ReporterType.AGENT,
    assigned_to: 'agent-2',
    metadata: { device: 'Samsung Galaxy S21', app_version: '1.0.0' },
    created_at: '2024-08-19T14:15:00Z',
    updated_at: '2024-08-20T08:00:00Z',
    tags: mockTags[1],
    profiles: mockProfiles[0],
    assigned_agent: mockProfiles[1]
  },
  {
    id: 'occ-3',
    title: 'Poste queimado na Rua da Consolação',
    description: 'Poste de iluminação queimado deixando área escura',
    video_url: 'https://sample-videos.com/zip/10/mp4/720/SampleVideo_720x480_1mb.mp4',
    video_filename: 'poste_consolacao.mp4',
    video_duration: 5,
    latitude: -23.5434,
    longitude: -46.6484,
    location_accuracy: 3,
    address: 'Rua da Consolação, 3456 - Consolação, São Paulo - SP',
    status: OccurrenceStatus.RESOLVED,
    priority: 4,
    tag_id: 3,
    reported_by: null,
    reporter_type: ReporterType.CITIZEN,
    assigned_to: 'agent-1',
    metadata: { device: 'Motorola Edge', app_version: '1.0.0' },
    created_at: '2024-08-18T20:00:00Z',
    updated_at: '2024-08-19T16:30:00Z',
    resolved_at: '2024-08-19T16:30:00Z',
    tags: mockTags[2],
    profiles: null,
    assigned_agent: mockProfiles[0]
  },
  {
    id: 'occ-4',
    title: 'Placa de trânsito danificada',
    description: 'Placa de pare danificada no cruzamento',
    video_url: 'https://sample-videos.com/zip/10/mp4/720/SampleVideo_720x480_2mb.mp4',
    video_filename: 'placa_transito.mp4',
    video_duration: 8,
    latitude: -23.5567,
    longitude: -46.6409,
    location_accuracy: 4,
    address: 'Av. Rebouças com Rua Henrique Schaumann - Pinheiros, São Paulo - SP',
    status: OccurrenceStatus.PENDING,
    priority: 2,
    tag_id: 4,
    reported_by: null,
    reporter_type: ReporterType.CITIZEN,
    assigned_to: null,
    metadata: { device: 'iPhone 12', app_version: '1.0.0' },
    created_at: '2024-08-20T07:45:00Z',
    updated_at: '2024-08-20T07:45:00Z',
    tags: mockTags[3],
    profiles: null,
    assigned_agent: null
  },
  {
    id: 'occ-5',
    title: 'Calçada quebrada na Vila Madalena',
    description: 'Calçada com diversos buracos dificultando passagem de pedestres',
    video_url: 'https://sample-videos.com/zip/10/mp4/720/SampleVideo_720x480_1mb.mp4',
    video_filename: 'calcada_vila_madalena.mp4',
    video_duration: 7,
    latitude: -23.5445,
    longitude: -46.6875,
    location_accuracy: 6,
    address: 'Rua Harmonia, 123 - Vila Madalena, São Paulo - SP',
    status: OccurrenceStatus.IN_PROGRESS,
    priority: 3,
    tag_id: 1,
    reported_by: 'agent-2',
    reporter_type: ReporterType.AGENT,
    assigned_to: 'agent-1',
    metadata: { device: 'Xiaomi Mi 11', app_version: '1.0.0' },
    created_at: '2024-08-19T11:20:00Z',
    updated_at: '2024-08-20T09:15:00Z',
    tags: mockTags[0],
    profiles: mockProfiles[1],
    assigned_agent: mockProfiles[0]
  }
]

// Mock Dashboard Stats
export const mockDashboardStats: DashboardStats = {
  total_occurrences: mockOccurrences.length,
  pending_occurrences: mockOccurrences.filter(o => o.status === OccurrenceStatus.PENDING).length,
  in_progress_occurrences: mockOccurrences.filter(o => o.status === OccurrenceStatus.IN_PROGRESS).length,
  resolved_occurrences: mockOccurrences.filter(o => o.status === OccurrenceStatus.RESOLVED).length,
  total_agents: mockProfiles.filter(p => p.role === 'agent').length,
  occurrences_today: 2,
  by_tag: [
    {
      tag_name: 'Buraco na Rua',
      count: 2,
      color: '#ef4444'
    },
    {
      tag_name: 'Lixo na Rua',
      count: 1,
      color: '#f59e0b'
    },
    {
      tag_name: 'Iluminação',
      count: 1,
      color: '#3b82f6'
    },
    {
      tag_name: 'Sinalização',
      count: 1,
      color: '#10b981'
    }
  ]
}