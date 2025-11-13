// lib/models/activity.dart
class Activity {
  final String? id;
  final String type; // created, updated, completed, commented, assigned
  final String userId;
  final String? userName;
  final String? userAvatar;
  final String? targetType; // task, project, group
  final String? targetId;
  final String? targetName;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  Activity({
    this.id,
    required this.type,
    required this.userId,
    this.userName,
    this.userAvatar,
    this.targetType,
    this.targetId,
    this.targetName,
    this.description,
    this.metadata,
    this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'] ?? json['id'],
      type: json['type'] ?? '',
      userId: json['user'] is Map
          ? json['user']['_id']
          : json['user']?.toString() ?? '',
      userName: json['user'] is Map ? json['user']['name'] : json['userName'],
      userAvatar: json['user'] is Map ? json['user']['avatar'] : null,
      targetType: json['targetType'],
      targetId: json['target'] is Map
          ? json['target']['_id']
          : json['target']?.toString(),
      targetName:
          json['target'] is Map ? json['target']['name'] : json['targetName'],
      description: json['description'],
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'type': type,
      'user': userId,
      if (targetType != null) 'targetType': targetType,
      if (targetId != null) 'target': targetId,
      if (description != null) 'description': description,
      if (metadata != null) 'metadata': metadata,
    };
  }

  String getActionText() {
    switch (type.toLowerCase()) {
      case 'created':
        return 'đã tạo';
      case 'updated':
        return 'đã cập nhật';
      case 'completed':
        return 'đã hoàn thành';
      case 'commented':
        return 'đã bình luận';
      case 'assigned':
        return 'đã gán';
      case 'deleted':
        return 'đã xóa';
      case 'archived':
        return 'đã lưu trữ';
      default:
        return 'đã thực hiện';
    }
  }

  String getTargetTypeText() {
    switch (targetType?.toLowerCase()) {
      case 'task':
        return 'task';
      case 'project':
        return 'project';
      case 'group':
        return 'group';
      case 'comment':
        return 'bình luận';
      default:
        return '';
    }
  }
}
