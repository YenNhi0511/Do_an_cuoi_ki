// lib/models/task.dart
class Task {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String? deadline;
  final String? groupId; // ✅ nhóm chứa công việc
  final String? creatorId; // ✅ người tạo công việc
  final List<String>? assignedUsers; // ✅ danh sách user được phân quyền
  final List<String>? tags; // ✅ tags/labels

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.deadline,
    this.groupId,
    this.creatorId,
    this.assignedUsers,
    this.tags,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      priority: json['priority'] ?? 'Trung bình',
      status: json['status'] ?? 'not started',
      deadline: json['deadline']?.toString(),
      groupId: json['groupId']?.toString(),
      creatorId: json['creatorId']?.toString(),
      assignedUsers: json['assignedUsers'] != null
          ? List<String>.from(json['assignedUsers'])
          : [],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
        'status': status,
        'deadline': deadline,
        'groupId': groupId,
        'creatorId': creatorId,
        'assignedUsers': assignedUsers,
        'tags': tags,
      };
}
