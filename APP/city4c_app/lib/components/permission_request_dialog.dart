import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';

class PermissionRequestDialog extends StatefulWidget {
  final String permissionType;
  final String description;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const PermissionRequestDialog({
    super.key,
    required this.permissionType,
    required this.description,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  @override
  State<PermissionRequestDialog> createState() => _PermissionRequestDialogState();
}

class _PermissionRequestDialogState extends State<PermissionRequestDialog> {
  bool _isRequesting = false;

  Future<void> _requestPermission() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      Permission permission;
      bool granted = false;

      switch (widget.permissionType.toLowerCase()) {
        case 'localização':
        case 'location':
          permission = Permission.location;
          break;
        case 'câmera':
        case 'camera':
          permission = Permission.camera;
          break;
        case 'microfone':
        case 'microphone':
          permission = Permission.microphone;
          break;
        default:
          permission = Permission.location;
      }

      var status = await permission.request();
      granted = status.isGranted;

      if (mounted) {
        Navigator.of(context).pop();
        
        if (granted) {
          widget.onPermissionGranted?.call();
          _showSuccessSnackBar();
        } else {
          widget.onPermissionDenied?.call();
          if (status.isPermanentlyDenied) {
            _showSettingsDialog();
          } else {
            _showDeniedSnackBar();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onPermissionDenied?.call();
        _showErrorSnackBar(e.toString());
      }
    }

    setState(() {
      _isRequesting = false;
    });
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Permissão de ${widget.permissionType} concedida!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeniedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Permissão de ${widget.permissionType} negada'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Erro: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showSettingsDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('🔒 Permissão de ${widget.permissionType}'),
          content: Text(
            'A permissão foi negada permanentemente.\n\n'
            'Para usar esta funcionalidade, você precisa habilitar a permissão nas configurações do dispositivo.',
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getPermissionIcon(),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Permissão de ${widget.permissionType}'),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.description),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta permissão é necessária para o funcionamento correto do app.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isRequesting ? null : () {
            Navigator.of(context).pop();
            widget.onPermissionDenied?.call();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isRequesting ? null : _requestPermission,
          child: _isRequesting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Permitir'),
        ),
      ],
    );
  }

  IconData _getPermissionIcon() {
    switch (widget.permissionType.toLowerCase()) {
      case 'localização':
      case 'location':
        return Icons.location_on;
      case 'câmera':
      case 'camera':
        return Icons.camera_alt;
      case 'microfone':
      case 'microphone':
        return Icons.mic;
      default:
        return Icons.security;
    }
  }
}

// Classe utilitária para facilitar o uso
class PermissionHelper {
  static Future<void> requestLocationPermission(
    BuildContext context, {
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionRequestDialog(
        permissionType: 'Localização',
        description: 'Para gravar vídeos com localização precisa, precisamos acessar sua localização atual.',
        onPermissionGranted: onGranted,
        onPermissionDenied: onDenied,
      ),
    );
  }

  static Future<void> requestCameraPermission(
    BuildContext context, {
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionRequestDialog(
        permissionType: 'Câmera',
        description: 'Para gravar vídeos, precisamos acessar sua câmera.',
        onPermissionGranted: onGranted,
        onPermissionDenied: onDenied,
      ),
    );
  }

  static Future<void> requestMicrophonePermission(
    BuildContext context, {
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionRequestDialog(
        permissionType: 'Microfone',
        description: 'Para gravar vídeos com áudio, precisamos acessar seu microfone.',
        onPermissionGranted: onGranted,
        onPermissionDenied: onDenied,
      ),
    );
  }
}