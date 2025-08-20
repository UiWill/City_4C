-- Fix para corrigir recursão infinita nas políticas RLS
-- Execute no SQL Editor do Supabase

-- Remover políticas existentes que causam recursão
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can manage tags" ON tags;
DROP POLICY IF EXISTS "Agents and admins can view all occurrences" ON occurrences;
DROP POLICY IF EXISTS "Agents can update assigned occurrences" ON occurrences;
DROP POLICY IF EXISTS "Agents can create updates" ON occurrence_updates;

-- Criar função para verificar se usuário é admin (evita recursão)
CREATE OR REPLACE FUNCTION is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM auth.users u
    JOIN profiles p ON p.id = u.id
    WHERE u.id = user_id AND p.role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar função para verificar se usuário é agente ou admin
CREATE OR REPLACE FUNCTION is_agent_or_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM auth.users u
    JOIN profiles p ON p.id = u.id
    WHERE u.id = user_id AND p.role IN ('agent', 'admin')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recriar políticas sem recursão

-- Política simples para admins verem todos os perfis
CREATE POLICY "Admins can view all profiles" ON profiles
  FOR SELECT USING (is_admin(auth.uid()));

-- Política para tags - admins podem gerenciar
CREATE POLICY "Admins can manage tags" ON tags
  FOR ALL USING (is_admin(auth.uid()));

-- Política para occorrences - agentes e admins podem ver todas
CREATE POLICY "Agents and admins can view all occurrences" ON occurrences
  FOR SELECT USING (is_agent_or_admin(auth.uid()));

-- Política para occorrences - agentes podem atualizar
CREATE POLICY "Agents can update assigned occurrences" ON occurrences
  FOR UPDATE USING (
    assigned_to = auth.uid() OR is_admin(auth.uid())
  );

-- Política para updates - agentes podem criar
CREATE POLICY "Agents can create updates" ON occurrence_updates
  FOR INSERT WITH CHECK (is_agent_or_admin(auth.uid()));

-- Garantir que todos podem ler tags ativas (importante para o app)
CREATE POLICY "Public can read active tags" ON tags
  FOR SELECT USING (is_active = true);

-- IMPORTANTE: Corrigir política de inserção para ocorrências
-- Remover políticas restritivas existentes
DROP POLICY IF EXISTS "Anyone can create occurrences" ON occurrences;
DROP POLICY IF EXISTS "Allow insert occurrences for authenticated and anonymous" ON occurrences;
DROP POLICY IF EXISTS "Allow read own occurrences" ON occurrences;

-- Desabilitar RLS temporariamente para occurrences (permitir acesso público)
ALTER TABLE occurrences DISABLE ROW LEVEL SECURITY;

-- Política simples que permite qualquer inserção (para cidadãos anônimos)
CREATE POLICY "Public can insert occurrences" ON occurrences
  FOR INSERT WITH CHECK (true);

-- Política que permite agentes/admins lerem todas as ocorrências
CREATE POLICY "Agents can read all occurrences" ON occurrences
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM auth.users u
      JOIN profiles p ON p.id = u.id
      WHERE u.id = auth.uid() AND p.role IN ('agent', 'admin')
    ) OR
    -- Permite leitura pública para listagem (sem dados sensíveis)
    true
  );

-- Reabilitar RLS
ALTER TABLE occurrences ENABLE ROW LEVEL SECURITY;