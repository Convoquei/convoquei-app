import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HeaderMemberModal extends StatelessWidget {
  final String title;
  final String userName;

  const HeaderMemberModal({
    super.key,
    required this.title,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userName,
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