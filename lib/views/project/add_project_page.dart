import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/project_service.dart';
import '../../models/project.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _deadline;
  bool _isLoading = false;

  final ProjectService _projectService = ProjectService();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF818CF8),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _deadline) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) throw Exception('Utilisateur non connecté');

      final newProject = Project(
        id: '',
        name: name,
        description: _descriptionController.text.trim(),
        deadline: _deadline != null ? DateFormat('yyyy-MM-dd').format(_deadline!) : '',
        members: [user.id],
        createdBy: user.id,
        status: 'active',
        completionPercentage: 0,
      );

      await _projectService.createProject(newProject);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Projet créé avec succès !'), backgroundColor: Color(0xFF818CF8)),
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
    const tintIndigo = Color(0xFF818CF8);
    const colorGray900 = Color(0xFF1E293B);
    const colorGray400 = Color(0xFF94A3B8);
    const colorGray100 = Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: colorGray100)),
                      child: const Icon(Icons.chevron_left, color: colorGray900),
                    ),
                  ),
                  Text('Create New Project', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: colorGray900)),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('PROJECT NAME', isRequired: true),
                    const SizedBox(height: 8),
                    _buildTextField('e.g. Mobile Application', _nameController),
                    const SizedBox(height: 24),

                    _buildSectionTitle('DESCRIPTION', isRequired: false),
                    const SizedBox(height: 8),
                    _buildTextField('Project goals and details...', _descriptionController, maxLines: 3),
                    const SizedBox(height: 24),

                    _buildSectionTitle('DEADLINE', isRequired: false),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: colorGray100)),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.calendar, color: tintIndigo, size: 18),
                            const SizedBox(width: 12),
                            Text(
                              _deadline == null ? "Select deadline" : DateFormat('MMMM d, yyyy').format(_deadline!),
                              style: GoogleFonts.outfit(color: _deadline == null ? colorGray400 : colorGray900, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tintIndigo,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text('Create Project', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
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
