// Shim de compatibilidade — aponte para o design system.
// Todas as features continuam funcionando sem alteração.
// Migre para context.colors / DSTheme na fase 2 e remova este arquivo.
import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

import '../../design_system/tokens/ds_colors_primitive.dart'; // não exportado via ds.dart

@Deprecated('Use context.colors via ds.dart')
class AppTheme {
  // ── Cores ─────────────────────────────────────────────────────────────────
  static const Color primaryColor    = DSColorsPrimitive.blue700;
  static const Color secondaryColor  = DSColorsPrimitive.orange500;
  static const Color backgroundColor = DSColorsPrimitive.slate50;
  static const Color textPrimary     = DSColorsPrimitive.slate800;
  static const Color textSecondary   = DSColorsPrimitive.slate500;
  static const Color borderColor     = DSColorsPrimitive.slate200;
  static const Color errorColor      = DSColorsPrimitive.red500;
  static const Color successColor    = DSColorsPrimitive.green500;
  static const Color warningColor    = DSColorsPrimitive.amber500;
  static const Color infoColor       = DSColorsPrimitive.sky500;
  static const Color surfaceSubtle   = DSColorsPrimitive.slate100;

  // ── Tema ──────────────────────────────────────────────────────────────────
  static ThemeData get light => DSTheme.light;
}
