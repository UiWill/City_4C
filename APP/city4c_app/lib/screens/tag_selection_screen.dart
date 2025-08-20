import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../models/tag.dart';
import '../services/supabase_service.dart';
import '../services/location_service.dart';
import '../services/camera_service.dart';
import '../main.dart';
import '../models/occurrence.dart';
import '../components/location_preview.dart';

class TagSelectionScreen extends StatefulWidget {
  final String videoPath;
  final bool isAgent;

  const TagSelectionScreen({
    super.key,
    required this.videoPath,
    required this.isAgent,
  });

  @override
  State<TagSelectionScreen> createState() => _TagSelectionScreenState();
}

class _TagSelectionScreenState extends State<TagSelectionScreen> with WidgetsBindingObserver {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<Tag> _tags = [];
  Tag? _selectedTag;
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoadingLocation = false;
  bool _isDisposed = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScreen();
  }

  @override
  void dispose() {
    print('🗑️ Disposing tag selection screen...');
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
    print('✅ Tag selection screen disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('📱 Tag screen lifecycle: $state');
  }

  Future<void> _initializeScreen() async {
    if (_hasInitialized || _isDisposed) return;
    
    try {
      print('🚀 Inicializando tela de seleção de tags...');
      _hasInitialized = true;
      
      // Verificar se o arquivo de vídeo existe
      final videoFile = File(widget.videoPath);
      if (!await videoFile.exists()) {
        throw Exception('Arquivo de vídeo não encontrado: ${widget.videoPath}');
      }
      
      final fileSize = await videoFile.length();
      print('📁 Arquivo de vídeo confirmado: ${fileSize} bytes');
      
      // Carregar dados em paralelo com delay para estabilidade
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!_isDisposed && mounted) {
        await Future.wait([
          _loadTags(),
          _getCurrentLocation(),
        ]);
      }
      
      print('✅ Tela inicializada com sucesso');
    } catch (e) {
      print('❌ Erro ao inicializar tela: $e');
      if (mounted && !_isDisposed) {
        _showError('Erro ao inicializar: $e');
      }
    }
  }

  Future<void> _loadTags() async {
    if (_isDisposed) return;
    
    try {
      print('🏷️ Carregando tags...');
      final tags = await SupabaseService.instance.getTags();
      
      if (!_isDisposed && mounted) {
        setState(() {
          _tags = tags;
        });
        print('✅ ${tags.length} tags carregadas');
      }
    } catch (e) {
      print('❌ Erro ao carregar tags: $e');
      if (!_isDisposed && mounted) {
        _showError('Erro ao carregar categorias: $e');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isDisposed) return;
    
    if (mounted) {
      setState(() {
        _isLoadingLocation = true;
      });
    }

    try {
      print('🌍 Solicitando localização com contexto...');
      final position = await LocationService.instance.getCurrentPosition(context: context);
      
      if (_isDisposed || !mounted) {
        print('⚠️ Widget disposed durante obtenção de localização');
        return;
      }
      
      print('📍 Localização obtida, buscando endereço...');
      final address = await LocationService.instance.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!_isDisposed && mounted) {
        setState(() {
          _currentPosition = position;
          _currentAddress = address;
          _isLoadingLocation = false;
        });
        
        print('✅ Localização completa: ${position.latitude}, ${position.longitude}');
      }
    } catch (e) {
      print('❌ Erro na localização: $e');
      
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        _showError('Erro ao obter localização: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Relato'),
        actions: [
          TextButton(
            onPressed: appState.isLoading ? null : _submitReport,
            child: appState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('ENVIAR'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video preview card
            _buildVideoPreviewCard(),

            const SizedBox(height: 16),

            // Location preview
            if (_currentPosition != null)
              LocationPreview(
                position: _currentPosition!,
                address: _currentAddress,
              )
            else
              _buildLocationCard(),

            const SizedBox(height: 16),

            // Category selection
            _buildCategorySelection(),

            const SizedBox(height: 16),

            // Title input (optional)
            _buildTitleInput(),

            const SizedBox(height: 16),

            // Description input (optional)
            _buildDescriptionInput(),

            const SizedBox(height: 32),

            // Submit button
            _buildSubmitButton(appState),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.videocam,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Vídeo Gravado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Arquivo: ${widget.videoPath.split('/').last}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Localização',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingLocation)
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Obtendo localização...'),
                ],
              )
            else if (_currentPosition != null) ...[
              Text(
                'Coordenadas: ${LocationService.formatCoordinates(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                )}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (_currentAddress != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Endereço: $_currentAddress',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Precisão: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ] else
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Erro ao obter localização')),
                  TextButton(
                    onPressed: _getCurrentLocation,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categoria da Ocorrência *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_tags.isEmpty)
              const Text('Carregando categorias...')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) => _buildTagChip(tag)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(Tag tag) {
    final isSelected = _selectedTag?.id == tag.id;
    final color = Color(int.parse(tag.color.substring(1, 7), radix: 16) + 0xFF000000);

    return FilterChip(
      label: Text(tag.name),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTag = selected ? tag : null;
        });
      },
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTitleInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título (Opcional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              maxLines: 1,
              maxLength: 100,
              decoration: const InputDecoration(
                hintText: 'Ex: Buraco na rua principal',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descrição Adicional (Opcional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Descreva detalhes adicionais sobre a ocorrência...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppState appState) {
    final canSubmit = _selectedTag != null && 
                     _currentPosition != null && 
                     !appState.isLoading;

    return ElevatedButton(
      onPressed: canSubmit ? _submitReport : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: appState.isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Enviando...'),
              ],
            )
          : const Text(
              'ENVIAR RELATO',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Future<void> _submitReport() async {
    if (_isDisposed || !mounted) return;
    
    if (_selectedTag == null || _currentPosition == null) {
      _showError('Selecione uma categoria e aguarde a localização');
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    
    try {
      print('📤 Iniciando envio do relato...');
      appState.setLoading(true);

      // Verificar novamente se o arquivo existe
      final videoFile = File(widget.videoPath);
      if (!await videoFile.exists()) {
        throw Exception('Arquivo de vídeo não encontrado');
      }

      final fileSize = await videoFile.length();
      if (fileSize == 0) {
        throw Exception('Arquivo de vídeo vazio');
      }

      print('📁 Arquivo válido: ${fileSize} bytes');

      // Upload video
      print('☁️ Fazendo upload do vídeo...');
      final fileName = CameraService.generateVideoFileName();
      final videoUrl = await SupabaseService.instance.uploadVideo(
        widget.videoPath,
        fileName,
      );

      if (_isDisposed || !mounted) {
        print('⚠️ Widget disposed durante upload');
        return;
      }

      print('✅ Upload concluído: $videoUrl');

      // Create occurrence
      print('📝 Criando ocorrência...');
      final occurrenceId = await SupabaseService.instance.createOccurrence(
        title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        videoUrl: videoUrl,
        videoFilename: fileName,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        locationAccuracy: _currentPosition!.accuracy,
        address: _currentAddress,
        tagId: _selectedTag!.id,
        reportedBy: widget.isAgent ? SupabaseService.instance.currentUser?.id : null,
        reporterType: widget.isAgent ? ReporterType.agent : ReporterType.citizen,
        metadata: {
          'device_info': {
            'platform': Platform.operatingSystem,
          },
          'app_version': '1.0.0',
          'submission_timestamp': DateTime.now().toIso8601String(),
        },
      );

      print('✅ Ocorrência criada: $occurrenceId');

      // Delete video file from device
      try {
        if (await videoFile.exists()) {
          await videoFile.delete();
          print('🗑️ Arquivo local deletado');
        }
      } catch (e) {
        print('⚠️ Erro ao deletar arquivo local: $e');
        // Não é crítico, continua
      }

      if (_isDisposed || !mounted) {
        print('⚠️ Widget disposed após criação de ocorrência');
        return;
      }

      appState.setLoading(false);
      print('🎉 Relato enviado com sucesso!');
      _showSuccessDialog(occurrenceId);

    } catch (e) {
      print('❌ Erro ao enviar relato: $e');
      
      if (!_isDisposed && mounted) {
        appState.setLoading(false);
        _showError('Erro ao enviar relato: $e');
      }
    }
  }

  void _showSuccessDialog(String occurrenceId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Relato Enviado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seu relato foi enviado com sucesso para a prefeitura.'),
            const SizedBox(height: 8),
            Text(
              'ID: ${occurrenceId.substring(0, 8)}...',
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('VOLTAR AO INÍCIO'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}