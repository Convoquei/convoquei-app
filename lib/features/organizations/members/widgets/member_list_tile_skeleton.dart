import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

class MemberListTileSkeleton extends StatelessWidget {
  const MemberListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const DSCard(
      child: Row(
        children: [
          DSSkeleton(width: 48, height: 48, borderRadius: 24),
          SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSSkeleton(width: 140, height: 14, borderRadius: 6),
                SizedBox(height: DSSpacing.sm),
                Row(
                  children: [
                    DSSkeleton(width: 48, height: 16, borderRadius: 4),
                    SizedBox(width: 6),
                    DSSkeleton(width: 64, height: 16, borderRadius: 6),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: DSSpacing.md),
          DSSkeleton(width: 20, height: 20, borderRadius: 10),
        ],
      ),
    );
  }
}
