<template>
  <div class="register-page">
    <div class="register-container">
      <div class="register-card">
        <!-- Header -->
        <div class="register-header">
          <div class="register-logo">
            <svg class="register-logo__icon" viewBox="0 0 24 24" fill="currentColor">
              <path d="M17 10.5V7a1 1 0 00-1-1H4a1 1 0 00-1 1v10a1 1 0 001 1h12a1 1 0 001-1v-3.5l4 2v-7l-4 2z"/>
            </svg>
          </div>
          <h1 class="register-title">Criar Conta</h1>
          <p class="register-subtitle">CITY 4C - Painel Administrativo</p>
        </div>

        <!-- Form -->
        <form @submit.prevent="handleSubmit" class="register-form">
          <div class="form-group">
            <label for="full-name" class="form-label">Nome Completo *</label>
            <input
              id="full-name"
              v-model="form.fullName"
              type="text"
              class="form-input"
              :class="{ 'form-input--error': errors.fullName }"
              placeholder="Seu nome completo"
              required
              :disabled="isLoading"
            />
            <div v-if="errors.fullName" class="form-error">
              {{ errors.fullName }}
            </div>
          </div>

          <div class="form-group">
            <label for="email" class="form-label">Email *</label>
            <input
              id="email"
              v-model="form.email"
              type="email"
              class="form-input"
              :class="{ 'form-input--error': errors.email }"
              placeholder="seu@email.com"
              required
              :disabled="isLoading"
            />
            <div v-if="errors.email" class="form-error">
              {{ errors.email }}
            </div>
          </div>

          <div class="form-group">
            <label for="password" class="form-label">Senha *</label>
            <div class="password-input">
              <input
                id="password"
                v-model="form.password"
                :type="showPassword ? 'text' : 'password'"
                class="form-input"
                :class="{ 'form-input--error': errors.password }"
                placeholder="••••••••"
                required
                :disabled="isLoading"
              />
              <button
                type="button"
                class="password-toggle"
                @click="showPassword = !showPassword"
                :disabled="isLoading"
              >
                <svg viewBox="0 0 24 24" fill="currentColor">
                  <path v-if="showPassword" d="M12 7c2.76 0 5 2.24 5 5 0 .65-.13 1.26-.36 1.83l2.92 2.92c1.51-1.26 2.7-2.89 3.43-4.75-1.73-4.39-6-7.5-11-7.5-1.4 0-2.74.25-3.98.7l2.16 2.16C10.74 7.13 11.35 7 12 7zM2 4.27l2.28 2.28.46.46C3.08 8.3 1.78 10.02 1 12c1.73 4.39 6 7.5 11 7.5 1.55 0 3.03-.3 4.38-.84l.42.42L19.73 22 21 20.73 3.27 3 2 4.27zM7.53 9.8l1.55 1.55c-.05.21-.08.43-.08.65 0 1.66 1.34 3 3 3 .22 0 .44-.03.65-.08l1.55 1.55c-.67.33-1.41.53-2.2.53-2.76 0-5-2.24-5-5 0-.79.2-1.53.53-2.2zm4.31-.78l3.15 3.15.02-.16c0-1.66-1.34-3-3-3l-.17.01z"/>
                  <path v-else d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/>
                </svg>
              </button>
            </div>
            <div v-if="errors.password" class="form-error">
              {{ errors.password }}
            </div>
            <small class="form-help">Mínimo 6 caracteres</small>
          </div>

          <div class="form-group">
            <label for="confirm-password" class="form-label">Confirmar Senha *</label>
            <input
              id="confirm-password"
              v-model="form.confirmPassword"
              type="password"
              class="form-input"
              :class="{ 'form-input--error': errors.confirmPassword }"
              placeholder="••••••••"
              required
              :disabled="isLoading"
            />
            <div v-if="errors.confirmPassword" class="form-error">
              {{ errors.confirmPassword }}
            </div>
          </div>

          <div class="form-group">
            <label for="role" class="form-label">Função *</label>
            <select
              id="role"
              v-model="form.role"
              class="form-select"
              :class="{ 'form-input--error': errors.role }"
              required
              :disabled="isLoading"
            >
              <option value="">Selecione sua função</option>
              <option value="agent">Agente Público</option>
              <option value="admin">Administrador</option>
            </select>
            <div v-if="errors.role" class="form-error">
              {{ errors.role }}
            </div>
          </div>

          <div class="form-group">
            <label for="department" class="form-label">Departamento</label>
            <input
              id="department"
              v-model="form.department"
              type="text"
              class="form-input"
              placeholder="Ex: Secretaria de Obras"
              :disabled="isLoading"
            />
          </div>

          <div class="form-group">
            <label for="phone" class="form-label">Telefone</label>
            <input
              id="phone"
              v-model="form.phone"
              type="tel"
              class="form-input"
              placeholder="(11) 99999-9999"
              :disabled="isLoading"
            />
          </div>

          <button 
            type="submit" 
            class="submit-button"
            :disabled="isLoading || !isFormValid"
          >
            <div v-if="isLoading" class="loading-spinner"></div>
            <span>{{ isLoading ? 'Criando conta...' : 'Criar Conta' }}</span>
          </button>

          <div v-if="errors.general" class="general-error">
            {{ errors.general }}
          </div>

          <div v-if="successMessage" class="success-message">
            {{ successMessage }}
          </div>
        </form>

        <!-- Login Link -->
        <div class="register-footer">
          <p>
            Já tem uma conta? 
            <RouterLink to="/login" class="login-link">Faça login</RouterLink>
          </p>
        </div>

        <!-- MVP Notice -->
        <div class="mvp-notice">
          <div class="mvp-notice__icon">
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
            </svg>
          </div>
          <div>
            <h3>Versão MVP</h3>
            <p>Qualquer pessoa pode criar uma conta de teste. Em produção, apenas administradores autorizados poderão criar novas contas.</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/config/supabase'

const router = useRouter()

const form = reactive({
  fullName: '',
  email: '',
  password: '',
  confirmPassword: '',
  role: '',
  department: '',
  phone: ''
})

const errors = reactive({
  fullName: '',
  email: '',
  password: '',
  confirmPassword: '',
  role: '',
  general: ''
})

const showPassword = ref(false)
const isLoading = ref(false)
const successMessage = ref('')

const isFormValid = computed(() => {
  return form.fullName && 
         form.email && 
         form.password && 
         form.confirmPassword && 
         form.role &&
         form.password === form.confirmPassword &&
         form.password.length >= 6
})

const clearErrors = () => {
  errors.fullName = ''
  errors.email = ''
  errors.password = ''
  errors.confirmPassword = ''
  errors.role = ''
  errors.general = ''
}

const validateForm = () => {
  clearErrors()
  let isValid = true

  if (!form.fullName.trim()) {
    errors.fullName = 'Nome completo é obrigatório'
    isValid = false
  }

  if (!form.email) {
    errors.email = 'Email é obrigatório'
    isValid = false
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) {
    errors.email = 'Email inválido'
    isValid = false
  }

  if (!form.password) {
    errors.password = 'Senha é obrigatória'
    isValid = false
  } else if (form.password.length < 6) {
    errors.password = 'Senha deve ter pelo menos 6 caracteres'
    isValid = false
  }

  if (!form.confirmPassword) {
    errors.confirmPassword = 'Confirmação de senha é obrigatória'
    isValid = false
  } else if (form.password !== form.confirmPassword) {
    errors.confirmPassword = 'Senhas não coincidem'
    isValid = false
  }

  if (!form.role) {
    errors.role = 'Função é obrigatória'
    isValid = false
  }

  return isValid
}

const handleSubmit = async () => {
  if (!validateForm()) return

  isLoading.value = true
  successMessage.value = ''

  try {
    // 1. Create user in Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: form.email,
      password: form.password,
      options: {
        data: {
          full_name: form.fullName.trim(),
          role: form.role
        }
      }
    })

    if (authError) throw authError

    if (authData.user) {
      // 2. Create profile in profiles table
      const { error: profileError } = await supabase
        .from('profiles')
        .insert({
          id: authData.user.id,
          full_name: form.fullName.trim(),
          role: form.role,
          department: form.department.trim() || null,
          phone: form.phone.trim() || null,
          is_active: true
        })

      if (profileError) {
        console.error('Profile creation error:', profileError)
        // Don't throw here - user was created successfully
      }

      // 3. Show success message
      successMessage.value = 'Conta criada com sucesso! Verifique seu email para confirmar a conta.'
      
      // 4. Clear form
      Object.keys(form).forEach(key => {
        form[key as keyof typeof form] = ''
      })

      // 5. Redirect to login after delay
      setTimeout(() => {
        router.push('/login')
      }, 3000)
    }

  } catch (error: any) {
    console.error('Registration error:', error)
    
    if (error.message?.includes('User already registered')) {
      errors.email = 'Este email já está cadastrado'
    } else if (error.message?.includes('Password should be at least 6 characters')) {
      errors.password = 'Senha deve ter pelo menos 6 caracteres'
    } else if (error.message?.includes('Invalid email')) {
      errors.email = 'Email inválido'
    } else {
      errors.general = 'Erro ao criar conta. Tente novamente.'
    }
  } finally {
    isLoading.value = false
  }
}
</script>

<style scoped>
.register-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 1rem;
}

.register-container {
  width: 100%;
  max-width: 480px;
}

.register-card {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
}

.register-header {
  text-align: center;
  margin-bottom: 2rem;
}

.register-logo {
  margin-bottom: 1rem;
}

.register-logo__icon {
  width: 48px;
  height: 48px;
  color: #4f46e5;
}

.register-title {
  font-size: 1.875rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 0.5rem 0;
}

.register-subtitle {
  color: #6b7280;
  margin: 0;
}

/* Form styles */
.register-form {
  margin-bottom: 1.5rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-label {
  display: block;
  font-weight: 500;
  color: #374151;
  margin-bottom: 0.5rem;
}

.form-input,
.form-select {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.form-input:focus,
.form-select:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.form-input--error,
.form-select--error {
  border-color: #ef4444;
}

.form-input--error:focus,
.form-select--error:focus {
  border-color: #ef4444;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}

.password-input {
  position: relative;
}

.password-toggle {
  position: absolute;
  right: 0.75rem;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: #6b7280;
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 4px;
  transition: color 0.2s;
}

.password-toggle:hover {
  color: #374151;
}

.password-toggle svg {
  width: 20px;
  height: 20px;
}

.form-error {
  color: #ef4444;
  font-size: 0.875rem;
  margin-top: 0.25rem;
}

.form-help {
  color: #6b7280;
  font-size: 0.875rem;
  margin-top: 0.25rem;
  display: block;
}

.submit-button {
  width: 100%;
  padding: 0.875rem;
  background-color: #4f46e5;
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.submit-button:hover:not(:disabled) {
  background-color: #4338ca;
}

.submit-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid transparent;
  border-top: 2px solid currentColor;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.general-error {
  background-color: #fef2f2;
  color: #dc2626;
  padding: 0.75rem;
  border-radius: 6px;
  border: 1px solid #fecaca;
  text-align: center;
  font-size: 0.875rem;
  margin-top: 1rem;
}

.success-message {
  background-color: #f0fdf4;
  color: #166534;
  padding: 0.75rem;
  border-radius: 6px;
  border: 1px solid #bbf7d0;
  text-align: center;
  font-size: 0.875rem;
  margin-top: 1rem;
}

/* Footer */
.register-footer {
  text-align: center;
  margin-bottom: 1.5rem;
}

.register-footer p {
  color: #6b7280;
  margin: 0;
}

.login-link {
  color: #4f46e5;
  text-decoration: none;
  font-weight: 500;
}

.login-link:hover {
  color: #4338ca;
  text-decoration: underline;
}

/* MVP Notice */
.mvp-notice {
  background-color: #eff6ff;
  border: 1px solid #bfdbfe;
  border-radius: 8px;
  padding: 1rem;
  display: flex;
  gap: 0.75rem;
}

.mvp-notice__icon {
  flex-shrink: 0;
}

.mvp-notice__icon svg {
  width: 20px;
  height: 20px;
  color: #3b82f6;
}

.mvp-notice h3 {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1e40af;
  margin: 0 0 0.25rem 0;
}

.mvp-notice p {
  font-size: 0.75rem;
  color: #3730a3;
  margin: 0;
  line-height: 1.4;
}

@media (max-width: 480px) {
  .register-card {
    padding: 1.5rem;
  }
  
  .register-title {
    font-size: 1.5rem;
  }
}
</style>