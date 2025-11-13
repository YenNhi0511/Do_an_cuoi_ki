// lib/screens/task_search_screen.dart
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../widgets/task_card.dart';
import 'task_form.dart';

class TaskSearchScreen extends StatefulWidget {
  const TaskSearchScreen({super.key});

  @override
  State<TaskSearchScreen> createState() => _TaskSearchScreenState();
}

class _TaskSearchScreenState extends State<TaskSearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  bool _loading = true;

  String? _selectedStatus;
  String? _selectedPriority;
  String? _selectedCategory;
  String? _selectedTag;

  final List<String> _statuses = [
    'Tất cả',
    'not started',
    'in progress',
    'completed',
    'paused'
  ];

  final List<String> _priorities = [
    'Tất cả',
    'Thấp',
    'Trung bình',
    'Cao',
    'Khẩn cấp'
  ];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTasks() async {
    try {
      final res = await _apiService.get('tasks');
      if (res is List) {
        setState(() {
          _allTasks = res.map((e) => Task.fromJson(e)).toList();
          _filteredTasks = _allTasks;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải công việc: $e");
      setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        // Lọc theo từ khóa tìm kiếm
        final searchText = _searchController.text.toLowerCase();
        final matchesSearch = searchText.isEmpty ||
            task.title.toLowerCase().contains(searchText) ||
            task.description.toLowerCase().contains(searchText) ||
            task.category.toLowerCase().contains(searchText);

        // Lọc theo trạng thái
        final matchesStatus = _selectedStatus == null ||
            _selectedStatus == 'Tất cả' ||
            task.status == _selectedStatus;

        // Lọc theo độ ưu tiên
        final matchesPriority = _selectedPriority == null ||
            _selectedPriority == 'Tất cả' ||
            task.priority == _selectedPriority;

        // Lọc theo danh mục
        final matchesCategory = _selectedCategory == null ||
            _selectedCategory == 'Tất cả' ||
            task.category == _selectedCategory;

        // Lọc theo tag
        final matchesTag = _selectedTag == null ||
            _selectedTag == 'Tất cả' ||
            (task.tags != null && task.tags!.contains(_selectedTag));

        return matchesSearch &&
            matchesStatus &&
            matchesPriority &&
            matchesCategory &&
            matchesTag;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _selectedPriority = null;
      _selectedCategory = null;
      _selectedTag = null;
      _filteredTasks = _allTasks;
    });
  }

  Future<void> _openTaskForm({Task? task}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
    if (result == true) _fetchTasks();
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _apiService.delete('tasks/$taskId');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa công việc!')),
        );
      }
      _fetchTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa công việc: $e')),
        );
      }
    }
  }

  // Lấy danh sách các danh mục duy nhất từ tất cả công việc
  List<String> _getUniqueCategories() {
    final categories = _allTasks
        .map((t) => t.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    categories.insert(0, 'Tất cả');
    return categories;
  }

  // Lấy danh sách các tags duy nhất từ tất cả công việc
  List<String> _getUniqueTags() {
    final tags = <String>{};
    for (var task in _allTasks) {
      if (task.tags != null) {
        tags.addAll(task.tags!);
      }
    }
    final tagList = tags.toList();
    tagList.insert(0, 'Tất cả');
    return tagList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tìm kiếm & Lọc công việc"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Tìm kiếm công việc...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Các bộ lọc
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Lọc trạng thái
                _buildFilterChip(
                  label: "Trạng thái: ${_selectedStatus ?? 'Tất cả'}",
                  onTap: () => _showStatusFilter(),
                ),
                const SizedBox(width: 8),

                // Lọc độ ưu tiên
                _buildFilterChip(
                  label: "Ưu tiên: ${_selectedPriority ?? 'Tất cả'}",
                  onTap: () => _showPriorityFilter(),
                ),
                const SizedBox(width: 8),

                // Lọc danh mục
                _buildFilterChip(
                  label: "Danh mục: ${_selectedCategory ?? 'Tất cả'}",
                  onTap: () => _showCategoryFilter(),
                ),
                const SizedBox(width: 8),

                // Lọc tags
                _buildFilterChip(
                  label: "Tag: ${_selectedTag ?? 'Tất cả'}",
                  onTap: () => _showTagFilter(),
                ),
                const SizedBox(width: 8),

                // Nút xóa bộ lọc
                OutlinedButton.icon(
                  icon: const Icon(Icons.clear_all),
                  label: const Text("Xóa lọc"),
                  onPressed: _clearFilters,
                ),
              ],
            ),
          ),

          const Divider(),

          // Kết quả tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Tìm thấy ${_filteredTasks.length} công việc",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Danh sách công việc
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTasks.isEmpty
                    ? const Center(child: Text("Không tìm thấy công việc nào"))
                    : ListView.builder(
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, i) {
                          final task = _filteredTasks[i];
                          return TaskCard(
                            task: task,
                            onUpdated: () => _openTaskForm(task: task),
                            onDeleted: () => _deleteTask(task.id!),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      {required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        avatar: const Icon(Icons.filter_list, size: 18),
      ),
    );
  }

  void _showStatusFilter() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Lọc theo trạng thái"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statuses.map((status) {
            return RadioListTile<String>(
              title: Text(status),
              value: status == 'Tất cả' ? 'Tất cả' : status,
              groupValue: _selectedStatus ?? 'Tất cả',
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value == 'Tất cả' ? null : value;
                  _applyFilters();
                });
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPriorityFilter() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Lọc theo độ ưu tiên"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _priorities.map((priority) {
            return RadioListTile<String>(
              title: Text(priority),
              value: priority,
              groupValue: _selectedPriority ?? 'Tất cả',
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value == 'Tất cả' ? null : value;
                  _applyFilters();
                });
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    final categories = _getUniqueCategories();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Lọc theo danh mục"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((category) {
            return RadioListTile<String>(
              title: Text(category),
              value: category,
              groupValue: _selectedCategory ?? 'Tất cả',
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value == 'Tất cả' ? null : value;
                  _applyFilters();
                });
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTagFilter() {
    final tags = _getUniqueTags();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Lọc theo Tag"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: tags.map((tag) {
              return RadioListTile<String>(
                title: Text(tag),
                value: tag,
                groupValue: _selectedTag ?? 'Tất cả',
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value == 'Tất cả' ? null : value;
                    _applyFilters();
                  });
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
