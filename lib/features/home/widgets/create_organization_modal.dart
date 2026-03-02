import 'package:convoquei_app/core/constants/app_breakpoints.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CreateOrganizationModal extends StatefulWidget {
  const CreateOrganizationModal({super.key});

  static Future<bool?> show(BuildContext context) {
    if (AppBreakpoints.isWide(context)) {
      return showDialog<bool>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: const _CreateOrganizationContent(isDialog: true),
          ),
        ),
      );
    }

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateOrganizationModal(),
    );
  }

  @override
  State<CreateOrganizationModal> createState() =>
      _CreateOrganizationModalState();
}

class _CreateOrganizationModalState
    extends State<CreateOrganizationModal> {
  @override
  Widget build(BuildContext context) {
    return const _CreateOrganizationContent(isDialog: false);
  }
}

// ---------------------------------------------------------------------------
// Conteúdo reutilizável
// ---------------------------------------------------------------------------

class _CreateOrganizationContent extends StatefulWidget {
  final bool isDialog;

  const _CreateOrganizationContent({required this.isDialog});

  @override
  State<_CreateOrganizationContent> createState() =>
      _CreateOrganizationContentState();
}

class _CreateOrganizationContentState
    extends State<_CreateOrganizationContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    // TODO: chamar provider/repositório para criar a organização
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = widget.isDialog
        ? 0.0
        : MediaQuery.viewInsetsOf(context).bottom;
    final theme = Theme.of(context);

    final borderRadius = widget.isDialog
        ? BorderRadius.circular(32)
        : const BorderRadius.vertical(top: Radius.circular(32));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle — só no bottom sheet
            if (!widget.isDialog) ...[
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
                      onPressed: () => Navigator.pop(context, false),
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
                      // NOME
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

                      // TIPO
                      Text(
                        "Tipo de Organização",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: "igreja",
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
                        onChanged: (_) {},
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
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Criar Organização"),
                    ),
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
// Widgets internos (inalterados)
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
