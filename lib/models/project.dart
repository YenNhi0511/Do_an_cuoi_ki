// lib/models/project.dart
class Project {
  final String? id;
  final String name;
  final String? description;
  final String? color; // Hex color code
  final String? icon; // Icon name or emoji
  final String? ownerId;
  final List<String>? memberIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isArchived;
  final int? taskCount;

  Project({
    this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.ownerId,
    this.memberIds,
    this.createdAt,
    this.updatedAt,
    this.isArchived = false,
    this.taskCount,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      color: json['color'],
      icon: json['icon'],
      ownerId: json['owner'] is Map
          ? json['owner']['_id']
          : json['owner']?.toString(),
      memberIds: json['members'] is List
          ? (json['members'] as List).map((e) => e.toString()).toList()
          : [],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isArchived: json['isArchived'] ?? false,
      taskCount: json['taskCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (ownerId != null) 'owner': ownerId,
      if (memberIds != null) 'members': memberIds,
      'isArchived': isArchived,
    };
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    String? ownerId,
    List<String>? memberIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    int? taskCount,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      taskCount: taskCount ?? this.taskCount,
    );
  }
}
