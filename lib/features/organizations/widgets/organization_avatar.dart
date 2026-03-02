
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/app_logo.dart';
import 'package:flutter/cupertino.dart';

class OrganizationAvatar extends StatelessWidget {
  final String photoUrl;

  const OrganizationAvatar({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl.isNotEmpty;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: hasPhoto
          ? ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          photoUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const AppLogo.icon(size: 34),
        ),
      )
          : const AppLogo.icon(size: 34),
    );
  }
}