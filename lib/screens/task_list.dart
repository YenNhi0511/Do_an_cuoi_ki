// lib/screens/task_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/task_card.dart';
import 'task_form.dart';

class TaskListScreen extends StatefulWidget {
  // Sửa lỗi 'super parameters'
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    // LỖI 'getTasks isn't defined' LÀ Ở FILE 'api_service.dart'
    _tasksFuture = _apiService.getTasks();
  }

  void _refreshTasks() {
    setState(() {
      // LỖI 'getTasks isn't defined' LÀ Ở FILE 'api_service.dart'
      _tasksFuture = _apiService.getTasks();
    });
  }

  void _openAddTaskForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
    if (result == true) _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    // LỖI 'userRole isn't defined' LÀ Ở FILE 'auth_service.dart'
    final isAdmin = auth.userRole == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách công việc')),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return const Center(child: Text('Chưa có công việc nào.'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (_, i) => TaskCard(task: tasks[i]),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _openAddTaskForm,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}