import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/task.dart';
import '../widgets/app_colors.dart';
import 'task_form.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedView = 'Tháng';
  Map<DateTime, List<Task>> _events = {};
  List<Task> _selectedTasks = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await ApiService.getTasks();
      setState(() {
        _events = {};
        for (var task in tasks) {
          if (task.deadline != null && task.deadline!.isNotEmpty) {
            try {
              final date = DateTime.parse(task.deadline!);
              final dateKey = DateTime(date.year, date.month, date.day);
              if (_events[dateKey] == null) {
                _events[dateKey] = [];
              }
              _events[dateKey]!.add(task);
            } catch (e) {
              print('Error parsing date: ${task.deadline}');
            }
          }
        }
        _selectedTasks = _getTasksForDay(_selectedDay!);
      });
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  List<DateTime> _getWeekDays(DateTime date) {
    final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(
        7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedView == 'Tuần'
              ? 'TUẦN NÀY'
              : _selectedView == 'Ngày'
                  ? 'HÔM NAY'
                  : 'Lịch công việc 📅',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.today, color: AppColors.primary),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = _focusedDay;
                _selectedTasks = _getTasksForDay(_selectedDay!);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildViewSelector(),
          Expanded(
            child: _buildViewContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewSelector() {
    final views = ['Tháng', 'Danh sách', 'Tuần', 'Ngày'];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: views
            .map(
              (view) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedView = view),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: _selectedView == view
                          ? AppColors.gradientPrimary
                          : null,
                      color: _selectedView == view ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _selectedView == view
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        view,
                        style: TextStyle(
                          color: _selectedView == view
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: _selectedView == view
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildViewContent() {
    switch (_selectedView) {
      case 'Tuần':
        return _buildWeekView();
      case 'Ngày':
        return _buildDayView();
      case 'Danh sách':
        return _buildListView();
      default:
        return _buildMonthView();
    }
  }

  // Week view - Hiển thị grid 7 ngày (theo hình mẫu)
  Widget _buildWeekView() {
    final weekDays = _getWeekDays(_focusedDay);
    final hours = List.generate(24, (index) => index);

    return Column(
      children: [
        // Week navigation header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: AppColors.primary),
                onPressed: () {
                  setState(() {
                    _focusedDay = _focusedDay.subtract(const Duration(days: 7));
                  });
                },
              ),
              Text(
                '${DateFormat('dd/MM').format(weekDays.first)} - ${DateFormat('dd/MM').format(weekDays.last)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.primary),
                onPressed: () {
                  setState(() {
                    _focusedDay = _focusedDay.add(const Duration(days: 7));
                  });
                },
              ),
            ],
          ),
        ),
        // Week grid view như hình
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column giờ bên trái
              Container(
                width: 70,
                color: Colors.white,
                child: Column(
                  children: [
                    // Header trống
                    Container(height: 50),
                    // Hours
                    Expanded(
                      child: ListView.builder(
                        itemCount: hours.length,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 80,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 8, top: 8),
                            child: Text(
                              '${hours[index].toString().padLeft(2, '0')}:00',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Grid 7 ngày
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDays.length,
                  itemBuilder: (context, weekIndex) {
                    final day = weekDays[weekIndex];
                    final isToday = isSameDay(day, DateTime.now());
                    final dayTasks = _getTasksForDay(day);

                    return Container(
                      width: (MediaQuery.of(context).size.width - 70) / 7,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border(
                          right: BorderSide(color: AppColors.border, width: 1),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Day header
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppColors.accent.withOpacity(0.1)
                                  : Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                    color: AppColors.border, width: 1),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Th ${day.weekday}',
                                  style: TextStyle(
                                    color: isToday
                                        ? AppColors.accent
                                        : AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                    color: isToday
                                        ? AppColors.accent
                                        : AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Timeline
                          Expanded(
                            child: Stack(
                              children: [
                                // Grid lines
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: hours.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                              color: AppColors.border,
                                              width: 0.5),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Tasks
                                if (dayTasks.isNotEmpty)
                                  ...dayTasks.asMap().entries.map((entry) {
                                    final taskIndex = entry.key;
                                    final task = entry.value;
                                    final topPosition =
                                        (11.0 + taskIndex * 2) * 80;

                                    return Positioned(
                                      top: topPosition,
                                      left: 2,
                                      right: 2,
                                      child: Container(
                                        height: 100,
                                        margin:
                                            const EdgeInsets.only(bottom: 4),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          gradient: AppColors.gradientAccent,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.accent
                                                  .withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              task.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '11:00 AM - 10:55 PM',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontSize: 9,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Day view - Chi tiết 1 ngày
  Widget _buildDayView() {
    final hours = List.generate(24, (index) => index);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: AppColors.primary),
                onPressed: () {
                  setState(() {
                    _selectedDay = (_selectedDay ?? _focusedDay)
                        .subtract(const Duration(days: 1));
                    _selectedTasks = _getTasksForDay(_selectedDay!);
                  });
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEEE', 'vi')
                          .format(_selectedDay ?? _focusedDay),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy')
                          .format(_selectedDay ?? _focusedDay),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.primary),
                onPressed: () {
                  setState(() {
                    _selectedDay = (_selectedDay ?? _focusedDay)
                        .add(const Duration(days: 1));
                    _selectedTasks = _getTasksForDay(_selectedDay!);
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                color: Colors.white,
                child: ListView.builder(
                  itemCount: hours.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 60,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 8, top: 4),
                      child: Text(
                        '${hours[index].toString().padLeft(2, '0')}:00',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      ListView.builder(
                        itemCount: hours.length,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: AppColors.border, width: 1),
                              ),
                            ),
                          );
                        },
                      ),
                      if (_selectedTasks.isNotEmpty)
                        ..._selectedTasks.map((task) {
                          final topPosition = 11.0 * 60;
                          return Positioned(
                            top: topPosition,
                            left: 8,
                            right: 8,
                            child: Container(
                              height: 100,
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppColors.gradientAccent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '11:00 AM - 10:55 PM',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (task.description.isNotEmpty)
                                    Expanded(
                                      child: Text(
                                        task.description,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 11,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    final allTasks = _events.values.expand((tasks) => tasks).toList();

    return Container(
      color: AppColors.background,
      child: allTasks.isEmpty
          ? Center(
              child: Text(
                'Không có công việc nào',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allTasks.length,
              itemBuilder: (context, index) {
                final task = allTasks[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: AppColors.accent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            task.deadline ?? 'No deadline',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.priority,
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          task.description,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMonthView() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedTasks = _getTasksForDay(selectedDay);
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: _getTasksForDay,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              gradient: AppColors.gradientAccent,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            outsideDaysVisible: false,
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildListView(),
        ),
      ],
    );
  }
}
