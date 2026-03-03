import 'package:convoquei_app/core/constants/app_breakpoints.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:convoquei_app/core/widgets/base_modal_stateful_widget.dart';
import 'package:flutter/material.dart';

class CreateOrganizationModal extends BaseModalStatefulWidget {
  final Future<void> Function(String name, String type) onSubmit;

  const CreateOrganizationModal({super.key, required this.onSubmit});

  static Future<bool?> show(
    BuildContext context,
    Future<void> Function(String name, String type) onSubmit,
  ) => BaseModalStatefulWidget.show<bool>(
    context,
    CreateOrganizationModal(onSubmit: onSubmit),
  );

  @override
  State<CreateOrganizationModal> createState() =>
      _CreateOrganizationModalState();
}

class _CreateOrganizationModalState extends State<CreateOrganizationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'igreja';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      await widget.onSubmit(_nameController.text.trim(), _selectedType);

      if (!mounted) return;

      BaseModalStatefulWidget.hide(context, true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDialog = AppBreakpoints.isWide(context);
    final bottomPadding = isDialog
        ? 0.0
        : MediaQuery.viewInsetsOf(context).bottom;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isDialog
            ? BorderRadius.circular(32)
            : const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle — só no bottom sheet
            if (!isDialog) ...[
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ] else
              const SizedBox(height: 8),

            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Nova Organização",
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () =>
                          BaseModalStatefulWidget.hide(context, false),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // BODY
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nome da Organização",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText:
                              "Ex: Igreja Central, Ministério de Louvor...",
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o nome da organização';
                          }
                          if (value.trim().length < 3) {
                            return 'Nome deve ter pelo menos 3 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      _SlugPreview(name: _nameController.text),
                      const SizedBox(height: 24),
                      Text(
                        "Tipo de Organização",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "igreja",
                            child: Text("Igreja / Congregação"),
                          ),
                          DropdownMenuItem(
                            value: "ministerio",
                            child: Text("Ministério / Grupo Interno"),
                          ),
                          DropdownMenuItem(
                            value: "voluntarios",
                            child: Text("Equipe de Voluntários"),
                          ),
                          DropdownMenuItem(
                            value: "empresa",
                            child: Text("Empresa / Negócio"),
                          ),
                          DropdownMenuItem(
                            value: "outro",
                            child: Text("Outro"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null)
                            setState(() => _selectedType = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      _FreePlanCard(),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // FOOTER
            Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomPadding),
              child: Column(
                children: [
                  ActionButton(
                    label: 'Criar Organização',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Ao criar, você concorda com os Termos de Uso.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets internos
// ---------------------------------------------------------------------------

class _SlugPreview extends StatelessWidget {
  final String name;

  const _SlugPreview({required this.name});

  String get slug {
    final value = name.trim().toLowerCase();
    final normalized = value
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '-');
    return normalized.isEmpty ? "sua-organizacao" : normalized;
  }

  @override
  Widget build(BuildContext context) {
    final available = !slug.contains("teste");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "convoquei.com.br/$slug",
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: available
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              available ? "Disponível" : "Indisponível",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: available
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreePlanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Comece 100% de graça",
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Você pode testar a plataforma de forma ilimitada. Só faça upgrade se a sua organização crescer.",
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                _FeatureItem("Até 10 membros ativos"),
                _FeatureItem("Até 7 eventos por mês"),
                _FeatureItem(
                  "Eventos recorrentes (Requer Pro)",
                  enabled: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  final bool enabled;

  const _FeatureItem(this.text, {this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.remove,
            size: 16,
            color: enabled ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: enabled
                    ? const Color(0xFF334155)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
