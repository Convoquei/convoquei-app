import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HeaderModalTitleSubtitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const HeaderModalTitleSubtitle({
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
        ),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}