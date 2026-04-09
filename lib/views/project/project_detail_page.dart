import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../models/project.dart';
import '../../models/task_item.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../task/add_task_page.dart';

class ProjectDetailPage extends StatefulWidget {
  final Project project;
  final List<TaskItem> projectTasks;
  final List<UserModel> allUsers;
  final VoidCallback onBack;
  final Function(TaskItem) onTaskClick;
  final Function(String, String) onUpdateTaskStatus;
  final Function(UserModel) onMemberClick;

  const ProjectDetailPage({
    super.key,
    required this.project,
    required this.projectTasks,
    required this.allUsers,
    required this.onBack,
    required this.onTaskClick,
    required this.onUpdateTaskStatus,
    required this.onMemberClick,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  String _activeTab = 'overview';
  String _taskFilter = 'all'; // all, todo, progress, done

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "";
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) { return dateStr; }
  }

  Color _getPriorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'urgent': return Colors.red;
      case 'high': return Colors.orange;
      case 'medium': return Colors.amber;
      default: return AppColors.gray400;
    }
  }

  Color _getStatusColor(String s) {
    switch(s.toLowerCase()) {
      case "to do": return AppColors.figmaTodo;
      case "in progress": return Colors.amber;
      case "done": return AppColors.emerald500;
      default: return AppColors.gray400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;
    final completedCount = widget.projectTasks.where((t) => t.status.toLowerCase() == "done").length;
    final inProgressCount = widget.projectTasks.where((t) => t.status.toLowerCase() == "in progress").length;
    final todoCount = widget.projectTasks.where((t) => t.status.toLowerCase() == "to do").length;
    final totalTasks = widget.projectTasks.length;
    final percentage = totalTasks == 0 ? 0 : ((completedCount / totalTasks) * 100).round();
    
    final members = widget.allUsers.where((u) => widget.project.members.contains(u.id)).toList();
    final projectStatus = widget.project.status.toLowerCase().isEmpty ? 'active' : widget.project.status.toLowerCase();
    
    DateTime? dl;
    try { dl = DateFormat('yyyy-MM-dd').parse(widget.project.deadline); } catch(_) {}
    final isOverdue = dl != null && dl.isBefore(DateTime.now()) && projectStatus != 'completed';
    // Timeline calculation
    int daysRemaining = dl != null ? dl.difference(DateTime.now()).inDays : 0;
    if (daysRemaining < 0) daysRemaining = 0;
    
    // Compute project age from the earliest task due date
    DateTime? earliestTaskDate;
    for (final t in widget.projectTasks) {
      if (t.dueDate.isNotEmpty) {
        try {
          final d = DateFormat('yyyy-MM-dd').parse(t.dueDate);
          if (earliestTaskDate == null || d.isBefore(earliestTaskDate)) {
            earliestTaskDate = d;
          }
        } catch (_) {}
      }
    }
    int projectAge = 14; // default fallback
    if (earliestTaskDate != null && dl != null) {
      projectAge = dl.difference(earliestTaskDate).inDays.abs();
      if (projectAge < 1) projectAge = 1;
    }
    double timelineProgress = 0;
    if (daysRemaining + projectAge > 0) {
      timelineProgress = (projectAge / (daysRemaining + projectAge)) * 100;
      if (timelineProgress > 100) timelineProgress = 100;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF5B7FFF), Color(0xFF7A9EFF)]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: widget.onBack,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
                                  child: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 24),
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: projectStatus == 'active' ? Colors.white.withValues(alpha: 0.25) : (projectStatus == 'completed' ? AppColors.emerald500.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                                    child: Text(projectStatus == 'active' ? '● Active' : (projectStatus == 'completed' ? '✓ Completed' : '⏸ On Hold'), style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(999)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(LucideIcons.folderKanban, size: 10, color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text('Development', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  if (isOverdue && projectStatus == 'active')
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(999)),
                                      child: Text('⚠️ Overdue', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(widget.project.name, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(LucideIcons.calendar, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text('Due ${_formatDate(widget.project.deadline)}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tabs
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gray100), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)]),
                          child: Row(
                            children: [
                              _buildTab('overview', 'Overview', LucideIcons.layoutGrid),
                              _buildTab('tasks', 'Tasks ($totalTasks)', LucideIcons.checkSquare),
                              _buildTab('team', 'Team (${members.length})', LucideIcons.users),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Content
                        if (_activeTab == 'overview') _buildOverview(daysRemaining, isOverdue, timelineProgress, projectAge, percentage, todoCount, inProgressCount, completedCount),
                        if (_activeTab == 'tasks') _buildTasks(),
                        if (_activeTab == 'team') _buildTeam(members, totalTasks),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Fixed bottom action button
            if (user.isAdmin)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), border: const Border(top: BorderSide(color: AppColors.gray100))),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskPage()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF5B7FFF), Color(0xFF4A6FD9)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Add New Task', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String id, String label, IconData icon) {
    bool isSel = _activeTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFF5B7FFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSel ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSel ? Colors.white : AppColors.gray400),
              const SizedBox(width: 4),
              Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: isSel ? Colors.white : AppColors.gray500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverview(int daysRemaining, bool isOverdue, double timelineProgress, int projectAge, int percentage, int t1, int t2, int t3) {
    return Column(
      children: [
        // Timeline
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF5B7FFF).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF5B7FFF).withValues(alpha: 0.1))),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF5B7FFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.clock, size: 14, color: Color(0xFF5B7FFF))),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Project Timeline', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.gray500)),
                          Text('$projectAge days', style: GoogleFonts.outfit(fontSize: 8, color: AppColors.gray400)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(isOverdue ? "Overdue" : (daysRemaining <= 0 ? "Expired" : "${daysRemaining}d left"), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isOverdue ? Colors.red : (daysRemaining <= 7 ? Colors.amber : const Color(0xFF5B7FFF)))),
                      Text('until deadline', style: GoogleFonts.outfit(fontSize: 7, color: AppColors.gray400)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  return SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      disabledActiveTrackColor: isOverdue ? Colors.redAccent : Colors.orangeAccent,
                      disabledInactiveTrackColor: AppColors.gray100,
                      disabledThumbColor: isOverdue ? Colors.redAccent : Colors.orangeAccent,
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: (timelineProgress / 100).clamp(0.0, 1.0),
                      min: 0,
                      max: 1.0,
                      onChanged: null,
                    ),
                  );
                }
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Start', style: GoogleFonts.outfit(fontSize: 8, color: AppColors.gray400)),
                  Text(_formatDate(widget.project.deadline), style: GoogleFonts.outfit(fontSize: 8, color: AppColors.gray400)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Task Status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray100), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)]),
          child: Column(
            children: [
              Row(
                children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF5B7FFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.activity, size: 16, color: Color(0xFF5B7FFF))),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Task Status', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                      Text('Current project progress', style: GoogleFonts.outfit(fontSize: 9, color: AppColors.gray400)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Circular Progress
                  SizedBox(
                    width: 104, height: 104,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: percentage / 100),
                      duration: const Duration(seconds: 1),
                      builder: (context, value, _) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Transform.rotate(
                              angle: -pi / 2,
                              child: CircularProgressIndicator(
                                value: value,
                                backgroundColor: AppColors.gray100,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B7FFF)),
                                strokeWidth: 10,
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(value * 100).round()}%',
                                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF5B7FFF)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'complete',
                                    style: GoogleFonts.outfit(fontSize: 9, color: AppColors.gray400),
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 48),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusLegend('To Do', t1, AppColors.figmaTodo),
                      const SizedBox(height: 20),
                      _buildStatusLegend('In Progress', t2, Colors.amber),
                      const SizedBox(height: 20),
                      _buildStatusLegend('Completed', t3, AppColors.emerald500),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Description
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray100), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF5B7FFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.info, size: 14, color: Color(0xFF5B7FFF))),
                  const SizedBox(width: 8),
                  Text('Description', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                ],
              ),
              const SizedBox(height: 12),
              Text(widget.project.description.isEmpty ? "No description available for this project." : widget.project.description, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.gray600, height: 1.5)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatusLegend(String label, int count, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.outfit(fontSize: 9, color: AppColors.gray500)),
            Text('$count tasks', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray700)),
          ],
        )
      ],
    );
  }

  Widget _buildTasks() {
    List<TaskItem> filtered = widget.projectTasks;
    if (_taskFilter != 'all') {
      final s = _taskFilter == 'todo' ? 'To Do' : (_taskFilter == 'progress' ? 'In Progress' : 'Done');
      filtered = filtered.where((t) => t.status.toLowerCase() == s.toLowerCase()).toList();
    }

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTaskFilterBtn('all', 'All', widget.projectTasks.length),
              const SizedBox(width: 8),
              _buildTaskFilterBtn('todo', 'To Do', widget.projectTasks.where((t) => t.status.toLowerCase() == 'to do').length),
              const SizedBox(width: 8),
              _buildTaskFilterBtn('progress', 'In Progress', widget.projectTasks.where((t) => t.status.toLowerCase() == 'in progress').length),
              const SizedBox(width: 8),
              _buildTaskFilterBtn('done', 'Done', widget.projectTasks.where((t) => t.status.toLowerCase() == 'done').length),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray100)),
            child: Center(
              child: Column(
                children: [
                  Container(width: 64, height: 64, decoration: const BoxDecoration(color: AppColors.gray50, shape: BoxShape.circle), child: const Icon(LucideIcons.checkSquare, size: 32, color: AppColors.gray300)),
                  const SizedBox(height: 12),
                  Text('No tasks found', style: GoogleFonts.outfit(fontSize: 14, color: AppColors.gray400)),
                  Text('Try a different filter', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.gray300)),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final task = filtered[i];
              final isDone = task.status.toLowerCase().contains("done");
              final pCol = _getPriorityColor(task.priority);
              final sCol = _getStatusColor(task.status);
              
              DateTime? tdl;
              try { tdl = DateFormat('yyyy-MM-dd').parse(task.dueDate); } catch(_) {}
              final isTOverdue = tdl != null && tdl.isBefore(DateTime.now()) && !isDone;

              return GestureDetector(
                onTap: () => widget.onTaskClick(task),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray100), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => widget.onUpdateTaskStatus(task.id, isDone ? "To Do" : "Done"),
                        child: Container(
                          width: 24, height: 24, margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(color: isDone ? AppColors.emerald500 : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: isDone ? AppColors.emerald500 : AppColors.gray300, width: 2)),
                          child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(width: 8, height: 8, decoration: BoxDecoration(color: pCol, shape: BoxShape.circle)),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(task.title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: isDone ? AppColors.gray400 : AppColors.gray800, decoration: isDone ? TextDecoration.lineThrough : null), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                      if (task.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(task.description, style: GoogleFonts.outfit(fontSize: 11, color: isDone ? AppColors.gray300 : AppColors.gray500, decoration: isDone ? TextDecoration.lineThrough : null), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ]
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: sCol.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                                      child: Text(task.status, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w600, color: sCol)),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.calendar, size: 10, color: AppColors.gray400),
                                        const SizedBox(width: 4),
                                        Text(_formatDate(task.dueDate), style: GoogleFonts.outfit(fontSize: 10, fontWeight: isTOverdue ? FontWeight.w600 : FontWeight.normal, color: isTOverdue ? Colors.red : AppColors.gray500)),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(color: AppColors.gray50, height: 1),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(task.priority.toUpperCase(), style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w600, color: pCol)),
                                const SizedBox(width: 8),
                                Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.gray300, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                const Icon(LucideIcons.folderKanban, size: 9, color: AppColors.gray300),
                                const SizedBox(width: 4),
                                Text(task.projectName, style: GoogleFonts.outfit(fontSize: 8, color: AppColors.gray400)),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          )
      ],
    );
  }

  Widget _buildTaskFilterBtn(String id, String label, int count) {
    bool isSel = _taskFilter == id;
    return GestureDetector(
      onTap: () => setState(() => _taskFilter = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF5B7FFF) : AppColors.gray100,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSel ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, 1))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w500, color: isSel ? Colors.white : AppColors.gray600)),
            const SizedBox(width: 4),
            Text('($count)', style: GoogleFonts.outfit(fontSize: 9, color: isSel ? Colors.white.withValues(alpha: 0.8) : AppColors.gray600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeam(List<UserModel> members, int totalProjTasks) {
    if (members.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray100)),
        child: Center(
          child: Column(
            children: [
              const Icon(LucideIcons.users, size: 48, color: AppColors.gray300),
              const SizedBox(height: 12),
              Text('No team members', style: GoogleFonts.outfit(fontSize: 14, color: AppColors.gray400)),
              Text('Invite members to collaborate', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.gray300)),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      itemBuilder: (ctx, i) {
        final m = members[i];
        final name = m.name;
        
        // Compute member task progression from real data
        final mTasks = widget.projectTasks.where((t) => t.assignedTo == m.id).toList();
        final mDone = mTasks.where((t) => t.status.toLowerCase().contains('done')).length;
        final mPct = mTasks.isEmpty ? 0 : ((mDone / mTasks.length) * 100).round();
        
        return GestureDetector(
          onTap: () => widget.onMemberClick(m),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray100), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))]),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: const Color(0xFF5B7FFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF5B7FFF).withValues(alpha: 0.2))),
                      child: Center(child: Text(name[0].toUpperCase(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF5B7FFF)))),
                    ),
                    if (mPct > 0 && mPct < 100)
                      Positioned(
                        top: -4, right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: const Color(0xFF5B7FFF), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          child: Text('$mPct%', style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    if (mPct == 100 && mTasks.isNotEmpty)
                      Positioned(
                        top: -4, right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(color: AppColors.emerald500, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          child: const Icon(LucideIcons.checkCircle2, size: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.gray800)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF5B7FFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                            child: Text(m.role.isNotEmpty ? '${m.role[0].toUpperCase()}${m.role.substring(1).toLowerCase()}' : 'Collaborateur', style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF5B7FFF))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.mail, size: 9, color: AppColors.gray400),
                          const SizedBox(width: 4),
                          Text(m.email, style: GoogleFonts.outfit(fontSize: 9, color: AppColors.gray400)),
                        ],
                      ),
                      if (mTasks.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$mDone/${mTasks.length} tasks', style: GoogleFonts.outfit(fontSize: 7, color: AppColors.gray400)),
                            Text('$mPct%', style: GoogleFonts.outfit(fontSize: 7, fontWeight: FontWeight.w600, color: const Color(0xFF5B7FFF))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 6,
                          decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(3)),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: mPct / 100,
                            child: Container(decoration: BoxDecoration(color: const Color(0xFF5B7FFF), borderRadius: BorderRadius.circular(3))),
                          ),
                        )
                      ]
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(LucideIcons.chevronRight, size: 16, color: AppColors.gray300),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
