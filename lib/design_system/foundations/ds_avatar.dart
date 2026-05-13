// Avatar circular com foto de rede ou iniciais geradas automaticamente.
//
// Exemplo:
//   DSAvatar(name: 'João Silva', radius: 20)
//   DSAvatar(name: 'Maria', avatarUrl: member.avatarUrl, radius: 18)
import 'package:flutter/material.dart';

import '../tokens/ds_typography.dart';

class DSAvatar extends StatelessWidget {
  const DSAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 18,
  });

  final String name;

  /// Quando nulo ou vazio, exibe as iniciais com cor derivada do nome.
  final String? avatarUrl;

  final double radius;

  bool get _hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  Color get _colorFromName {
    const palette = [
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFFEF4444),
      Color(0xFFF97316),
      Color(0xFF10B981),
      Color(0xFF14B8A6),
      Color(0xFF0EA5E9),
      Color(0xFF1D4ED8),
      Color(0xFF64748B),
    ];
    final index = name.codeUnits.fold(0, (sum, c) => sum + c) % palette.length;
    return palette[index];
  }

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.first.isNotEmpty) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _hasAvatar ? Colors.transparent : _colorFromName,
      backgroundImage: _hasAvatar ? NetworkImage(avatarUrl!) : null,
      child: !_hasAvatar
          ? Text(
              _initials,
              style: TextStyle(
                fontFamily: DSTypography.bodyFamily,
                color: Colors.white,
                fontSize: radius * 0.65,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            )
          : null,
    );
  }
}
