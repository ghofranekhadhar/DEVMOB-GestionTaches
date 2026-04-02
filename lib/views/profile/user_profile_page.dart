import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../models/task_item.dart';
import '../../models/project.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';

class UserProfilePage extends StatelessWidget {
  final UserModel member;
  final List<TaskItem> memberTasks;
  final List<Project> memberProjects;
  final VoidCallback onClose;
  final Function(TaskItem) onTaskClick;
  final Function(Project) onProjectClick;

  const UserProfilePage({
    super.key,
    required this.member,
    required this.memberTasks,
    required this.memberProjects,
    required this.onClose,
    required this.onTaskClick,
    required this.onProjectClick,
  });

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "N/A";
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mName = member.name;
    final mInitials = mName.length >= 2
        ? mName.substring(0, 2).toUpperCase()
        : mName.toUpperCase();

    final completedTasks = memberTasks
        .where(
          (t) =>
              t.status.toLowerCase().contains('done') ||
              t.status.toLowerCase().contains('terminé'),
        )
        .length;
    final totalTasks = memberTasks.length;
    final perc = totalTasks == 0
        ? 0
        : ((completedTasks / totalTasks) * 100).round();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.accent.withOpacity(0.2),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    mInitials,
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mName,
                                      style: GoogleFonts.outfit(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gray800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            member.role.isNotEmpty
                                                ? '${member.role[0].toUpperCase()}${member.role.substring(1).toLowerCase()}'
                                                : 'Collaborateurr',
                                            style: GoogleFonts.outfit(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          LucideIcons.mapPin,
                                          size: 10,
                                          color: AppColors.gray400,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Tunisie',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            color: AppColors.gray500,
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
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.gray100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              LucideIcons.x,
                              size: 20,
                              color: AppColors.gray600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Contact Info Cards
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gray100),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.mail,
                                  size: 14,
                                  color: AppColors.gray400,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    member.email,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppColors.gray600,
                                    ),
                                    maxLines: 1,
                                  ),
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
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gray100),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.phone,
                                  size: 14,
                                  color: AppColors.gray400,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '+1 (555) 000-0000',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Stats Summary
                    Row(
                      children: [
                        _buildSummaryBox(
                          LucideIcons.checkCircle2,
                          AppColors.emerald500,
                          'Tasks Done',
                          '$completedTasks/$totalTasks',
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryBox(
                          LucideIcons.folder,
                          AppColors.accent,
                          'Projects',
                          '${memberProjects.length}',
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryBox(
                          LucideIcons.activity,
                          AppColors.amber500,
                          'Success Rate',
                          '$perc%',
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Associated Projects
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Associated Projects',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gray200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${memberProjects.length}',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (memberProjects.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.gray200,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'No assigned projects',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.gray400,
                            ),
                          ),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: memberProjects.map((p) {
                            return GestureDetector(
                              onTap: () {
                                onClose();
                                onProjectClick(p);
                              },
                              child: Container(
                                width: 220,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.gray100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: AppColors.accent.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            LucideIcons.folderKanban,
                                            size: 10,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            p.name,
                                            style: GoogleFonts.outfit(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.gray800,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          p.status,
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            color:
                                                p.status.toLowerCase() ==
                                                    'completed'
                                                ? AppColors.emerald600
                                                : AppColors.accent,
                                          ),
                                        ),
                                        Text(
                                          _formatDate(p.deadline),
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            color: AppColors.gray400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Current Assigned Tasks
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Assigned Tasks',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$totalTasks',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (memberTasks.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.gray200,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                LucideIcons.checkSquare,
                                size: 32,
                                color: AppColors.gray300,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No assigned tasks',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppColors.gray400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: memberTasks.map((t) {
                          final isDone =
                              t.status.toLowerCase().contains("done") ||
                              t.status.toLowerCase().contains("terminé");
                          return GestureDetector(
                            onTap: () {
                              onClose();
                              onTaskClick(t);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.gray100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.01),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isDone
                                          ? AppColors.emerald50
                                          : AppColors.gray50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isDone
                                          ? LucideIcons.checkCircle2
                                          : t.status.toLowerCase().contains(
                                              'progress',
                                            )
                                          ? LucideIcons.loader2
                                          : LucideIcons.circle,
                                      size: 14,
                                      color: isDone
                                          ? AppColors.emerald500
                                          : AppColors.gray400,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.title,
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
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                t.projectName,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 9,
                                                  color: AppColors.gray400,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 4,
                                              height: 4,
                                              decoration: const BoxDecoration(
                                                color: AppColors.gray300,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              LucideIcons.calendar,
                                              size: 9,
                                              color: AppColors.gray400,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatDate(t.dueDate),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.getStatusBgColor(
                                        t.status,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      t.status,
                                      style: GoogleFonts.outfit(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.getStatusColor(
                                          t.status,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryBox(
    IconData icon,
    Color color,
    String label,
    String value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 9, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
