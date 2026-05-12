import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BaseScrollablePage extends StatefulWidget {
  const BaseScrollablePage({
    super.key,
    required this.children,
    required this.useSafeArea,
    this.searchHint = 'Procurar...',
    this.onIconTap,
    this.icon = Icons.add,
    this.onSearchChanged,
    this.onRequestNextPage,
    this.emptyState,
  });

  final List<Widget> children;
  final String searchHint;
  final VoidCallback? onIconTap;
  final IconData icon;
  final ValueChanged<String>? onSearchChanged;
  final bool useSafeArea;
  final AsyncCallback? onRequestNextPage;

  /// Quando fornecido, substitui o scroll e é centralizado no espaço disponível.
  /// Use quando não há itens para listar.
  final Widget? emptyState;

  @override
  State<BaseScrollablePage> createState() => _BaseScrollablePageState();
}

class _BaseScrollablePageState extends State<BaseScrollablePage> {
  ScrollController? _scrollController;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    if (widget.onRequestNextPage != null) {
      _scrollController = ScrollController()..addListener(_onScroll);
    }
  }

  @override
  void didUpdateWidget(BaseScrollablePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.onRequestNextPage != null && _scrollController == null) {
      _scrollController = ScrollController()..addListener(_onScroll);
    }

    if (widget.onRequestNextPage == null && _scrollController != null) {
      _scrollController!.removeListener(_onScroll);
      _scrollController!.dispose();
      _scrollController = null;
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    super.dispose();
  }

  Future<void> _onScroll() async {
    if (_isFetching || _scrollController == null) return;
    if (!_scrollController!.hasClients) return;

    final nearBottom =
        _scrollController!.position.pixels >=
            _scrollController!.position.maxScrollExtent - 200;

    if (!nearBottom) return;

    _isFetching = true;
    try {
      await widget.onRequestNextPage?.call();
    } finally {
      if (mounted) _isFetching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      body: Column(
        children: [
          if (widget.emptyState != null)
            Expanded(
              child: Align(
                alignment: const Alignment(0, -0.2),
                child: widget.emptyState!,
              ),
            )
          else ...[
            _SearchBar(
              hint: widget.searchHint,
              onIconTap: widget.onIconTap,
              addIcon: widget.icon,
              onChanged: widget.onSearchChanged,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(children: widget.children),
              ),
            ),
          ]
        ],
      ),
    );

    return widget.useSafeArea ? SafeArea(child: scaffold) : scaffold;
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.hint,
    this.onIconTap,
    this.addIcon = Icons.add,
    this.onChanged,
  });

  final String hint;
  final VoidCallback? onIconTap;
  final IconData addIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),
          if (onIconTap != null) ...[
            const SizedBox(width: 12),
            _AddButton(onTap: onIconTap!, icon: addIcon),
          ],
        ],
      ),
    );
  }
}

// ─── Add button ───────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap, this.icon = Icons.add});

  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primaryColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 40,
          width: 40,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}