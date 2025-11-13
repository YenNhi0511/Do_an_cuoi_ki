// lib/screens/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'task_form.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();

  List<dynamic> _comments = [];
  bool _loadingComments = false;
  late Task _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    if (_currentTask.id == null) return;

    setState(() => _loadingComments = true);
    try {
      final response =
          await _apiService.get('comments/task/${_currentTask.id}');
      if (response is List) {
        setState(() {
          _comments = response;
          _loadingComments = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải comments: $e");
      setState(() => _loadingComments = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await _apiService.post('comments', {
        'taskId': _currentTask.id,
        'content': _commentController.text.trim(),
      });

      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm bình luận!')),
        );
      }
      _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi thêm bình luận: $e')),
        );
      }
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text(
            "Bạn có chắc muốn xóa công việc '${_currentTask.title}' không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _apiService.delete('tasks/${_currentTask.id}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa công việc!')),
          );
          Navigator.pop(context, true); // Trả về true để reload danh sách
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi xóa công việc: $e')),
          );
        }
      }
    }
  }

  Future<void> _editTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: _currentTask)),
    );

    if (result == true && mounted) {
      // Reload task data
      try {
        final response = await _apiService.get('tasks/${_currentTask.id}');
        setState(() {
          _currentTask = Task.fromJson(response);
        });
      } catch (e) {
        debugPrint("Lỗi reload task: $e");
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Colors.green;
      case "in progress":
        return Colors.orange;
      case "paused":
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "Khẩn cấp":
        return Colors.red;
      case "Cao":
        return Colors.orange;
      case "Trung bình":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_currentTask.status);
    final priorityColor = _getPriorityColor(_currentTask.priority);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết công việc"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editTask,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentTask.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status & Priority
                    Row(
                      children: [
                        Chip(
                          label: Text(_currentTask.status),
                          backgroundColor: statusColor.withOpacity(0.2),
                          avatar:
                              Icon(Icons.circle, color: statusColor, size: 12),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(_currentTask.priority),
                          backgroundColor: priorityColor.withOpacity(0.2),
                          avatar:
                              Icon(Icons.flag, color: priorityColor, size: 16),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    // Description
                    _buildInfoRow(
                      icon: Icons.description,
                      label: "Mô tả",
                      value: _currentTask.description.isEmpty
                          ? "Không có mô tả"
                          : _currentTask.description,
                    ),

                    const SizedBox(height: 12),

                    // Category
                    _buildInfoRow(
                      icon: Icons.category,
                      label: "Danh mục",
                      value: _currentTask.category.isEmpty
                          ? "Chưa phân loại"
                          : _currentTask.category,
                    ),

                    const SizedBox(height: 12),

                    // Deadline
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: "Hạn chót",
                      value: _formatDeadline(_currentTask.deadline),
                    ),

                    // Tags
                    if (_currentTask.tags != null &&
                        _currentTask.tags!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.label, size: 20, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _currentTask.tags!.map((tag) {
                                return Chip(
                                  label: Text(tag),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  labelStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Comments section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bình luận & Thảo luận",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Comment input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: "Viết bình luận...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepPurple),
                        onPressed: _addComment,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Comments list
                  _loadingComments
                      ? const Center(child: CircularProgressIndicator())
                      : _comments.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text("Chưa có bình luận nào"),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                return _buildCommentCard(comment);
                              },
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentCard(dynamic comment) {
    final username = comment['user']?['username'] ?? 'Unknown';
    final content = comment['content'] ?? '';
    final createdAt = comment['createdAt'];

    String timeStr = '';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        timeStr = DateFormat('dd/MM/yyyy HH:mm').format(date);
      } catch (e) {
        timeStr = createdAt.toString();
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(username[0].toUpperCase()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (timeStr.isNotEmpty)
                        Text(
                          timeStr,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  String _formatDeadline(String? deadline) {
    if (deadline == null || deadline.isEmpty) {
      return "Không có hạn";
    }

    try {
      final date = DateTime.parse(deadline);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      String formatted = DateFormat('dd/MM/yyyy').format(date);

      if (difference < 0) {
        return "$formatted (Đã quá hạn)";
      } else if (difference == 0) {
        return "$formatted (Hôm nay)";
      } else if (difference == 1) {
        return "$formatted (Ngày mai)";
      } else {
        return "$formatted (Còn $difference ngày)";
      }
    } catch (e) {
      return deadline;
    }
  }
}
