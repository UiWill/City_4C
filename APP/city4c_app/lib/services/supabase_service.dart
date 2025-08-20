import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/occurrence.dart';
import '../models/tag.dart';
import 'encryption_service.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  // Tags
  Future<List<Tag>> getTags() async {
    try {
      print('🏷️ Buscando tags...');
      final response = await client
          .from('tags')
          .select()
          .eq('is_active', true)
          .order('name');
      
      final tags = (response as List)
          .map((json) => Tag.fromJson(json))
          .toList();
      
      print('✅ ${tags.length} tags encontradas');
      return tags;
    } catch (e) {
      print('❌ Erro ao buscar tags: $e');
      
      // Se der erro, retorna tags padrão
      print('🔄 Usando tags padrão...');
      return _getDefaultTags();
    }
  }

  List<Tag> _getDefaultTags() {
    return [
      Tag(
        id: 1,
        name: 'Iluminação Pública',
        description: 'Problemas com postes e iluminação',
        color: '#FCD34D',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      Tag(
        id: 2,
        name: 'Buracos na Via',
        description: 'Buracos e problemas no asfalto',
        color: '#EF4444',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      Tag(
        id: 3,
        name: 'Limpeza Urbana',
        description: 'Problemas de limpeza e coleta',
        color: '#10B981',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      Tag(
        id: 4,
        name: 'Infraestrutura',
        description: 'Problemas de infraestrutura geral',
        color: '#3B82F6',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  // Occurrences
  Future<String> createOccurrence({
    String? title,
    String? description,
    required String videoUrl,
    required String videoFilename,
    int? videoDuration,
    required double latitude,
    required double longitude,
    double? locationAccuracy,
    String? address,
    int? tagId,
    String? reportedBy,
    ReporterType reporterType = ReporterType.citizen,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('📝 Criando ocorrência sem autenticação...');

      // Gerar um ID único para submissões anônimas
      final anonymousId = DateTime.now().millisecondsSinceEpoch.toString();

      final occurrenceData = {
        'title': title,
        'description': description,
        'video_url': videoUrl,
        'video_filename': videoFilename,
        'video_duration': videoDuration,
        'latitude': latitude,
        'longitude': longitude,
        'location_accuracy': locationAccuracy,
        'address': address,
        'tag_id': tagId,
        'reported_by': reportedBy, // Pode ser null para submissões anônimas
        'reporter_type': reporterType.name,
        'metadata': {
          ...?metadata,
          'anonymous_id': anonymousId, // ID para tracking interno
          'submission_time': DateTime.now().toIso8601String(),
        },
        'location': 'POINT($longitude $latitude)', // PostGIS format
      };

      print('📊 Dados da ocorrência: $occurrenceData');

      final response = await client
          .from('occurrences')
          .insert(occurrenceData)
          .select('id')
          .single();

      print('✅ Ocorrência criada com ID: ${response['id']}');
      return response['id'];
    } catch (e) {
      print('❌ Erro ao criar ocorrência: $e');
      throw Exception('Erro ao criar ocorrência: $e');
    }
  }

  // Storage with encryption
  Future<String> uploadVideo(String filePath, String fileName) async {
    try {
      // Encrypt video data before upload
      final encryptedData = await EncryptionService.instance.encryptVideoData(filePath);
      
      // Generate secure filename
      final secureFileName = EncryptionService.instance.generateSecureFilename(fileName);
      
      // Upload encrypted data
      await client.storage
          .from(SupabaseConfig.videoBucket)
          .uploadBinary(secureFileName, encryptedData);
      
      final url = client.storage
          .from(SupabaseConfig.videoBucket)
          .getPublicUrl(secureFileName);
      
      return url;
    } catch (e) {
      throw Exception('Erro ao fazer upload do vídeo: $e');
    }
  }

  // Auth
  Future<void> signInAnonymously() async {
    try {
      await client.auth.signInAnonymously();
    } catch (e) {
      throw Exception('Erro ao fazer login anônimo: $e');
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  bool get isLoggedIn => client.auth.currentUser != null;
  User? get currentUser => client.auth.currentUser;
}