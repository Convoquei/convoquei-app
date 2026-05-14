import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

class EventAutoScheduleLockedInfo extends StatelessWidget {
  const EventAutoScheduleLockedInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return DSInfoBanner(
      bgColor: context.colors.infoTint,
      borderColor: context.colors.info,
      icon: Icons.info_outline_rounded,
      iconColor: context.colors.info,
      label: 'Escala Automática indisponível',
      sublabel:
          'A Escala Automática fecha a janela de disponibilidade no horário configurado e define as escalas sem intervenção manual. Este recurso ainda não está ativo nesta organização.',
    );
  }
}
