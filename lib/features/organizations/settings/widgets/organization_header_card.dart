import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/organization_avatar.dart';
import 'package:flutter/material.dart';

class OrganizationHeaderCard extends StatelessWidget {
  const OrganizationHeaderCard({
    super.key,
    required this.organization,
    required this.totalEvents,
    required this.monthEvents,
    this.onEditTap,
  });

  final OrganizationModel organization;
  final int totalEvents;
  final int monthEvents;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  organization: organization,
                  onEditTap: onEditTap,
                ),
                const SizedBox(height: 20),
                _StatsGrid(
                  totalMembers: organization.totalMembers,
                  totalEvents: totalEvents,
                  monthEvents: monthEvents,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header row (icon + title + edit button) ─────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.organization,
    this.onEditTap,
  });

  final OrganizationModel organization;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrganizationAvatar(photoUrl: organization.photoUrl),
        const SizedBox(width: 12),
        Expanded(child: _OrgInfo(organization: organization)),
        _EditButton(onTap: onEditTap),
      ],
    );
  }
}

class _OrgInfo extends StatelessWidget {
  const _OrgInfo({required this.organization});

  final OrganizationModel organization;

  String get _formattedDate {
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    final d = organization.createdAt;
    return 'Criada em ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          organization.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formattedDate,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Icon(
          Icons.edit_outlined,
          size: 16,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

// ─── Stats grid ──────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.totalMembers,
    required this.totalEvents,
    required this.monthEvents,
  });

  final int totalMembers;
  final int totalEvents;
  final int monthEvents;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Membros',
                value: '$totalMembers',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Total Eventos',
                value: '$totalEvents',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MonthEventsCard(monthEvents: monthEvents),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthEventsCard extends StatelessWidget {
  const _MonthEventsCard({required this.monthEvents});

  final int monthEvents;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331D4ED8),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EVENTOS NESTE MÊS',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBFDBFE),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$monthEvents realizados',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}