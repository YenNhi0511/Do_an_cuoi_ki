// lib/screens/task_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Thêm import này
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/tags_input.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final String? initialProjectId;
  // Sửa lỗi 'super parameters'
  const TaskFormScreen({super.key, this.task, this.initialProjectId});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  // KHÔNG tạo mới AuthService ở đây, chúng ta sẽ dùng Provider
  // final AuthService _auth = AuthService(); <-- BỎ DÒNG NÀY

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;
  late TextEditingController _priorityController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _locationController;
  late List<String> _tags;

  bool _isAllDay = false;
  bool _hasReminder = false;
  String _repeatType = 'Không lặp lại';
  Color _selectedColor = const Color(0xFF14B8A6);
  String _reminderTime = '15 phút trước';

  final List<String> _repeatOptions = [
    'Không lặp lại',
    'Hàng ngày',
    'Hàng tuần',
    'Hàng tháng',
    'Hàng năm',
  ];

  final List<Color> _colorOptions = [
    Color(0xFF14B8A6), // Teal
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFFF97316), // Orange
    Color(0xFF000000), // Black
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController =
        TextEditingController(text: widget.task?.description ?? '');
    _categoryController =
        TextEditingController(text: widget.task?.category ?? '');
    _priorityController =
        TextEditingController(text: widget.task?.priority ?? 'Trung bình');

    final now = DateTime.now();
    _startDateController = TextEditingController(
      text: widget.task?.deadline ??
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    );
    _endDateController = TextEditingController(
      text: widget.task?.deadline ??
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    );
    _startTimeController = TextEditingController(text: '05:16');
    _endTimeController = TextEditingController(text: '06:16');
    _locationController = TextEditingController(text: '');
    _tags = List<String>.from(widget.task?.tags ?? []);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    // --- SỬA LỖI ASYNC GAP VÀ AUTHSERVICE ---
    // 1. Lấy auth service từ Provider (listen: false vì đang ở trong 1 hàm)
    final authService = Provider.of<AuthService>(context, listen: false);

    // 2. Lấy các đối tượng liên quan đến 'context' TRƯỚC khi await
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    // --- KẾT THÚC SỬA LỖI ---

    final data = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'category': _categoryController.text.trim(),
      'priority': _priorityController.text.trim(),
      'deadline': _startDateController.text.trim(),
      'status': widget.task?.status ?? 'not started',
      'group': authService.groupId,
      'assignedUsers': [authService.userId],
      'tags': _tags,
      'isAllDay': _isAllDay,
      'repeatType': _repeatType,
      'location': _locationController.text.trim(),
      'hasReminder': _hasReminder,
      'reminderTime': _reminderTime,
      'startTime': _startTimeController.text,
      'endTime': _endTimeController.text,
      'color': _selectedColor.value.toRadixString(16),
    };

    try {
      if (widget.task == null) {
        // Thêm công việc mới
        await _apiService.post('tasks', data);
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('✅ Đã thêm công việc!')));
      } else {
        // Cập nhật công việc
        await _apiService.put('tasks/${widget.task!.id}', data);
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Đã cập nhật công việc!')));
      }
      // Dùng 'navigator' đã lấy ở trên
      navigator.pop(true);
    } catch (e) {
      // Dùng 'scaffoldMessenger' đã lấy ở trên
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Lỗi lưu công việc: $e')));
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E40AF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        controller.text =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E40AF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        controller.text =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E40AF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.task == null ? 'Thêm công việc mới ✨' : 'Chỉnh sửa công việc',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _titleController,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: 'Tên công việc',
                  labelStyle: TextStyle(color: const Color(0xFF475569)),
                  prefixIcon:
                      const Icon(Icons.work_outline, color: Color(0xFF1E40AF)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Vui lòng nhập tên công việc' : null,
              ),
            ),
            const SizedBox(height: 16),

            // Description Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _descController,
                maxLines: 4,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Mô tả chi tiết',
                  labelStyle: TextStyle(color: const Color(0xFF475569)),
                  prefixIcon: const Icon(Icons.description_outlined,
                      color: Color(0xFF1E40AF)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _categoryController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Danh mục',
                  labelStyle: TextStyle(color: const Color(0xFF475569)),
                  prefixIcon: const Icon(Icons.category_outlined,
                      color: Color(0xFF1E40AF)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priority Dropdown
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonFormField<String>(
                value: _priorityController.text.isEmpty
                    ? 'Trung bình'
                    : _priorityController.text,
                decoration: const InputDecoration(
                  labelText: 'Mức độ ưu tiên',
                  labelStyle: TextStyle(color: Color(0xFF475569)),
                  prefixIcon:
                      Icon(Icons.flag_outlined, color: Color(0xFF1E40AF)),
                  border: InputBorder.none,
                ),
                items: ['Thấp', 'Trung bình', 'Cao', 'Khẩn cấp']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _priorityController.text = value ?? 'Trung bình';
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Start Date Picker
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _startDateController,
                readOnly: true,
                onTap: () => _pickDate(_startDateController),
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Ngày bắt đầu',
                  labelStyle: TextStyle(color: const Color(0xFF475569)),
                  prefixIcon: const Icon(Icons.calendar_today_outlined,
                      color: Color(0xFF1E40AF)),
                  suffixIcon: const Icon(Icons.arrow_drop_down,
                      color: Color(0xFF475569)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tags Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: TagsInput(
                tags: _tags,
                onChanged: (newTags) {
                  setState(() {
                    _tags = newTags;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  widget.task == null ? '✨ Thêm công việc' : '💾 Lưu thay đổi',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
