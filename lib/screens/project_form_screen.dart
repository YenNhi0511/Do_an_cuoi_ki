// lib/screens/project_form_screen.dart
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;

  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  String? _selectedColor;
  String? _selectedIcon;

  bool _loading = false;

  // Predefined colors
  final List<Map<String, dynamic>> _colors = [
    {'name': 'Indigo', 'hex': '#6366F1'},
    {'name': 'Purple', 'hex': '#8B5CF6'},
    {'name': 'Pink', 'hex': '#EC4899'},
    {'name': 'Red', 'hex': '#EF4444'},
    {'name': 'Orange', 'hex': '#F97316'},
    {'name': 'Amber', 'hex': '#F59E0B'},
    {'name': 'Green', 'hex': '#10B981'},
    {'name': 'Teal', 'hex': '#14B8A6'},
    {'name': 'Blue', 'hex': '#3B82F6'},
    {'name': 'Cyan', 'hex': '#06B6D4'},
  ];

  // Predefined icons (emojis)
  final List<String> _icons = [
    '📁',
    '📂',
    '🗂️',
    '📊',
    '📈',
    '🎯',
    '🚀',
    '💼',
    '🏆',
    '⭐',
    '💡',
    '🔥',
    '⚡',
    '🎨',
    '🛠️',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.project?.description ?? '');
    _selectedColor = widget.project?.color ?? '#6366F1';
    _selectedIcon = widget.project?.icon ?? '📁';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'color': _selectedColor,
        'icon': _selectedIcon,
      };

      if (widget.project?.id != null) {
        // Update existing project
        await _apiService.put('projects/${widget.project!.id}', data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật project!')),
          );
        }
      } else {
        // Create new project
        await _apiService.post('projects', data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã tạo project mới!')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.project?.id != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Chỉnh sửa Project' : 'Tạo Project Mới',
          style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProject,
              child: Text(
                isEdit ? 'Lưu' : 'Tạo',
                style: AppTextStyles.button.copyWith(color: AppColors.primary),
              ),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Preview Card
            _buildPreviewCard(),

            const SizedBox(height: AppSpacing.xl),

            // Icon Selector
            _buildSectionTitle('Icon'),
            const SizedBox(height: AppSpacing.sm),
            _buildIconSelector(),

            const SizedBox(height: AppSpacing.xl),

            // Color Selector
            _buildSectionTitle('Màu sắc'),
            const SizedBox(height: AppSpacing.sm),
            _buildColorSelector(),

            const SizedBox(height: AppSpacing.xl),

            // Name Field
            _buildSectionTitle('Tên project *'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'VD: Marketing Campaign Q4',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên project';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Description Field
            _buildSectionTitle('Mô tả'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Mô tả ngắn về project này...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPreviewCard() {
    final color = Color(
      int.parse(_selectedColor!.replaceFirst('#', '0xFF')),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(
                    _selectedIcon!,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty
                          ? 'Project Name'
                          : _nameController.text,
                      style: AppTextStyles.h5.copyWith(
                        color: _nameController.text.isEmpty
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_descriptionController.text.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _descriptionController.text,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _icons.length,
        itemBuilder: (context, index) {
          final icon = _icons[index];
          final isSelected = _selectedIcon == icon;

          return GestureDetector(
            onTap: () => setState(() => _selectedIcon = icon),
            child: Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _colors.map((colorData) {
        final color = Color(
          int.parse(colorData['hex'].replaceFirst('#', '0xFF')),
        );
        final isSelected = _selectedColor == colorData['hex'];

        return GestureDetector(
          onTap: () => setState(() => _selectedColor = colorData['hex']),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? AppColors.textPrimary : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected ? AppShadows.medium : AppShadows.small,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 28)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
