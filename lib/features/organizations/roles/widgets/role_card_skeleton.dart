import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

class RoleCardSkeleton extends StatelessWidget {
  const RoleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSCard(
      child: Row(
        children: [
          DSSkeleton(width: 44, height: 44, borderRadius: DSRadius.md),
          SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSSkeleton(width: 120, height: 16, borderRadius: 6),
                SizedBox(height: 6),
                DSSkeleton(width: 70, height: 20, borderRadius: DSRadius.sm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
