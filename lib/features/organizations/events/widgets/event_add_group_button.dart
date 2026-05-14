import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

class EventAddGroupButton extends StatelessWidget {
  final VoidCallback onTap;

  const EventAddGroupButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.primaryTint,
          borderRadius: DSRadius.allMd,
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: context.colors.primary, size: 18),
            const SizedBox(width: 6),
            Text(
              'Adicionar Grupo',
              style: context.textStyles.labelMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
