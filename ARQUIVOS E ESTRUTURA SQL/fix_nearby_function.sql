-- Corrigir função get_nearby_occurrences para resolver erro de ROUND()
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