import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:convoquei_app/core/widgets/modals/app_modal.dart';
import 'package:convoquei_app/core/widgets/selectable_tile.dart';
import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:flutter/material.dart';

// Sentinel value to represent the "no function" option internally.
const _kNoFunction = '';

class FunctionSelectionModal extends StatefulWidget {
  final List<EventCalledFunctionModel> calledFunctions;

  /// When true, a "Participar sem função" option is shown at the end of the
  /// list (used when the event's callMode is allMembersWithFunctionLimits).
  final bool allowNoFunction;

  const FunctionSelectionModal._({
    required this.calledFunctions,
    required this.allowNoFunction,
  });

  /// Shows the modal and returns:
  /// - `null`                → user cancelled / dismissed
  /// - `(functionId: null)`  → user confirmed without selecting a function
  /// - `(functionId: 'id')`  → user confirmed with the selected function
  static Future<({String? functionId})?> show(
    BuildContext context, {
    required List<EventCalledFunctionModel> calledFunctions,
    required bool allowNoFunction,
  }) {
    return AppModal.show<({String? functionId})>(
      context,
      FunctionSelectionModal._(
        calledFunctions: calledFunctions,
        allowNoFunction: allowNoFunction,
      ),
    );
  }

  @override
  State<FunctionSelectionModal> createState() => _FunctionSelectionModalState();
}

class _FunctionSelectionModalState extends State<FunctionSelectionModal> {
  /// `null`          → nothing selected yet
  /// `_kNoFunction`  → "no function" option selected
  /// any other value → function ID selected
  String? _selectedId;

  String _limitLabel(EventCalledFunctionModel fn) {
    final max = fn.maxMembers != null ? ' / Máx. ${fn.maxMembers}' : '';
    return 'Mín. ${fn.minMembers}$max membro${fn.minMembers != 1 ? 's' : ''}';
  }

  void _confirm() {
    AppModal.hide<({String? functionId})>(
      context,
      (functionId: _selectedId == _kNoFunction ? null : _selectedId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Escolha sua função',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Selecione a função com a qual vai participar deste evento.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...widget.calledFunctions.map(
                        (fn) => SelectableTile(
                          title: '${fn.emoji}  ${fn.name}',
                          description: _limitLabel(fn),
                          isSelected: _selectedId == fn.id,
                          onTap: () => setState(() => _selectedId = fn.id),
                        ),
                      ),
                      if (widget.allowNoFunction)
                        SelectableTile(
                          title: 'Participar sem função',
                          isSelected: _selectedId == _kNoFunction,
                          onTap: () =>
                              setState(() => _selectedId = _kNoFunction),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ActionButton(
                      label: 'Cancelar',
                      schema: ActionButtonSchema.ghost,
                      outlined: true,
                      onPressed: () => AppModal.hide(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionButton(
                      label: 'Confirmar',
                      onPressed: _selectedId != null ? _confirm : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
