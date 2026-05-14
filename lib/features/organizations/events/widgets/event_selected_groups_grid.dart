import 'package:convoquei_app/design_system/ds.dart';
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
          color: context.colors.surfaceSubtle,
          borderRadius: DSRadius.allMd,
          border: Border.all(color: context.colors.border),
        ),
        child: Text(
          'Nenhum grupo selecionado. Adicione abaixo.',
          textAlign: TextAlign.center,
          style: context.textStyles.bodySmall,
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
            color: context.colors.surface,
            borderRadius: DSRadius.allMd,
            border: Border.all(color: context.colors.border),
            boxShadow: DSElevation.sm,
          ),
          child: Row(
            children: [
              Text(group.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  group.name,
                  style: context.textStyles.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => onRemove(group),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
