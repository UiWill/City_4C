Passo 1: Configuração Inicial

	1.	Definir arquitetura técnica
	•	Aplicativo móvel: Flutter (cross-platform) para Android e iOS.
	•	Backend e banco de dados: Supabase (PostgreSQL) para dados geoespaciais e autenticação.
	•	Armazenamento de arquivos: Supabase Storage para vídeos e imagens.
	•	Painel administrativo: Vue.js (frontend) integrado ao backend do Supabase.

Passo 2: Desenvolvimento do Aplicativo Móvel

Módulo de Autenticação

	•	Implementar login para agentes públicos/terceirizados com autenticação via Supabase Auth.
	•	Permitir acesso anônimo para cidadãos (sem cadastro), limitado a funcionalidades específicas.

Módulo de Gravação de Vídeo

	•	Interface de câmera com limite de 7 segundos (configurável).
	•	Bloqueio de edição pós-gravação (sem cortes ou ajustes).
	•	Inserção automática de metadados no vídeo: data/hora e coordenadas geográficas.

Módulo de Geolocalização

	•	Captura de coordenadas precisas durante a gravação (GPS + rede).
	•	Validação da precisão da localização.
	•	Exibição de mapa de preview com localização após gravação.

Módulo de Tags e Envio

	•	Lista de tags configuráveis pelo administrador (ex.: “lixo”, “barulho”).
	•	Criptografia básica dos dados antes do envio.
	•	Exclusão do vídeo do dispositivo após envio bem-sucedido.

Passo 3: Painel Administrativo (Web)

Módulo de Dashboard

	•	Mapa interativo com ocorrências georreferenciadas.
	•	Filtros por data, tag e status.
	•	Indicadores básicos em tempo real (ex.: quantidade de ocorrências por região).

Módulo de Gestão de Ocorrências

	•	Player de vídeos com exibição dos metadados (data, hora, localização).
	•	Sistema básico de priorização manual das ocorrências.
	•	Exportação de dados em formato CSV.

Passo 4: Infraestrutura e Integração

	•	Integração entre aplicativo móvel (Flutter) e painel administrativo (Vue) via API do Supabase.
	•	Configuração inicial de autenticação, permissões e controle de acesso.
	•	Organização do banco de dados com tabelas para usuários, ocorrências, tags e vídeos.

Passo 5: Testes e Validação

	•	Testes básicos de gravação e envio em diferentes modelos de dispositivos.
	•	Teste de precisão de localização.
	•	Teste de performance no carregamento dos vídeos no painel administrativo.

⚠️ Observação: Este documento descreve a versão MVP (Prova de Conceito) conforme o orçamento aprovado, priorizando funcionalidades essenciais para operação inicial e validação junto a investidores. Funcionalidades como decibelímetro, modo ao vivo e IA preditiva serão implementadas em fases futuras.