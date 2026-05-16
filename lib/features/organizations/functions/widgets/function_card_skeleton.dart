import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

class FunctionCardSkeleton extends StatelessWidget {
  const FunctionCardSkeleton({super.key});

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
                DSSkeleton(width: 140, height: 16, borderRadius: 6),
                SizedBox(height: 6),
                DSSkeleton(width: 80, height: 20, borderRadius: DSRadius.sm),
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
