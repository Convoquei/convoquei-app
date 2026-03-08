import 'package:convoquei_app/features/organizations/members/pages/org_members_page.dart'
    show OrgMembersTab;
import 'package:convoquei_app/features/organizations/settings/pages/org_settings_page.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/organization_shell_app_bar.dart';
import 'package:flutter/material.dart';

class OrgSettingsShell extends StatefulWidget {
  final OrganizationModel organization;
  final void Function(OrgMembersTab)? onNavigateToMembersTab;
  final Widget? initialPage;
  final String? initialTitle;

  const OrgSettingsShell({
    super.key,
    required this.organization,
    this.onNavigateToMembersTab,
    this.initialPage,
    this.initialTitle,
  });

  @override
  State<OrgSettingsShell> createState() => _OrgSettingsShellState();
}

class _OrgSettingsShellState extends State<OrgSettingsShell> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  String _currentTitle = 'Configurações';
  late final _TitleObserver _titleObserver;

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) _currentTitle = widget.initialTitle!;
    _titleObserver = _TitleObserver((title) {
      if (mounted) setState(() => _currentTitle = title);
    });
  }

  bool _popInner() {
    final nav = _navKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!_popInner()) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: OrganizationShellAppBar(
          organization: widget.organization,
          currentPage: _currentTitle,
          onBackTap: () {
            if (!_popInner()) Navigator.of(context).pop();
          },
        ),
        body: Navigator(
          key: _navKey,
          observers: [_titleObserver],
          onGenerateRoute: (settings) {
            final initialPage = widget.initialPage;
            if (initialPage != null) {
              return MaterialPageRoute(
                settings: RouteSettings(name: widget.initialTitle),
                builder: (_) => initialPage,
              );
            }
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => OrgSettingsPage(
                organization: widget.organization,
                onNavigateToMembersTab: widget.onNavigateToMembersTab,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TitleObserver extends NavigatorObserver {
  final void Function(String) onTitleChanged;

  _TitleObserver(this.onTitleChanged);

  String _titleOf(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name == '/') return 'Configurações';
    return name;
  }

  void _notify(String title) {
    WidgetsBinding.instance.addPostFrameCallback((_) => onTitleChanged(title));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _notify(_titleOf(route));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _notify(_titleOf(previousRoute));
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _notify(_titleOf(newRoute));
  }
}
