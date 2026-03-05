import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/organization_tab.dart';
import 'package:flutter/material.dart';

/// Top AppBar used in the narrow (mobile) layout of [OrganizationShell].
///
/// Shows the organization name, the current tab label, a back button and a
/// settings button.
class OrganizationShellAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final OrganizationModel organization;
  final String currentPage;
  final VoidCallback onBackTap;
  final VoidCallback? onSettingsTap;

  const OrganizationShellAppBar({
    super.key,
    required this.organization,
    required this.currentPage,
    required this.onBackTap,
    this.onSettingsTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    tooltip: 'Voltar',
                    onPressed: onBackTap,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        organization.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.2,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentPage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                if (onSettingsTap != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.settings_rounded, color: Colors.white),
                      tooltip: 'Configurações',
                      onPressed: onSettingsTap,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
