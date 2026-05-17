import 'package:flutter/material.dart';

import '../../foundations/ds_badge.dart';
import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_spacing.dart';

class DSSectionHeader extends StatelessWidget {
  const DSSectionHeader({
    super.key,
    required this.title,
    this.count,
    this.countColor,
  });

  final String title;
  final int? count;
  final Color? countColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(DSSpacing.xs, DSSpacing.sm, DSSpacing.xs, DSSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: context.textStyles.labelSmall.copyWith(
                color: context.colors.textSecondary,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (count != null)
            DSBadge(
              label: count.toString(),
              color: countColor ?? context.colors.textSecondary,
              variant: DSBadgeVariant.soft,
              size: DSBadgeSize.sm,
            ),
        ],
      ),
    );
  }
}
