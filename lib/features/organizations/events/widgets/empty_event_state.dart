import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/events/pages/org_events_page.dart' show OrgEventsTab;
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_my_member_profile_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EmptyEventsState extends StatelessWidget {
  final OrgEventsTab tab;
  final String dateLabel;
  final OrganizationMyMemberProfile membership;
  final VoidCallback? onCreateEvent;

  const EmptyEventsState({
    super.key,
    required this.tab,
    required this.dateLabel,
    required this.membership,
    this.onCreateEvent,
  });

  String get _tabLabel => switch (tab) {
    OrgEventsTab.all         => null,
    OrgEventsTab.mySchedules => 'que você está escalado',
    OrgEventsTab.pending     => 'que estão pendentes de resposta',
  } ??
      '';

  String get _message {
    if (tab == OrgEventsTab.all) {
      return 'Nenhum evento encontrado para $dateLabel';
    }
    return 'Nenhum evento encontrado para $dateLabel\n$_tabLabel';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canManage = membership.hasPermission(OrganizationPermissionEnum.manageEvents);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                size: 36,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhum evento encontrado',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (canManage)
              Text.rich(
                TextSpan(
                  style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  children: [
                    TextSpan(
                      text: 'Clique aqui para criar um novo evento',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.textPrimary,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = onCreateEvent,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              )
            else
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}