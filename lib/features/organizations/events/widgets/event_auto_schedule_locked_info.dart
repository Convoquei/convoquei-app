import 'package:flutter/material.dart';

class EventAutoScheduleLockedInfo extends StatelessWidget {
  const EventAutoScheduleLockedInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF0284C7)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'A Escala Automática fecha a janela de disponibilidade no horário configurado e define as escalas sem intervenção manual. Este recurso ainda não está ativo nesta organização.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: Color(0xFF0369A1),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
