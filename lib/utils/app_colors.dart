import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // DASH-CORCT Figma Explicit Colors
  static const Color figmaBg = Color(0xFFF4F7FA);
  static const Color figmaHeroStart = Color(0xFF6388E4);
  static const Color figmaHeroEnd = Color(0xFF4B6DBF);
  static const Color figmaUrgentBg = Color(0xFFFDECEA);
  static const Color figmaUrgent = Color(0xFFE53935);
  static const Color figmaDone = Color(0xFF10B981);
  static const Color figmaTodo = Color(0xFF5C85E5);
  static const Color figmaInProgress = Color(0xFFF4B400);

  static const Color accent = Color(0xFF5B7FFF);
  static const Color accentLight = Color(0xFF7A9EFF);
  static const Color accentDark = Color(0xFF4A6FD9);
  
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);

  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);

  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);

  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange600 = Color(0xFFEA580C);

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent': return red600;
      case 'high': return orange600;
      case 'medium': return amber600;
      case 'low': return gray500;
      default: return gray500;
    }
  }

  static Color getPriorityBgColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent': return red50;
      case 'high': return orange50;
      case 'medium': return amber50;
      case 'low': return gray50;
      default: return gray50;
    }
  }

  static Color getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('done') || s.contains('terminé')) return emerald600;
    if (s.contains('in progress') || s.contains('en cours')) return amber600;
    return accent;
  }

  static Color getStatusBgColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('done') || s.contains('terminé')) return emerald50;
    if (s.contains('in progress') || s.contains('en cours')) return amber50;
    return accent.withOpacity(0.1);
  }
}
