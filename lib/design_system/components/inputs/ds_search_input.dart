// Campo de busca padronizado com ícone fixo e callback de limpeza.
//
// Exemplo:
//   DSSearchInput(
//     controller: _controller,
//     hintText: 'Buscar membros...',
//     onChanged: (q) => ref.read(filterProvider.notifier).setQuery(q),
//   )
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';

class DSSearchInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const DSSearchInput({
    super.key,
    this.controller,
    this.hintText = 'Buscar...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: onClear != null
            ? IconButton(
                icon: Icon(Icons.close_rounded, size: 18, color: colors.textSecondary),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                },
              )
            : null,
      ),
    );
  }
}
