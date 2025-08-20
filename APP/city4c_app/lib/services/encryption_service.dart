import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static EncryptionService? _instance;
  static EncryptionService get instance => _instance ??= EncryptionService._();
  
  EncryptionService._();

  // Simple key derivation - in production, use proper key management
  static const String _secretKey = 'city4c_video_encryption_key_2024';

  /// Encrypts video file data before upload
  /// Note: This is basic encryption for MVP. Production should use AES with proper key management
  Future<Uint8List> encryptVideoData(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      // Generate a simple checksum for data integrity
      final checksum = sha256.convert(bytes).toString();
      
      // Create metadata object
      final metadata = {
        'checksum': checksum,
        'originalSize': bytes.length,
        'encryptedAt': DateTime.now().toIso8601String(),
        'version': '1.0'
      };
      
      // Convert metadata to bytes
      final metadataBytes = utf8.encode(json.encode(metadata));
      final metadataLength = metadataBytes.length;
      
      // Simple XOR encryption (for MVP demonstration)
      final encryptedBytes = _xorEncrypt(bytes, _secretKey);
      
      // Combine: [metadata_length(4 bytes)][metadata][encrypted_data]
      final result = BytesBuilder();
      result.add(_intToBytes(metadataLength));
      result.add(metadataBytes);
      result.add(encryptedBytes);
      
      return result.toBytes();
    } catch (e) {
      throw Exception('Erro ao criptografar dados do vídeo: $e');
    }
  }

  /// Decrypts video data (for server-side use)
  /// This method is for reference - actual decryption happens on server
  Map<String, dynamic> decryptVideoData(Uint8List encryptedData) {
    try {
      // Extract metadata length
      final metadataLength = _bytesToInt(encryptedData.sublist(0, 4));
      
      // Extract metadata
      final metadataBytes = encryptedData.sublist(4, 4 + metadataLength);
      final metadata = json.decode(utf8.decode(metadataBytes));
      
      // Extract and decrypt video data
      final encryptedVideoData = encryptedData.sublist(4 + metadataLength);
      final decryptedVideoData = _xorDecrypt(encryptedVideoData, _secretKey);
      
      // Verify checksum
      final computedChecksum = sha256.convert(decryptedVideoData).toString();
      if (computedChecksum != metadata['checksum']) {
        throw Exception('Checksum verification failed - data may be corrupted');
      }
      
      return {
        'videoData': decryptedVideoData,
        'metadata': metadata,
      };
    } catch (e) {
      throw Exception('Erro ao descriptografar dados: $e');
    }
  }

  /// Simple XOR encryption for MVP demonstration
  /// Note: XOR is not secure for production use - use AES instead
  Uint8List _xorEncrypt(Uint8List data, String key) {
    final keyBytes = utf8.encode(key);
    final encrypted = Uint8List(data.length);
    
    for (int i = 0; i < data.length; i++) {
      encrypted[i] = data[i] ^ keyBytes[i % keyBytes.length];
    }
    
    return encrypted;
  }

  /// Simple XOR decryption
  Uint8List _xorDecrypt(Uint8List encryptedData, String key) {
    // XOR encryption is symmetric, so decryption is the same as encryption
    return _xorEncrypt(encryptedData, key);
  }

  /// Converts integer to 4-byte array
  Uint8List _intToBytes(int value) {
    final bytes = Uint8List(4);
    bytes[0] = (value >> 24) & 0xFF;
    bytes[1] = (value >> 16) & 0xFF;
    bytes[2] = (value >> 8) & 0xFF;
    bytes[3] = value & 0xFF;
    return bytes;
  }

  /// Converts 4-byte array to integer
  int _bytesToInt(Uint8List bytes) {
    return (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
  }

  /// Generates secure filename for upload
  String generateSecureFilename(String originalFilename) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    final hash = sha256.convert(utf8.encode('$originalFilename$timestamp$random'));
    
    return 'enc_${hash.toString().substring(0, 16)}_$timestamp.dat';
  }

  /// Creates metadata hash for video file
  String createVideoHash(String filePath, double latitude, double longitude) {
    final dataString = '$filePath$latitude$longitude${DateTime.now().toIso8601String()}';
    return sha256.convert(utf8.encode(dataString)).toString();
  }
}