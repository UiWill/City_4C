import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';
import '../services/supabase_service.dart';
import '../config/supabase_config.dart';
import '../main.dart';
import 'tag_selection_screen.dart';

class CameraScreen extends StatefulWidget {
  final bool isAgent;

  const CameraScreen({super.key, required this.isAgent});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService.instance;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  bool _isRecording = false;
  String? _videoPath;
  bool _isDisposed = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      setState(() {});
    } catch (e) {
      _showError('Erro ao inicializar câmera: $e');
    }
  }

  @override
  void dispose() {
    print('🗑️ Disposing camera screen...');
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _recordingTimer?.cancel();
    
    // Não dispose o camera service aqui se estivermos navegando
    if (!_isNavigating) {
      _cameraService.dispose();
    }
    
    super.dispose();
    print('✅ Camera screen disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('📱 App lifecycle changed: $state');
    
    switch (state) {
      case AppLifecycleState.paused:
        if (_isRecording) {
          print('⚠️ App pausado durante gravação, parando...');
          _stopRecording();
        }
        break;
      case AppLifecycleState.resumed:
        print('▶️ App resumido');
        break;
      case AppLifecycleState.detached:
        print('💀 App detached');
        break;
      case AppLifecycleState.inactive:
        print('😴 App inativo');
        break;
      case AppLifecycleState.hidden:
        print('🙈 App hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.isAgent ? 'Relato Agente' : 'Relato Cidadão',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (_cameraService.cameras != null && _cameraService.cameras!.length > 1)
            IconButton(
              onPressed: _switchCamera,
              icon: const Icon(Icons.flip_camera_ios),
            ),
        ],
      ),
      body: appState.isLoading
        ? const Center(child: CircularProgressIndicator())
        : _buildCameraPreview(),
      bottomNavigationBar: _buildControlsBar(appState),
    );
  }

  Widget _buildCameraPreview() {
    if (!_cameraService.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraService.controller!),
        
        // Recording timer overlay
        if (_isRecording)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.fiber_manual_record,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_recordingSeconds}s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Recording guide
        if (!_isRecording)
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Toque para iniciar gravação (máximo ${SupabaseConfig.maxVideoDurationSeconds}s)',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        
        // Recording instructions
        if (_isRecording)
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Gravando... Toque no botão vermelho para parar',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildControlsBar(AppState appState) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button (placeholder)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.photo_library,
              color: Colors.white,
            ),
          ),

          // Record button
          GestureDetector(
            onTap: _toggleRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isRecording ? Colors.red : Colors.white,
                  width: _isRecording ? 0 : 4,
                ),
                boxShadow: [
                  if (_isRecording)
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: _isRecording
                ? const Icon(
                    Icons.stop,
                    color: Colors.white,
                    size: 32,
                  )
                : const Icon(
                    Icons.videocam,
                    color: Colors.red,
                    size: 32,
                  ),
            ),
          ),

          // Switch camera button
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _switchCamera,
              icon: const Icon(
                Icons.flip_camera_ios,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() async {
    if (_isRecording || !_cameraService.isInitialized) return;

    try {
      print('🎥 Iniciando gravação...');
      await _cameraService.startVideoRecording();
      
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      print('⏱️ Timer de gravação iniciado');
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && _isRecording) {
          setState(() {
            _recordingSeconds++;
          });

          print('⏱️ Gravando: ${_recordingSeconds}s');

          if (_recordingSeconds >= SupabaseConfig.maxVideoDurationSeconds) {
            print('⏰ Tempo máximo atingido, parando gravação');
            _stopRecording();
          }
        } else {
          timer.cancel();
        }
      });
    } catch (e) {
      print('❌ Erro ao iniciar gravação: $e');
      _showError('Erro ao iniciar gravação: $e');
    }
  }

  void _stopRecording() async {
    if (!_isRecording || _isDisposed || _isNavigating) return;

    try {
      print('🛑 Parando gravação...');
      
      // Para o timer primeiro
      _recordingTimer?.cancel();
      _recordingTimer = null;

      final video = await _cameraService.stopVideoRecording();

      if (_isDisposed || !mounted) {
        print('⚠️ Widget disposed durante stop recording');
        return;
      }

      setState(() {
        _isRecording = false;
        _videoPath = video.path;
      });

      print('✅ Gravação finalizada: ${video.path}');

      // Verificar se o vídeo foi gravado com sucesso
      final videoFile = File(video.path);
      if (await videoFile.exists()) {
        final fileSize = await videoFile.length();
        print('📁 Tamanho do arquivo: ${fileSize} bytes');
        
        if (fileSize > 0) {
          print('🚀 Navegando para seleção de tags...');
          await _navigateToTagSelection(video.path);
        } else {
          print('❌ Arquivo de vídeo vazio');
          _showError('Erro: vídeo não foi gravado corretamente');
        }
      } else {
        print('❌ Arquivo de vídeo não existe');
        _showError('Erro: arquivo de vídeo não encontrado');
      }
    } catch (e) {
      print('❌ Erro ao parar gravação: $e');
      
      if (mounted && !_isDisposed) {
        setState(() {
          _isRecording = false;
        });
      }
      
      _recordingTimer?.cancel();
      _recordingTimer = null;
      _showError('Erro ao parar gravação: $e');
    }
  }

  Future<void> _navigateToTagSelection(String videoPath) async {
    if (_isNavigating || _isDisposed || !mounted) return;

    try {
      _isNavigating = true;
      
      // Small delay to ensure UI is stable
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted || _isDisposed) {
        print('⚠️ Widget não mais disponível para navegação');
        return;
      }

      print('🎯 Iniciando navegação para TagSelectionScreen');
      
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TagSelectionScreen(
            videoPath: videoPath,
            isAgent: widget.isAgent,
          ),
        ),
      );
      
      print('✅ Navegação concluída');
    } catch (e) {
      print('❌ Erro durante navegação: $e');
      _isNavigating = false;
      if (mounted) {
        _showError('Erro ao navegar: $e');
      }
    }
  }

  void _switchCamera() async {
    try {
      await _cameraService.switchCamera();
      setState(() {});
    } catch (e) {
      _showError('Erro ao trocar câmera: $e');
    }
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