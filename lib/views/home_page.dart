import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/task_item.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';
import 'task/add_task_page.dart';

// Import modular views
import 'dashboard_view.dart';
import 'task/task_board_page.dart';
import 'project/project_list_page.dart';
import 'profile/team_member_page.dart';
import 'task/task_detail_page.dart';
import 'project/project_detail_page.dart';
import 'profile/user_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Navigation
  int _currentIndex = 0;

  // Global filters
  String _dashboardPeriod = "Day";
  String _dashboardTaskFilter = "All";

  // Drill-down states
  bool _showTaskDetail = false;
  TaskItem? _selectedTask;
  bool _showProjectDetail = false;
  Project? _selectedProject;


  // Handlers
  void _updateTaskStatus(String taskId, String newStatus) async {
    try {
      await TaskService().updateTaskStatus(taskId, newStatus);
    } catch (e) {
      debugPrint('Erreur updateTaskStatus: $e');
    }
  }



  void _openMemberModal(UserModel m, List<TaskItem> allTs, List<Project> allPs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final mTasks = allTs.where((t) => t.assignedTo == m.id).toList();
        final pIds = mTasks.map((t) => t.projectId).toSet();
        final mProjects = allPs.where((p) => pIds.contains(p.id)).toList();
        return UserProfilePage(
          member: m,
          memberTasks: mTasks,
          memberProjects: mProjects,
          onClose: () => Navigator.pop(ctx),
          onTaskClick: (t) {
            setState(() { _selectedTask = t; _showTaskDetail = true; });
          },
          onProjectClick: (p) {
            setState(() { _selectedProject = p; _showProjectDetail = true; });
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    if (projectProvider.isLoading || taskProvider.isLoading || authProvider.user == null) {
      return Scaffold(
        backgroundColor: AppColors.figmaBg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.figmaHeroStart),
              if (projectProvider.errorMessage != null || taskProvider.isLoading == false /* maybe handling task error in the future */) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    projectProvider.errorMessage ?? "Chargement...",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.gray500, fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final user = authProvider.user!;
    final projects = projectProvider.projects;
    final allTasks = taskProvider.tasks;
    final allUsers = projectProvider.users;
    final myTasks = allTasks.where((t) => t.assignedTo == user.id).toList();

    final todoCount = myTasks.where((t) => t.status.toLowerCase().contains("to do")).length;
    final progCount = myTasks.where((t) => t.status.toLowerCase().contains("progress")).length;
    final compCount = myTasks.where((t) => t.status.toLowerCase().contains("done")).length;
    final urgentCount = myTasks.where((t) => t.priority == 'urgent' && !t.status.toLowerCase().contains("done")).length;
    final perc = myTasks.isEmpty ? 100 : ((compCount / myTasks.length) * 100).round();

    // Resolve overlay state
    if (_showTaskDetail && _selectedTask != null) {
      return TaskDetailPage(
        task: _selectedTask!,
        onBack: () => setState(() => _showTaskDetail = false),
        onUpdateTask: _updateTaskStatus,
      );
    }

    if (_showProjectDetail && _selectedProject != null) {
      final pTasks = allTasks.where((t) => t.projectId == _selectedProject!.id).toList();
      return ProjectDetailPage(
        project: _selectedProject!,
        projectTasks: pTasks,
        allUsers: allUsers,
        onBack: () => setState(() => _showProjectDetail = false),
        onTaskClick: (t) => setState(() { _selectedTask = t; _showTaskDetail = true; }),
        onUpdateTaskStatus: _updateTaskStatus,
        onMemberClick: (m) => _openMemberModal(m, pTasks, [_selectedProject!]),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.figmaBg,
      appBar: _buildAppBar(user, allUsers, projects, allTasks, _computeReminders(myTasks)),
      body: _buildCurrentBody(user, projects, myTasks, allTasks, allUsers, todoCount, progCount, compCount, urgentCount, perc),
      floatingActionButton: user.isAdmin ? Padding(
        padding: const EdgeInsets.only(top: 20),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => const AddTaskPage()));
          },
          backgroundColor: AppColors.accent,
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(user),
    );
  }

  PreferredSizeWidget _buildAppBar(UserModel currentUser, List<UserModel> allUsers, List<Project> projects, List<TaskItem> allTasks, List<Map<String, dynamic>> reminders) {
    final String mName = currentUser.name;
    final nameParts = mName.trim().split(RegExp(r'\s+'));
    final String initials = nameParts.take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();

    return AppBar(
      backgroundColor: AppColors.figmaBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 90,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(top: 16, left: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getPageTitle(), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gray800, height: 1.1)),
            const SizedBox(height: 2),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.gray400),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 16, right: 20),
          child: Row(
            children: [
              // Bell notification
              PopupMenuButton<Map<String, dynamic>>(
                offset: const Offset(0, 48),
                tooltip: 'Notifications',
                onSelected: (rem) {
                  if (rem['task'] != null) {
                    setState(() { _selectedTask = rem['task'] as TaskItem; _showTaskDetail = true; });
                  }
                },
                itemBuilder: (ctx) {
                  if (reminders.isEmpty) {
                    return [
                      PopupMenuItem(
                        enabled: false,
                        child: Text("No new notifications", style: GoogleFonts.outfit(color: AppColors.gray500, fontSize: 13)),
                      )
                    ];
                  }
                  return reminders.map((rem) => PopupMenuItem<Map<String, dynamic>>(
                    value: rem,
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: rem['color'] as Color, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rem['title'] as String, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gray800)),
                              Text(rem['message'] as String, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.gray500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )).toList();
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gray100),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                      ),
                      child: const Center(child: Icon(LucideIcons.bell, color: AppColors.gray600, size: 17)),
                    ),
                    if (reminders.isNotEmpty)
                      Positioned(
                        right: 7, top: 7,
                        child: Container(
                          width: 9, height: 9,
                          decoration: BoxDecoration(
                            color: AppColors.figmaUrgent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // User avatar with logout popup
              PopupMenuButton<String>(
                offset: const Offset(0, 48),
                onSelected: (value) async {
                  if (value == 'logout') {
                    Provider.of<AuthProvider>(context, listen: false).signOut();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'profile',
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mName, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                        Text(currentUser.email, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.gray400)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(LucideIcons.logOut, color: AppColors.red500, size: 18),
                        const SizedBox(width: 8),
                        Text('Logout', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.red500)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [AppColors.figmaHeroStart, AppColors.figmaHeroEnd]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.figmaHeroStart.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Center(
                    child: Text(initials, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0: return 'My Dashboard';
      case 1: return 'My Tasks';
      case 2: return 'All Projects';
      case 3: return 'Team Members';
      default: return 'Dashboard';
    }
  }

  Widget _buildCurrentBody(UserModel currentUser, List<Project> projects, List<TaskItem> myTasks, List<TaskItem> allTasks, List<UserModel> allUsers, int tTodo, int tProg, int tDone, int tUrg, int perc) {
    if (_currentIndex == 0) {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime startOfWeek = today.subtract(Duration(days: now.weekday - 1));
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      final dashboardTasks = myTasks.where((t) {
        if (t.dueDate.isEmpty) return false;
        DateTime? dueDate;
        try {
          dueDate = DateTime.parse(t.dueDate);
        } catch (e) {
          return false;
        }

        if (_dashboardPeriod == "Day") {
          return dueDate.year == today.year && dueDate.month == today.month && dueDate.day == today.day;
        } else if (_dashboardPeriod == "Week") {
          return dueDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
                 dueDate.isBefore(endOfWeek.add(const Duration(seconds: 1)));
        } else if (_dashboardPeriod == "Month") {
          return dueDate.year == today.year && dueDate.month == today.month;
        }
        return true;
      }).toList();

      final dashTodoCount = dashboardTasks.where((t) => t.status.toLowerCase().contains("to do")).length;
      final dashProgCount = dashboardTasks.where((t) => t.status.toLowerCase().contains("progress")).length;
      final dashDoneCount = dashboardTasks.where((t) => t.status.toLowerCase().contains("done")).length;
      final dashUrgCount = dashboardTasks.where((t) => t.priority == 'urgent' && !t.status.toLowerCase().contains("done")).length;
      final dashPerc = dashboardTasks.isEmpty ? 100 : ((dashDoneCount / dashboardTasks.length) * 100).round();

      return DashboardView(
        currentUser: currentUser,
        period: _dashboardPeriod,
        onPeriodChanged: (p) => setState(() => _dashboardPeriod = p),
        pendingCount: dashTodoCount + dashProgCount,
        completedCount: dashDoneCount,
        urgentCount: dashUrgCount,
        myProjectsCount: projects.length,
        totalTasks: dashboardTasks.length,
        percentage: dashPerc,
        todoTasks: dashboardTasks.where((t) => t.status.toLowerCase().contains("to do")).toList(),
        inProgressTasks: dashboardTasks.where((t) => t.status.toLowerCase().contains("progress")).toList(),
        completedTasks: dashboardTasks.where((t) => t.status.toLowerCase().contains("done")).toList(),
        myTasks: dashboardTasks,
        allMyTasks: myTasks, // Pass unfiltered tasks for project progress
        projects: projects,
        teamMembers: allUsers,
        filteredTasks: dashboardTasks.where((t) {
          if (_dashboardTaskFilter == "All") return true;
          return t.status.toLowerCase().contains(_dashboardTaskFilter.toLowerCase());
        }).toList(),
        taskFilter: _dashboardTaskFilter,
        onTaskFilterChanged: (f) => setState(() => _dashboardTaskFilter = f),
        onTaskClick: (t) => setState(() { _selectedTask = t; _showTaskDetail = true; }),
        onMemberClick: (m) => _openMemberModal(m, allTasks, projects),
      );
    } else if (_currentIndex == 1) {
      return TaskBoardPage(
        tasks: myTasks,
        onTaskClick: (t) => setState(() { _selectedTask = t; _showTaskDetail = true; }),
        onTaskStatusChanged: (t, s) => _updateTaskStatus(t.id, s),
      );
    } else if (_currentIndex == 2) {
      return ProjectListPage(
        projects: projects,
        allTasks: allTasks,
        onProjectClick: (p) => setState(() { _selectedProject = p; _showProjectDetail = true; }),
      );
    } else {
      return TeamMemberPage(
        allUsers: allUsers,
        allTasks: allTasks,
        projects: projects,
        currentUser: currentUser,
        onMemberClick: (m) => _openMemberModal(m, allTasks, projects),
      );
    }
  }

  Widget _buildBottomNav(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: AppColors.accent.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, LucideIcons.home, "Home"),
            _buildNavItem(1, LucideIcons.checkSquare, "Tasks"),
            if (user.isAdmin) const SizedBox(width: 48),
            _buildNavItem(2, LucideIcons.folderKanban, "Projects"),
            _buildNavItem(3, LucideIcons.users, "Team"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() {
        _currentIndex = index;
        _showTaskDetail = false;
        _showProjectDetail = false;
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppColors.accent : AppColors.gray400, size: 22),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.accent : AppColors.gray500)),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _computeReminders(List<TaskItem> myTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> reminders = [];

    for (final task in myTasks) {
      final isDone = task.status.toLowerCase().contains('done') || task.status.toLowerCase().contains('terminé');
      if (isDone) continue;

      if (task.dueDate.isNotEmpty) {
        try {
          final deadline = DateFormat('yyyy-MM-dd').parse(task.dueDate);
          final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);

          if (deadlineDay.isBefore(today)) {
            final daysOverdue = today.difference(deadlineDay).inDays;
            reminders.add({
              'task': task,
              'title': 'Overdue',
              'message': '${task.title} is overdue by $daysOverdue day${daysOverdue != 1 ? "s" : ""}',
              'color': AppColors.figmaUrgent,
            });
            continue;
          }

          final daysUntil = deadlineDay.difference(today).inDays;
          if (daysUntil <= 3 && (task.priority == 'urgent' || task.priority == 'high')) {
            reminders.add({
              'task': task,
              'title': 'Due Soon',
              'message': daysUntil == 0
                  ? '${task.title} is due today'
                  : '${task.title} is due in $daysUntil day${daysUntil != 1 ? "s" : ""}',
              'color': Colors.orange,
            });
          }
        } catch (_) {}
      }
    }
    return reminders;
  }
}
