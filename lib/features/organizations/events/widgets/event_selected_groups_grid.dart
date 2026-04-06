import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/events/models/event_form_step2_data.dart';
import 'package:flutter/material.dart';

class EventSelectedGroupsGrid extends StatelessWidget {
  final List<CreateEventGroupSelection> selected;
  final ValueChanged<CreateEventGroupSelection> onRemove;

  const EventSelectedGroupsGrid({
    super.key,
    required this.selected,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (selected.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          'Nenhum grupo selecionado. Adicione abaixo.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3.2,
      ),
      itemCount: selected.length,
      itemBuilder: (_, i) {
        final group = selected[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Color(0x08000000), blurRadius: 4),
            ],
          ),
          child: Row(
            children: [
              Text(group.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  group.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => onRemove(group),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
