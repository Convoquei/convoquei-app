// Atalhos de BuildContext para acessar tokens semânticos do design system.
//
// Exemplo:
//   context.colors.primary
//   context.textStyles.titleLarge
import 'package:flutter/material.dart';

import 'ds_colors.dart';
import 'ds_text_styles.dart';

extension DSContext on BuildContext {
  DSColors get colors => Theme.of(this).extension<DSColors>()!;
  DSTextStyles get textStyles => Theme.of(this).extension<DSTextStyles>()!;
}
