import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/organization_tab.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/organization_avatar.dart';
import 'package:flutter/material.dart';

// Width of the rail when expanded (label visible)
const double _kRailExpanded = 220;
// Width of the rail when collapsed (icons only)
const double _kRailCollapsed = 64;

/// Persistent side navigation rail used on wide (desktop/tablet) layouts.
///
/// Collapses to icons-only and expands with labels on hover.
class OrganizationSideRail extends StatefulWidget {
  final OrganizationModel organization;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onSettingsTap;
  final VoidCallback onExitTap;

  const OrganizationSideRail({
    super.key,
    required this.organization,
    required this.currentIndex,
    required this.onTabChanged,
    required this.onSettingsTap,
    required this.onExitTap,
  });

  @override
  State<OrganizationSideRail> createState() => _OrganizationSideRailState();
}

class _OrganizationSideRailState extends State<OrganizationSideRail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  static const _bg = Colors.white;
  static const _dividerColor = Color(0xFFE2E8F0);
  static const _iconMuted = Color(0xFF94A3B8);
  static const _labelMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final double width =
              _kRailCollapsed + (_kRailExpanded - _kRailCollapsed) * _anim.value;
          final double labelOpacity = _anim.value;

          return Container(
            width: width,
            decoration: const BoxDecoration(
              color: _bg,
              border: Border(
                right: BorderSide(color: _dividerColor, width: 1),
              ),
            ),
            child: ClipRect(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RailHeader(
                      organization: widget.organization,
                      labelOpacity: labelOpacity,
                    ),
                    const Divider(color: _dividerColor, height: 1, thickness: 1),
                    const SizedBox(height: 6),
                    ..._buildNavItems(labelOpacity),
                    const Spacer(),
                    const Divider(color: _dividerColor, height: 1, thickness: 1),
                    _RailFooterItem(
                      icon: Icons.settings_outlined,
                      label: 'Configurações',
                      labelOpacity: labelOpacity,
                      verticalPadding: 4,
                      onTap: widget.onSettingsTap,
                    ),
                    _RailFooterItem(
                      icon: Icons.logout_rounded,
                      label: 'Sair da organização',
                      labelOpacity: labelOpacity,
                      verticalPadding: 12,
                      onTap: widget.onExitTap,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildNavItems(double labelOpacity) {
    return kOrgTabs.asMap().entries.map((entry) {
      final index = entry.key;
      final tab = entry.value;
      final selected = widget.currentIndex == index;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Material(
          color: selected
              ? AppTheme.primaryColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => widget.onTabChanged(index),
            child: SizedBox(
              height: 40,
              child: Stack(
                children: [
                  // Icon — always visible in the collapsed zone
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: _kRailCollapsed - 12,
                    child: Center(
                      child: Icon(
                        tab.icon,
                        size: 20,
                        color: selected ? AppTheme.primaryColor : _iconMuted,
                      ),
                    ),
                  ),
                  // Label — fades in to the right as the rail expands
                  Positioned(
                    left: _kRailCollapsed - 12,
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: Opacity(
                      opacity: labelOpacity,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tab.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 13,
                            color: selected ? AppTheme.primaryColor : _labelMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

// ── Private sub-widgets ──────────────────────────────────────────────────────

class _RailHeader extends StatelessWidget {
  final OrganizationModel organization;
  final double labelOpacity;

  const _RailHeader({
    required this.organization,
    required this.labelOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: _kRailCollapsed,
            child: Center(
              child: OrganizationAvatar(
                photoUrl: organization.photoUrl,
                size: 36,
              ),
            ),
          ),
          Positioned(
            left: _kRailCollapsed,
            top: 0,
            bottom: 0,
            right: 8,
            child: Opacity(
              opacity: labelOpacity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  organization.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailFooterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double labelOpacity;
  final double verticalPadding;
  final VoidCallback onTap;

  static const _iconMuted = Color(0xFF94A3B8);
  static const _labelMuted = Color(0xFF64748B);

  const _RailFooterItem({
    required this.icon,
    required this.label,
    required this.labelOpacity,
    required this.verticalPadding,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 6, right: 6, bottom: verticalPadding),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            height: 40,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _kRailCollapsed - 12,
                  child: Center(
                    child: Icon(icon, size: 20, color: _iconMuted),
                  ),
                ),
                Positioned(
                  left: _kRailCollapsed - 12,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Opacity(
                    opacity: labelOpacity,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: _labelMuted,
                        ),
                      ),
                    ),
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
