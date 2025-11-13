import 'package:flutter/material.dart';
import '../models/task.dart';

class TimelineScreen extends StatelessWidget {
  final List<Task> tasks;
  const TimelineScreen({super.key, required this.tasks});

  Color _getTagColor(String priority) {
    switch (priority) {
      case 'Cao':
        return Colors.redAccent;
      case 'Trung bình':
        return Colors.orange;
      case 'Thấp':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  // ✅ Chuyển String deadline -> DateTime (nếu hợp lệ)
  DateTime _parseDate(String? dateStr) {
    try {
      if (dateStr == null || dateStr.isEmpty) return DateTime(2100);
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime(2100);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Sort theo ngày, nếu không có deadline thì đẩy xuống cuối
    final sortedTasks = List<Task>.from(tasks)
      ..sort((a, b) =>
          _parseDate(a.deadline).compareTo(_parseDate(b.deadline)));

    return Scaffold(
      appBar: AppBar(title: const Text('Timeline công việc')),
      body: tasks.isEmpty
          ? const Center(child: Text('Không có công việc nào'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sortedTasks.length,
              itemBuilder: (context, i) {
                final task = sortedTasks[i];
                final deadlineDate = _parseDate(task.deadline);
                final deadlineText = task.deadline == null ||
                        task.deadline!.isEmpty
                    ? 'Không có hạn'
                    : '${deadlineDate.day}/${deadlineDate.month}/${deadlineDate.year}';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getTagColor(task.priority),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getTagColor(task.priority),
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                    title: Text(task.title),
                    subtitle: Text(
                      '${task.category} | ${task.status ?? "Không rõ"}\nHạn: $deadlineText',
                    ),
                    trailing: Text(
                      task.priority,
                      style: TextStyle(
                        color: _getTagColor(task.priority),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
