import 'package:convoquei_app/core/theme/app_theme.dart';
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
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
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
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
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: value ? AppTheme.primaryColor : const Color(0xFFCBD5E1),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x20000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
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
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 4),
          ],
        ),
        child: Icon(icon, size: 20, color: AppTheme.textSecondary),
      ),
    );
  }
}
