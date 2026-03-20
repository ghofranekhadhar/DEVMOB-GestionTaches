import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';
import '../models/project.dart';
import '../models/user_model.dart';
import '../utils/app_colors.dart';
import '../widgets/project_card.dart';
import '../widgets/task_tile.dart';

class DashboardView extends StatelessWidget {
  final UserModel currentUser;
  final String period;
  final Function(String) onPeriodChanged;
  final int pendingCount;
  final int completedCount;
  final int urgentCount;
  final int myProjectsCount;
  final int totalTasks;
  final int percentage;
  final List<TaskItem> todoTasks;
  final List<TaskItem> inProgressTasks;
  final List<TaskItem> completedTasks;
  final List<TaskItem> myTasks;
  final List<TaskItem> allMyTasks;
  final List<Project> projects;
  final List<UserModel> teamMembers;
  final List<TaskItem> filteredTasks;
  final String taskFilter;
  final Function(String) onTaskFilterChanged;
  final Function(TaskItem) onTaskClick;
  final Function(UserModel) onMemberClick;

  const DashboardView({
    super.key,
    required this.currentUser,
    required this.period,
    required this.onPeriodChanged,
    required this.pendingCount,
    required this.completedCount,
    required this.urgentCount,
    required this.myProjectsCount,
    required this.totalTasks,
    required this.percentage,
    required this.todoTasks,
    required this.inProgressTasks,
    required this.completedTasks,
    required this.myTasks,
    required this.allMyTasks,
    required this.projects,
    required this.teamMembers,
    required this.filteredTasks,
    required this.taskFilter,
    required this.onTaskFilterChanged,
    required this.onTaskClick,
    required this.onMemberClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _buildWelcomeBanner(),
        const SizedBox(height: 20),
        _buildPeriodTabs(),
        const SizedBox(height: 16),
        _buildStatsGrid(),
        const SizedBox(height: 20),
        _buildMyProgress(),
        const SizedBox(height: 20),
        _buildTaskOverview(),
        const SizedBox(height: 20),
        _buildProjectProgressList(context),
        const SizedBox(height: 20),
        _buildVisibleNotifications(),
        const SizedBox(height: 20),
        _buildTasksListCompact(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    final firstName = currentUser.name.split(" ")[0];
    String displayName = "User";
    if (firstName.isNotEmpty) {
      displayName = '${firstName[0].toUpperCase()}${firstName.substring(1)}';
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.figmaHeroStart, AppColors.figmaHeroEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello, $displayName',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have $pendingCount task${pendingCount != 1 ? "s" : ""} to complete.',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.checkSquare,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs() {
    String dateLabel = "";
    if (period == "Day") {
      dateLabel = DateFormat('MMMM d').format(DateTime.now());
    } else if (period == "Week") {
      DateTime now = DateTime.now();
      int dayOfWeek = now.weekday;
      DateTime start = now.subtract(Duration(days: dayOfWeek - 1));
      DateTime end = start.add(const Duration(days: 6));
      dateLabel =
          '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}';
    } else {
      dateLabel = DateFormat('MMMM yyyy').format(DateTime.now());
    }

    String infoText = period == "Day"
        ? "Tasks due on $dateLabel"
        : period == "Week"
        ? "Tasks due between $dateLabel"
        : "Tasks due in $dateLabel";

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              ...["Day", "Week", "Month"].map((p) {
                bool isSelected = period == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onPeriodChanged(p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          p,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.figmaHeroStart
                                : AppColors.gray500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 4),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.figmaHeroStart,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.calendar,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(LucideIcons.info, size: 10, color: AppColors.gray400),
            const SizedBox(width: 4),
            Text(
              infoText,
              style: GoogleFonts.outfit(fontSize: 9, color: AppColors.gray400),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.folderKanban,
                    size: 14,
                    color: AppColors.figmaHeroStart,
                  ),
                ),
                Text(
                  'MY PROJECTS',
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$myProjectsCount',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'projects',
                        style: GoogleFonts.outfit(
                          fontSize: 8,
                          color: AppColors.gray400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.clock,
                    size: 14,
                    color: AppColors.figmaHeroStart,
                  ),
                ),
                Text(
                  'MY TASKS • $period',
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$totalTasks',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'assigned',
                        style: GoogleFonts.outfit(
                          fontSize: 8,
                          color: AppColors.gray400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.figmaHeroStart.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.figmaHeroStart.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.rocket,
                      size: 14,
                      color: AppColors.figmaHeroStart,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Progress',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray700,
                        ),
                      ),
                      Text(
                        period == "Day"
                            ? "Today's tasks"
                            : period == "Week"
                            ? "This week"
                            : "This month",
                        style: GoogleFonts.outfit(
                          fontSize: 8,
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '$percentage%',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.figmaHeroStart,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 28,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: AppColors.figmaHeroStart,
                            value:
                                completedCount == 0 &&
                                    pendingCount == 0 &&
                                    urgentCount == 0
                                ? 0
                                : completedCount.toDouble(),
                            title: '',
                            radius: 8,
                          ),
                          if (urgentCount > 0)
                            PieChartSectionData(
                              color: AppColors.figmaUrgent,
                              value: urgentCount.toDouble(),
                              title: '',
                              radius: 8,
                            ),
                          if (pendingCount > 0)
                            PieChartSectionData(
                              color: AppColors.gray100,
                              value: pendingCount.toDouble(),
                              title: '',
                              radius: 8,
                            ),
                          if (completedCount == 0 &&
                              pendingCount == 0 &&
                              urgentCount == 0)
                            PieChartSectionData(
                              color: AppColors.figmaHeroStart, // 100% progress color
                              value: 1,
                              title: '',
                              radius: 8,
                            ),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        '$percentage%',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.figmaHeroStart,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 180), // Added more space
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProgressStatRow(
                    'Completed',
                    completedCount,
                    LucideIcons.checkCircle2,
                    AppColors.gray800,
                  ),
                  const SizedBox(height: 8),
                  _buildProgressStatRow(
                    'Remaining',
                    pendingCount,
                    LucideIcons.clock,
                    AppColors.gray400,
                  ),
                  const SizedBox(height: 8),
                  _buildProgressStatRow(
                    'Urgent',
                    urgentCount,
                    LucideIcons.flag,
                    AppColors.figmaUrgent,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStatRow(
    String label,
    int value,
    IconData icon,
    Color colorText,
  ) {
    return SizedBox(
      width: 110,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 8, color: colorText),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(fontSize: 10, color: colorText),
              ),
            ],
          ),
          Text(
            '$value',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.figmaHeroStart.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.activity,
                size: 12,
                color: AppColors.figmaHeroStart,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Task Overview',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.gray700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatBox(
              'To Do',
              todoTasks.length,
              LucideIcons.circle,
              AppColors.figmaHeroStart,
            ),
            const SizedBox(width: 12),
            _buildStatBox(
              'In Progress',
              inProgressTasks.length,
              Icons.incomplete_circle,
              AppColors.figmaInProgress,
            ),
            const SizedBox(width: 12),
            _buildStatBox(
              'Done',
              completedTasks.length,
              LucideIcons.checkCircle2,
              AppColors.figmaDone,
            ),
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            _buildGraphCard(
              'To Do',
              todoTasks.length,
              AppColors.figmaHeroStart,
              max(
                1.0,
                [
                  todoTasks.length,
                  inProgressTasks.length,
                  completedTasks.length,
                ].reduce(max).toDouble(),
              ),
            ),
            const SizedBox(width: 12),
            _buildGraphCard(
              'In Progress',
              inProgressTasks.length,
              AppColors.figmaInProgress,
              max(
                1.0,
                [
                  todoTasks.length,
                  inProgressTasks.length,
                  completedTasks.length,
                ].reduce(max).toDouble(),
              ),
            ),
            const SizedBox(width: 12),
            _buildGraphCard(
              'Done',
              completedTasks.length,
              AppColors.figmaDone,
              max(
                1.0,
                [
                  todoTasks.length,
                  inProgressTasks.length,
                  completedTasks.length,
                ].reduce(max).toDouble(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(String title, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.outfit(fontSize: 7, color: AppColors.gray400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphCard(
    String title,
    int count,
    Color color,
    double maxCount,
  ) {
    return Expanded(
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  maxY: maxCount * 1.2 > 0 ? maxCount * 1.2 : 1.0,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: const FlTitlesData(show: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: count == 0 ? maxCount * 0.08 : count.toDouble(),
                          color: count == 0 ? color.withValues(alpha: 0.3) : color,
                          width: 24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectProgressList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.figmaHeroStart.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.trendingUp,
                    size: 12,
                    color: AppColors.figmaHeroStart,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Project Progress',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray700,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                'Total (${projects.length})',
                style: GoogleFonts.outfit(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (projects.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray100),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    LucideIcons.folderKanban,
                    size: 24,
                    color: AppColors.gray300,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No projects yet',
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: projects.length,
              separatorBuilder: (c, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final project = projects[index];
                final pTasks = allMyTasks
                    .where((t) => t.projectId == project.id)
                    .toList();

                return ProjectCard(
                  project: project,
                  tasks: pTasks,
                  compact: true,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildVisibleNotifications() {
    // Compute real reminders from Firebase task data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<Map<String, String>> reminders = [];

    for (final task in myTasks) {
      final isDone = task.status.toLowerCase().contains('done');
      if (isDone) continue;

      // Check overdue
      if (task.dueDate.isNotEmpty) {
        try {
          final deadline = DateFormat('yyyy-MM-dd').parse(task.dueDate);
          final deadlineDay = DateTime(
            deadline.year,
            deadline.month,
            deadline.day,
          );

          if (deadlineDay.isBefore(today)) {
            final daysOverdue = today.difference(deadlineDay).inDays;
            reminders.add({
              'title': task.title,
              'message':
                  'Overdue by $daysOverdue day${daysOverdue != 1 ? "s" : ""}',
            });
            continue;
          }

          // Check due soon (within 3 days) for urgent/high priority
          final daysUntil = deadlineDay.difference(today).inDays;
          if (daysUntil <= 3 &&
              (task.priority == 'urgent' || task.priority == 'high')) {
            reminders.add({
              'title': task.title,
              'message': daysUntil == 0
                  ? 'Due today - ${task.priority} task'
                  : 'Due in $daysUntil day${daysUntil != 1 ? "s" : ""} - ${task.priority} task',
            });
          }
        } catch (_) {}
      }
    }

    // Hide section if no reminders
    if (reminders.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.alertCircle,
                  size: 14,
                  color: AppColors.figmaUrgent,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reminders',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray700,
                    ),
                  ),
                  Text(
                    '${reminders.length} task${reminders.length != 1 ? "s" : ""} needing attention',
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...reminders
              .take(5)
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildNotificationItem(r['title']!, r['message']!),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                LucideIcons.flag,
                size: 10,
                color: AppColors.figmaUrgent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray700,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 8,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksListCompact() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$period Tasks (${filteredTasks.length})',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.gray700,
              ),
            ),
            Row(
              children: [
                _buildFilterSmallBtn('All', 'All'),
                const SizedBox(width: 4),
                _buildFilterSmallBtn('To Do', 'To Do', LucideIcons.circle),
                const SizedBox(width: 4),
                _buildFilterSmallBtn(
                  'In Progress',
                  'In Progress',
                  Icons.incomplete_circle,
                ),
                const SizedBox(width: 4),
                _buildFilterSmallBtn('Done', 'Done', LucideIcons.checkCircle2),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filteredTasks.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.gray100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.checkSquare,
                      size: 20,
                      color: AppColors.gray300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No tasks found',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray500,
                    ),
                  ),
                  Text(
                    'Try a different filter',
                    style: GoogleFonts.outfit(
                      fontSize: 7,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...filteredTasks
              .take(10)
              .map(
                (t) => TaskTile(
                  task: t,
                  variant: TaskTileVariant.list,
                  onTap: () => onTaskClick(t),
                ),
              ),
      ],
    );
  }

  Widget _buildFilterSmallBtn(String label, String value, [IconData? icon]) {
    bool isSelected = taskFilter.toLowerCase() == value.toLowerCase();
    return GestureDetector(
      onTap: () => onTaskFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.figmaHeroStart : AppColors.gray100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 6,
                color: isSelected ? Colors.white : AppColors.gray500,
              ),
              const SizedBox(width: 2),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
