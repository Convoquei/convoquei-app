// Seção de menu agrupado (inset grouped) com título opcional e itens
// separados por DSDivider, dentro de um card arredondado com borda e
// elevação sutil.
//
// Exemplo:
//   DSMenuSection(
//     title: 'A sua conta',
//     children: [
//       DSActionCard(icon: Icons.person, title: 'Dados pessoais', subtitle: '...', outlined: true, onTap: ...),
//       DSActionCard(icon: Icons.credit_card, title: 'Assinaturas', subtitle: '...', outlined: true, onTap: ...),
//     ],
//   )
import 'package:flutter/material.dart';

import '../../foundations/ds_divider.dart';
import '../../foundations/ds_text.dart';
import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../cards/ds_card.dart';

class DSMenuSection extends StatelessWidget {
  const DSMenuSection({
    super.key,
    this.title,
    required this.children,
    this.visible = true,
  });

  final String? title;
  final List<Widget> children;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible || children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: DSSpacing.xs),
            child: DSText(
              title!.toUpperCase(),
              variant: DSTextVariant.labelSmall,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.md),
        ],
        DSCard(
          padding: EdgeInsets.zero,
          hasElevation: true,
          child: ClipRRect(
            borderRadius: DSRadius.allLg,
            child: Column(children: _withDividers(children)),
          ),
        ),
      ],
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(const DSDivider());
      }
    }
    return result;
  }
}
