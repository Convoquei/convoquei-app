import 'package:flutter/material.dart';

/// Chip que exibe a contagem de participantes escalados em um evento.
class ParticipantsChip extends StatelessWidget {
  final int count;

  const ParticipantsChip({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_rounded, size: 12, color: Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            '$count membros',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
