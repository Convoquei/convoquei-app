import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class NoRolesEmptyState extends StatelessWidget {
  const NoRolesEmptyState({super.key, this.onCreateRole});

  final VoidCallback? onCreateRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Ícone ────────────────────────────────────────────────────────
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDBEAFE)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.shield_outlined,
              color: AppTheme.primaryColor,
              size: 48,
            ),
          ),

          const SizedBox(height: 24),

          // ── Título ───────────────────────────────────────────────────────
          Text(
            'O que são Papéis?',
            textAlign: TextAlign.center,
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          // ── Descrição ────────────────────────────────────────────────────
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
              children: const [
                TextSpan(
                  text:
                  'Em vez de dar permissões pessoa por pessoa, crie papéis como ',
                ),
                TextSpan(
                  text: '"Administrador"',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextSpan(
                  text:
                  '. Defina os acessos e atribua rapidamente à sua equipe.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Botão ────────────────────────────────────────────────────────
          if (onCreateRole != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCreateRole,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Criar o Primeiro Papel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: 2,
                  shadowColor: const Color(0x331D4ED8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}