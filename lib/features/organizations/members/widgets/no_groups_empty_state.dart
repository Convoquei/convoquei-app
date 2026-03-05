import 'package:flutter/material.dart';

/// Shown when an organization has no groups yet.
///
/// Pass [onCreateGroup] to display a "Criar primeiro grupo" button.
class NoGroupsEmptyState extends StatelessWidget {
  const NoGroupsEmptyState({super.key, this.onCreateGroup});

  final VoidCallback? onCreateGroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text('👥', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum grupo criado ainda',
            style: theme.textTheme.titleSmall?.copyWith(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Grupos são uma ferramenta poderosa para organizar sua equipe.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _BenefitItem(
            emoji: '📅',
            text:
                'Convoque membros de um grupo inteiro para um evento de uma vez',
          ),
          const SizedBox(height: 8),
          _BenefitItem(
            emoji: '🔒',
            text:
                'Restrinja eventos e escalas a grupos específicos',
          ),
          const SizedBox(height: 8),
          _BenefitItem(
            emoji: '🗂️',
            text:
                'Organize membros por função, departamento ou qualquer critério da sua organização',
          ),
          const SizedBox(height: 8),
          _BenefitItem(
            emoji: '⚡',
            text:
                'Agilize a gestão de escalas filtrando e convocando por grupo',
          ),
          if (onCreateGroup != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCreateGroup,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Criar primeiro grupo'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Text(
              'Para criar grupos, acesse a aba Equipe e alterne para Grupos.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF94A3B8),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
