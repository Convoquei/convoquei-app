import 'dart:ui';

import 'package:convoquei_app/core/widgets/app_loading_info.dart';
import 'package:flutter/material.dart';

// ── Tipo de skeleton ────────────────────────────────────────────────────────

/// Define a estrutura de skeleton exibida como fundo na [AppLoadingScreen].
///
/// - [details] — Tela de detalhes: card hero + tabs + lista de membros.
/// - [list]    — Tela de listagem: barra de busca + sequência de cards de linha.
enum AppLoadingSkeleton { details, list }

// ── AppLoadingScreen ────────────────────────────────────────────────────────

/// Tela de carregamento com skeleton minimalista e overlay com o spinner da marca.
///
/// Preenche 100% do espaço disponível no pai via [SizedBox.expand].
/// O shell da organização (AppBar/header) permanece visível — esta tela
/// ocupa apenas o corpo da rota filha.
///
/// Exemplos de uso:
/// ```dart
/// // Tela de detalhes
/// AppLoadingScreen(
///   content: AppLoadingInfo(
///     label: 'Carregando evento...',
///     description: 'Buscando detalhes e participantes',
///   ),
/// )
///
/// // Tela de listagem
/// AppLoadingScreen(
///   content: AppLoadingInfo(label: 'Carregando...', description: ''),
///   skeleton: AppLoadingSkeleton.list,
/// )
/// ```
class AppLoadingScreen extends StatelessWidget {
  final AppLoadingInfo content;
  final AppLoadingSkeleton skeleton;

  const AppLoadingScreen({
    super.key,
    required this.content,
    this.skeleton = AppLoadingSkeleton.details,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // ── Skeletons de fundo ──────────────────────────────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: switch (skeleton) {
                AppLoadingSkeleton.details => const _DetailsSkeleton(),
                AppLoadingSkeleton.list    => const _ListPageSkeleton(),
              },
            ),
          ),

          // ── Overlay com blur + spinner centralizado ─────────────────────
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.white.withAlpha(153), // ~60% opacidade
                  alignment: Alignment.center,
                  child: content,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// ── Skeletons compostos ─────────────────────────────────────────────────────

/// Layout de skeleton para telas de detalhes:
/// card hero + tabs + card de lista com membros.
class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _HeroCardSkeleton(),
        SizedBox(height: 12),
        _TabsSkeleton(),
        SizedBox(height: 12),
        _MemberListCardSkeleton(),
      ],
    );
  }
}

/// Layout de skeleton para telas de listagem:
/// barra de busca/filtro + repetição de cards de linha.
class _ListPageSkeleton extends StatelessWidget {
  const _ListPageSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Barra de busca + botão de filtro ─────────────────────────────
        Row(
          children: [
            Expanded(child: _ShimmerBox(height: 48, borderRadius: 12)),
            SizedBox(width: 10),
            _ShimmerBox(width: 48, height: 48, borderRadius: 12),
          ],
        ),
        SizedBox(height: 14),

        // ── Tabs ──────────────────────────────────────────────────────────
        _TabsSkeleton(),
        SizedBox(height: 20),

        // ── Divider de mês ────────────────────────────────────────────────
        _ShimmerBox(width: 100, height: 14, borderRadius: 6),
        SizedBox(height: 12),

        // ── Cards de evento ───────────────────────────────────────────────
        _EventRowCardSkeleton(),
        SizedBox(height: 12),
        _EventRowCardSkeleton(),
        SizedBox(height: 12),
        _EventRowCardSkeleton(),
      ],
    );
  }
}

// ── Blocos de skeleton atômicos ─────────────────────────────────────────────

/// Card hero (cabeçalho com info principal — usado na tela de detalhes).
class _HeroCardSkeleton extends StatelessWidget {
  const _HeroCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ShimmerBox(width: 64, height: 20, borderRadius: 10),
              _ShimmerBox(width: 80, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 16),
          const _ShimmerBox(height: 28, borderRadius: 10),
          const SizedBox(height: 16),
          const _ShimmerBox(width: 180, height: 14, borderRadius: 6),
          const SizedBox(height: 10),
          const _ShimmerBox(width: 140, height: 14, borderRadius: 6),
          const SizedBox(height: 10),
          const _ShimmerBox(width: 120, height: 14, borderRadius: 6),
        ],
      ),
    );
  }
}

/// Skeleton de tabs (ex.: Pessoas / Configurações).
class _TabsSkeleton extends StatelessWidget {
  const _TabsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Expanded(child: _ShimmerBox(height: double.infinity, borderRadius: 12)),
          SizedBox(width: 6),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

/// Card de lista com avatar + linhas de texto (detalhes).
class _MemberListCardSkeleton extends StatelessWidget {
  const _MemberListCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBox(width: 140, height: 16, borderRadius: 6),
          SizedBox(height: 16),
          _AvatarRowSkeleton(),
          SizedBox(height: 12),
          Divider(color: Color(0xFFF1F5F9), height: 1),
          SizedBox(height: 12),
          _AvatarRowSkeleton(),
        ],
      ),
    );
  }
}

/// Linha de avatar + texto + badge de ação (membros).
class _AvatarRowSkeleton extends StatelessWidget {
  const _AvatarRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _ShimmerBox(width: 40, height: 40, borderRadius: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(height: 14, borderRadius: 6),
              SizedBox(height: 6),
              _ShimmerBox(width: 80, height: 12, borderRadius: 4),
            ],
          ),
        ),
        SizedBox(width: 12),
        _ShimmerBox(width: 32, height: 24, borderRadius: 8),
      ],
    );
  }
}

/// Card de linha de evento (usado na listagem): data + conteúdo + badge.
class _EventRowCardSkeleton extends StatelessWidget {
  const _EventRowCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(14),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Coluna de data ──────────────────────────────────────────────
          _ShimmerBox(width: 44, height: 52, borderRadius: 10),
          SizedBox(width: 12),

          // ── Linhas de texto ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(height: 16, borderRadius: 6),
                SizedBox(height: 8),
                _ShimmerBox(width: 120, height: 12, borderRadius: 4),
                SizedBox(height: 6),
                _ShimmerBox(width: 90, height: 12, borderRadius: 4),
              ],
            ),
          ),
          SizedBox(width: 12),

          // ── Badge de status ─────────────────────────────────────────────
          _ShimmerBox(width: 28, height: 28, borderRadius: 14),
        ],
      ),
    );
  }
}

// ── Bloco de shimmer reutilizável ───────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _color = ColorTween(
      begin: const Color(0xFFF1F5F9),
      end: const Color(0xFFE2E8F0),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _color.value,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
