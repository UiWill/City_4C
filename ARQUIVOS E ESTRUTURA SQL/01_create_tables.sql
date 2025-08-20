-- CITY 4C Database Structure
-- Execute estas queries no SQL Editor do Supabase

-- Ativar extensão PostGIS para dados geoespaciais
CREATE EXTENSION IF NOT EXISTS postgis;

-- Tabela de perfis de usuários (extends auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  role TEXT CHECK (role IN ('agent', 'admin')) DEFAULT 'agent',
  phone TEXT,
  department TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de tags configuráveis
CREATE TABLE public.tags (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  color TEXT DEFAULT '#3B82F6',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Tabela de ocorrências
CREATE TABLE public.occurrences (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT,
  description TEXT,
  video_url TEXT NOT NULL,
  video_filename TEXT NOT NULL,
  video_duration INTEGER, -- em segundos
  location GEOMETRY(POINT, 4326) NOT NULL, -- PostGIS point
  latitude DECIMAL(10,8) NOT NULL,
  longitude DECIMAL(11,8) NOT NULL,
  location_accuracy DECIMAL(5,2), -- precisão do GPS em metros
  address TEXT,
  status TEXT CHECK (status IN ('pending', 'in_progress', 'resolved', 'rejected')) DEFAULT 'pending',
  priority INTEGER DEFAULT 1 CHECK (priority BETWEEN 1 AND 5),
  tag_id INTEGER REFERENCES tags(id),
  reported_by UUID REFERENCES auth.users(id), -- NULL para reportes anônimos
  reporter_type TEXT CHECK (reporter_type IN ('agent', 'citizen')) DEFAULT 'citizen',
  assigned_to UUID REFERENCES auth.users(id),
  metadata JSONB, -- dados extras como device info, etc
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resolved_at TIMESTAMP WITH TIME ZONE
);

-- Tabela de comentários/atualizações nas ocorrências
CREATE TABLE public.occurrence_updates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  occurrence_id UUID REFERENCES occurrences(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id),
  comment TEXT NOT NULL,
  status_change TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_occurrences_location ON occurrences USING GIST (location);
CREATE INDEX idx_occurrences_status ON occurrences (status);
CREATE INDEX idx_occurrences_created_at ON occurrences (created_at);
CREATE INDEX idx_occurrences_tag_id ON occurrences (tag_id);
CREATE INDEX idx_profiles_role ON profiles (role);

-- Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE occurrences ENABLE ROW LEVEL SECURITY;
ALTER TABLE occurrence_updates ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para profiles
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" ON profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Políticas RLS para tags
CREATE POLICY "Anyone can view active tags" ON tags
  FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage tags" ON tags
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Políticas RLS para occurrences
CREATE POLICY "Anyone can create occurrences" ON occurrences
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Agents and admins can view all occurrences" ON occurrences
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role IN ('agent', 'admin')
    )
  );

CREATE POLICY "Users can view own occurrences" ON occurrences
  FOR SELECT USING (reported_by = auth.uid());

CREATE POLICY "Agents can update assigned occurrences" ON occurrences
  FOR UPDATE USING (
    assigned_to = auth.uid() OR
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Políticas RLS para occurrence_updates
CREATE POLICY "Agents can create updates" ON occurrence_updates
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role IN ('agent', 'admin')
    )
  );

CREATE POLICY "Anyone can view updates" ON occurrence_updates
  FOR SELECT USING (true);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_occurrences_updated_at BEFORE UPDATE ON occurrences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();