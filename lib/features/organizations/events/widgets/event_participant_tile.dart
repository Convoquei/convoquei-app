import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:flutter/material.dart';

/// Tile de exibição de um participante do evento.
///
/// [dimmed] aplica opacidade reduzida (útil para indisponíveis).
/// [strikethrough] risca o nome (usado para indisponíveis com subtítulo fixo).
/// [functionColor] sobrescreve a cor do texto da função.
/// [trailing] widget opcional no lado direito (ações contextuais).
class EventParticipantTile extends StatelessWidget {
  final OrganizationEventParticipantModel participant;
  final Widget? trailing;
  final bool dimmed;
  final bool strikethrough;
  final Color? functionColor;

  const EventParticipantTile({
    super.key,
    required this.participant,
    this.trailing,
    this.dimmed = false,
    this.strikethrough = false,
    this.functionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.55 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          children: [
            DSAvatar(
              name: participant.name,
              avatarUrl: participant.avatarUrl,
              radius: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.name,
                    style: context.textStyles.labelMedium?.copyWith(
                          decoration: strikethrough
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (strikethrough)
                    Text(
                      'Informou indisponibilidade',
                      style: context.textStyles.labelSmall?.copyWith(
                            color: context.colors.danger,
                          ),
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (participant.function != null)
                    Text(
                      participant.function!,
                      style: context.textStyles.labelSmall?.copyWith(
                            color: functionColor ?? context.colors.textSecondary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
