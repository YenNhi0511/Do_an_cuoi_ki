import 'package:flutter/material.dart';
import '../models/task.dart';
import '../screens/task_detail_screen.dart';
import '../constants/app_colors.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onUpdated;
  final VoidCallback? onDeleted;

  const TaskCard({
    super.key,
    required this.task,
    this.onUpdated,
    this.onDeleted,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return AppColors.success;
      case "in progress":
        return AppColors.info;
      case "paused":
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "Khẩn cấp":
        return AppColors.urgent;
      case "Cao":
        return AppColors.high;
      case "Trung bình":
        return AppColors.medium;
      case "Thấp":
        return AppColors.low;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Icons.check_circle;
      case "in progress":
        return Icons.play_circle_outline;
      case "paused":
        return Icons.pause_circle_outline;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  String _getDeadlineText() {
    if (task.deadline == null || task.deadline!.trim().isEmpty) {
      return "Không có hạn";
    }

    try {
      final deadline = DateTime.parse(task.deadline!);
      final now = DateTime.now();
      final difference = deadline.difference(now).inDays;

      if (difference < 0) {
        return "Quá hạn ${-difference} ngày";
      } else if (difference == 0) {
        return "Hôm nay";
      } else if (difference == 1) {
        return "Ngày mai";
      } else if (difference <= 7) {
        return "Còn $difference ngày";
      } else {
        return "${deadline.day}/${deadline.month}/${deadline.year}";
      }
    } catch (_) {
      return task.deadline!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(task.status);
    final priorityColor = _getPriorityColor(task.priority);
    final deadlineText = _getDeadlineText();
    final isOverdue = task.deadline != null &&
        task.deadline!.trim().isNotEmpty &&
        DateTime.parse(task.deadline!).isBefore(DateTime.now()) &&
        task.status != "completed";

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            priorityColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.small,
        border: Border.all(
          color: priorityColor.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskDetailScreen(task: task),
              ),
            ).then((result) {
              if (result == true && onUpdated != null) {
                onUpdated!();
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Status Icon
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        _getStatusIcon(task.status),
                        color: statusColor,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    // Priority Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(
                          color: priorityColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        task.priority,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Delete Button
                    if (onDeleted != null)
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          _showOptionsMenu(context);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Title
                Text(
                  task.title,
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                    decoration: task.status == "completed"
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Description
                if (task.description.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    task.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),

                // Tags
                if (task.tags != null && task.tags!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: task.tags!.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Footer Row
                Row(
                  children: [
                    // Category
                    if (task.category.trim().isNotEmpty) ...[
                      Icon(
                        Icons.folder_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.category,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],

                    // Deadline
                    Icon(
                      isOverdue
                          ? Icons.warning_amber
                          : Icons.calendar_today_outlined,
                      size: 14,
                      color:
                          isOverdue ? AppColors.error : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deadlineText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isOverdue
                            ? AppColors.error
                            : AppColors.textSecondary,
                        fontWeight:
                            isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),

                    const Spacer(),

                    // Status Text
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        task.status,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.info),
              title: const Text("Chỉnh sửa"),
              onTap: () {
                Navigator.pop(ctx);
                if (onUpdated != null) onUpdated!();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text("Xóa công việc"),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: const Text("Xác nhận xóa"),
                    content: Text(
                      "Bạn có chắc muốn xóa công việc '${task.title}' không?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: const Text("Hủy"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          if (onDeleted != null) onDeleted!();
                        },
                        child: const Text(
                          "Xóa",
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
