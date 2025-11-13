// lib/screens/activity_feed_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Activity> _activities = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchActivities() async {
    setState(() => _loading = true);
    try {
      final res = await _apiService.get('/activities');
      if (res is List) {
        setState(() {
          _activities = res.map((e) => Activity.fromJson(e)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải activities: $e");
      setState(() => _loading = false);
    }
  }

  List<Activity> _filterActivities(String filter) {
    final now = DateTime.now();
    switch (filter) {
      case 'today':
        return _activities.where((a) {
          if (a.createdAt == null) return false;
          return a.createdAt!.year == now.year &&
              a.createdAt!.month == now.month &&
              a.createdAt!.day == now.day;
        }).toList();
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return _activities.where((a) {
          if (a.createdAt == null) return false;
          return a.createdAt!.isAfter(weekAgo);
        }).toList();
      case 'all':
      default:
        return _activities;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Activity Feed',
          style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _fetchActivities,
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Hôm nay'),
            Tab(text: 'Tuần này'),
            Tab(text: 'Tất cả'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActivityList(_filterActivities('today')),
                _buildActivityList(_filterActivities('week')),
                _buildActivityList(_filterActivities('all')),
              ],
            ),
    );
  }

  Widget _buildActivityList(List<Activity> activities) {
    if (activities.isEmpty) {
      return _buildEmptyState();
    }

    // Group by date
    final groupedActivities = <String, List<Activity>>{};
    for (var activity in activities) {
      if (activity.createdAt == null) continue;
      final dateKey = DateFormat('yyyy-MM-dd').format(activity.createdAt!);
      groupedActivities.putIfAbsent(dateKey, () => []);
      groupedActivities[dateKey]!.add(activity);
    }

    final sortedDates = groupedActivities.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _fetchActivities,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final dateActivities = groupedActivities[date]!;
          return _buildDateSection(date, dateActivities);
        },
      ),
    );
  }

  Widget _buildDateSection(String dateKey, List<Activity> activities) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    String dateLabel;

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      dateLabel = 'Hôm nay';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      dateLabel = 'Hôm qua';
    } else {
      dateLabel = DateFormat('dd/MM/yyyy').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text(
            dateLabel,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...activities.map((activity) => _buildActivityItem(activity)),
      ],
    );
  }

  Widget _buildActivityItem(Activity activity) {
    final icon = _getActivityIcon(activity.type);
    final color = _getActivityColor(activity.type);
    final timeAgo =
        activity.createdAt != null ? _getTimeAgo(activity.createdAt!) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.small,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar or Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    activity.userName != null && activity.userName!.isNotEmpty
                        ? Text(
                            activity.userName![0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          )
                        : Icon(icon, color: color, size: 20),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User and Action
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: activity.userName ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' ${activity.getActionText()} '),
                        if (activity.targetName != null)
                          TextSpan(
                            text: activity.getTargetTypeText(),
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        if (activity.targetName != null)
                          TextSpan(
                            text: ' "${activity.targetName}"',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Description
                  if (activity.description != null &&
                      activity.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      activity.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Time
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        timeAgo,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Activity Type Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Chưa có hoạt động nào',
              style: AppTextStyles.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Các hoạt động của bạn và team sẽ hiển thị ở đây',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'created':
        return Icons.add_circle_outline;
      case 'updated':
        return Icons.edit_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      case 'commented':
        return Icons.comment_outlined;
      case 'assigned':
        return Icons.person_add_outlined;
      case 'deleted':
        return Icons.delete_outline;
      case 'archived':
        return Icons.archive_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'created':
        return AppColors.info;
      case 'updated':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'commented':
        return AppColors.warning;
      case 'assigned':
        return AppColors.primary;
      case 'deleted':
        return AppColors.error;
      case 'archived':
        return AppColors.medium;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }
}
