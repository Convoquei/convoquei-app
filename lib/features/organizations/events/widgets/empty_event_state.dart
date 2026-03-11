import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/org_events_tab.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_my_member_profile_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EmptyEventsState extends StatelessWidget {
  final OrgEventsTab tab;
  final OrganizationMyMemberProfile membership;
  final VoidCallback? onCreateEvent;

  const EmptyEventsState({
    super.key,
    required this.tab,
    required this.membership,
    this.onCreateEvent,
  });

  String get _message => switch (tab) {
    OrgEventsTab.all         => 'Nenhum evento próximo encontrado',
    OrgEventsTab.pending     => 'Nenhum evento aguardando sua resposta',
    OrgEventsTab.mySchedules => 'Você não está escalado em nenhum evento',
  };

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
              _message,
              style: textTheme.titleMedium,
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