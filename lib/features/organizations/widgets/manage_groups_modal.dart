import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Mock data model — substituir por modelos reais ao refatorar
// ---------------------------------------------------------------------------
class _MockGroup {
  final String name;
  final String subtitle;
  final Color color;
  final IconData icon;
  bool selected;

  _MockGroup({
    required this.name,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.selected = false,
  });
}

// ---------------------------------------------------------------------------
// Modal de gestão de grupos de um membro
// ---------------------------------------------------------------------------

/// Bottom sheet que lista os grupos disponíveis e permite atribuir/remover
/// o membro de cada um. É um mock — substituir pela lógica real ao refatorar.
///
/// Uso:
/// ```dart
/// ManageGroupsModal.show(context, memberName: 'João Pedro');
/// ```
class ManageGroupsModal extends StatefulWidget {
  const ManageGroupsModal({super.key, required this.memberName});

  final String memberName;

  static Future<void> show(BuildContext context, {required String memberName}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManageGroupsModal(memberName: memberName),
    );
  }

  @override
  State<ManageGroupsModal> createState() => _ManageGroupsModalState();
}

class _ManageGroupsModalState extends State<ManageGroupsModal> {
  // Mock groups — trocar por dados reais
  final List<_MockGroup> _groups = [
    _MockGroup(
      name: 'Vocal',
      subtitle: 'Cantores e Sopranos',
      color: const Color(0xFFDBEAFE),
      icon: Icons.mic_rounded,
      selected: false,
    ),
    _MockGroup(
      name: 'Instrumental',
      subtitle: 'Banda e Músicos',
      color: const Color(0xFFF3E8FF),
      icon: Icons.piano_rounded,
      selected: true,
    ),
    _MockGroup(
      name: 'Sonoplastia',
      subtitle: 'Técnicos de Áudio',
      color: const Color(0xFFFFEDD5),
      icon: Icons.tune_rounded,
      selected: false,
    ),
    _MockGroup(
      name: 'Mídia e Projeção',
      subtitle: 'Transmissão e Letras',
      color: const Color(0xFFCCFBF1),
      icon: Icons.videocam_rounded,
      selected: false,
    ),
  ];

  final Map<String, Color> _iconColors = {
    'Vocal': const Color(0xFF1D4ED8),
    'Instrumental': const Color(0xFF9333EA),
    'Sonoplastia': const Color(0xFFF97316),
    'Mídia e Projeção': const Color(0xFF0D9488),
  };

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // ── drag handle ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),

              // ── header ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Gerir Grupos',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontFamily: 'Poppins'),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(99),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 18, color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_rounded,
                            size: 14, color: AppTheme.primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          'Membro: ',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        Text(
                          widget.memberName,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // ── list ─────────────────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  children: [
                    Text(
                      'SELECIONE AS EQUIPAS DO MEMBRO',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ..._groups.map((g) => _GroupCheckTile(
                          group: g,
                          iconColor: _iconColors[g.name] ?? AppTheme.primaryColor,
                          onChanged: (val) =>
                              setState(() => g.selected = val ?? false),
                        )),
                  ],
                ),
              ),

              // ── footer actions ────────────────────────────────────────
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
                child: Column(
                  children: [
                    ActionButton(
                      label: 'Guardar Alterações',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Remover membro da organização',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tile de grupo com checkbox estilizado
// ---------------------------------------------------------------------------
class _GroupCheckTile extends StatelessWidget {
  const _GroupCheckTile({
    required this.group,
    required this.iconColor,
    required this.onChanged,
  });

  final _MockGroup group;
  final Color iconColor;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => onChanged(!group.selected),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: group.selected
                ? const Color(0xFFEFF6FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: group.selected
                  ? AppTheme.primaryColor
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: group.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(group.icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      group.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: group.selected ? AppTheme.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: group.selected
                        ? AppTheme.primaryColor
                        : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
                child: group.selected
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

