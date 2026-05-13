// Sombras padronizadas para superfícies elevadas.
// Use como: boxShadow: DSElevation.sm
import 'package:flutter/material.dart';

abstract final class DSElevation {
  // Sutil — cards inline, chips
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  // Médio — cards principais, inputs com foco
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // Alto — modais, bottom sheets, overlays
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
