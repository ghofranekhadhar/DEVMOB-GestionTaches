import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../models/task_item.dart';
import '../../utils/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class TaskDetailPage extends StatefulWidget {
  final TaskItem task;
  final VoidCallback onBack;
  final Function(String, String) onUpdateTask;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.onBack,
    required this.onUpdateTask,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  bool showStatusMenu = false;
  late double _progressValue;

  @override
  void initState() {
    super.initState();
    bool isDone = widget.task.status.toLowerCase() == "done";
    bool inProgress = widget.task.status.toLowerCase() == "in progress";
    _progressValue = isDone ? 100 : (inProgress ? 50 : 0);
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "";
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;
    final canUpdateStatus = user.isAdmin || widget.task.assignedTo == user.id;

    bool isDone = widget.task.status.toLowerCase() == "done";
    bool inProgress = widget.task.status.toLowerCase() == "in progress";
    Color statusColor = isDone
        ? AppColors.emerald500
        : (inProgress ? Colors.amber : AppColors.figmaTodo);

    DateTime? deadline;
    try {
      deadline = DateFormat('yyyy-MM-dd').parse(widget.task.dueDate);
    } catch (_) {}
    bool isOverdue =
        deadline != null && deadline.isBefore(DateTime.now()) && !isDone;
    int daysLeft = deadline != null
        ? deadline.difference(DateTime.now()).inDays
        : 0;
    DateTime? startDate;
    if (deadline != null) {
      startDate = deadline.subtract(const Duration(days: 3));
    } else {
      startDate = DateTime.now().subtract(const Duration(days: 1));
    }
    String startDateStr = DateFormat('MMM d, yyyy').format(startDate);
    final int progress = _progressValue.round();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                // Header Gradient
                Container(
                  margin: const EdgeInsets.all(16).copyWith(top: 48),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF5B7FFF), Color(0xFF7A9EFF)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          child: const Icon(
                            LucideIcons.chevronLeft,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          9999,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        widget.task.status,
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (widget.task.priority == "urgent" ||
                                                widget.task.priority == "high")
                                            ? Colors.redAccent.withValues(
                                                alpha: 0.9,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.25,
                                              ),
                                        borderRadius: BorderRadius.circular(
                                          9999,
                                        ),
                                      ),
                                      child: Text(
                                        widget.task.priority.toUpperCase(),
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.task.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.task.description.isEmpty
                                      ? "No description provided."
                                      : widget.task.description,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (user.isAdmin)
                            Column(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    LucideIcons.edit3,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.8,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.redAccent.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    LucideIcons.trash2,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                      ),
                    ],
                  ),
                ),

                // Grid stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: [
                      // Start Date
                      _buildGridStat(
                        LucideIcons.calendar,
                        'Start Date',
                        startDateStr,
                      ),
                      // Due Date
                      _buildGridStat(
                        LucideIcons.calendar,
                        'Due Date',
                        '${_formatDate(widget.task.dueDate)}${(!isDone && daysLeft <= 2 && daysLeft > 0) ? '\n($daysLeft d left)' : ''}',
                        isOverdue ? Colors.red : AppColors.gray800,
                      ),
                      // Project
                      _buildGridStat(
                        LucideIcons.folderKanban,
                        'Project',
                        widget.task.projectName,
                      ),
                      // Status
                      GestureDetector(
                        onTap: () {
                          if (canUpdateStatus) {
                            setState(() => showStatusMenu = !showStatusMenu);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.gray100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.figmaTodo.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          LucideIcons.flag,
                                          size: 14,
                                          color: AppColors.figmaTodo,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Status',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.gray500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        isDone
                                            ? LucideIcons.checkCircle
                                            : (inProgress
                                                  ? LucideIcons.loader
                                                  : LucideIcons.circle),
                                        size: 12,
                                        color: statusColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.task.status,
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.gray800,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      if (canUpdateStatus)
                                        Icon(
                                          showStatusMenu
                                              ? LucideIcons.chevronDown
                                              : LucideIcons.chevronRight,
                                          size: 12,
                                          color: AppColors.gray800,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (showStatusMenu)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gray100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: ["To Do", "In Progress", "Done"]
                            .map(
                              (s) => ListTile(
                                title: Text(
                                  s,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                leading: Icon(
                                  s == "Done"
                                      ? LucideIcons.checkCircle
                                      : (s == "In Progress"
                                            ? LucideIcons.loader
                                            : LucideIcons.circle),
                                  size: 14,
                                  color: s == "Done"
                                      ? AppColors.emerald500
                                      : (s == "In Progress"
                                            ? Colors.amber
                                            : AppColors.figmaTodo),
                                ),
                                onTap: () {
                                  widget.onUpdateTask(widget.task.id, s);
                                  setState(() => showStatusMenu = false);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),

                // Progress Banner
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.figmaTodo.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  LucideIcons.trendingUp,
                                  size: 16,
                                  color: AppColors.figmaTodo,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Task Progress',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gray800,
                                    ),
                                  ),
                                  Text(
                                    'Drag to update progress',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      color: AppColors.gray400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: progress == 0
                                  ? AppColors.gray100
                                  : AppColors.figmaTodo.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$progress%',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: progress == 0
                                    ? AppColors.gray400
                                    : AppColors.figmaTodo,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Interactive Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: progress == 0
                              ? AppColors.gray300
                              : AppColors.figmaTodo,
                          inactiveTrackColor: AppColors.gray100,
                          thumbColor: progress == 0
                              ? AppColors.gray400
                              : AppColors.figmaTodo,
                          overlayColor: AppColors.figmaTodo.withValues(
                            alpha: 0.1,
                          ),
                          trackHeight: 8,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16,
                          ),
                        ),
                        child: Slider(
                          value: _progressValue,
                          min: 0,
                          max: 100,
                          divisions: 20,
                          onChanged: (v) => setState(() => _progressValue = v),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Project Timeline separator
                      Row(
                        children: [
                          const Icon(LucideIcons.clock, size: 14, color: AppColors.gray400),
                          const SizedBox(width: 8),
                          Text('Project Timeline', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.gray500)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Timeline Bar
                      Builder(
                        builder: (context) {
                          int totalDays = deadline != null && startDate != null ? deadline.difference(startDate).inDays : 1;
                          if (totalDays <= 0) totalDays = 1;
                          int elapsedDays = startDate != null ? DateTime.now().difference(startDate).inDays : 0;
                          double timeProgress = (elapsedDays / totalDays).clamp(0.0, 1.0);
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
                              value: timeProgress,
                              min: 0,
                              max: 1.0,
                              onChanged: null, // Read-only
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Start: $startDateStr',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              color: AppColors.gray400,
                            ),
                          ),
                          Text(
                            'Due: ${_formatDate(widget.task.dueDate)}',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              color: AppColors.gray400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Comments
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.figmaTodo.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                LucideIcons.messageSquare,
                                size: 14,
                                color: AppColors.figmaTodo,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Comments',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray800,
                                  ),
                                ),
                                Text(
                                  '0 comments',
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    color: AppColors.gray400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: AppColors.gray100),
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.gray50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  LucideIcons.messageSquare,
                                  size: 24,
                                  color: AppColors.gray300,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No comments yet',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.gray500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Be the first to share your thoughts',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  color: AppColors.gray400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(height: 1, color: AppColors.gray100),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.gray50,
                                  border: Border.all(color: AppColors.gray200),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Write a comment...',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: AppColors.gray400,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.figmaTodo,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Send',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Fixed Bottom Bar
          if (canUpdateStatus)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.gray100)),
                ),
                child: GestureDetector(
                  onTap: () => widget.onUpdateTask(
                    widget.task.id,
                    isDone ? "To Do" : "Done",
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.gray100 : AppColors.figmaTodo,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDone
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        isDone ? "Reopen Task" : "Complete Task",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDone ? AppColors.gray600 : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGridStat(
    IconData icon,
    String label,
    String value, [
    Color? valueColor,
  ]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.figmaTodo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 14, color: AppColors.figmaTodo),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.gray800,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
