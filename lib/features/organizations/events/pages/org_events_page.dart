import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/custom_calendar.dart';
import 'package:convoquei_app/core/widgets/timeline_group.dart';
import 'package:convoquei_app/features/organizations/events/widgets/empty_event_state.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_card.dart';
import 'package:convoquei_app/features/organizations/home/widgets/team_toggle_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OrgEventsTab { all, mySchedules, pending }

class OrgEventsPage extends ConsumerStatefulWidget {
  const OrgEventsPage({super.key});

  @override
  ConsumerState<OrgEventsPage> createState() => _OrgEventsPageState();
}

class _OrgEventsPageState extends ConsumerState<OrgEventsPage> {
  late OrgEventsTab selectedTab = OrgEventsTab.all;

  void _handleTabChange(OrgEventsTab newTab) {
    setState(() {
      selectedTab = newTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasEvents = true;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomCalendar(
                      events: {
                        DateTime(2026, 04, 11): ['casamento'],
                      },
                      onDaySelected: (selected, deselected) {
                        debugPrint(
                          'Selecionado: $selected | Deselecionado: $deselected',
                        );
                      },
                      onPageChanged: (firstDay) {
                        debugPrint('Período alterado, primeiro dia: $firstDay');
                      },
                      onRangeChanged: (first, last) {
                        debugPrint('Visível de $first até $last');
                      },
                    ),
                    const SizedBox(height: 20),
                    ToggleTabs(
                      selected: selectedTab,
                      onChanged: (tab) => _handleTabChange(tab),
                      values: OrgEventsTab.values,
                      labelBuilder: (tab) => switch (tab) {
                        OrgEventsTab.all => 'Todos eventos',
                        OrgEventsTab.mySchedules => 'Minhas Escalas',
                        OrgEventsTab.pending => 'Pendentes',
                      },
                    ),
                    const SizedBox(height: 20),
                    if (hasEvents)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TimelineGroup(title: "DOMINGO, 8 DE MARÇO", children: []),
                          const SizedBox(height: 8),

                          // Escalado com alerta urgente
                          EventCard(
                            title: 'Culto de Domingo | EBD',
                            time: '18:30',
                            location: 'Templo Principal',
                            eventStatus: EventStatus.inProgress,
                            participantStatus: ParticipantStatus.assigned,
                            availabilityStatus: AvailabilityStatus.available,
                            role: 'Vocal',
                            memberCount: 12,
                            hasUrgentAlert: true,
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),

                          // Pendente - não respondeu
                          EventCard(
                            title: 'Ensaio de Naipe (Vocal)',
                            time: '20:00',
                            location: 'Sala de Música 2',
                            eventStatus: EventStatus.scheduled,
                            participantStatus: ParticipantStatus.pending,
                            availabilityStatus: AvailabilityStatus.notAnswered,
                            onAvailable: () {},
                            onUnavailable: () {},
                          ),
                          const SizedBox(height: 12),

                          // Pendente - marcou disponível
                          EventCard(
                            title: 'Reunião de Liderança',
                            time: '21:30',
                            location: 'Online (Google Meet)',
                            eventStatus: EventStatus.scheduled,
                            participantStatus: ParticipantStatus.pending,
                            availabilityStatus: AvailabilityStatus.available,
                            onRemoveAvailability: () {},
                          ),
                          const SizedBox(height: 12),

                          // Pendente - marcou indisponível
                          EventCard(
                            title: 'Treinamento de Obreiros',
                            time: '19:00',
                            location: 'Sala 3',
                            eventStatus: EventStatus.scheduled,
                            participantStatus: ParticipantStatus.pending,
                            availabilityStatus: AvailabilityStatus.unavailable,
                            onRemoveUnavailability: () {},
                          ),
                          const SizedBox(height: 20),

                          const TimelineGroup(title: "SEGUNDA-FEIRA, 9 DE MARÇO", children: []),
                          const SizedBox(height: 8),

                          // Aguardando escalação
                          EventCard(
                            title: 'Ensaio Geral do Coral',
                            time: '19:00',
                            location: 'Salão Principal',
                            eventStatus: EventStatus.scheduled,
                            participantStatus: ParticipantStatus.awaitingAssignment,
                            memberCount: 24,
                          ),
                          const SizedBox(height: 12),

                          // Aguardando sorteio
                          EventCard(
                            title: 'Reunião de Célula',
                            time: '20:30',
                            location: 'Casa do Pr. João',
                            eventStatus: EventStatus.scheduled,
                            participantStatus: ParticipantStatus.awaitingDraw,
                          ),
                          const SizedBox(height: 12),

                          // Escala fechada
                          EventCard(
                            title: 'Conferência de Pastores',
                            time: '09:00',
                            location: 'Auditório Central',
                            eventStatus: EventStatus.scheduled,
                            participantStatus: ParticipantStatus.notAssigned,
                          ),
                          const SizedBox(height: 20),

                          const TimelineGroup(title: "QUARTA-FEIRA, 11 DE MARÇO", children: []),
                          const SizedBox(height: 8),

                          // Escalado com urgência
                          EventCard(
                            title: 'Culto de Quarta',
                            time: '19:30',
                            location: 'Templo Principal',
                            eventStatus: EventStatus.scheduled,
                            participantStatus: ParticipantStatus.assigned,
                            availabilityStatus: AvailabilityStatus.available,
                            role: 'Guitarra',
                            memberCount: 8,
                            hasUrgentAlert: true,
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),

                          // Concluído
                          EventCard(
                            title: 'Treinamento de Obreiros',
                            time: '21:00',
                            location: 'Sala 3',
                            eventStatus: EventStatus.completed,
                            participantStatus: ParticipantStatus.assigned,
                            role: 'Participante',
                            memberCount: 15,
                          ),
                          const SizedBox(height: 12),

                          // Cancelado
                          EventCard(
                            title: 'Confraternização da Equipe',
                            time: '18:00',
                            location: 'Pátio da Igreja',
                            eventStatus: EventStatus.canceled,
                            participantStatus: ParticipantStatus.assigned,
                            role: 'Organização',
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    else
                      SizedBox(
                        height: constraints.maxHeight - 300,
                        // espaço restante aproximado
                        child: EmptyEventsState(
                          eventsContext: EmptyEventsContext.range,
                          tab: selectedTab,
                          startDate: DateTime(2026, 4, 11),
                          endDate: DateTime(2026, 4, 30),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: AppTheme.primaryColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge urgente
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: 13,
                            color: Color(0xFFDC2626),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'A escala encerra em 2h',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Título + horário
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Culto de Domingo | EBD',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            '18:30',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF334155),
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Local
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Templo Principal',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 12),

                    // Status + avatares
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFD1FAE5)),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Color(0xFF059669),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Você está escalado',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                    fontSize: 12,
                                  ),
                            ),
                            Text(
                              'Função: Vocal',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Avatares
                        SizedBox(
                          width: 80,
                          height: 28,
                          child: Stack(
                            children: [
                              _avatar('https://i.pravatar.cc/100?img=33', 0),
                              _avatar('https://i.pravatar.cc/100?img=12', 20),
                              _avatarCount('+4', 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String url, double left) {
    return Positioned(
      left: left,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _avatarCount(String label, double left) {
    return Positioned(
      left: left,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF1F5F9),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}
