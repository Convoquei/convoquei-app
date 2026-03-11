import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:flutter/material.dart';

/// Botão de filtro reutilizável que abre um bottom-sheet com os filtros
/// fornecidos por [childrenBuilder].
///
/// O builder é chamado de forma lazy (ao abrir o sheet), permitindo que o
/// chamador inicialize o estado temporário (draft) no momento certo.
///
/// Exemplo de uso:
/// ```dart
/// FilterButton(
///   isActive: _hasActiveFilters,
///   onClear: _clearFilters,
///   onApply: _applyFilters,
///   childrenBuilder: () => [
///     FilterSection(
///       title: 'Status',
///       child: Wrap(children: [...]),
///     ),
///   ],
/// )
/// ```
class FilterButton extends StatelessWidget {
  /// Builder chamado ao abrir o sheet — deve retornar as seções de filtro.
  final List<Widget> Function() childrenBuilder;

  /// [true] quando há filtros ativos — exibe indicador azul no botão.
  final bool isActive;

  /// Chamado ao pressionar "Limpar" — deve resetar o estado dos filtros.
  final VoidCallback onClear;

  /// Chamado ao pressionar "Aplicar Filtros" — deve efetivar os filtros selecionados.
  final VoidCallback onApply;

  /// Título exibido no cabeçalho do bottom-sheet.
  final String title;

  const FilterButton({
    super.key,
    required this.childrenBuilder,
    required this.onClear,
    required this.onApply,
    this.isActive = false,
    this.title = 'Filtrar Eventos',
  });

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterBottomSheet(
        title: title,
        children: childrenBuilder(), // lazy: chamado ao construir o sheet
        onClear: () {
          onClear();
          Navigator.of(context).pop();
        },
        onApply: () {
          onApply();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 20,
              color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            if (isActive)
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom-sheet interno ──────────────────────────────────────────────────────

class _FilterBottomSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onClear;
  final VoidCallback onApply;

  const _FilterBottomSheet({
    required this.title,
    required this.children,
    required this.onClear,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),

              // ── Cabeçalho ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppTheme.textSecondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // ── Corpo dos filtros ─────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  children: children
                      .expand((child) => [child, const SizedBox(height: 24)])
                      .toList(),
                ),
              ),

              // ── Footer ───────────────────────────────────────────
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: ActionButton(
                        label: 'Limpar',
                        outlined: true,
                        schema: ActionButtonSchema.ghost,
                        onPressed: onClear,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActionButton(
                        label: 'Aplicar Filtros',
                        onPressed: onApply,
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

// ── Seção de filtro genérica ──────────────────────────────────────────────────

/// Seção de filtro com título e conteúdo (chips, date pickers, etc.).
class FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const FilterSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// ── Chip de filtro genérico ───────────────────────────────────────────────────

/// Chip selecionável para uso dentro de [FilterSection].
class FilterOptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const FilterOptionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
