// Durações e curvas de animação padronizadas.
// Use como: duration: DSMotion.fast, curve: DSMotion.standard
import 'package:flutter/material.dart';

abstract final class DSMotion {
  static const Duration fast   = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow   = Duration(milliseconds: 400);

  static const Curve standard  = Curves.easeInOut;
  static const Curve emphasized = Curves.fastOutSlowIn;
  static const Curve decelerate = Curves.decelerate;
}
