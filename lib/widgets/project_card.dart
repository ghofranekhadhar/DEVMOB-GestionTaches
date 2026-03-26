import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';
import '../models/task_item.dart';
import '../utils/app_colors.dart';

/// Widget réutilisable pour afficher une carte de projet.
///
/// Supporte deux variantes :
/// - [compact] = false (défaut) : carte détaillée avec description, stats,
///   barre de progression, deadline et nombre de membres.
/// - [compact] = true : carte résumée horizontale pour le dashboard.
class ProjectCard extends StatelessWidget {
  final Project project;
  final List<TaskItem> tasks;
  final VoidCallback? onTap;
  final bool compact;

  const ProjectCard({
    super.key,
    required this.project,
    required this.tasks,
    this.onTap,
    this.compact = false,
  });

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
    return compact ? _buildCompact() : _buildFull();
  }

  // ──────────────────────────────────────────────
  // FULL VARIANT  (project_list_page)
  // ──────────────────────────────────────────────

  Widget _buildFull() {
    final bool isActive = project.status.toLowerCase() == 'active';
    final doneCount =
        tasks.where((t) => t.status.toLowerCase().contains('done')).length;
    final inProgressCount =
        tasks.where((t) => t.status.toLowerCase().contains('progress')).length;
    final todoCount =
        tasks.where((t) => t.status.toLowerCase().contains('to do')).length;
    final percentage =
        tasks.isEmpty ? 0 : ((doneCount / tasks.length) * 100).round();

    DateTime? deadline;
    try {
      deadline = DateFormat('yyyy-MM-dd').parse(project.deadline);
    } catch (_) {}
    final bool isOverdue =
        deadline != null && deadline.isBefore(DateTime.now()) && isActive;
    final int daysLeft =
        deadline != null ? deadline.difference(DateTime.now()).inDays : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
          children: [
            // Header : icon + name + description + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.figmaTodo.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.folderKanban,
                          size: 18,
                          color: AppColors.figmaTodo,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray800,
                              ),
                            ),
                            Text(
                              project.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.emerald500.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Completed',
                    style: GoogleFonts.outfit(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: isActive ? AppColors.emerald500 : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Task stats row
            Row(
              children: [
                _buildStatItem(
                  LucideIcons.circle,
                  AppColors.figmaTodo,
                  'To Do',
                  todoCount,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  LucideIcons.loader,
                  Colors.amber,
                  'Doing',
                  inProgressCount,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  LucideIcons.checkCircle,
                  AppColors.emerald500,
                  'Done',
                  doneCount,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            if (tasks.isNotEmpty)
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  if (percentage > 0)
                    FractionallySizedBox(
                      widthFactor: percentage / 100,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.figmaTodo,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                ],
              )
            else
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'No tasks yet',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: AppColors.gray400,
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Footer : deadline + members + overdue
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.gray50)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.calendar,
                        size: 10,
                        color: AppColors.gray400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${_formatDate(project.deadline)}${(!isOverdue && daysLeft <= 7 && daysLeft > 0 && isActive) ? ' ($daysLeft d left)' : ''}',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          color: isOverdue ? Colors.red : AppColors.gray500,
                          fontWeight:
                              isOverdue ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.users,
                        size: 10,
                        color: AppColors.gray400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${project.members.length} members',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                  if (isOverdue && isActive)
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.alertCircle,
                          size: 8,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Overdue',
                          style: GoogleFonts.outfit(
                            fontSize: 7,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String label, int count) {
    return Row(
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 10, color: AppColors.gray600),
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // COMPACT VARIANT  (dashboard horizontal list)
  // ──────────────────────────────────────────────

  Widget _buildCompact() {
    final totalCount = tasks.length;
    final doneCount =
        tasks.where((t) => t.status.toLowerCase().contains('done')).length;
    final pTodo = tasks
        .where(
          (t) =>
              t.status.toLowerCase().contains('todo') ||
              t.status.toLowerCase().contains('to do'),
        )
        .length;
    final pProg =
        tasks.where((t) => t.status.toLowerCase().contains('progress')).length;
    final pPerc =
        totalCount == 0 ? 0 : ((doneCount / totalCount) * 100).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray100),
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
                    color: pPerc == 100
                        ? AppColors.figmaDone.withValues(alpha: 0.1)
                        : AppColors.figmaHeroStart.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    pPerc == 100
                        ? LucideIcons.checkCircle2
                        : LucideIcons.folderKanban,
                    size: 14,
                    color: pPerc == 100
                        ? AppColors.figmaDone
                        : AppColors.figmaHeroStart,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${project.members.length} members',
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$pPerc% complete',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                  ),
                ),
                Text(
                  '$doneCount/$totalCount',
                  style: GoogleFonts.outfit(
                    fontSize: 8,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pPerc > 100 ? 1 : pPerc / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.figmaHeroStart,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.figmaHeroStart,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'To Do ($pTodo)',
                        style: GoogleFonts.outfit(
                          fontSize: 7,
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.figmaInProgress,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Doing ($pProg)',
                        style: GoogleFonts.outfit(
                          fontSize: 7,
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
