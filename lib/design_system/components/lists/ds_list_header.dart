import 'package:flutter/material.dart';

import '../../foundations/ds_text.dart';
import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_spacing.dart';
import '../buttons/ds_icon_button.dart';
import '../inputs/ds_search_input.dart';

class DSListHeader extends StatelessWidget {
  const DSListHeader({
    super.key,
    this.searchController,
    this.searchHint,
    this.onSearchChanged,
    this.onClear,
    this.counterLabel,
    this.onActionTap,
    this.actionIcon = Icons.add_rounded,
    this.actionTooltip,
    this.enabled = true,
  });

  final TextEditingController? searchController;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onClear;
  final String? counterLabel;
  final VoidCallback? onActionTap;
  final IconData actionIcon;
  final String? actionTooltip;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.xl,
        DSSpacing.md,
        DSSpacing.xl,
        DSSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(child: _leading(context)),
          if (onActionTap != null) ...[
            const SizedBox(width: DSSpacing.md),
            _actionButton(context),
          ],
        ],
      ),
    );
  }

  Widget _leading(BuildContext context) {
    if (searchController != null) {
      return Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: AbsorbPointer(
          absorbing: !enabled,
          child: DSSearchInput(
            controller: searchController!,
            hintText: searchHint ?? '',
            onChanged: onSearchChanged,
            onClear: onClear,
          ),
        ),
      );
    }
    return DSText(
      counterLabel ?? '',
      variant: DSTextVariant.labelMedium,
      color: context.colors.textSecondary,
    );
  }

  Widget _actionButton(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Tooltip(
          message: actionTooltip ?? '',
          child: DSIconButton(
            icon: actionIcon,
            backgroundColor: context.colors.primary,
            iconColor: context.colors.onPrimary,
            onPressed: onActionTap,
          ),
        ),
      ),
    );
  }
}
