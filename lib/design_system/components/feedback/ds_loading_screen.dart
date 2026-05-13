// Tela de carregamento com skeleton de fundo e overlay com DSSpinner.
// Anteriormente: AppLoadingScreen.
//
// Exemplo:
//   DSLoadingScreen(label: 'Carregando evento...', description: 'Buscando participantes')
//   DSLoadingScreen(label: 'Carregando...', description: '', skeleton: DSLoadingSkeleton.list)
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../foundations/ds_skeleton.dart';
import '../../foundations/ds_spinner.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';

enum DSLoadingSkeleton { details, list }

class DSLoadingScreen extends StatelessWidget {
  final String label;
  final String description;
  final double iconSize;
  final DSLoadingSkeleton skeleton;

  const DSLoadingScreen({
    super.key,
    required this.label,
    required this.description,
    this.iconSize = 96,
    this.skeleton = DSLoadingSkeleton.details,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.lg,
                vertical: DSSpacing.xl,
              ),
              child: switch (skeleton) {
                DSLoadingSkeleton.details => const _DetailsSkeleton(),
                DSLoadingSkeleton.list   => const _ListSkeleton(),
              },
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.white.withAlpha(153),
                  alignment: Alignment.center,
                  child: _LoadingInfo(
                    label: label,
                    description: description,
                    iconSize: iconSize,
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

// ── Info centralizada ─────────────────────────────────────────────────────────

class _LoadingInfo extends StatelessWidget {
  final String label;
  final String description;
  final double iconSize;

  const _LoadingInfo({
    required this.label,
    required this.description,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DSSpinner(size: iconSize),
        const SizedBox(height: DSSpacing.xl),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ── Skeletons ─────────────────────────────────────────────────────────────────

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _HeroCardSkeleton(),
        SizedBox(height: DSSpacing.md),
        _TabsSkeleton(),
        SizedBox(height: DSSpacing.md),
        _MemberListCardSkeleton(),
      ],
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: DSSkeleton(height: 48, borderRadius: DSRadius.md)),
            SizedBox(width: DSSpacing.sm + 2),
            DSSkeleton(width: 48, height: 48, borderRadius: DSRadius.md),
          ],
        ),
        SizedBox(height: 14),
        _TabsSkeleton(),
        SizedBox(height: DSSpacing.xl),
        DSSkeleton(width: 100, height: 14, borderRadius: 6),
        SizedBox(height: DSSpacing.md),
        _EventRowCardSkeleton(),
        SizedBox(height: DSSpacing.md),
        _EventRowCardSkeleton(),
        SizedBox(height: DSSpacing.md),
        _EventRowCardSkeleton(),
      ],
    );
  }
}

class _HeroCardSkeleton extends StatelessWidget {
  const _HeroCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DSRadius.allLg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DSSkeleton(width: 64, height: 20, borderRadius: 10),
              DSSkeleton(width: 80, height: 24, borderRadius: DSRadius.md),
            ],
          ),
          SizedBox(height: DSSpacing.lg),
          DSSkeleton(height: 28, borderRadius: 10),
          SizedBox(height: DSSpacing.lg),
          DSSkeleton(width: 180, height: 14, borderRadius: 6),
          SizedBox(height: DSSpacing.sm + 2),
          DSSkeleton(width: 140, height: 14, borderRadius: 6),
          SizedBox(height: DSSpacing.sm + 2),
          DSSkeleton(width: 120, height: 14, borderRadius: 6),
        ],
      ),
    );
  }
}

class _TabsSkeleton extends StatelessWidget {
  const _TabsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: DSRadius.allLg,
      ),
      child: const Row(
        children: [
          Expanded(child: DSSkeleton(height: double.infinity, borderRadius: DSRadius.md)),
          SizedBox(width: 6),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class _MemberListCardSkeleton extends StatelessWidget {
  const _MemberListCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DSRadius.allLg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSSkeleton(width: 140, height: 16, borderRadius: 6),
          SizedBox(height: DSSpacing.lg),
          _AvatarRowSkeleton(),
          SizedBox(height: DSSpacing.md),
          Divider(color: Color(0xFFF1F5F9), height: 1),
          SizedBox(height: DSSpacing.md),
          _AvatarRowSkeleton(),
        ],
      ),
    );
  }
}

class _AvatarRowSkeleton extends StatelessWidget {
  const _AvatarRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        DSSkeleton(width: 40, height: 40, borderRadius: 20),
        SizedBox(width: DSSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSSkeleton(height: 14, borderRadius: 6),
              SizedBox(height: 6),
              DSSkeleton(width: 80, height: 12, borderRadius: 4),
            ],
          ),
        ),
        SizedBox(width: DSSpacing.md),
        DSSkeleton(width: 32, height: 24, borderRadius: DSRadius.sm),
      ],
    );
  }
}

class _EventRowCardSkeleton extends StatelessWidget {
  const _EventRowCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DSRadius.allLg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(14),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DSSkeleton(width: 44, height: 52, borderRadius: 10),
          SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSSkeleton(height: 16, borderRadius: 6),
                SizedBox(height: DSSpacing.sm),
                DSSkeleton(width: 120, height: 12, borderRadius: 4),
                SizedBox(height: 6),
                DSSkeleton(width: 90, height: 12, borderRadius: 4),
              ],
            ),
          ),
          SizedBox(width: DSSpacing.md),
          DSSkeleton(width: 28, height: 28, borderRadius: 14),
        ],
      ),
    );
  }
}
