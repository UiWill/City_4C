# 🛠️ CITY 4C - Instruções de Build (MVP)

## 📱 **App Mobile Modificado - Versão MVP**

### ⚡ **Mudanças Principais:**
- ❌ **Criptografia desabilitada** temporariamente 
- ✅ **Upload direto** de arquivos `.mp4`
- ✅ **Compatível** com reprodução no site web

---

## 🚀 **Como Compilar e Testar:**

### **1. Preparar Ambiente:**
```bash
# Navegue para a pasta do app
cd /path/to/CITY\ 4C/APP/city4c_app

# Instale dependências
flutter pub get

# Verifique configuração
flutter doctor
```

### **2. Build para Android:**
```bash
# Build de debug (recomendado para testes)
flutter build apk --debug

# Build de release (para produção)
flutter build apk --release

# Instalar em dispositivo conectado
flutter install
```

### **3. Build para iOS:**
```bash
# Build para iOS (precisa de macOS e Xcode)
flutter build ios --debug

# Para release
flutter build ios --release
```

### **4. Executar em Desenvolvimento:**
```bash
# Executar em dispositivo/emulador conectado
flutter run

# Com logs detalhados
flutter run -v
```

---

## 🧪 **Testar o Fluxo Completo:**

### **1. Gravar Vídeo no App:**
- Abrir app mobile
- Permitir permissões de câmera e localização
- Gravar vídeo de 7 segundos
- Selecionar tag/categoria
- Confirmar envio

### **2. Verificar no Console:**
Procure por logs como:
```
📤 Fazendo upload do vídeo sem criptografia (modo MVP)...
📁 Nome do arquivo: video_1755123456789.mp4
📊 Tamanho do arquivo: 1234567 bytes
✅ Upload concluído! URL: https://...
```

### **3. Verificar no Site Web:**
- Acessar [site administrativo]
- Ir em "Ocorrências"
- Clicar na ocorrência recém-criada
- **Vídeo deve reproduzir automaticamente** ✅
- Não deve aparecer a mensagem de criptografia ❌

---

## 🐛 **Troubleshooting:**

### **Erro de Build:**
```bash
# Limpar cache
flutter clean
flutter pub get
```

### **Erro de Permissões:**
- Verificar AndroidManifest.xml
- Verificar Info.plist (iOS)
- Testar permissões no app

### **Erro de Upload:**
- Verificar conectividade
- Conferir configurações Supabase
- Verificar logs no console

### **Vídeo não reproduz no site:**
- Verificar se arquivo é realmente `.mp4`
- Conferir se não há erro 404 na URL
- Testar URL diretamente no navegador

---

## 📊 **Monitoramento:**

### **Logs Importantes:**
```dart
// Durante gravação:
🎬 Iniciando gravação de vídeo...
✅ Gravação iniciada com sucesso

// Durante upload:
📤 Fazendo upload do vídeo sem criptografia (modo MVP)...
📁 Nome do arquivo: video_[timestamp].mp4
✅ Upload concluído!

// Durante criação da ocorrência:
📝 Criando ocorrência sem autenticação...
✅ Ocorrência criada com ID: [uuid]
```

### **Verificar Storage:**
- Acessar Supabase Dashboard
- Ir em Storage > occurrence-videos
- Verificar se novos arquivos estão em formato `.mp4`
- **NÃO** devem mais aparecer arquivos `.dat`

---

## 🔄 **Para Voltar à Versão com Criptografia:**

1. Restaurar código original do `supabase_service.dart`
2. Re-importar `encryption_service.dart` 
3. Testar sistema completo
4. Implementar descriptografia no site

---

**Status Atual:** ✅ Pronto para teste MVP  
**Próximos Passos:** Compilar app → Testar upload → Verificar site