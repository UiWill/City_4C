class SupabaseConfig {
  static const String supabaseUrl = 'https://xpljlgvlyxwpoydbglkw.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhwbGpsZ3ZseXh3cG95ZGJnbGt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxMDA4NzEsImV4cCI6MjA3MDY3Njg3MX0.VmgkrssxMnrOt212blinnCnRp_hnw2gCCzI3477vdiQ';
  
  // Configurações do Storage
  static const String videoBucket = 'occurrence-videos';
  static const String avatarBucket = 'avatars';
  
  // Configurações de vídeo
  static const int maxVideoDurationSeconds = 7;
  static const double minLocationAccuracy = 100.0; // metros
}