// lib/screens/task_form.dart - Redesigned theo hình 1-2
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final String? initialProjectId;
  const TaskFormScreen({super.key, this.task, this.initialProjectId});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

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
    _titleController =
        TextEditingController(text: widget.task?.title ?? 'EVENT');
    _descController =
        TextEditingController(text: widget.task?.description ?? '');
    _categoryController =
        TextEditingController(text: widget.task?.category ?? '');
    _priorityController =
        TextEditingController(text: widget.task?.priority ?? 'Trung bình');

    final now = DateTime.now();
    _startDateController = TextEditingController(
      text: widget.task?.deadline ??
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
    );
    _endDateController = TextEditingController(
      text: widget.task?.deadline ??
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
    );
    _startTimeController = TextEditingController(text: '05:16 CH');
    _endTimeController = TextEditingController(text: '06:16 CH');
    _locationController = TextEditingController(text: '');
    _tags = List<String>.from(widget.task?.tags ?? []);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Convert dd/MM/yyyy to ISO string
    String? deadlineIso;
    try {
      final parts = _startDateController.text.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        deadlineIso = DateTime(year, month, day).toIso8601String();
      }
    } catch (e) {
      deadlineIso = null;
    }

    // Convert repeatType to backend format
    String repeatTypeBackend = 'none';
    switch (_repeatType) {
      case 'Hàng ngày':
        repeatTypeBackend = 'daily';
        break;
      case 'Hàng tuần':
        repeatTypeBackend = 'weekly';
        break;
      case 'Hàng tháng':
        repeatTypeBackend = 'monthly';
        break;
      case 'Hàng năm':
        repeatTypeBackend = 'yearly';
        break;
    }

    // Convert time format (05:16 CH -> 17:16)
    String? convertTime(String timeStr) {
      try {
        final regex = RegExp(r'(\d{2}):(\d{2})\s*(SA|CH)');
        final match = regex.firstMatch(timeStr);
        if (match != null) {
          int hour = int.parse(match.group(1)!);
          final minute = match.group(2)!;
          final period = match.group(3)!;

          if (period == 'CH' && hour != 12) hour += 12;
          if (period == 'SA' && hour == 12) hour = 0;

          return '${hour.toString().padLeft(2, '0')}:$minute';
        }
      } catch (e) {
        return null;
      }
      return null;
    }

    final data = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'category': _categoryController.text.trim(),
      'priority': _priorityController.text.trim(),
      'deadline': deadlineIso,
      'tags': _tags,
      'isAllDay': _isAllDay,
      'repeatType': repeatTypeBackend,
      'location': _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      'reminders': _hasReminder ? [_reminderTime] : [],
      'startTime': convertTime(_startTimeController.text),
      'endTime': convertTime(_endTimeController.text),
      'color':
          '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
    };

    try {
      if (widget.task == null) {
        await _apiService.post('tasks', data);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('✅ Thêm công việc thành công!')),
        );
      } else {
        await _apiService.put('tasks/${widget.task!.id}', data);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('✅ Cập nhật công việc thành công!')),
        );
      }
      navigator.pop(true);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('❌ Lỗi: $e')),
      );
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'SA' : 'CH';
      setState(() {
        controller.text = '${hour.toString().padLeft(2, '0')}:$minute $period';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF808080),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'HÔM NAY',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF14B8A6)),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tiêu đề + Sticker Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tiêu đề',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF14B8A6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Sticker',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'EVENT',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                  ),
                  const Divider(height: 24),
                  TextFormField(
                    controller: _descController,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Thêm chi tiết',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cả ngày Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF14B8A6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Cả ngày',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isAllDay,
                    onChanged: (val) => setState(() => _isAllDay = val),
                    activeColor: const Color(0xFF14B8A6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Date & Time Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Start Date/Time
                  Row(
                    children: [
                      const Icon(Icons.arrow_forward,
                          color: Color(0xFF14B8A6), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickDate(_startDateController),
                          child: Text(
                            _startDateController.text,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      if (!_isAllDay)
                        GestureDetector(
                          onTap: () => _pickTime(_startTimeController),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _startTimeController.text,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 24),
                  // End Date/Time
                  Row(
                    children: [
                      const Icon(Icons.arrow_back,
                          color: Color(0xFF14B8A6), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickDate(_endDateController),
                          child: Text(
                            _endDateController.text,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      if (!_isAllDay)
                        GestureDetector(
                          onTap: () => _pickTime(_endTimeController),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _endTimeController.text,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Reminder Settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14B8A6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Color(0xFF14B8A6),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Cài đặt nhắc nhở',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Switch(
                        value: _hasReminder,
                        onChanged: (val) => setState(() => _hasReminder = val),
                        activeColor: const Color(0xFF14B8A6),
                      ),
                    ],
                  ),
                  if (_hasReminder) ...[
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: Color(0xFF14B8A6), size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          '15 phút trước',
                          style: TextStyle(fontSize: 14),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add,
                          color: Color(0xFF14B8A6), size: 18),
                      label: const Text(
                        'Thêm nhắc nhở',
                        style: TextStyle(
                          color: Color(0xFF14B8A6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Nhắc nhở báo thức
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.alarm,
                      color: Color(0xFF14B8A6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Nhắc nhở báo thức',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.workspace_premium,
                      color: Colors.orange, size: 18),
                  const Spacer(),
                  Switch(
                    value: false,
                    onChanged: null,
                    activeColor: const Color(0xFF14B8A6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Repeat Settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.repeat,
                      color: Color(0xFF14B8A6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _repeatType,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Color Picker
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14B8A6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.palette,
                          color: Color(0xFF14B8A6),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Xanh lá cây',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _colorOptions.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Calendar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: Color(0xFF14B8A6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Calendar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Location & URL
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add,
                        color: Color(0xFF14B8A6), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.location_on,
                            color: Color(0xFF14B8A6), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Vị trí',
                          style: TextStyle(
                            color: Color(0xFF14B8A6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.link, color: Color(0xFFF59E0B), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'URL',
                          style: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Countdown Timer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.hourglass_empty,
                      color: Color(0xFF14B8A6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Đếm ngược',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.play_arrow, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Free',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: false,
                    onChanged: null,
                    activeColor: const Color(0xFF14B8A6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hidden fields for backend compatibility
            Visibility(
              visible: false,
              child: Column(
                children: [
                  TextFormField(controller: _categoryController),
                  TextFormField(controller: _priorityController),
                  TextFormField(controller: _locationController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _priorityController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
