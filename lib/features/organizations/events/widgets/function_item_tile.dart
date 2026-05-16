import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/functions/models/organization_function_model.dart';
import 'package:flutter/material.dart';

/// Tile de seleção de função para uso em modais (MultiSelectModal).
class FunctionItemTile extends StatelessWidget {
  final OrganizationFunctionModel function;
  final bool isSelected;
  final VoidCallback onTap;

  const FunctionItemTile({
    super.key,
    required this.function,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DSMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.06)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: context.colors.surfaceSubtle,
                borderRadius: DSRadius.all(10),
              ),
              alignment: Alignment.center,
              child:
                  Text(function.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                function.name,
                style: context.textStyles.titleSmall,
              ),
            ),
            AnimatedContainer(
              duration: DSMotion.fast,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? context.colors.primary : Colors.transparent,
                borderRadius: DSRadius.all(6),
                border: Border.all(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded,
                      size: 14, color: context.colors.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
