// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'task_detail_screen.dart';
import '../models/task.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      // Lấy tất cả tasks để tạo notifications
      final response = await _apiService.get('tasks');

      if (response is List) {
        final tasks = response.map((e) => Task.fromJson(e)).toList();
        final now = DateTime.now();

        final notifications = <Map<String, dynamic>>[];

        // Tạo notifications cho tasks sắp hết hạn
        for (var task in tasks) {
          if (task.deadline != null && task.deadline!.isNotEmpty) {
            try {
              final deadline = DateTime.parse(task.deadline!);
              final daysUntil = deadline.difference(now).inDays;

              // Task quá hạn
              if (daysUntil < 0 && task.status != 'completed') {
                notifications.add({
                  'id': '${task.id}_overdue',
                  'type': 'overdue',
                  'title': 'Công việc quá hạn!',
                  'message': '"${task.title}" đã quá hạn ${-daysUntil} ngày',
                  'task': task,
                  'time': deadline,
                  'priority': 'high',
                  'read': false,
                });
              }
              // Task sắp hết hạn (1-3 ngày)
              else if (daysUntil >= 0 &&
                  daysUntil <= 3 &&
                  task.status != 'completed') {
                notifications.add({
                  'id': '${task.id}_due_soon',
                  'type': 'due_soon',
                  'title': 'Sắp hết hạn!',
                  'message': '"${task.title}" còn $daysUntil ngày',
                  'task': task,
                  'time': deadline,
                  'priority': daysUntil == 0 ? 'high' : 'medium',
                  'read': false,
                });
              }
            } catch (e) {
              debugPrint('Error parsing deadline: $e');
            }
          }

          // Task với priority Khẩn cấp chưa hoàn thành
          if (task.priority == 'Khẩn cấp' && task.status != 'completed') {
            notifications.add({
              'id': '${task.id}_urgent',
              'type': 'urgent',
              'title': 'Công việc khẩn cấp!',
              'message': '"${task.title}" cần xử lý ngay',
              'task': task,
              'time': DateTime.now(),
              'priority': 'high',
              'read': false,
            });
          }

          // Task mới được giao (trong 24h)
          if (task.id != null) {
            // Giả sử task có createdAt (cần thêm vào model nếu chưa có)
            // notifications.add({...});
          }
        }

        // Sắp xếp theo priority và time
        notifications.sort((a, b) {
          final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
          final aPriority = priorityOrder[a['priority']] ?? 2;
          final bPriority = priorityOrder[b['priority']] ?? 2;

          if (aPriority != bPriority) {
            return aPriority.compareTo(bPriority);
          }

          return (b['time'] as DateTime).compareTo(a['time'] as DateTime);
        });

        setState(() {
          _notifications = notifications;
          _unreadCount = notifications.where((n) => !n['read']).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải thông báo: $e');
      setState(() => _isLoading = false);
    }
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['read'] = true;
      _unreadCount = _notifications.where((n) => !n['read']).length;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
      _unreadCount = 0;
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      if (!_notifications[index]['read']) {
        _unreadCount--;
      }
      _notifications.removeAt(index);
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'overdue':
        return Icons.warning_amber_rounded;
      case 'due_soon':
        return Icons.access_time_rounded;
      case 'urgent':
        return Icons.priority_high_rounded;
      case 'assigned':
        return Icons.assignment_ind_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(time);
    } else if (diff.inDays > 0) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo ${_unreadCount > 0 ? '($_unreadCount)' : ''}'),
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Đánh dấu tất cả đã đọc',
              onPressed: _markAllAsRead,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không có thông báo nào',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final isRead = notification['read'] as bool;
                      final priority = notification['priority'] as String;
                      final priorityColor = _getPriorityColor(priority);

                      return Dismissible(
                        key: Key(notification['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteNotification(index),
                        child: Card(
                          elevation: isRead ? 1 : 3,
                          color:
                              isRead ? null : priorityColor.withOpacity(0.05),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getTypeIcon(notification['type']),
                                color: priorityColor,
                              ),
                            ),
                            title: Text(
                              notification['title'],
                              style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(notification['message']),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(notification['time'] as DateTime),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: priorityColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                            onTap: () {
                              _markAsRead(index);

                              // Mở task detail nếu có
                              if (notification['task'] != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TaskDetailScreen(
                                      task: notification['task'] as Task,
                                    ),
                                  ),
                                ).then((_) => _loadNotifications());
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
