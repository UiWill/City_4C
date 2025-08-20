class Occurrence {
  final String id;
  final String? title;
  final String? description;
  final String videoUrl;
  final String videoFilename;
  final int? videoDuration;
  final double latitude;
  final double longitude;
  final double? locationAccuracy;
  final String? address;
  final OccurrenceStatus status;
  final int priority;
  final int? tagId;
  final String? reportedBy;
  final ReporterType reporterType;
  final String? assignedTo;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  Occurrence({
    required this.id,
    this.title,
    this.description,
    required this.videoUrl,
    required this.videoFilename,
    this.videoDuration,
    required this.latitude,
    required this.longitude,
    this.locationAccuracy,
    this.address,
    required this.status,
    this.priority = 1,
    this.tagId,
    this.reportedBy,
    this.reporterType = ReporterType.citizen,
    this.assignedTo,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  factory Occurrence.fromJson(Map<String, dynamic> json) {
    return Occurrence(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['video_url'],
      videoFilename: json['video_filename'],
      videoDuration: json['video_duration'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      locationAccuracy: json['location_accuracy'] != null 
        ? double.parse(json['location_accuracy'].toString())
        : null,
      address: json['address'],
      status: OccurrenceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OccurrenceStatus.pending,
      ),
      priority: json['priority'] ?? 1,
      tagId: json['tag_id'],
      reportedBy: json['reported_by'],
      reporterType: ReporterType.values.firstWhere(
        (e) => e.name == json['reporter_type'],
        orElse: () => ReporterType.citizen,
      ),
      assignedTo: json['assigned_to'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      resolvedAt: json['resolved_at'] != null 
        ? DateTime.parse(json['resolved_at'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'video_filename': videoFilename,
      'video_duration': videoDuration,
      'latitude': latitude,
      'longitude': longitude,
      'location_accuracy': locationAccuracy,
      'address': address,
      'status': status.name,
      'priority': priority,
      'tag_id': tagId,
      'reported_by': reportedBy,
      'reporter_type': reporterType.name,
      'assigned_to': assignedTo,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }
}

enum OccurrenceStatus {
  pending,
  inProgress,
  resolved,
  rejected
}

enum ReporterType {
  agent,
  citizen
}

extension OccurrenceStatusExtension on OccurrenceStatus {
  String get displayName {
    switch (this) {
      case OccurrenceStatus.pending:
        return 'Pendente';
      case OccurrenceStatus.inProgress:
        return 'Em Andamento';
      case OccurrenceStatus.resolved:
        return 'Resolvido';
      case OccurrenceStatus.rejected:
        return 'Rejeitado';
    }
  }
}