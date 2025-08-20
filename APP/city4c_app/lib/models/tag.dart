class Tag {
  final int id;
  final String name;
  final String? description;
  final String color;
  final bool isActive;
  final DateTime createdAt;
  final String? createdBy;

  Tag({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    this.isActive = true,
    required this.createdAt,
    this.createdBy,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: json['color'] ?? '#3B82F6',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }
}