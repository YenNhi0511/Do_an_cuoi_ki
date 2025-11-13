import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';
import 'export_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ApiService _apiService = ApiService();
  bool _loading = true;

  int total = 0;
  int completed = 0;
  int inProgress = 0;
  int notStarted = 0;
  int paused = 0;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  /// 🔹 Hàm tải dữ liệu báo cáo từ API
  Future<void> _loadReport() async {
    try {
      final response = await _apiService.get("tasks");

      if (response is List) {
        // ✅ Đổi từ TaskModel -> Task
        final tasks = response.map((e) => Task.fromJson(e)).toList();

        setState(() {
          total = tasks.length;
          completed =
              tasks.where((t) => t.status.toLowerCase() == "completed").length;
          inProgress = tasks
              .where((t) => t.status.toLowerCase() == "in progress")
              .length;
          notStarted = tasks
              .where((t) => t.status.toLowerCase() == "not started")
              .length;
          paused =
              tasks.where((t) => t.status.toLowerCase() == "paused").length;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        debugPrint("⚠️ Response không phải danh sách hợp lệ: $response");
      }
    } catch (e) {
      debugPrint("❌ Lỗi tải báo cáo: $e");
      setState(() => _loading = false);
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
          "Báo cáo & Thống kê 📈",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download, color: AppColors.primary),
            tooltip: 'Xuất báo cáo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExportScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pie_chart_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tổng số công việc",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$total",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard(
                        "Hoàn thành",
                        completed.toString(),
                        Icons.check_circle_rounded,
                        AppColors.success,
                      ),
                      _buildStatCard(
                        "Đang làm",
                        inProgress.toString(),
                        Icons.play_circle_rounded,
                        AppColors.info,
                      ),
                      _buildStatCard(
                        "Chưa bắt đầu",
                        notStarted.toString(),
                        Icons.access_time_rounded,
                        AppColors.warning,
                      ),
                      _buildStatCard(
                        "Tạm dừng",
                        paused.toString(),
                        Icons.pause_circle_rounded,
                        AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
