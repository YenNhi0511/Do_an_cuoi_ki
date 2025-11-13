import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  bool _loading = true;

  int _totalTasks = 0;
  int _completedTasks = 0;
  int _inProgressTasks = 0;
  int _notStartedTasks = 0;
  int _pausedTasks = 0;

  Map<String, int> _priorityStats = {};
  Map<String, int> _categoryStats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final response = await _apiService.get('tasks');
      if (response is List) {
        final tasks = response.map((e) => Task.fromJson(e)).toList();

        setState(() {
          _totalTasks = tasks.length;
          _completedTasks = tasks.where((t) => t.status == 'completed').length;
          _inProgressTasks =
              tasks.where((t) => t.status == 'in progress').length;
          _notStartedTasks =
              tasks.where((t) => t.status == 'not started').length;
          _pausedTasks = tasks.where((t) => t.status == 'paused').length;

          // Thống kê theo độ ưu tiên
          _priorityStats = {};
          for (var task in tasks) {
            _priorityStats[task.priority] =
                (_priorityStats[task.priority] ?? 0) + 1;
          }

          // Thống kê theo danh mục
          _categoryStats = {};
          for (var task in tasks) {
            if (task.category.isNotEmpty) {
              _categoryStats[task.category] =
                  (_categoryStats[task.category] ?? 0) + 1;
            }
          }

          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải thống kê: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final completionRate =
        _totalTasks == 0 ? 0.0 : (_completedTasks / _totalTasks * 100);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Dashboard 📊',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () {
              setState(() => _loading = true);
              _loadStats();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Tổng quan công việc',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Cards thống kê pastel
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  'Tổng số',
                  _totalTasks.toString(),
                  Icons.work_outline_rounded,
                  AppColors.info,
                ),
                _buildStatCard(
                  'Hoàn thành',
                  _completedTasks.toString(),
                  Icons.check_circle_rounded,
                  AppColors.success,
                ),
                _buildStatCard(
                  'Đang làm',
                  _inProgressTasks.toString(),
                  Icons.pending_outlined,
                  AppColors.warning,
                ),
                _buildStatCard(
                  'Chưa bắt đầu',
                  _notStartedTasks.toString(),
                  Icons.access_time_rounded,
                  AppColors.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tỷ lệ hoàn thành
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.trending_up_rounded,
                          color: AppColors.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tỷ lệ hoàn thành',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.success.withOpacity(0.1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: completionRate / 100,
                        backgroundColor: Colors.transparent,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.success),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${completionRate.toStringAsFixed(1)}% công việc đã hoàn thành',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Biểu đồ trạng thái
            Text(
              'Phân bố trạng thái 📊',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      if (_completedTasks > 0)
                        PieChartSectionData(
                          value: _completedTasks.toDouble(),
                          title: '$_completedTasks',
                          color: AppColors.success,
                          radius: 60,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      if (_inProgressTasks > 0)
                        PieChartSectionData(
                          value: _inProgressTasks.toDouble(),
                          title: '$_inProgressTasks',
                          color: AppColors.warning,
                          radius: 60,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      if (_notStartedTasks > 0)
                        PieChartSectionData(
                          value: _notStartedTasks.toDouble(),
                          title: '$_notStartedTasks',
                          color: AppColors.textSecondary,
                          radius: 60,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      if (_pausedTasks > 0)
                        PieChartSectionData(
                          value: _pausedTasks.toDouble(),
                          title: '$_pausedTasks',
                          color: AppColors.error,
                          radius: 60,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegend('Hoàn thành', AppColors.success),
                _buildLegend('Đang làm', AppColors.warning),
                _buildLegend('Chưa bắt đầu', AppColors.textSecondary),
                _buildLegend('Tạm dừng', AppColors.error),
              ],
            ),

            const SizedBox(height: 24),

            // Báo cáo chi tiết
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.assessment_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Báo cáo tổng hợp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildReportItem(
                      '✅ Hoàn thành', _completedTasks, Colors.white),
                  const Divider(color: Colors.white24, height: 24),
                  _buildReportItem(
                      '🚧 Đang thực hiện', _inProgressTasks, Colors.white),
                  const Divider(color: Colors.white24, height: 24),
                  _buildReportItem(
                      '🕓 Chưa bắt đầu', _notStartedTasks, Colors.white),
                  const Divider(color: Colors.white24, height: 24),
                  _buildReportItem('⏸️ Tạm dừng', _pausedTasks, Colors.white),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Thống kê độ ưu tiên
            if (_priorityStats.isNotEmpty) ...[
              Text(
                'Phân bố độ ưu tiên ⭐',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: _priorityStats.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(entry.key),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: _getPriorityColor(entry.key)
                                      .withOpacity(0.2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: entry.value / _totalTasks,
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getPriorityColor(entry.key),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${entry.value}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(String label, int value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.9),
            fontSize: 16,
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Khẩn cấp':
        return Colors.red;
      case 'Cao':
        return Colors.orange;
      case 'Trung bình':
        return Colors.blue;
      case 'Thấp':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
