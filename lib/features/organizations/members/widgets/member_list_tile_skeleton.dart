import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/function_card_skeleton.dart';
import 'package:flutter/material.dart';

class MemberListTileSkeleton extends StatelessWidget {
  const MemberListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: const Row(
        children: [
          ShimmerBox(width: 48, height: 48, borderRadius: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 14, borderRadius: 6),
                SizedBox(height: 8),
                Row(
                  children: [
                    ShimmerBox(width: 48, height: 16, borderRadius: 4),
                    SizedBox(width: 6),
                    ShimmerBox(width: 64, height: 16, borderRadius: 6),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          ShimmerBox(width: 20, height: 20, borderRadius: 10),
        ],
      ),
    );
  }
}
