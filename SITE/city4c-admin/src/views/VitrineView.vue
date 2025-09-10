<template>
  <div class="vitrine">
    <!-- Navigation -->
    <nav class="navbar">
      <div class="container">
        <div class="nav-brand">
          <div class="logo">
            <div class="logo-symbol">
              <span class="logo-number">4C</span>
            </div>
            <div class="logo-text">
              <span class="brand-name">CITY</span>
              <span class="brand-tagline">URBAN INTELLIGENCE</span>
            </div>
          </div>
        </div>
        <ul class="nav-menu" :class="{ active: mobileMenuOpen }">
          <li><a href="#home" @click="scrollTo('home')">Plataforma</a></li>
          <li><a href="#desafio" @click="scrollTo('desafio')">Desafio</a></li>
          <li><a href="#solucao" @click="scrollTo('solucao')">Solução</a></li>
          <li><a href="#tecnologia" @click="scrollTo('tecnologia')">Tecnologia</a></li>
          <li><a href="#contato" @click="scrollTo('contato')">Contato</a></li>
        </ul>
        <div class="cta-nav">
          <router-link to="/sistema" class="btn-nav">Acessar Sistema</router-link>
        </div>
        <div class="hamburger" :class="{ active: mobileMenuOpen }" @click="toggleMobileMenu">
          <span></span>
          <span></span>
          <span></span>
        </div>
      </div>
    </nav>

    <!-- Hero Section -->
    <section id="home" class="hero">
      <div class="hero-background"></div>
      <div class="container">
        <div class="hero-content">
          <div class="hero-text">
            <div class="hero-badge">
              <i class="fas fa-shield-alt"></i>
              <span>Tecnologia de Segurança Urbana Avançada</span>
            </div>
            <h1>Transforme Dados em <span class="gradient-text">Inteligência Urbana</span></h1>
            <p class="hero-description">
              Plataforma corporativa que converte dispositivos móveis em sensores de segurança urbana, 
              fornecendo dados georreferenciados confiáveis para tomada de decisões estratégicas.
            </p>
            <div class="hero-stats">
              <div class="stat">
                <span class="stat-number">100%</span>
                <span class="stat-label">Dados Confiáveis</span>
              </div>
              <div class="stat">
                <span class="stat-number">7s</span>
                <span class="stat-label">Tempo de Captura</span>
              </div>
              <div class="stat">
                <span class="stat-number">24/7</span>
                <span class="stat-label">Monitoramento</span>
              </div>
            </div>
            <div class="hero-actions">
              <button class="btn btn-primary" @click="scrollTo('solucao')">
                <i class="fas fa-info-circle"></i>
                Saiba Mais
              </button>
              <button class="btn btn-secondary" @click="scrollTo('contato')">
                <i class="fas fa-envelope"></i>
                Entre em Contato
              </button>
            </div>
          </div>
          <div class="hero-visual">
            <div class="platform-preview">
              <div class="device-frame">
                <div class="device-screen">
                  <div class="app-header">
                    <span class="app-title">City 4C</span>
                    <span class="status-indicator active"></span>
                  </div>
                  <div class="camera-viewport">
                    <div class="google-maps-view">
                      <!-- Simulated Google Maps background -->
                      <div class="maps-terrain">
                        <div class="street street-1"></div>
                        <div class="street street-2"></div>
                        <div class="street street-3"></div>
                        <div class="street street-4"></div>
                        <div class="building building-1"></div>
                        <div class="building building-2"></div>
                        <div class="building building-3"></div>
                        <div class="building building-4"></div>
                        <div class="park-area"></div>
                      </div>
                      <div class="location-marker-main">
                        <i class="fas fa-map-marker-alt"></i>
                      </div>
                      <div class="maps-ui">
                        <div class="maps-label">Praça Sete de Setembro</div>
                        <div class="maps-controls">
                          <button class="zoom-btn">+</button>
                          <button class="zoom-btn">-</button>
                        </div>
                      </div>
                    </div>
                    <div class="data-overlay">
                      <div class="location-data">
                        <i class="fas fa-map-marker-alt"></i>
                        <span>-19.9167, -43.9345</span>
                      </div>
                      <div class="sound-meter">
                        <i class="fas fa-volume-up"></i>
                        <span class="decibel-reading">82 dB</span>
                      </div>
                      <div class="timestamp">
                        <i class="fas fa-clock"></i>
                        <span>14:23:47</span>
                      </div>
                    </div>
                  </div>
                  <div class="control-panel">
                    <button class="record-btn pulsing">
                      <i class="fas fa-circle"></i>
                    </button>
                  </div>
                </div>
              </div>
              <div class="data-streams">
                <div class="stream-indicator">
                  <div class="stream-dot"></div>
                  <span>Streaming em tempo real</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Challenge Section -->
    <section id="desafio" class="challenge-section">
      <div class="container">
        <div class="section-header">
          <span class="section-badge">O Desafio</span>
          <h2>Cenário Urbano Crítico</h2>
          <p>Dados alarmantes exigem soluções tecnológicas avançadas para segurança pública</p>
        </div>
        
        <div class="challenge-grid">
          <div class="challenge-metric">
            <div class="metric-visual">
              <div class="metric-chart">
                <div class="chart-bar" style="height: 60%"></div>
                <div class="chart-bar" style="height: 100%"></div>
              </div>
            </div>
            <div class="metric-content">
              <h3>+41% Vandalismo</h3>
              <p>Crescimento dos casos de vandalismo em Belo Horizonte apenas no primeiro semestre</p>
              <span class="metric-source">Fonte: SEJUSP-MG</span>
            </div>
          </div>

          <div class="challenge-metric">
            <div class="metric-visual">
              <div class="clock-visual">
                <i class="fas fa-exclamation-triangle"></i>
                <span class="clock-text">2h</span>
              </div>
            </div>
            <div class="metric-content">
              <h3>Ocorrência a cada 2 horas</h3>
              <p>Frequência alarmante de atos de vandalismo exige monitoramento contínuo</p>
              <span class="metric-impact">Impacto social crítico</span>
            </div>
          </div>

          <div class="challenge-metric">
            <div class="metric-visual">
              <div class="efficiency-meter">
                <div class="meter-fill" style="width: 25%"></div>
                <span class="meter-label">25%</span>
              </div>
            </div>
            <div class="metric-content">
              <h3>Ineficácia Tradicional</h3>
              <p>Sistemas 156 e 190 capturam apenas informações parciais e imprecisas</p>
              <span class="metric-problem">Dados não confiáveis</span>
            </div>
          </div>
        </div>

        <div class="challenge-impact">
          <div class="impact-content">
            <h3>O Custo da Inação</h3>
            <p>Sem ferramentas adequadas, gestores públicos tomam decisões baseadas em informações incompletas, perpetuando ciclos de insegurança urbana.</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Solution Section -->
    <section id="solucao" class="solution-section">
      <div class="container">
        <div class="section-header">
          <span class="section-badge">Nossa Solução</span>
          <h2>Tecnologia que <span class="gradient-text">Transforma</span></h2>
          <p>Sistema integrado de captura, processamento e análise de dados urbanos em tempo real</p>
        </div>

        <div class="solution-showcase">
          <div class="solution-feature main-feature">
            <div class="feature-visual">
              <div class="video-frame">
                <div class="video-controls">
                  <div class="recording-indicator">
                    <span class="rec-dot"></span>
                    <span>REC 00:07</span>
                  </div>
                </div>
                <div class="video-overlay">
                  <div class="metadata-panel">
                    <div class="geo-data">
                      <i class="fas fa-crosshairs"></i>
                      <span>GPS: -19.9167, -43.9345</span>
                    </div>
                    <div class="audio-data">
                      <i class="fas fa-microphone"></i>
                      <span>82.4 dB</span>
                    </div>
                    <div class="time-data">
                      <i class="fas fa-clock"></i>
                      <span>2024-01-15 14:23:47</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="feature-content">
              <h3>Evidência Digital Irrefutável</h3>
              <p>Vídeos de 7 segundos com metadados criptográficos incluindo geolocalização precisa, medição sonora e timestamp automático.</p>
              <div class="feature-benefits">
                <div class="benefit">
                  <i class="fas fa-lock"></i>
                  <span>Não editável</span>
                </div>
                <div class="benefit">
                  <i class="fas fa-satellite"></i>
                  <span>Georreferenciado</span>
                </div>
                <div class="benefit">
                  <i class="fas fa-certificate"></i>
                  <span>Certificado digital</span>
                </div>
              </div>
            </div>
          </div>

          <div class="solution-features-grid">
            <div class="solution-feature">
              <div class="feature-icon">
                <i class="fas fa-broadcast-tower"></i>
              </div>
              <h4>Transmissão Live</h4>
              <p>Streaming em tempo real para centrais de comando durante emergências críticas</p>
            </div>

            <div class="solution-feature">
              <div class="feature-icon">
                <i class="fas fa-chart-line"></i>
              </div>
              <h4>Analytics Avançado</h4>
              <p>Processamento inteligente de dados para identificação de padrões e tendências</p>
            </div>

            <div class="solution-feature">
              <div class="feature-icon">
                <i class="fas fa-shield-alt"></i>
              </div>
              <h4>Segurança Total</h4>
              <p>Criptografia end-to-end e blockchain para garantir integridade dos dados</p>
            </div>

            <div class="solution-feature">
              <div class="feature-icon">
                <i class="fas fa-network-wired"></i>
              </div>
              <h4>Integração Completa</h4>
              <p>API robusta para integração com sistemas existentes de segurança pública</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Technology Section -->
    <section id="tecnologia" class="tech-section">
      <div class="container">
        <div class="section-header">
          <span class="section-badge">Tecnologia</span>
          <h2>Arquitetura <span class="gradient-text">Enterprise</span></h2>
          <p>Infraestrutura escalável e segura para atender demandas municipais e estaduais</p>
        </div>

        <div class="tech-architecture">
          <div class="arch-layer">
            <div class="layer-header">
              <h3>Camada de Captura</h3>
              <span class="layer-badge">Mobile & IoT</span>
            </div>
            <div class="layer-components">
              <div class="component">
                <i class="fas fa-mobile-alt"></i>
                <span>Apps Nativos</span>
              </div>
              <div class="component">
                <i class="fas fa-camera"></i>
                <span>Sensores Integrados</span>
              </div>
              <div class="component">
                <i class="fas fa-microchip"></i>
                <span>Edge Computing</span>
              </div>
            </div>
          </div>

          <div class="arch-layer">
            <div class="layer-header">
              <h3>Camada de Processamento</h3>
              <span class="layer-badge">Cloud Native</span>
            </div>
            <div class="layer-components">
              <div class="component">
                <i class="fas fa-server"></i>
                <span>Microserviços</span>
              </div>
              <div class="component">
                <i class="fas fa-brain"></i>
                <span>IA & Machine Learning</span>
              </div>
              <div class="component">
                <i class="fas fa-database"></i>
                <span>Big Data Analytics</span>
              </div>
            </div>
          </div>

          <div class="arch-layer">
            <div class="layer-header">
              <h3>Camada de Gestão</h3>
              <span class="layer-badge">Executive Dashboard</span>
            </div>
            <div class="layer-components">
              <div class="component">
                <i class="fas fa-chart-pie"></i>
                <span>Business Intelligence</span>
              </div>
              <div class="component">
                <i class="fas fa-map"></i>
                <span>GIS Avançado</span>
              </div>
              <div class="component">
                <i class="fas fa-bell"></i>
                <span>Alertas Inteligentes</span>
              </div>
            </div>
          </div>
        </div>

        <div class="tech-specs">
          <div class="spec-item">
            <h4>Performance</h4>
            <ul>
              <li>Processamento em tempo real (<200ms)</li>
              <li>Escalabilidade horizontal automática</li>
              <li>99.9% de disponibilidade garantida</li>
            </ul>
          </div>
          <div class="spec-item">
            <h4>Segurança</h4>
            <ul>
              <li>Certificação ISO 27001</li>
              <li>Compliance LGPD total</li>
              <li>Auditoria blockchain</li>
            </ul>
          </div>
          <div class="spec-item">
            <h4>Integração</h4>
            <ul>
              <li>APIs RESTful documentadas</li>
              <li>SDK multiplataforma</li>
              <li>Conectores para sistemas legacy</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- Contact Section -->
    <section id="contato" class="contact-section">
      <div class="container">
        <div class="contact-content">
          <div class="contact-info">
            <span class="section-badge">Entre em Contato</span>
            <h2>City 4C - Em Desenvolvimento</h2>
            <p class="contact-description">
              Projeto em fase de desenvolvimento. Entre em contato para mais informações 
              sobre o City 4C e acompanhar o progresso da plataforma.
            </p>
            
            <div class="contact-benefits">
              <div class="benefit-item">
                <i class="fas fa-cogs"></i>
                <div>
                  <h4>Projeto em Desenvolvimento</h4>
                  <p>Tecnologia inovadora sendo aprimorada pela equipe</p>
                </div>
              </div>
              <div class="benefit-item">
                <i class="fas fa-lightbulb"></i>
                <div>
                  <h4>Conceito Inovador</h4>
                  <p>Solução única para segurança urbana inteligente</p>
                </div>
              </div>
              <div class="benefit-item">
                <i class="fas fa-envelope"></i>
                <div>
                  <h4>Informações</h4>
                  <p>Entre em contato para acompanhar o desenvolvimento</p>
                </div>
              </div>
            </div>

            <div class="contact-direct">
              <div class="contact-method">
                <i class="fas fa-phone"></i>
                <div>
                  <span class="method-label">Informações</span>
                  <span class="method-value">31 99377-1247</span>
                </div>
              </div>
              <div class="contact-method">
                <i class="fas fa-envelope"></i>
                <div>
                  <span class="method-label">E-mail</span>
                  <span class="method-value">gavetadothiago@gmail.com</span>
                </div>
              </div>
            </div>
          </div>

          <div class="contact-form-container">
            <form class="contact-form" @submit.prevent="submitForm">
              <h3>Interesse no Projeto</h3>
              
              <div class="form-row">
                <div class="form-group">
                  <label>Nome Completo *</label>
                  <input type="text" v-model="form.name" required>
                </div>
                <div class="form-group">
                  <label>Cargo *</label>
                  <input type="text" v-model="form.position" required>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group">
                  <label>E-mail Corporativo *</label>
                  <input type="email" v-model="form.email" required>
                </div>
                <div class="form-group">
                  <label>Telefone *</label>
                  <input type="tel" v-model="form.phone" required>
                </div>
              </div>

              <div class="form-group">
                <label>Organização *</label>
                <input type="text" v-model="form.organization" placeholder="Prefeitura, Estado, Órgão de Segurança..." required>
              </div>

              <div class="form-group">
                <label>Tipo de Interesse</label>
                <select v-model="form.interestType" required>
                  <option value="">Selecione...</option>
                  <option value="informacoes">Informações sobre o Projeto</option>
                  <option value="acompanhar">Acompanhar Desenvolvimento</option>
                  <option value="parceria">Interesse em Parceria</option>
                  <option value="investimento">Interesse em Investimento</option>
                </select>
              </div>

              <div class="form-group">
                <label>Mensagem</label>
                <textarea v-model="form.message" rows="4" placeholder="Deixe sua mensagem ou dúvidas sobre o projeto..."></textarea>
              </div>

              <button type="submit" class="btn btn-primary full-width" :disabled="isSubmitting">
                <i class="fas fa-paper-plane"></i>
                {{ isSubmitting ? 'Enviando...' : 'Enviar Mensagem' }}
              </button>
            </form>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
      <div class="container">
        <div class="footer-content">
          <div class="footer-brand">
            <div class="logo">
              <div class="logo-symbol">
                <span class="logo-number">4C</span>
              </div>
              <div class="logo-text">
                <span class="brand-name">CITY</span>
                <span class="brand-tagline">URBAN INTELLIGENCE</span>
              </div>
            </div>
            <p class="footer-description">
              Transformando dados urbanos em inteligência estratégica para cidades mais seguras e eficientes.
            </p>
          </div>
          
          <div class="footer-info">
            <div class="footer-section">
              <h4>Tecnologia</h4>
              <ul>
                <li>Plataforma Cloud</li>
                <li>Mobile Apps</li>
                <li>APIs & Integrações</li>
                <li>Analytics IA</li>
              </ul>
            </div>
            <div class="footer-section">
              <h4>Segurança</h4>
              <ul>
                <li>ISO 27001</li>
                <li>LGPD Compliant</li>
                <li>Blockchain</li>
                <li>Criptografia E2E</li>
              </ul>
            </div>
            <div class="footer-section">
              <h4>Suporte</h4>
              <ul>
                <li>Implementação</li>
                <li>Treinamento</li>
                <li>Suporte 24/7</li>
                <li>Manutenção</li>
              </ul>
            </div>
          </div>
        </div>
        
        <div class="footer-bottom">
          <p>&copy; 2024 City 4C Urban Intelligence. Todos os direitos reservados.</p>
          <div class="footer-badges">
            <span class="badge">Enterprise Ready</span>
            <span class="badge">ISO Certified</span>
            <span class="badge">LGPD Compliant</span>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

// Reactive data
const mobileMenuOpen = ref(false)
const isSubmitting = ref(false)
const form = ref({
  name: '',
  position: '',
  email: '',
  phone: '',
  organization: '',
  interestType: '',
  message: ''
})

// Methods
const toggleMobileMenu = () => {
  mobileMenuOpen.value = !mobileMenuOpen.value
}

const scrollTo = (elementId: string) => {
  const element = document.getElementById(elementId)
  if (element) {
    const offsetTop = element.offsetTop - 70
    window.scrollTo({
      top: offsetTop,
      behavior: 'smooth'
    })
  }
  mobileMenuOpen.value = false
}

const submitForm = async () => {
  isSubmitting.value = true
  
  // Simulate form submission
  setTimeout(() => {
    isSubmitting.value = false
    alert('Mensagem enviada com sucesso!')
    
    // Reset form
    form.value = {
      name: '',
      position: '',
      email: '',
      phone: '',
      organization: '',
      interestType: '',
      message: ''
    }
  }, 2000)
}

const handleScroll = () => {
  const navbar = document.querySelector('.navbar') as HTMLElement
  if (navbar) {
    if (window.scrollY > 50) {
      navbar.style.backgroundColor = 'rgba(44, 44, 44, 0.95)'
    } else {
      navbar.style.backgroundColor = 'rgba(44, 44, 44, 0.95)'
    }
  }
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>

<style scoped>
/* Import vitrine styles - will be created next */
@import '@/assets/vitrine.css';
</style>