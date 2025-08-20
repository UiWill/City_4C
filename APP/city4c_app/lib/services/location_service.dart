import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../config/supabase_config.dart';
import '../components/permission_request_dialog.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  
  LocationService._();

  Future<bool> checkPermissions() async {
    try {
      print('🔍 Verificando permissões de localização...');
      
      // 1. Verificar se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Serviço de localização desabilitado');
        throw Exception('Serviço de localização desabilitado. Habilite nas configurações do dispositivo.');
      }
      
      // 2. Verificar permissão usando permission_handler
      var status = await Permission.location.status;
      print('📍 Status atual da permissão: $status');
      
      if (status.isPermanentlyDenied) {
        print('❌ Permissão negada permanentemente');
        throw Exception('Permissão de localização negada permanentemente. Habilite nas configurações do app.');
      }
      
      if (status.isDenied) {
        print('⚠️ Permissão negada, solicitando novamente...');
        status = await Permission.location.request();
        print('📍 Novo status após solicitação: $status');
        
        if (status.isDenied) {
          throw Exception('Permissão de localização negada pelo usuário');
        }
        
        if (status.isPermanentlyDenied) {
          throw Exception('Permissão de localização negada permanentemente. Habilite nas configurações do app.');
        }
      }

      // 3. Verificar também com geolocator para compatibilidade
      LocationPermission geoPermission = await Geolocator.checkPermission();
      print('🌍 Permissão geolocator: $geoPermission');
      
      bool hasPermission = status.isGranted && 
                          (geoPermission == LocationPermission.whileInUse || 
                           geoPermission == LocationPermission.always);
      
      print('✅ Permissão de localização: ${hasPermission ? "CONCEDIDA" : "NEGADA"}');
      return hasPermission;
      
    } catch (e) {
      print('❌ Erro ao verificar permissões de localização: $e');
      rethrow;
    }
  }

  Future<Position> getCurrentPosition({BuildContext? context}) async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        if (context != null) {
          // Se temos contexto, mostra diálogo para solicitar permissão
          await _requestLocationPermissionInContext(context);
          // Verifica novamente após o diálogo
          final hasPermissionAfter = await checkPermissions();
          if (!hasPermissionAfter) {
            throw Exception('Permissão de localização é necessária para continuar');
          }
        } else {
          throw Exception('Permissão de localização negada');
        }
      }

      print('🌍 Obtendo posição atual...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      print('📍 Posição obtida: ${position.latitude}, ${position.longitude} (precisão: ${position.accuracy.toStringAsFixed(1)}m)');

      if (position.accuracy > SupabaseConfig.minLocationAccuracy) {
        print('⚠️ Precisão insuficiente: ${position.accuracy.toStringAsFixed(1)}m > ${SupabaseConfig.minLocationAccuracy}m');
        throw Exception('Precisão da localização insuficiente: ${position.accuracy.toStringAsFixed(1)}m');
      }

      return position;
    } catch (e) {
      print('❌ Erro ao obter localização: $e');
      throw Exception('Erro ao obter localização: $e');
    }
  }

  Future<void> _requestLocationPermissionInContext(BuildContext context) async {
    await PermissionHelper.requestLocationPermission(
      context,
      onGranted: () {
        print('✅ Permissão de localização concedida via diálogo');
      },
      onDenied: () {
        print('❌ Permissão de localização negada via diálogo');
      },
    );
  }

  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street ?? ''}, ${placemark.subLocality ?? ''}, ${placemark.locality ?? ''} - ${placemark.administrativeArea ?? ''}';
      }
    } catch (e) {
      // Silently fail - address is optional
    }
    return null;
  }

  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  static double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}