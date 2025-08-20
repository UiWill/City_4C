-- CITY 4C - Configuração do Storage
-- Execute no SQL Editor do Supabase para configurar os buckets de storage

-- Criar bucket para vídeos das ocorrências
INSERT INTO storage.buckets (id, name, public)
VALUES ('occurrence-videos', 'occurrence-videos', false);

-- Políticas para o bucket occurrence-videos
-- Permitir upload para usuários autenticados e anônimos
CREATE POLICY "Anyone can upload videos" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'occurrence-videos');

-- Permitir download apenas para agentes e admins
CREATE POLICY "Agents can view videos" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'occurrence-videos' AND (
      auth.uid() IS NULL OR -- Para acesso através da API com service key
      EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = auth.uid() AND role IN ('agent', 'admin')
      )
    )
  );

-- Permitir delete apenas para admins
CREATE POLICY "Admins can delete videos" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'occurrence-videos' AND
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Criar bucket para avatars (futuro)
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

-- Política para avatars - usuários podem gerenciar seus próprios avatars
CREATE POLICY "Users can manage own avatar" ON storage.objects
  FOR ALL USING (
    bucket_id = 'avatars' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );