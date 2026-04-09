import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../models/task_item.dart';
import '../../utils/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../services/task_service.dart';
import '../../models/user_model.dart';

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
  late String _currentStatus;

  late List<TaskComment> _localComments;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.task.status;
    _localComments = List.from(widget.task.comments);
    bool isDone = _currentStatus.toLowerCase() == "done" || _currentStatus.toLowerCase() == "terminé";
    bool inProgress = _currentStatus.toLowerCase() == "in progress" || _currentStatus.toLowerCase() == "en cours";
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
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitComment(UserModel user) async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isSubmittingComment = true);
    
    final newComment = TaskComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      user: user.name,
      text: _commentController.text.trim(),
      date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    );
    
    try {
      await TaskService().addCommentToTask(widget.task.id, newComment);
      setState(() {
        _localComments.add(newComment);
        _commentController.clear();
      });
      _commentFocusNode.unfocus();
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmittingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;
    final canUpdateStatus = user.isAdmin || widget.task.assignedTo == user.id;

    bool isDone = _currentStatus.toLowerCase() == "done" || _currentStatus.toLowerCase() == "terminé";
    bool inProgress = _currentStatus.toLowerCase() == "in progress" || _currentStatus.toLowerCase() == "en cours";
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
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
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
                                        _currentStatus,
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
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
                  child: Column(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _buildGridStat(
                                LucideIcons.calendar,
                                'Start Date',
                                startDateStr,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGridStat(
                                LucideIcons.calendar,
                                'Due Date',
                                '${_formatDate(widget.task.dueDate)}${(!isDone && daysLeft <= 2 && daysLeft > 0) ? '\n($daysLeft d left)' : ''}',
                                isOverdue ? Colors.red : AppColors.gray800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _buildGridStat(
                                LucideIcons.folderKanban,
                                'Project',
                                widget.task.projectName,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                          Expanded(
                                            child: Text(
                                              _currentStatus,
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.gray800,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                                ),
                              ),
                            ),
                          ],
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
                                  setState(() {
                                    _currentStatus = s;
                                    showStatusMenu = false;
                                    bool sDone = s.toLowerCase() == "done";
                                    bool sProg = s.toLowerCase() == "in progress";
                                    _progressValue = sDone ? 100 : (sProg ? 50 : 0);
                                  });
                                  widget.onUpdateTask(widget.task.id, s);
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
                          Expanded(
                            child: Row(
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Task Progress',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.gray800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Drag to update progress',
                                        style: GoogleFonts.outfit(
                                          fontSize: 9,
                                          color: AppColors.gray400,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                          onChanged: (v) {
                            setState(() {
                              _progressValue = v;
                              if (v > 0 && v < 100 && _currentStatus != 'In Progress') {
                                _currentStatus = 'In Progress';
                                widget.onUpdateTask(widget.task.id, 'In Progress');
                              } else if (v == 100 && _currentStatus != 'Done') {
                                _currentStatus = 'Done';
                                widget.onUpdateTask(widget.task.id, 'Done');
                              } else if (v == 0 && _currentStatus != 'To Do') {
                                _currentStatus = 'To Do';
                                widget.onUpdateTask(widget.task.id, 'To Do');
                              }
                            });
                          },
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Comments',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gray800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${_localComments.length} comments',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      color: AppColors.gray400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: AppColors.gray100),
                      if (_localComments.isEmpty)
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
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _localComments.length,
                          itemBuilder: (ctx, i) {
                            final c = _localComments[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5B7FFF).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        c.user.isNotEmpty ? c.user[0].toUpperCase() : '?',
                                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF5B7FFF)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              c.user,
                                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray800),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatDate(c.date.split(' ')[0]),
                                              style: GoogleFonts.outfit(fontSize: 9, color: AppColors.gray400),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          c.text,
                                          style: GoogleFonts.outfit(fontSize: 11, color: AppColors.gray600, height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      Divider(height: 1, color: AppColors.gray100),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.gray50,
                                  border: Border.all(color: AppColors.gray200),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _commentController,
                                  focusNode: _commentFocusNode,
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.gray800),
                                  decoration: InputDecoration(
                                    hintText: 'Write a comment...',
                                    hintStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.gray400),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _isSubmittingComment ? null : () => _submitComment(user),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _isSubmittingComment ? AppColors.gray300 : AppColors.figmaTodo,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _isSubmittingComment ? null : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: _isSubmittingComment 
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text(
                                        'Send',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
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
        mainAxisAlignment: MainAxisAlignment.center,
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
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
