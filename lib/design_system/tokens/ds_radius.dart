// Raios de borda padronizados.
// Use como: borderRadius: DSRadius.allMd
import 'package:flutter/material.dart';

abstract final class DSRadius {
  static const double sm = 8;  // botões xs, tags pequenas
  static const double md = 12; // botões, inputs, cards inline
  static const double lg = 16; // cards, modais, containers
  static const double xl = 20; // date/time picker, bottom sheets

  static BorderRadius get allSm => BorderRadius.circular(sm);
  static BorderRadius get allMd => BorderRadius.circular(md);
  static BorderRadius get allLg => BorderRadius.circular(lg);
  static BorderRadius get allXl => BorderRadius.circular(xl);

  static BorderRadius all(double r) => BorderRadius.circular(r);
}
