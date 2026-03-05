import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_members_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/widgets/member_list_tile.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MembersList extends ConsumerStatefulWidget {
  const MembersList({
    super.key,
    required this.currentUserId,
    this.searchQuery,
    this.onOptionsPressed,
  });

  final String currentUserId;
  final String? searchQuery;
  final void Function(OrganizationMemberModel member)? onOptionsPressed;

  @override
  ConsumerState<MembersList> createState() => _MembersListState();
}

class _MembersListState extends ConsumerState<MembersList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => ref
          .read(membersPagedProvider.notifier)
          .loadNextPage(name: widget.searchQuery),
    );
  }

  @override
  void didUpdateWidget(MembersList old) {
    super.didUpdateWidget(old);
    if (old.searchQuery != widget.searchQuery) {
      Future.microtask(() {
        if (!mounted) return;
        ref
            .read(membersPagedProvider.notifier)
            .reset(name: widget.searchQuery);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final nearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (!nearBottom) return;

    final s = ref.read(membersPagedProvider);
    if (s.isLoadingMore || s.isInitialLoading || !s.hasNextPage) return;

    ref
        .read(membersPagedProvider.notifier)
        .loadNextPage(name: widget.searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membersPagedProvider);

    if (state.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Erro ao carregar membros'),
            TextButton(
              onPressed: () => ref
                  .read(membersPagedProvider.notifier)
                  .loadNextPage(name: widget.searchQuery),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return const Center(child: Text('Nenhum membro encontrado'));
    }

    return ListView.separated(
      controller: _scrollController,
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
          isCurrentUser: m.id == widget.currentUserId,
          onOptionsPressed: () {
            if (widget.onOptionsPressed != null) {
              widget.onOptionsPressed!(m);
            }
          },
        );
      },
    );
  }
}
