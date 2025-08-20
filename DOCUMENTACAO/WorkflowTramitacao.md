# Sistema de Workflow e Tramitação - CITY 4C

## Visão Geral

O sistema CITY 4C inclui um módulo completo de workflow para tramitação de ocorrências, permitindo acompanhar todo o ciclo de vida desde a identificação até a resolução final.

## Fluxo de Tramitação

### 1. Identificação da Demanda
- **Origem**: Relato via aplicativo móvel (cidadão ou agente)
- **Status Inicial**: `pending` (Pendente)
- **Responsável**: Sistema automaticamente

### 2. Triagem e Atribuição  
- **Operador do Sistema**: PM, Guarda Municipal, Supervisor, etc.
- **Ações Disponíveis**:
  - Aceitar ocorrência → Status: `in_progress`
  - Rejeitar ocorrência → Status: `rejected`
  - Atribuir responsável específico
  - Definir prioridade (1-5)
  - Adicionar comentários de triagem

### 3. Ordem de Serviço
- **Geração Automática**: Quando status muda para `in_progress`
- **Conteúdo da OS**:
  - Número único de protocolo
  - Descrição detalhada da demanda
  - Localização georreferenciada
  - Prioridade definida
  - Responsável atribuído
  - Prazo estimado (baseado na categoria)

### 4. Andamento e Acompanhamento
- **Timeline de Atualizações**: Todas as mudanças são registradas
- **Comentários**: Agentes podem adicionar observações
- **Mudança de Status**: Histórico completo de alterações
- **Notificações**: Sistema de alertas para prazos

### 5. Finalização da Demanda
- **Status Final**: `resolved` (Resolvido)
- **Documentação**: Comentário obrigatório de finalização
- **Timestamp**: Data/hora de resolução
- **Relatório**: Geração automática de relatório da OS

## Status de Tramitação

| Status | Descrição | Ações Disponíveis |
|--------|-----------|-------------------|
| `pending` | Aguardando triagem | Aceitar, Rejeitar, Comentar |
| `in_progress` | Em andamento | Atualizar, Finalizar, Reatribuir |
| `resolved` | Resolvido | Reabrir (se necessário) |
| `rejected` | Rejeitado | Reabrir para reavaliação |

## Integrações Futuras (Fase 2)

### Para Polícia Militar
- **API de Integração**: Endpoint para envio automático de ocorrências de segurança
- **Protocolo**: Sistema de numeração compatível com protocolos PM
- **Categorização**: Mapeamento automático de tags para códigos PM

### Para Prefeituras Pequenas
- **Workflow Completo**: Sistema interno de tramitação
- **Relatórios Gerenciais**: Dashboard para gestores
- **SLA**: Definição de prazos por categoria
- **Notificações**: Email/SMS para munícipes sobre andamento

## Funcionalidades Implementadas (MVP)

✅ **Base do Sistema de Tramitação**:
- Status de ocorrências (pending → in_progress → resolved)
- Sistema de comentários/atualizações
- Atribuição de responsáveis
- Priorização manual (1-5)
- Timeline completa de mudanças
- Exportação de relatórios (CSV)

✅ **Dashboard de Gestão**:
- Indicadores em tempo real
- Filtros por status, categoria, prioridade
- Mapa de ocorrências
- Estatísticas de performance

## Roadmap de Evolução

### Fase 2 - Sistema de OS Completo
- [ ] Geração automática de Ordem de Serviço
- [ ] Numeração sequencial de protocolos
- [ ] Prazos automáticos por categoria
- [ ] Sistema de notificações (email/SMS)
- [ ] Relatórios de performance por agente
- [ ] Dashboard gerencial para supervisores

### Fase 3 - Integrações Externas
- [ ] API para integração com sistemas PM
- [ ] Webhook para sistemas de terceiros
- [ ] Portal do cidadão para acompanhamento
- [ ] App mobile para agentes de campo

## Tecnologia

- **Backend**: Supabase (PostgreSQL + Real-time)
- **Frontend**: Vue.js 3 + TypeScript
- **Mobile**: Flutter (cross-platform)
- **Autenticação**: Supabase Auth + RLS
- **Storage**: Supabase Storage (vídeos criptografados)

## Conclusão

O sistema atual já possui toda a infraestrutura necessária para um workflow completo de tramitação. As funcionalidades base estão implementadas e funcionais, permitindo evolução gradual conforme demanda dos clientes.