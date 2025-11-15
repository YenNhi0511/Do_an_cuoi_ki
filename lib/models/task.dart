// lib/models/task.dart
class Task {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String? deadline;
  final String? startTime; // Giờ bắt đầu (HH:mm)
  final String? endTime; // Giờ kết thúc (HH:mm)
  final bool isAllDay; // Cả ngày hay không
  final String? repeatType; // none, daily, weekly, monthly, yearly
  final List<String>?
      reminders; // Danh sách thời gian nhắc nhở (15 phút trước, 1 giờ trước...)
  final String? color; // Màu sắc task
  final String? location; // Địa điểm
  final String? url; // URL liên quan
  final String? groupId; // ✅ nhóm chứa công việc
  final String? creatorId; // ✅ người tạo công việc
  final List<String>? assignedUsers; // ✅ danh sách user được phân quyền
  final List<String>? tags; // ✅ tags/labels
  final List<String>? attachments; // File đính kèm

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.deadline,
    this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.repeatType,
    this.reminders,
    this.color,
    this.location,
    this.url,
    this.groupId,
    this.creatorId,
    this.assignedUsers,
    this.tags,
    this.attachments,
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
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      isAllDay: json['isAllDay'] ?? false,
      repeatType: json['repeatType']?.toString() ?? 'none',
      reminders:
          json['reminders'] != null ? List<String>.from(json['reminders']) : [],
      color: json['color']?.toString(),
      location: json['location']?.toString(),
      url: json['url']?.toString(),
      // FIX: Backend dùng 'group' không phải 'groupId'
      groupId: _extractId(json['group']),
      // FIX: Backend dùng 'creator' không phải 'creatorId'
      creatorId: _extractId(json['creator']),
      // FIX: assignedUsers có thể là array of ObjectId hoặc populated objects
      assignedUsers: _extractIds(json['assignedUsers']),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : [],
    );
  }

  // Helper để extract ID từ object hoặc string
  static String? _extractId(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map && value.containsKey('_id')) {
      return value['_id'].toString();
    }
    return value.toString();
  }

  // Helper để extract array of IDs
  static List<String>? _extractIds(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value.map((item) {
      if (item is String) return item;
      if (item is Map && item.containsKey('_id')) {
        return item['_id'].toString();
      }
      return item.toString();
    }).toList();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
    };

    // Chỉ thêm các field không null
    if (deadline != null) map['deadline'] = deadline;
    if (startTime != null) map['startTime'] = startTime;
    if (endTime != null) map['endTime'] = endTime;
    map['isAllDay'] = isAllDay;
    if (repeatType != null) map['repeatType'] = repeatType;
    if (reminders != null && reminders!.isNotEmpty)
      map['reminders'] = reminders;
    if (color != null) map['color'] = color;
    if (location != null) map['location'] = location;
    if (url != null) map['url'] = url;

    // Backend expects 'group' not 'groupId'
    if (groupId != null) map['group'] = groupId;
    // Backend expects 'creator' not 'creatorId'
    if (creatorId != null) map['creator'] = creatorId;
    if (assignedUsers != null && assignedUsers!.isNotEmpty) {
      map['assignedUsers'] = assignedUsers;
    }
    if (tags != null && tags!.isNotEmpty) map['tags'] = tags;
    if (attachments != null && attachments!.isNotEmpty) {
      map['attachments'] = attachments;
    }

    return map;
  }

  // Helper để lấy giờ bắt đầu dạng double (11.5 = 11:30)
  double? get startHour {
    if (startTime == null || startTime!.isEmpty) return null;
    try {
      final parts = startTime!.split(':');
      return double.parse(parts[0]) + (double.parse(parts[1]) / 60);
    } catch (e) {
      return null;
    }
  }

  // Helper để lấy giờ kết thúc dạng double
  double? get endHour {
    if (endTime == null || endTime!.isEmpty) return null;
    try {
      final parts = endTime!.split(':');
      return double.parse(parts[0]) + (double.parse(parts[1]) / 60);
    } catch (e) {
      return null;
    }
  }

  // Lấy duration (số giờ)
  double get duration {
    if (startHour == null || endHour == null) return 1.0;
    return endHour! - startHour!;
  }
}
