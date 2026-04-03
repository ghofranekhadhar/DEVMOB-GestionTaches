import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_item.dart';
import '../utils/app_colors.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final int count;
  final Color dotColor;
  final List<TaskItem> tasks;
  final Widget Function(BuildContext, TaskItem) itemBuilder;
  final Function(TaskItem) onTaskDrop;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.count,
    required this.dotColor,
    required this.tasks,
    required this.itemBuilder,
    required this.onTaskDrop,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<TaskItem>(
      onWillAcceptWithDetails: (details) {
        // Optionnel : on pourrait refuser de drop dans la même colonne, 
        // ou d'autres règles métiers. Pour l'instant, on accepte tout.
        return true;
      },
      onAcceptWithDetails: (details) {
        onTaskDrop(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovered = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovered ? AppColors.figmaHeroStart.withValues(alpha: 0.1) : AppColors.gray50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered ? AppColors.figmaHeroStart : AppColors.gray100,
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 2,
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$count',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (ctx, i) {
                  final task = tasks[i];
                  return Draggable<TaskItem>(
                    data: task,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Opacity(
                        opacity: 0.8,
                        child: SizedBox(
                          width: 280 - 24, // Matches the column width minus padding
                          child: itemBuilder(ctx, task),
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: itemBuilder(ctx, task),
                    ),
                    child: itemBuilder(ctx, task),
                  );
                },
              ),
              // Feedback visuel au survol si la colonne est vide
              if (tasks.isEmpty && isHovered)
                Container(
                  height: 60,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: AppColors.figmaHeroStart.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.figmaHeroStart.withValues(alpha: 0.5),
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
