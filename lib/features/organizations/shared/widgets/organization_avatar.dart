import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/app_logo.dart';
import 'package:flutter/material.dart';

class OrganizationAvatar extends StatelessWidget {
  final String photoUrl;
  final double size;

  const OrganizationAvatar({super.key, required this.photoUrl, this.size = 60});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl.isNotEmpty;
    final radius = size * 0.3;
    final iconSize = size * 0.567;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: hasPhoto
          ? ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image.network(
                photoUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => AppLogo.icon(size: iconSize),
              ),
            )
          : AppLogo.icon(size: iconSize),
    );
  }
}