import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../config/supabase_config.dart';

class CameraService {
  static CameraService? _instance;
  static CameraService get instance => _instance ??= CameraService._();
  
  CameraService._();

  List<CameraDescription>? _cameras;
  CameraController? _controller;

  List<CameraDescription>? get cameras => _cameras;
  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        await _initializeController(_cameras!.first);
      }
    } catch (e) {
      throw Exception('Erro ao inicializar câmera: $e');
    }
  }

  Future<void> _initializeController(CameraDescription description) async {
    await dispose(); // Dispose previous controller if exists
    
    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    print('✅ Câmera inicializada: ${description.name}');
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final currentCamera = _controller!.description;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera != currentCamera,
      orElse: () => _cameras!.first,
    );

    await dispose();
    await _initializeController(newCamera);
  }

  Future<String> startVideoRecording() async {
    if (!isInitialized) {
      throw Exception('Câmera não inicializada');
    }

    if (_controller!.value.isRecordingVideo) {
      throw Exception('Gravação já em andamento');
    }

    try {
      print('🎬 Iniciando gravação de vídeo...');
      await _controller!.startVideoRecording();
      print('✅ Gravação iniciada com sucesso');
      
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      return filePath;
    } catch (e) {
      print('❌ Erro ao iniciar gravação: $e');
      throw Exception('Erro ao iniciar gravação: $e');
    }
  }

  Future<XFile> stopVideoRecording() async {
    if (!isInitialized) {
      throw Exception('Câmera não inicializada');
    }

    if (!_controller!.value.isRecordingVideo) {
      throw Exception('Gravação não está em andamento');
    }

    try {
      print('🛑 Parando gravação de vídeo...');
      final video = await _controller!.stopVideoRecording();
      print('✅ Gravação parada com sucesso: ${video.path}');
      return video;
    } catch (e) {
      print('❌ Erro ao parar gravação: $e');
      throw Exception('Erro ao parar gravação: $e');
    }
  }

  Future<void> dispose() async {
    try {
      if (_controller != null) {
        if (_controller!.value.isRecordingVideo) {
          print('⚠️ Parando gravação antes de dispose...');
          await _controller!.stopVideoRecording();
        }
        print('🗑️ Disposing câmera...');
        await _controller!.dispose();
        _controller = null;
        print('✅ Câmera disposed');
      }
    } catch (e) {
      print('❌ Erro ao fazer dispose da câmera: $e');
      _controller = null;
    }
  }

  bool get isRecording => _controller?.value.isRecordingVideo ?? false;

  static bool isValidVideoDuration(Duration duration) {
    return duration.inSeconds <= SupabaseConfig.maxVideoDurationSeconds;
  }

  static String generateVideoFileName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'video_$timestamp.mp4';
  }

  /// Gets video file size in bytes
  static Future<int> getVideoFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      print('❌ Erro ao obter tamanho do arquivo: $e');
      return 0;
    }
  }
}