// Paleta de cores cruas — valores hex sem semântica.
// Não importe este arquivo em features. Use context.colors via ds.dart.
import 'package:flutter/material.dart';

abstract final class DSColorsPrimitive {
  // Brand
  static const Color blue50  = Color(0xFFEFF6FF);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue500 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8); // primary

  // Neutrals
  static const Color slate50  = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate800 = Color(0xFF1E293B); // textPrimary atual
  static const Color slate900 = Color(0xFF0F172A);

  // Dark surfaces
  static const Color darkSurface    = Color(0xFF1E293B);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkBorder     = Color(0xFF334155);
  static const Color darkSubtle     = Color(0xFF1E293B);

  // iOS surfaces
  static const Color iosBackground = Color(0xFFF2F2F7);
  static const Color iosSeparator  = Color(0xFFC6C6C8);

  // Semantic raw
  static const Color orange500 = Color(0xFFF97316);
  static const Color green500  = Color(0xFF10B981);
  static const Color green100  = Color(0xFFD1FAE5);
  static const Color red500    = Color(0xFFEF4444);
  static const Color red100    = Color(0xFFFECACA);
  static const Color amber500  = Color(0xFFF59E0B);
  static const Color amber100  = Color(0xFFFEF3C7);
  static const Color sky500    = Color(0xFF3B82F6);
  static const Color sky100    = Color(0xFFDBEAFE);
}
