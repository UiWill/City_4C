import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'login_screen.dart';
import 'nearby_occurrences_screen.dart';
import '../services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.videocam,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CITY 4C',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Relatos cidadãos para uma cidade melhor',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Instructions
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Como funciona',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInstructionItem('1. Grave um vídeo de até 7 segundos'),
                              _buildInstructionItem('2. Selecione a categoria da ocorrência'),
                              _buildInstructionItem('3. Sua localização será capturada automaticamente'),
                              _buildInstructionItem('4. Envie para a prefeitura'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Action buttons
                      _buildActionButton(
                        context,
                        title: 'Reportar Ocorrência',
                        subtitle: 'Grave um vídeo como cidadão',
                        icon: Icons.videocam,
                        onTap: () => _startRecording(context, isAgent: false),
                        isPrimary: true,
                      ),

                      const SizedBox(height: 16),

                      _buildActionButton(
                        context,
                        title: 'Ver Ocorrências Próximas',
                        subtitle: 'Veja o que já foi reportado na região',
                        icon: Icons.location_searching,
                        onTap: () => _navigateToNearbyOccurrences(context),
                        isPrimary: false,
                      ),

                      const SizedBox(height: 16),

                      _buildActionButton(
                        context,
                        title: 'Login como Agente',
                        subtitle: 'Acesso para funcionários públicos',
                        icon: Icons.badge,
                        onTap: () => _navigateToLogin(context),
                        isPrimary: false,
                      ),

                      const Spacer(),

                      // Footer
                      Text(
                        'Versão 1.0.0 - MVP',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Card(
      elevation: isPrimary ? 8 : 2,
      color: isPrimary ? Theme.of(context).colorScheme.primary : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary 
                    ? Colors.white.withOpacity(0.2)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isPrimary 
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isPrimary ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isPrimary 
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isPrimary 
                  ? Colors.white.withOpacity(0.8)
                  : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startRecording(BuildContext context, {required bool isAgent}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraScreen(isAgent: isAgent),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  void _navigateToNearbyOccurrences(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NearbyOccurrencesScreen(),
      ),
    );
  }
}