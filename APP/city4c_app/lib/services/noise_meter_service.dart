import 'dart:async';
import 'dart:math';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class NoiseMeterService {
  static final NoiseMeterService _instance = NoiseMeterService._internal();
  factory NoiseMeterService() => _instance;
  NoiseMeterService._internal();

  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  StreamController<double>? _decibelController;
  
  bool _isListening = false;
  double _currentDecibel = 0.0;
  double _maxDecibel = 0.0;
  double _avgDecibel = 0.0;
  List<double> _decibelReadings = [];
  Timer? _avgTimer;

  // Getters
  bool get isListening => _isListening;
  double get currentDecibel => _currentDecibel;
  double get maxDecibel => _maxDecibel;
  double get avgDecibel => _avgDecibel;
  
  Stream<double>? get decibelStream => _decibelController?.stream;

  Future<bool> initialize() async {
    try {
      print('🎤 Inicializando medidor de ruído...');
      
      // Check microphone permission
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        print('❌ Permissão de microfone não concedida');
        return false;
      }

      _noiseMeter = NoiseMeter();
      _decibelController = StreamController<double>.broadcast();
      
      print('✅ Medidor de ruído inicializado');
      return true;
    } catch (e) {
      print('❌ Erro ao inicializar medidor de ruído: $e');
      return false;
    }
  }

  Future<void> startListening() async {
    if (_isListening || _noiseMeter == null) return;

    try {
      print('🎧 Iniciando medição de ruído...');
      
      _isListening = true;
      _currentDecibel = 0.0;
      _maxDecibel = 0.0;
      _avgDecibel = 0.0;
      _decibelReadings.clear();

      _noiseSubscription = _noiseMeter!.noise.listen(
        (NoiseReading noiseReading) {
          _updateDecibelReading(noiseReading.meanDecibel);
        },
        onError: (error) {
          print('❌ Erro na leitura de ruído: $error');
        },
      );

      // Timer para calcular média a cada segundo
      _avgTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _calculateAverage();
      });

      print('✅ Medição de ruído iniciada');
    } catch (e) {
      print('❌ Erro ao iniciar medição: $e');
      _isListening = false;
    }
  }

  void _updateDecibelReading(double decibel) {
    // Filtrar leituras muito baixas ou muito altas (possíveis erros)
    if (decibel < 20 || decibel > 130) return;

    _currentDecibel = decibel;
    
    // Atualizar máximo
    if (decibel > _maxDecibel) {
      _maxDecibel = decibel;
    }

    // Adicionar à lista para cálculo de média
    _decibelReadings.add(decibel);
    
    // Manter apenas os últimos 10 segundos de leituras (aprox 100 leituras)
    if (_decibelReadings.length > 100) {
      _decibelReadings.removeAt(0);
    }

    // Emitir valor atual
    _decibelController?.add(_currentDecibel);
  }

  void _calculateAverage() {
    if (_decibelReadings.isNotEmpty) {
      final sum = _decibelReadings.reduce((a, b) => a + b);
      _avgDecibel = sum / _decibelReadings.length;
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      print('🛑 Parando medição de ruído...');
      
      _isListening = false;
      await _noiseSubscription?.cancel();
      _noiseSubscription = null;
      _avgTimer?.cancel();
      _avgTimer = null;
      
      print('✅ Medição de ruído parada');
      print('📊 Estatísticas finais:');
      print('   - Atual: ${_currentDecibel.toStringAsFixed(1)} dB');
      print('   - Máximo: ${_maxDecibel.toStringAsFixed(1)} dB');
      print('   - Média: ${_avgDecibel.toStringAsFixed(1)} dB');
    } catch (e) {
      print('❌ Erro ao parar medição: $e');
    }
  }

  String getNoiseLevel() {
    if (_currentDecibel < 30) return 'Muito Silencioso';
    if (_currentDecibel < 50) return 'Silencioso';
    if (_currentDecibel < 60) return 'Moderado';
    if (_currentDecibel < 70) return 'Alto';
    if (_currentDecibel < 80) return 'Muito Alto';
    if (_currentDecibel < 90) return 'Extremamente Alto';
    return 'Perigoso';
  }

  String getNoiseDescription() {
    if (_currentDecibel < 30) return 'Biblioteca, quarto à noite';
    if (_currentDecibel < 50) return 'Casa silenciosa, escritório';
    if (_currentDecibel < 60) return 'Conversa normal, TV';
    if (_currentDecibel < 70) return 'Trânsito urbano, restaurante';
    if (_currentDecibel < 80) return 'Trânsito pesado, aspirador';
    if (_currentDecibel < 90) return 'Motocicleta, cortador de grama';
    return 'Martelete, show de rock';
  }

  Map<String, dynamic> getStatistics() {
    return {
      'current_db': _currentDecibel,
      'max_db': _maxDecibel,
      'avg_db': _avgDecibel,
      'noise_level': getNoiseLevel(),
      'description': getNoiseDescription(),
      'readings_count': _decibelReadings.length,
    };
  }

  void dispose() {
    print('🗑️ Liberando recursos do medidor de ruído...');
    stopListening();
    _decibelController?.close();
    _decibelController = null;
    _noiseMeter = null;
  }
}