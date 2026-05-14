import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers compartilhados entre os steps do wizard de criação de evento.
// Uso restrito ao feature de criação de eventos.
// ─────────────────────────────────────────────────────────────────────────────

/// Card padrão de cada seção dentro de um step.
class StepCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const StepCard({super.key, required this.children, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: DSRadius.allXl,
        border: Border.all(color: context.colors.border),
        boxShadow: DSElevation.sm,
      ),
      padding: padding ?? const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Label uppercase acima dos campos.
class FieldLabel extends StatelessWidget {
  final String label;

  const FieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: context.textStyles.labelSmall?.copyWith(
          color: context.colors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Toggle switch estilizado reutilizável.
class StepToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const StepToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: DSMotion.fast,
        width: 48,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: DSRadius.all(13),
          color: value ? context.colors.primary : context.colors.border,
        ),
        child: AnimatedAlign(
          duration: DSMotion.fast,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: context.colors.surface,
              shape: BoxShape.circle,
              boxShadow: DSElevation.sm,
            ),
          ),
        ),
      ),
    );
  }
}

/// Spinner numérico com botões +/-.
class NumberSpinner extends StatelessWidget {
  final int value;
  final String label;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;
  final double fontSize;

  const NumberSpinner({
    super.key,
    required this.value,
    required this.label,
    required this.min,
    required this.max,
    this.step = 1,
    required this.onChanged,
    this.fontSize = 28,
  });

  void _increment() {
    if (value + step <= max) onChanged(value + step);
  }

  void _decrement() {
    if (value - step >= min) onChanged(value - step);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SpinButton(icon: Icons.keyboard_arrow_up_rounded, onTap: _increment),
        const SizedBox(height: 6),
        SizedBox(
          width: 48,
          child: Column(
            children: [
              Text(
                value.toString().padLeft(2, '0'),
                style: context.textStyles.displayMedium?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: context.textStyles.labelSmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textSecondary,
                  letterSpacing: 0.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _SpinButton(icon: Icons.keyboard_arrow_down_rounded, onTap: _decrement),
      ],
    );
  }
}

class _SpinButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SpinButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 32,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: DSRadius.allSm,
          border: Border.all(color: context.colors.border),
          boxShadow: DSElevation.sm,
        ),
        child: Icon(icon, size: 20, color: context.colors.textSecondary),
      ),
    );
  }
}
