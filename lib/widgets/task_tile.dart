import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';
import '../utils/app_colors.dart';

/// Variantes d'affichage pour le widget [TaskTile].
enum TaskTileVariant {
  /// Mode liste : checkbox + titre + badge statut + infos (priorité, projet, date).
  /// Utilisé dans le dashboard et la vue liste des tâches.
  list,

  /// Mode board (kanban) : badge priorité + titre + description + projet + date.
  /// Utilisé dans la vue kanban du tableau des tâches.
  board,
}

/// Widget réutilisable pour afficher une tuile de tâche.
///
/// Supporte deux variantes via [variant] :
/// - [TaskTileVariant.list] : affichage en liste avec checkbox interactive.
/// - [TaskTileVariant.board] : carte kanban avec badge priorité et description.
class TaskTile extends StatelessWidget {
  final TaskItem task;
  final TaskTileVariant variant;
  final VoidCallback? onTap;

  /// Callback optionnel pour le toggle de statut via le checkbox (mode liste uniquement).
  /// Si null, le checkbox est affiché mais non interactif.
  final VoidCallback? onStatusToggle;

  const TaskTile({
    super.key,
    required this.task,
    this.variant = TaskTileVariant.list,
    this.onTap,
    this.onStatusToggle,
  });

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      default:
        return AppColors.gray400;
    }
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'to do':
        return AppColors.figmaTodo;
      case 'in progress':
        return Colors.amber;
      case 'done':
        return AppColors.emerald500;
      default:
        return AppColors.gray400;
    }
  }

  bool _isOverdue(String? d, bool isDone) {
    if (d == null || d.isEmpty || isDone) return false;
    try {
      final du = DateFormat('yyyy-MM-dd').parse(d);
      final dl = DateTime(du.year, du.month, du.day);
      final n = DateTime.now();
      final today = DateTime(n.year, n.month, n.day);
      return dl.isBefore(today);
    } catch (_) {
      return false;
    }
  }

  String _fmtDate(String? d) {
    if (d == null || d.isEmpty) return 'No Date';
    try {
      final p = DateFormat('yyyy-MM-dd').parse(d);
      return DateFormat('MMM d, yyyy').format(p);
    } catch (_) {
      return d;
    }
  }

  @override
  Widget build(BuildContext context) {
    return variant == TaskTileVariant.board ? _buildBoard() : _buildList();
  }

  // ──────────────────────────────────────────────
  // LIST VARIANT  (dashboard + task list view)
  // ──────────────────────────────────────────────

  Widget _buildList() {
    final isDone = task.status.toLowerCase().contains('done');
    final isOverdue = _isOverdue(task.dueDate, isDone);
    final pCol = _priorityColor(task.priority);
    final sCol = _statusColor(task.status);

    // Checkbox widget — interactif si onStatusToggle est fourni
    Widget checkbox = Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: isDone ? AppColors.emerald500 : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDone ? AppColors.emerald500 : AppColors.gray300,
          width: 2,
        ),
      ),
      child: isDone
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );

    if (onStatusToggle != null) {
      checkbox = GestureDetector(onTap: onStatusToggle, child: checkbox);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            checkbox,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row + status badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: pCol,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                task.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDone
                                      ? AppColors.gray400
                                      : AppColors.gray800,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: sCol.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.status,
                          style: GoogleFonts.outfit(
                            fontSize: 7,
                            fontWeight: FontWeight.w600,
                            color: sCol,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Info row : priority · project · date
                  Row(
                    children: [
                      Text(
                        task.priority.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 7,
                          fontWeight: FontWeight.w500,
                          color: pCol,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.gray300,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        LucideIcons.folderKanban,
                        size: 8,
                        color: AppColors.gray300,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          task.projectName,
                          style: GoogleFonts.outfit(
                            fontSize: 8,
                            color: AppColors.gray400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.gray300,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        LucideIcons.calendar,
                        size: 8,
                        color: AppColors.gray300,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _fmtDate(task.dueDate),
                        style: GoogleFonts.outfit(
                          fontSize: 8,
                          fontWeight:
                              isOverdue ? FontWeight.w600 : FontWeight.normal,
                          color: isOverdue ? Colors.red : AppColors.gray400,
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

  // ──────────────────────────────────────────────
  // BOARD VARIANT  (kanban card)
  // ──────────────────────────────────────────────

  Widget _buildBoard() {
    final isDone = task.status.toLowerCase().contains('done');
    final pCol = _priorityColor(task.priority);
    final isOverdue = _isOverdue(task.dueDate, isDone);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority badge + more icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: pCol.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.priority.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: pCol,
                    ),
                  ),
                ),
                const Icon(
                  LucideIcons.moreHorizontal,
                  size: 14,
                  color: AppColors.gray400,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              task.title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDone ? AppColors.gray400 : AppColors.gray800,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Description (optional)
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: isDone ? AppColors.gray300 : AppColors.gray500,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),

            // Footer : project + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.folderKanban,
                        size: 10,
                        color: AppColors.gray400,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          task.projectName,
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            color: AppColors.gray500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      size: 10,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _fmtDate(task.dueDate),
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight:
                            isOverdue ? FontWeight.w600 : FontWeight.normal,
                        color: isOverdue ? Colors.red : AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
