// Cabeçalho padrão para modais com título e subtítulo. Anteriormente: HeaderModalTitleSubtitle.
//
// Exemplo:
//   DSModalHeader(title: 'João Silva', subtitle: 'Membro desde jan/2024')
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';

class DSModalHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const DSModalHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.colors.textPrimary,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
        ),
      ],
    );
  }
}
