import 'package:convoquei_app/core/widgets/base_scrollable_page.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageRolesPage extends ConsumerStatefulWidget {
  final OrganizationModel organization;

  const ManageRolesPage({super.key, required this.organization});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManageRolesPageState();
}

class _ManageRolesPageState extends ConsumerState<ManageRolesPage> {
  @override
  Widget build(BuildContext context) {
    return BaseScrollablePage(
      children: [Text("oioio"), Text("oioio")],
      useSafeArea: true,
      searchHint: "Procurar pepéis...",
    );
  }
}
