-- CITY 4C - Dados iniciais
-- Execute após criar as tabelas

-- Inserir tags padrão do sistema
INSERT INTO public.tags (name, description, color) VALUES
  ('Lixo', 'Acúmulo de lixo ou descarte inadequado', '#EF4444'),
  ('Iluminação', 'Problemas com iluminação pública', '#F59E0B'),
  ('Pavimentação', 'Buracos, rachaduras na via', '#6B7280'),
  ('Barulho', 'Poluição sonora', '#8B5CF6'),
  ('Água', 'Vazamentos, falta de água', '#06B6D4'),
  ('Esgoto', 'Problemas no sistema de esgoto', '#84CC16'),
  ('Trânsito', 'Sinalização, semáforo', '#F97316'),
  ('Verde', 'Problemas em praças, árvores', '#10B981'),
  ('Segurança', 'Situações de risco', '#DC2626'),
  ('Outros', 'Outras ocorrências', '#6B7280');

-- Criar função para buscar ocorrências por proximidade
CREATE OR REPLACE FUNCTION get_nearby_occurrences(
  user_lat DECIMAL,
  user_lng DECIMAL,
  radius_km INTEGER DEFAULT 5
)
RETURNS TABLE (
  id UUID,
  title TEXT,
  description TEXT,
  latitude DECIMAL,
  longitude DECIMAL,
  distance_km DECIMAL,
  status TEXT,
  tag_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    o.id,
    o.title,
    o.description,
    o.latitude,
    o.longitude,
    ROUND(
      CAST(ST_Distance(
        o.location,
        ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)
      ) / 1000 AS NUMERIC), 2
    ) AS distance_km,
    o.status,
    t.name AS tag_name,
    o.created_at
  FROM occurrences o
  LEFT JOIN tags t ON o.tag_id = t.id
  WHERE ST_DWithin(
    o.location,
    ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326),
    radius_km * 1000
  )
  ORDER BY ST_Distance(
    o.location,
    ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para estatísticas do dashboard
CREATE OR REPLACE FUNCTION get_dashboard_stats()
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_occurrences', (SELECT COUNT(*) FROM occurrences),
    'pending_occurrences', (SELECT COUNT(*) FROM occurrences WHERE status = 'pending'),
    'in_progress_occurrences', (SELECT COUNT(*) FROM occurrences WHERE status = 'in_progress'),
    'resolved_occurrences', (SELECT COUNT(*) FROM occurrences WHERE status = 'resolved'),
    'total_agents', (SELECT COUNT(*) FROM profiles WHERE role = 'agent' AND is_active = true),
    'occurrences_today', (SELECT COUNT(*) FROM occurrences WHERE created_at::date = CURRENT_DATE),
    'by_tag', (
      SELECT json_agg(
        json_build_object(
          'tag_name', t.name,
          'count', COALESCE(tag_counts.count, 0),
          'color', t.color
        )
      )
      FROM tags t
      LEFT JOIN (
        SELECT tag_id, COUNT(*) as count
        FROM occurrences
        WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY tag_id
      ) tag_counts ON t.id = tag_counts.tag_id
      WHERE t.is_active = true
    )
  ) INTO result;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;