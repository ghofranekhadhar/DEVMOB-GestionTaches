import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/task_service.dart';
import '../../models/task_item.dart';
import '../../models/project.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  String? _selectedProjectId;
  String? _selectedProjectName;
  String _selectedPriority = 'medium';
  bool _isLoading = false;

  final TaskService _taskService = TaskService();

  // Colors from HomePage for consistency
  final colorAccent = const Color(0xFF517db0);
  final colorBgStart = const Color(0xFFF0F2F9);
  final colorBgEnd = const Color(0xFFF9FAFF);
  final colorGray900 = const Color(0xFF1E293B);
  final colorGray400 = const Color(0xFF94A3B8);
  final colorGray100 = const Color(0xFFF1F5F9);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorAccent,
              onPrimary: Colors.white,
              onSurface: colorGray900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueDate) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedProjectId == null || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) throw Exception('Utilisateur non connecté');

      final newTask = TaskItem(
        id: '',
        title: title,
        description: _descriptionController.text.trim(),
        assignedTo: user.id,
        createdBy: user.id,
        dueDate: DateFormat('yyyy-MM-dd').format(_dueDate!),
        status: 'To Do',
        projectId: _selectedProjectId!,
        projectName: _selectedProjectName ?? '',
        priority: _selectedPriority,
        comments: [],
      );

      await _taskService.createTask(newTask);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Tâche ajoutée avec succès !'), backgroundColor: colorAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [colorBgStart, colorBgEnd])),
        child: Stack(
          children: [
            Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(color: colorAccent.withOpacity(0.1), shape: BoxShape.circle))),
            Positioned(bottom: -50, left: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(color: Colors.pink.withOpacity(0.05), shape: BoxShape.circle))),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white)),
                            child: Icon(Icons.chevron_left, color: colorGray900),
                          ),
                        ),
                        Text('Create Task', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: colorGray900)),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('TASK TITLE', isRequired: true),
                          const SizedBox(height: 8),
                          _buildTextField('e.g. Design Login Page', _titleController),
                          const SizedBox(height: 24),

                          _buildSectionTitle('DESCRIPTION', isRequired: false),
                          const SizedBox(height: 8),
                          _buildTextField('Task details...', _descriptionController, maxLines: 3),
                          const SizedBox(height: 24),

                          _buildSectionTitle('PROJECT', isRequired: true),
                          const SizedBox(height: 8),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('projects').snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const LinearProgressIndicator();
                              final projects = snapshot.data!.docs.map((d) => Project.fromFirestore(d)).toList();
                              
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: colorGray100)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    hint: Text("Select a project", style: GoogleFonts.outfit(fontSize: 14, color: colorGray400)),
                                    value: _selectedProjectId,
                                    items: projects.map((p) => DropdownMenuItem(
                                      value: p.id,
                                      child: Text(p.name, style: GoogleFonts.outfit(fontSize: 14, color: colorGray900)),
                                    )).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedProjectId = val;
                                        _selectedProjectName = projects.firstWhere((p) => p.id == val).name;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('DUE DATE', isRequired: true),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () => _selectDate(context),
                                      child: Container(
                                        height: 56,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: colorGray100)),
                                        child: Row(
                                          children: [
                                            Icon(LucideIcons.calendar, color: colorAccent, size: 18),
                                            const SizedBox(width: 12),
                                            Text(
                                              _dueDate == null ? "Select date" : DateFormat('MMM d').format(_dueDate!),
                                              style: GoogleFonts.outfit(color: _dueDate == null ? colorGray400 : colorGray900, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('PRIORITY', isRequired: true),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: colorGray100)),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: _selectedPriority,
                                          items: ['low', 'medium', 'high', 'urgent'].map((p) => DropdownMenuItem(
                                            value: p,
                                            child: Text(p.substring(0,1).toUpperCase() + p.substring(1), style: GoogleFonts.outfit(fontSize: 13, color: colorGray900)),
                                          )).toList(),
                                          onChanged: (val) => setState(() => _selectedPriority = val!),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),

                          Container(
                            width: double.infinity, height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(colors: [colorAccent, colorAccent.withOpacity(0.8)]),
                              boxShadow: [BoxShadow(color: colorAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text('Create New Task', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required bool isRequired}) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 1.0)),
        if (isRequired) const Text(' *', style: TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.outfit(color: const Color(0xFF1E293B), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF818CF8), width: 2)),
      ),
    );
  }
}
