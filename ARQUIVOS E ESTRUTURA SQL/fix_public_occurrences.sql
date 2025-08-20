-- Fix definitivo para permitir criação de ocorrências por cidadãos anônimos
-- Execute no SQL Editor do Supabase

-- Remover todas as políticas existentes da tabela occurrences
DROP POLICY IF EXISTS "Public can insert occurrences" ON occurrences;
DROP POLICY IF EXISTS "Agents can read all occurrences" ON occurrences;
DROP POLICY IF EXISTS "Anyone can create occurrences" ON occurrences;
DROP POLICY IF EXISTS "Allow insert occurrences for authenticated and anonymous" ON occurrences;
DROP POLICY IF EXISTS "Allow read own occurrences" ON occurrences;
DROP POLICY IF EXISTS "Agents and admins can view all occurrences" ON occurrences;
DROP POLICY IF EXISTS "Agents can update assigned occurrences" ON occurrences;

-- Desabilitar RLS na tabela occurrences para permitir acesso público
ALTER TABLE occurrences DISABLE ROW LEVEL SECURITY;

-- Verificar se RLS está desabilitado
SELECT schemaname, tablename, rowsecurity, relrowsecurity 
FROM pg_tables t 
JOIN pg_class c ON c.relname = t.tablename 
WHERE t.tablename = 'occurrences';

-- Política alternativa: Se você quiser manter RLS habilitado mas permitir acesso público
-- Descomente as linhas abaixo e comente a linha "DISABLE ROW LEVEL SECURITY" acima

-- ALTER TABLE occurrences ENABLE ROW LEVEL SECURITY;

-- CREATE POLICY "Allow public insert and read occurrences" ON occurrences
--   FOR ALL USING (true) WITH CHECK (true);

-- Para a tabela tags, garantir que qualquer um pode ler tags ativas
ALTER TABLE tags DISABLE ROW LEVEL SECURITY;

-- Ou manter RLS e permitir leitura pública:
-- ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
-- DROP POLICY IF EXISTS "Public can read active tags" ON tags;
-- CREATE POLICY "Public can read active tags" ON tags
--   FOR SELECT USING (is_active = true);

-- Verificar o status atual das tabelas
SELECT 
    schemaname, 
    tablename, 
    rowsecurity 
FROM pg_tables 
WHERE tablename IN ('occurrences', 'tags', 'profiles')
ORDER BY tablename;