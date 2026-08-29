import 'package:flutter/material.dart';

class AppColors {
  // Base Palette - Premium Dark Navy & Slate
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);

  // Light Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Accents
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color accentViolet = Color(0xFF7C3AED);
  static const Color accentVioletLight = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);

  // Match / Status Colors
  static const Color matchStrong = Color(0xFF10B981); // Green
  static const Color matchPartial = Color(0xFFF59E0B); // Amber/Yellow
  static const Color matchMissing = Color(0xFFEF4444); // Red
  static const Color matchInfo = Color(0xFF3B82F6); // Blue

  // Priority Colors
  static const Color priorityCritical = Color(0xFFDC2626);
  static const Color priorityHigh = Color(0xFFEA580C);
  static const Color priorityMedium = Color(0xFFD97706);
  static const Color priorityLow = Color(0xFF059669);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, accentViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scoreGradient = LinearGradient(
    colors: [primaryBlueLight, accentVioletLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
