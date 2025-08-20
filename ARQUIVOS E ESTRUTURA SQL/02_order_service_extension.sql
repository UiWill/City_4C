-- CITY 4C Order Service Extension
-- Execute após 01_create_tables.sql

-- Tabela de ordens de serviço
CREATE TABLE public.service_orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  occurrence_id UUID REFERENCES occurrences(id) ON DELETE CASCADE UNIQUE,
  protocol_number TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  priority INTEGER DEFAULT 1 CHECK (priority BETWEEN 1 AND 5),
  estimated_duration_hours INTEGER, -- prazo estimado em horas
  due_date TIMESTAMP WITH TIME ZONE,
  status TEXT CHECK (status IN ('created', 'in_progress', 'completed', 'cancelled')) DEFAULT 'created',
  assigned_to UUID REFERENCES auth.users(id),
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

-- Tabela para sequencial de protocolo por ano
CREATE TABLE public.protocol_sequence (
  year INTEGER PRIMARY KEY,
  current_number INTEGER DEFAULT 0
);

-- Função para gerar número de protocolo sequencial
CREATE OR REPLACE FUNCTION generate_protocol_number()
RETURNS TEXT AS $$
DECLARE
  current_year INTEGER;
  sequence_number INTEGER;
  protocol_number TEXT;
BEGIN
  current_year := EXTRACT(YEAR FROM NOW());
  
  -- Inserir ou atualizar sequencial do ano
  INSERT INTO protocol_sequence (year, current_number)
  VALUES (current_year, 1)
  ON CONFLICT (year) 
  DO UPDATE SET current_number = protocol_sequence.current_number + 1
  RETURNING current_number INTO sequence_number;
  
  -- Formato: CITY4C-YYYY-NNNNNN (ex: CITY4C-2024-000001)
  protocol_number := 'CITY4C-' || current_year || '-' || LPAD(sequence_number::TEXT, 6, '0');
  
  RETURN protocol_number;
END;
$$ LANGUAGE plpgsql;

-- Função para criar ordem de serviço automaticamente
CREATE OR REPLACE FUNCTION create_service_order_for_occurrence()
RETURNS TRIGGER AS $$
DECLARE
  estimated_hours INTEGER;
  due_date_calculated TIMESTAMP WITH TIME ZONE;
  os_title TEXT;
  os_description TEXT;
BEGIN
  -- Só criar OS quando status muda para 'in_progress'
  IF NEW.status = 'in_progress' AND OLD.status != 'in_progress' THEN
    
    -- Calcular prazo baseado na prioridade
    CASE NEW.priority
      WHEN 5 THEN estimated_hours := 4;   -- Emergência: 4 horas
      WHEN 4 THEN estimated_hours := 24;  -- Alta: 24 horas
      WHEN 3 THEN estimated_hours := 72;  -- Média: 3 dias
      WHEN 2 THEN estimated_hours := 168; -- Baixa: 7 dias
      ELSE estimated_hours := 336;        -- Normal: 14 dias
    END CASE;
    
    due_date_calculated := NOW() + (estimated_hours || ' hours')::INTERVAL;
    
    -- Preparar título e descrição
    os_title := COALESCE(NEW.title, 'Ocorrência reportada via CITY 4C');
    os_description := COALESCE(NEW.description, 'Ocorrência sem descrição detalhada') || 
                      E'\n\nLocalização: ' || COALESCE(NEW.address, 'Lat: ' || NEW.latitude || ', Lng: ' || NEW.longitude) ||
                      E'\nReportado em: ' || TO_CHAR(NEW.created_at, 'DD/MM/YYYY HH24:MI');
    
    -- Inserir ordem de serviço
    INSERT INTO service_orders (
      occurrence_id,
      protocol_number,
      title,
      description,
      priority,
      estimated_duration_hours,
      due_date,
      assigned_to,
      created_by
    ) VALUES (
      NEW.id,
      generate_protocol_number(),
      os_title,
      os_description,
      NEW.priority,
      estimated_hours,
      due_date_calculated,
      NEW.assigned_to,
      auth.uid()
    );
    
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para criação automática de OS
CREATE TRIGGER auto_create_service_order
  AFTER UPDATE ON occurrences
  FOR EACH ROW
  EXECUTE FUNCTION create_service_order_for_occurrence();

-- Índices para performance
CREATE INDEX idx_service_orders_occurrence_id ON service_orders (occurrence_id);
CREATE INDEX idx_service_orders_protocol_number ON service_orders (protocol_number);
CREATE INDEX idx_service_orders_status ON service_orders (status);
CREATE INDEX idx_service_orders_assigned_to ON service_orders (assigned_to);
CREATE INDEX idx_service_orders_due_date ON service_orders (due_date);

-- RLS para service_orders
ALTER TABLE service_orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Agents and admins can view service orders" ON service_orders
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role IN ('agent', 'admin')
    )
  );

CREATE POLICY "Agents can manage assigned service orders" ON service_orders
  FOR ALL USING (
    assigned_to = auth.uid() OR
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS para protocol_sequence
ALTER TABLE protocol_sequence ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow protocol sequence access" ON protocol_sequence
  FOR ALL USING (true);

-- Trigger para updated_at em service_orders
CREATE TRIGGER update_service_orders_updated_at BEFORE UPDATE ON service_orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Função para buscar estatísticas de ordens de serviço
CREATE OR REPLACE FUNCTION get_service_orders_stats()
RETURNS TABLE (
  total_orders BIGINT,
  pending_orders BIGINT,
  in_progress_orders BIGINT,
  completed_orders BIGINT,
  overdue_orders BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*) as total_orders,
    COUNT(*) FILTER (WHERE status = 'created') as pending_orders,
    COUNT(*) FILTER (WHERE status = 'in_progress') as in_progress_orders,
    COUNT(*) FILTER (WHERE status = 'completed') as completed_orders,
    COUNT(*) FILTER (WHERE status IN ('created', 'in_progress') AND due_date < NOW()) as overdue_orders
  FROM service_orders;
END;
$$ LANGUAGE plpgsql;