import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/supabase_service.dart';
import '../main.dart';

class NearbyOccurrencesScreen extends StatefulWidget {
  const NearbyOccurrencesScreen({super.key});

  @override
  State<NearbyOccurrencesScreen> createState() => _NearbyOccurrencesScreenState();
}

class _NearbyOccurrencesScreenState extends State<NearbyOccurrencesScreen> {
  final LocationService _locationService = LocationService.instance;
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  List<Map<String, dynamic>> _nearbyOccurrences = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _radiusKm = 1.0; // Raio padrão de 1km
  
  @override
  void initState() {
    super.initState();
    _loadNearbyOccurrences();
  }

  Future<void> _loadNearbyOccurrences() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📍 Buscando localização atual...');
      final position = await _locationService.getCurrentPosition();
      
      if (position != null) {
        print('📍 Localização encontrada: ${position.latitude}, ${position.longitude}');
        print('🔍 Buscando ocorrências em um raio de $_radiusKm km...');
        
        final occurrences = await _supabaseService.getNearbyOccurrences(
          position.latitude,
          position.longitude,
          _radiusKm,
        );
        
        setState(() {
          _nearbyOccurrences = occurrences;
          _isLoading = false;
        });
        
        print('✅ Encontradas ${occurrences.length} ocorrências próximas');
      } else {
        setState(() {
          _errorMessage = 'Não foi possível obter sua localização';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erro ao buscar ocorrências próximas: $e');
      setState(() {
        _errorMessage = 'Erro ao buscar ocorrências próximas: $e';
        _isLoading = false;
      });
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pendente';
      case 'in_progress':
        return 'Em Andamento';
      case 'resolved':
        return 'Resolvido';
      case 'rejected':
        return 'Rejeitado';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
      } else {
        return 'Agora mesmo';
      }
    } catch (e) {
      return 'Data inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ocorrências Próximas',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _loadNearbyOccurrences,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro de raio
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Raio de busca: ${_radiusKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _radiusKm,
                  min: 0.5,
                  max: 10.0,
                  divisions: 19,
                  label: '${_radiusKm.toStringAsFixed(1)} km',
                  onChanged: (value) {
                    setState(() {
                      _radiusKm = value;
                    });
                  },
                  onChangeEnd: (value) {
                    _loadNearbyOccurrences();
                  },
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Buscando ocorrências próximas...'),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadNearbyOccurrences,
                                child: const Text('Tentar Novamente'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _nearbyOccurrences.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_searching,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Nenhuma ocorrência encontrada',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Não há ocorrências em um raio de ${_radiusKm.toStringAsFixed(1)}km da sua localização.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _radiusKm = 5.0;
                                      });
                                      _loadNearbyOccurrences();
                                    },
                                    child: const Text('Expandir para 5km'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _nearbyOccurrences.length,
                            itemBuilder: (context, index) {
                              final occurrence = _nearbyOccurrences[index];
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header com status e distância
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(occurrence['status']).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: _getStatusColor(occurrence['status']),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              _getStatusLabel(occurrence['status']),
                                              style: TextStyle(
                                                color: _getStatusColor(occurrence['status']),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color: Colors.blue[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${occurrence['distance_km']}km',
                                                  style: TextStyle(
                                                    color: Colors.blue[600],
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 12),
                                      
                                      // Título
                                      Text(
                                        occurrence['title'] ?? 'Ocorrência sem título',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      
                                      if (occurrence['description'] != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          occurrence['description'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                      
                                      const SizedBox(height: 12),
                                      
                                      // Footer com categoria e data
                                      Row(
                                        children: [
                                          if (occurrence['tag_name'] != null) ...[
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                occurrence['tag_name'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Text(
                                            _formatDate(occurrence['created_at']),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}