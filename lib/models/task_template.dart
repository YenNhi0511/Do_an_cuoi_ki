// lib/models/task_template.dart
class TaskTemplate {
  final String? id;
  final String name;
  final String? description;
  final String category;
  final String priority;
  final List<String>? tags;
  final String? defaultAssignee;
  final int? estimatedDays;
  final bool isPublic;
  final String? createdBy;
  final int useCount;

  TaskTemplate({
    this.id,
    required this.name,
    this.description,
    this.category = '',
    this.priority = 'medium',
    this.tags,
    this.defaultAssignee,
    this.estimatedDays,
    this.isPublic = false,
    this.createdBy,
    this.useCount = 0,
  });

  factory TaskTemplate.fromJson(Map<String, dynamic> json) {
    return TaskTemplate(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? '',
      priority: json['priority'] ?? 'medium',
      tags: json['tags'] is List
          ? (json['tags'] as List).map((e) => e.toString()).toList()
          : [],
      defaultAssignee: json['defaultAssignee']?.toString(),
      estimatedDays: json['estimatedDays'],
      isPublic: json['isPublic'] ?? false,
      createdBy: json['createdBy']?.toString(),
      useCount: json['useCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      if (description != null) 'description': description,
      'category': category,
      'priority': priority,
      if (tags != null) 'tags': tags,
      if (defaultAssignee != null) 'defaultAssignee': defaultAssignee,
      if (estimatedDays != null) 'estimatedDays': estimatedDays,
      'isPublic': isPublic,
      'useCount': useCount,
    };
  }

  TaskTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? priority,
    List<String>? tags,
    String? defaultAssignee,
    int? estimatedDays,
    bool? isPublic,
    String? createdBy,
    int? useCount,
  }) {
    return TaskTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      defaultAssignee: defaultAssignee ?? this.defaultAssignee,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      isPublic: isPublic ?? this.isPublic,
      createdBy: createdBy ?? this.createdBy,
      useCount: useCount ?? this.useCount,
    );
  }
}
