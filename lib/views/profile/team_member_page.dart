import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/task_item.dart';
import '../../models/project.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';

class TeamMemberPage extends StatefulWidget {
  final List<UserModel> allUsers;
  final List<TaskItem> allTasks;
  final List<Project> projects;
  final UserModel currentUser;
  final Function(UserModel) onMemberClick;

  const TeamMemberPage({
    super.key,
    required this.allUsers,
    required this.allTasks,
    required this.projects,
    required this.currentUser,
    required this.onMemberClick,
  });

  @override
  State<TeamMemberPage> createState() => _TeamMemberPageState();
}

class _TeamMemberPageState extends State<TeamMemberPage> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // Include ALL users — current user appears first with a "You" badge
    // Sort: current user first, then others alphabetically
    var allMembers = [
      ...widget.allUsers.where((u) => u.id == widget.currentUser.id),
      ...widget.allUsers.where((u) => u.id != widget.currentUser.id),
    ];

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      allMembers = allMembers.where((u) {
        final n = u.name.toLowerCase();
        return n.contains(q) || u.email.toLowerCase().contains(q);
      }).toList();
    }

    final filteredMembers = allMembers;

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
                // Header Card - Gradient
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF5B7FFF), Color(0xFF7A9EFF)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 4, height: 20, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 8),
                          Text('Team', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text('Connect and collaborate', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.users, size: 12, color: Colors.white),
                                const SizedBox(width: 6),
                                Text('${filteredMembers.length} Members', style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w500, color: Colors.white)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.activity, size: 12, color: Colors.white),
                                const SizedBox(width: 6),
                                Text('Active Team', style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w500, color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Search Input
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
                      const Icon(LucideIcons.search, size: 14, color: AppColors.gray400),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.gray800),
                          decoration: InputDecoration(
                            hintText: 'Find a team member...',
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

                // Members List
                if (filteredMembers.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.figmaTodo.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(LucideIcons.users, size: 24, color: AppColors.figmaTodo)),
                          const SizedBox(height: 12),
                          Text('No members found', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gray500)),
                          const SizedBox(height: 4),
                          Text('Try a different search term', style: GoogleFonts.outfit(fontSize: 9, color: AppColors.gray400)),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: filteredMembers.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMemberCard(m),
                    )).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(UserModel member) {
    final name = member.name;
    final initials = name.trim().split(RegExp(r'\s+')).take(2).map((e) => e[0]).join().toUpperCase();

    final isCurrentUser = member.id == widget.currentUser.id;
    
    final mTasks = widget.allTasks.where((t) => t.assignedTo == member.id).toList();
    final doneCount = mTasks.where((t) => t.status.toLowerCase().contains("done")).length;
    final total = mTasks.length;
    final percentage = total == 0 ? 0 : ((doneCount / total) * 100).round();

    return GestureDetector(
      onTap: () => widget.onMemberClick(member),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrentUser ? AppColors.figmaTodo.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCurrentUser ? AppColors.figmaTodo.withValues(alpha: 0.3) : AppColors.gray100),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.figmaTodo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.figmaTodo.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Text(initials, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.figmaTodo)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800), overflow: TextOverflow.ellipsis),
                            ),
                            if (isCurrentUser) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(color: AppColors.figmaTodo, borderRadius: BorderRadius.circular(999)),
                                child: Text('You', style: GoogleFonts.outfit(fontSize: 7, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight, size: 14, color: AppColors.gray300),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(LucideIcons.mail, size: 9, color: AppColors.gray400),
                      const SizedBox(width: 4),
                      Text(member.email, style: GoogleFonts.outfit(fontSize: 9, color: AppColors.gray400)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.figmaTodo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9999)),
                    child: Text(
                      member.role.isNotEmpty ? '${member.role[0].toUpperCase()}${member.role.substring(1).toLowerCase()}' : 'Collaborateur',
                      style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w500, color: AppColors.figmaTodo),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(total == 0 ? '0/0 tasks' : '$doneCount/$total tasks', style: GoogleFonts.outfit(fontSize: 7, color: AppColors.gray400)),
                      Text('$percentage%', style: GoogleFonts.outfit(fontSize: 7, fontWeight: FontWeight.w500, color: percentage == 0 ? AppColors.gray400 : AppColors.figmaTodo)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Bar always visible: gray at 0%, blue if > 0%
                  Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(2)),
                      ),
                      if (percentage > 0)
                        FractionallySizedBox(
                          widthFactor: percentage / 100,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(color: AppColors.figmaTodo, borderRadius: BorderRadius.circular(2)),
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
}
