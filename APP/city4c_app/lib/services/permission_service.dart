import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PermissionService {
  static PermissionService? _instance;
  static PermissionService get instance => _instance ??= PermissionService._();
  
  PermissionService._();

  Future<bool> requestAllPermissions(BuildContext context) async {
    try {
      print('🔐 Iniciando solicitação de permissões...');
      
      // 1. Verificar e solicitar permissão de localização
      final locationGranted = await _requestLocationPermission(context);
      print('📍 Localização: ${locationGranted ? "✅" : "❌"}');
      
      // 2. Verificar e solicitar permissão de câmera
      final cameraGranted = await _requestCameraPermission(context);
      print('📷 Câmera: ${cameraGranted ? "✅" : "❌"}');
      
      // 3. Verificar e solicitar permissão de microfone
      final microphoneGranted = await _requestMicrophonePermission(context);
      print('🎤 Microfone: ${microphoneGranted ? "✅" : "❌"}');
      
      final allGranted = locationGranted && cameraGranted && microphoneGranted;
      print('🎯 Todas as permissões: ${allGranted ? "✅ CONCEDIDAS" : "❌ NEGADAS"}');
      
      return allGranted;
    } catch (e) {
      print('❌ Erro ao solicitar permissões: $e');
      return false;
    }
  }

  Future<bool> _requestLocationPermission(BuildContext context) async {
    try {
      // Verificar se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Serviço de localização desabilitado');
        if (context.mounted) {
          await _showLocationServiceDialog(context);
        }
        return false;
      }

      // Verificar permissão atual
      var status = await Permission.location.status;
      print('📍 Status atual da localização: $status');

      // Se negada, solicitar
      if (status.isDenied) {
        status = await Permission.location.request();
        print('📍 Novo status após solicitação: $status');
      }

      // Se ainda negada, tentar permissão precisa
      if (status.isDenied) {
        status = await Permission.locationWhenInUse.request();
        print('📍 Status locationWhenInUse: $status');
      }

      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          await _showPermissionDeniedDialog(context, 'Localização');
        }
        return false;
      }

      return status.isGranted;
    } catch (e) {
      print('❌ Erro ao solicitar permissão de localização: $e');
      return false;
    }
  }

  Future<bool> _requestCameraPermission(BuildContext context) async {
    try {
      var status = await Permission.camera.status;
      print('📷 Status atual da câmera: $status');

      if (status.isDenied) {
        status = await Permission.camera.request();
        print('📷 Novo status após solicitação: $status');
      }

      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          await _showPermissionDeniedDialog(context, 'Câmera');
        }
        return false;
      }

      return status.isGranted;
    } catch (e) {
      print('❌ Erro ao solicitar permissão de câmera: $e');
      return false;
    }
  }

  Future<bool> _requestMicrophonePermission(BuildContext context) async {
    try {
      var status = await Permission.microphone.status;
      print('🎤 Status atual do microfone: $status');

      if (status.isDenied) {
        status = await Permission.microphone.request();
        print('🎤 Novo status após solicitação: $status');
      }

      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          await _showPermissionDeniedDialog(context, 'Microfone');
        }
        return false;
      }

      return status.isGranted;
    } catch (e) {
      print('❌ Erro ao solicitar permissão de microfone: $e');
      return false;
    }
  }

  Future<void> _showLocationServiceDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('📍 Serviço de Localização'),
          content: const Text(
            'O serviço de localização está desabilitado.\n\n'
            'É necessário habilitar para gravar vídeos com localização precisa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: const Text('Abrir Configurações'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionDeniedDialog(BuildContext context, String permission) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('🚫 Permissão de $permission'),
          content: Text(
            'A permissão de $permission foi negada permanentemente.\n\n'
            'Para usar esta funcionalidade, é necessário habilitar nas configurações do dispositivo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Abrir Configurações'),
            ),
          ],
        );
      },
    );
  }

  // Métodos de verificação
  Future<bool> checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      var status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      print('❌ Erro ao verificar permissão de localização: $e');
      return false;
    }
  }

  Future<bool> checkCameraPermission() async {
    try {
      var status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      print('❌ Erro ao verificar permissão de câmera: $e');
      return false;
    }
  }

  Future<bool> checkMicrophonePermission() async {
    try {
      var status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      print('❌ Erro ao verificar permissão de microfone: $e');
      return false;
    }
  }

  // Método para solicitar novamente todas as permissões
  Future<void> requestPermissionsAgain(BuildContext context) async {
    await requestAllPermissions(context);
  }
}