import 'package:convoquei_app/core/widgets/custom_calendar.dart';
import 'package:convoquei_app/core/widgets/timeline_group.dart';
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
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
                ]),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: TimelineGroup(
                      title: "QUINTA-FEIRA, 12 DE NOVEMBRO",
                      children: const [],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const Text("oi"),
                      childCount: 100,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
