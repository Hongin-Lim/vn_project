// lib/utils/grade_utils.dart
import 'package:flutter/material.dart';

String getGradeIcon(String? grade) {
  switch(grade?.toLowerCase()) {
    case 'bronze':
      return '🥉';
    case 'silver':
      return '🥈';
    case 'gold':
      return '🥇';
    case 'platinum':
      return '💎';
    default:
      return '🥉';
      // return '🔰';
  }
}

Color getGradeColor(String? grade) {
  switch(grade?.toLowerCase()) {
    case 'bronze':
      return Color(0xFFCD7F32);
    case 'silver':
      return Color(0xFFC0C0C0);
    case 'gold':
      return Color(0xFFFFD700);
    case 'platinum':
      return Color(0xFFE5E4E2);
    default:
      return Colors.grey;
  }
}