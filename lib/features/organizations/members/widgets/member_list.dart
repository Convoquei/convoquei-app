import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/features/organizations/members/widgets/member_list_tile.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:flutter/material.dart';

class MembersList extends StatelessWidget {
  const MembersList({
    super.key,
    required this.state,
    required this.currentUserId,
    required this.scrollController,
    this.onOptionsPressed,
  });

  final StateListPaged<OrganizationMemberModel> state;
  final String currentUserId;
  final ScrollController scrollController;
  final void Function(OrganizationMemberModel member)? onOptionsPressed;

  @override
  Widget build(BuildContext context) {
    if (state.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Erro ao carregar membros'),
            TextButton(onPressed: () {}, child: const Text('Tentar novamente')),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return const Center(child: Text('Nenhum membro encontrado'));
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: state.items.length + (state.hasNextPage ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final m = state.items[index];
        return MemberListTile(
          member: m,
          isCurrentUser: m.id == currentUserId,
          onOptionsPressed: () {
            if (onOptionsPressed != null) {
              onOptionsPressed!(m);
            }
          },
        );
      },
    );
  }
}
