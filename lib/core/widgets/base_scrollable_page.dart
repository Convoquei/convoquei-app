import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/app_search_input.dart';
import 'package:flutter/material.dart';

class BaseScrollablePage extends StatelessWidget {
  const BaseScrollablePage({
    super.key,
    required this.children,
    required this.useSafeArea,
    this.searchHint = 'Procurar...',
    this.onAddTap,
    this.onSearchChanged,
  });

  final List<Widget> children;

  final String searchHint;

  final VoidCallback? onAddTap;

  final ValueChanged<String>? onSearchChanged;

  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      body: Column(
        children: [
          _SearchBar(
            hint: searchHint,
            onAddTap: onAddTap,
            onChanged: onSearchChanged,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: children,
              ),
            ),
          ),
        ],
      ),
    );

    return useSafeArea ? SafeArea(child: scaffold) : scaffold;
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.hint,
    this.onAddTap,
    this.onChanged,
  });

  final String hint;
  final VoidCallback? onAddTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: AppSearchInput(
              hint: hint,
              onChanged: onChanged,
            ),
          ),
          if (onAddTap != null) ...[
            const SizedBox(width: 12),
            _AddButton(onTap: onAddTap!),
          ],
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primaryColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const SizedBox(
          height: 40,
          width: 40,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}