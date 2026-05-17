import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/auth/models/user_model.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            DSAvatar(
              name: user.name,
              avatarUrl: user.avatarUrl,
              radius: 56,
            ),
            Positioned(
              bottom: 0,
              right: -4,
              child: DSIconButton(
                icon: Icons.photo_camera_rounded,
                backgroundColor: context.colors.primary,
                onPressed: () => ToastFeedbackService.showToast(
                  context,
                  'Em breve. Estamos preparando essa funcionalidade.',
                  ToastType.info,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.md),
        DSText(user.name, variant: DSTextVariant.titleLarge),
        const SizedBox(height: DSSpacing.xs),
        DSText(
          user.email,
          variant: DSTextVariant.bodyMedium,
          color: context.colors.textSecondary,
        ),
      ],
    );
  }
}
