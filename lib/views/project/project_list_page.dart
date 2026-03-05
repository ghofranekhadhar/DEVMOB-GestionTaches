import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../models/task_item.dart';
import '../../models/project.dart';
import '../../utils/app_colors.dart';
import '../../widgets/project_card.dart';

class ProjectListPage extends StatefulWidget {
  final List<Project> projects;
  final List<TaskItem> allTasks;
  final Function(Project) onProjectClick;

  const ProjectListPage({
    super.key,
    required this.projects,
    required this.allTasks,
    required this.onProjectClick,
  });

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  String _searchQuery = "";
  String _statusFilter = "all"; // all, active, completed
  String _sortOrder = "asc"; // asc, desc

  @override
  Widget build(BuildContext context) {
    var filteredProjects = widget.projects;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredProjects = filteredProjects
          .where((p) => p.name.toLowerCase().contains(q))
          .toList();
    }

    if (_statusFilter != "all") {
      filteredProjects = filteredProjects.where((p) {
        final st = p.status.toLowerCase().trim();
        if (_statusFilter == "active") {
          // Active = not completed and not 100%
          final isCompleted = st == "completed" || st == "done" || p.completionPercentage >= 100;
          return !isCompleted;
        }
        if (_statusFilter == "completed") {
          // Completed = status is done/completed OR completionPercentage is 100
          return st == "completed" || st == "done" || p.completionPercentage >= 100;
        }
        return true;
      }).toList();
    }

    filteredProjects.sort((a, b) {
      DateTime da;
      DateTime db;
      try {
        da = DateFormat('yyyy-MM-dd').parse(a.deadline);
      } catch (_) {
        da = DateTime.now();
      }
      try {
        db = DateFormat('yyyy-MM-dd').parse(b.deadline);
      } catch (_) {
        db = DateTime.now();
      }
      return _sortOrder == "asc" ? da.compareTo(db) : db.compareTo(da);
    });

    int completedCount = widget.projects.where((p) {
      final st = p.status.toLowerCase().trim();
      return st == "completed" || st == "done" || p.completionPercentage >= 100;
    }).length;
    int activeCount = widget.projects.length - completedCount;

    int grandTotalTasks = widget.allTasks.length;
    int grandTotalDone = widget.allTasks
        .where((t) => t.status.toLowerCase().contains('done'))
        .length;
    int overallPercentage = grandTotalTasks == 0
        ? 0
        : ((grandTotalDone / grandTotalTasks) * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B7FFF), Color(0xFF7A9EFF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Overview',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              'Projects & tasks summary',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$overallPercentage%',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'completed',
                            style: GoogleFonts.outfit(
                              fontSize: 8,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Sort Row
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.gray100),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.calendar,
                            size: 12,
                            color: AppColors.gray400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sort by due date',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildSortBtn('Soon first', 'asc'),
                          _buildSortBtn('Later first', 'desc'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gray100),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.search,
                        size: 14,
                        color: AppColors.gray400,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppColors.gray800,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search projects...',
                            hintStyle: GoogleFonts.outfit(
                              fontSize: 14,
                              color: AppColors.gray400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Status Filters
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatusBtn(
                          'All (${widget.projects.length})',
                          'all',
                        ),
                      ),
                      Expanded(
                        child: _buildStatusBtn(
                          'Active ($activeCount)',
                          'active',
                        ),
                      ),
                      Expanded(
                        child: _buildStatusBtn(
                          'Completed ($completedCount)',
                          'completed',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Project List
                if (filteredProjects.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: AppColors.gray50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.folderKanban,
                              size: 40,
                              color: AppColors.gray300,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No projects found',
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
                    children: filteredProjects
                        .map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ProjectCard(
                              project: p,
                              tasks: widget.allTasks
                                  .where((t) => t.projectId == p.id)
                                  .toList(),
                              onTap: () => widget.onProjectClick(p),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBtn(String label, String value) {
    bool isSel = _sortOrder == value;
    return GestureDetector(
      onTap: () => setState(() => _sortOrder = value),
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSel ? AppColors.figmaTodo : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: isSel ? AppColors.figmaTodo : AppColors.gray400,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBtn(String label, String value) {
    bool isSel = _statusFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColors.figmaTodo : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSel
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSel ? Colors.white : AppColors.gray500,
          ),
        ),
      ),
    );
  }

}

