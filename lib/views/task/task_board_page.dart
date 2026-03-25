import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../models/task_item.dart';
import '../../utils/app_colors.dart';
import '../../widgets/kanban_column.dart';
import '../../widgets/task_tile.dart';

class TaskBoardPage extends StatefulWidget {
  final List<TaskItem> tasks;
  final Function(TaskItem) onTaskClick;
  final Function(TaskItem, String) onTaskStatusChanged;

  const TaskBoardPage({
    super.key,
    required this.tasks,
    required this.onTaskClick,
    required this.onTaskStatusChanged,
  });

  @override
  State<TaskBoardPage> createState() => _TaskBoardPageState();
}

class _TaskBoardPageState extends State<TaskBoardPage> {
  String _search = '';
  String _viewMode = 'board'; // board, list, calendar
  String _statusFilter = 'All'; // All, To Do, In Progress, Done
  String _dateFilter = 'all'; // all, overdue, today, week

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'to do': return AppColors.figmaTodo;
      case 'in progress': return Colors.amber;
      case 'done': return AppColors.emerald500;
      default: return AppColors.gray400;
    }
  }

  List<TaskItem> get _filteredTasks {
    final sSearch = widget.tasks.where((t) => t.title.toLowerCase().contains(_search.toLowerCase())).toList();
    
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final week = today.add(const Duration(days: 7));

    final sDate = sSearch.where((t) {
      if (t.dueDate.isEmpty) return _dateFilter == 'all';
      try {
        final d = DateFormat('yyyy-MM-dd').parse(t.dueDate);
        final deadline = DateTime(d.year, d.month, d.day);
        final isDone = t.status.toLowerCase().contains('done');
        if (_dateFilter == 'today') return deadline.isAtSameMomentAs(today) && !isDone;
        if (_dateFilter == 'week') return (deadline.isAtSameMomentAs(today) || deadline.isAfter(today)) && (deadline.isBefore(week) || deadline.isAtSameMomentAs(week)) && !isDone;
        if (_dateFilter == 'overdue') return deadline.isBefore(today) && !isDone;
        return true;
      } catch (_) { return true; }
    }).toList();

    if (_statusFilter == 'All') return sDate;
    return sDate.where((t) => t.status.toLowerCase() == _statusFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedTasks = _filteredTasks;
    final todoCount = displayedTasks.where((t) => t.status.toLowerCase() == 'to do').length;
    final progressCount = displayedTasks.where((t) => t.status.toLowerCase() == 'in progress').length;
    final doneCount = displayedTasks.where((t) => t.status.toLowerCase() == 'done').length;
    final totalFiltered = displayedTasks.length;
    final urgentCount = displayedTasks.where((t) => t.priority.toLowerCase() == 'urgent' && !t.status.toLowerCase().contains('done')).length;
    final completionPct = totalFiltered == 0 ? 0 : ((doneCount / totalFiltered) * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF5B7FFF), Color(0xFF7A9EFF)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 4, height: 20, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        Text('Current View', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(width: 8),
                        Text('filtered', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ),
                    if (urgentCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text('$urgentCount urgent', style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w500, color: Colors.white)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$totalFiltered', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(width: 8),
                        Text('total tasks', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ),
                    if (totalFiltered > 0) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Completion', style: GoogleFonts.outfit(fontSize: 7, color: Colors.white.withValues(alpha: 0.6))),
                                Text('$completionPct%', style: GoogleFonts.outfit(fontSize: 7, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.8))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 4,
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
                              child: FractionallySizedBox(
                                widthFactor: completionPct / 100,
                                alignment: Alignment.centerLeft,
                                child: Container(decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(2))),
                              ),
                            )
                          ],
                        ),
                      ),
                    ]
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Date Filters
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gray100))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 12, color: AppColors.gray400),
                    const SizedBox(width: 6),
                    Text('Due', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.gray500)),
                  ],
                ),
                Row(
                  children: [
                    _buildDateBtn('All', 'all'),
                    const SizedBox(width: 12),
                    _buildDateBtn('Overdue', 'overdue'),
                    const SizedBox(width: 12),
                    _buildDateBtn('Today', 'today'),
                    const SizedBox(width: 12),
                    _buildDateBtn('Week', 'week'),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search
          Container(
            height: 40,
            decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gray100)),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(LucideIcons.search, size: 14, color: AppColors.gray400),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: GoogleFonts.outfit(fontSize: 14, color: AppColors.gray800),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: GoogleFonts.outfit(fontSize: 14, color: AppColors.gray400),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // View Mode Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                _buildViewToggle('board', 'Board', LucideIcons.layoutGrid),
                _buildViewToggle('list', 'List', LucideIcons.list),
                _buildViewToggle('calendar', 'Calendar', LucideIcons.calendarDays),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Status Filters (List Only)
          if (_viewMode == 'list') ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusFilter('All', totalFiltered),
                  const SizedBox(width: 6),
                  _buildStatusFilter('To Do', todoCount),
                  const SizedBox(width: 6),
                  _buildStatusFilter('In Progress', progressCount),
                  const SizedBox(width: 6),
                  _buildStatusFilter('Done', doneCount),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.gray100, height: 1),
            const SizedBox(height: 16),
          ],

          // Content
          if (_viewMode == 'board') _buildBoard(displayedTasks),
          if (_viewMode == 'list') _buildList(displayedTasks),
          if (_viewMode == 'calendar') _buildCalendar(displayedTasks),
        ],
      ),
    );
  }

  Widget _buildDateBtn(String label, String id) {
    bool isSel = _dateFilter == id;
    Color c = AppColors.gray400;
    if (isSel) {
      if (id == 'overdue') c = Colors.redAccent;
      else if (id == 'today') c = Colors.amber;
      else c = const Color(0xFF5B7FFF);
    }
    return GestureDetector(
      onTap: () => setState(() => _dateFilter = id),
      child: Container(
        padding: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(border: isSel ? Border(bottom: BorderSide(color: c, width: 2)) : null),
        child: Text(label, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w500, color: isSel ? c : AppColors.gray400)),
      ),
    );
  }

  Widget _buildViewToggle(String id, String label, IconData icon) {
    bool isSel = _viewMode == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewMode = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSel ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSel ? const Color(0xFF5B7FFF) : AppColors.gray500),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: isSel ? const Color(0xFF5B7FFF) : AppColors.gray500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter(String label, int count) {
    bool isSel = _statusFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = label),
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
            Text('($count)', style: GoogleFonts.outfit(fontSize: 8, color: isSel ? Colors.white.withValues(alpha: 0.8) : AppColors.gray600)),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard(List<TaskItem> tasks) {
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Container(width: 48, height: 48, decoration: const BoxDecoration(color: AppColors.gray50, shape: BoxShape.circle), child: const Icon(LucideIcons.checkSquare, size: 20, color: AppColors.gray300)),
              const SizedBox(height: 12),
              Text('No tasks found', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.gray500)),
            ],
          ),
        ),
      );
    }

    Map<String, List<TaskItem>> grouped = {'To Do': [], 'In Progress': [], 'Done': []};
    for (var t in tasks) {
      String st = 'To Do';
      if (t.status.toLowerCase().contains('progress')) st = 'In Progress';
      else if (t.status.toLowerCase().contains('done')) st = 'Done';
      grouped[st]?.add(t);
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grouped.entries.map((e) => _buildBoardCol(e.key, e.value)).toList(),
      ),
    );
  }

  Widget _buildBoardCol(String title, List<TaskItem> tasks) {
    return KanbanColumn(
      title: title,
      count: tasks.length,
      dotColor: _statusColor(title),
      tasks: tasks,
      onTaskDrop: (task) {
        // Change the status according to the new column
        String newStatus = title;
        if (task.status != newStatus) {
          widget.onTaskStatusChanged(task, newStatus);
        }
      },
      itemBuilder: (ctx, t) => TaskTile(
        task: t,
        variant: TaskTileVariant.board,
        onTap: () => widget.onTaskClick(t),
      ),
    );
  }

  Widget _buildList(List<TaskItem> tasks) {
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Container(width: 48, height: 48, decoration: const BoxDecoration(color: AppColors.gray50, shape: BoxShape.circle), child: const Icon(LucideIcons.checkSquare, size: 20, color: AppColors.gray300)),
              const SizedBox(height: 12),
              Text('No tasks found', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.gray500)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (ctx, i) {
        final t = tasks[i];
        final isDone = t.status.toLowerCase().contains('done');
        return TaskTile(
          task: t,
          variant: TaskTileVariant.list,
          onTap: () => widget.onTaskClick(t),
          onStatusToggle: () => widget.onTaskStatusChanged(t, isDone ? 'To Do' : 'Done'),
        );
      },
    );
  }

  Widget _buildCalendar(List<TaskItem> tasks) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray100)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('MMMM yyyy').format(DateTime.now()), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800)),
              Row(
                children: [
                  Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(8)), child: const Icon(LucideIcons.chevronLeft, size: 16, color: AppColors.gray600)),
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(8)), child: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.gray600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'].map((d) => SizedBox(width: 32, child: Center(child: Text(d, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.gray400))))).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: 31,
            itemBuilder: (ctx, idx) {
              final day = idx + 1;
              final isToday = day == DateTime.now().day;
              final hasTasks = tasks.any((t) {
                if (t.dueDate.isEmpty) return false;
                try { return DateFormat('yyyy-MM-dd').parse(t.dueDate).day == day; } catch(_) { return false; }
              });

              return Container(
                decoration: BoxDecoration(color: isToday ? const Color(0xFF5B7FFF) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$day', style: GoogleFonts.outfit(fontSize: 12, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? Colors.white : AppColors.gray800)),
                      if (hasTasks) ...[
                        const SizedBox(height: 2),
                        Container(width: 4, height: 4, decoration: BoxDecoration(color: isToday ? Colors.white : const Color(0xFF5B7FFF), shape: BoxShape.circle)),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
          if (tasks.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(children: [Text('Upcoming Tasks', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray800))]),
            const SizedBox(height: 12),
            _buildList(tasks.take(3).toList()),
          ]
        ],
      ),
    );
  }
}
