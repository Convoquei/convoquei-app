// Divisor semântico que consome a cor de borda do tema.
//
// Exemplo:
//   DSDivider()
//   DSDivider(indent: DSSpacing.lg)
import 'package:flutter/material.dart';

import '../theme/ds_context_extensions.dart';

class DSDivider extends StatelessWidget {
  final double? indent;
  final double? endIndent;
  final double thickness;

  const DSDivider({
    super.key,
    this.indent,
    this.endIndent,
    this.thickness = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: thickness,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: context.colors.divider,
    );
  }
}
