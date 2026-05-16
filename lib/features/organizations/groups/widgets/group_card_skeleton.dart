import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

class GroupCardSkeleton extends StatelessWidget {
  const GroupCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSCard(
      child: Row(
        children: [
          DSSkeleton(width: 48, height: 48, borderRadius: DSRadius.md),
          SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSSkeleton(width: 120, height: 16, borderRadius: 6),
                SizedBox(height: 6),
                DSSkeleton(width: 96, height: 11, borderRadius: 6),
              ],
            ),
          ),
          SizedBox(width: DSSpacing.md),
          DSSkeleton(width: 24, height: 24, borderRadius: 12),
        ],
      ),
    );
  }
}
