import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_model.dart';
import 'package:flutter/material.dart';

class CreateRoleModal extends DSBaseModal {
  final Future<OrganizationRoleModel> Function(String name) onSubmit;

  const CreateRoleModal({super.key, required this.onSubmit});

  static Future<OrganizationRoleModel?> show(
    BuildContext context,
    Future<OrganizationRoleModel> Function(String name) onSubmit,
  ) =>
      DSBaseModal.show<OrganizationRoleModel>(context, CreateRoleModal(onSubmit: onSubmit));

  @override
  State<CreateRoleModal> createState() => _CreateRoleModalState();
}

class _CreateRoleModalState extends DSBaseModalState<CreateRoleModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  String? get titleText => 'Novo Papel';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      final role = await widget.onSubmit(_nameController.text.trim());
      if (!mounted) return;
      DSBaseModal.hide(context, role);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  List<Widget> buildBody(BuildContext context) {
    return [
      Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            DSSpacing.xl, DSSpacing.xs, DSSpacing.xl, DSSpacing.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText('Nome do Papel', variant: DSTextVariant.labelLarge),
                const SizedBox(height: DSSpacing.sm),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    hintText: 'Ex: Administrador, Líder de Louvor...',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o nome do papel';
                    if (v.trim().length < 2) return 'Mínimo de 2 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: DSSpacing.sm),
                DSText(
                  'Após criar, você poderá definir as permissões do papel.',
                  variant: DSTextVariant.bodySmall,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(DSSpacing.xl, 0, DSSpacing.xl, DSSpacing.xl),
        child: DSButton(
          label: 'Criar Papel',
          isLoading: _isLoading,
          onPressed: _isLoading || _nameController.text.trim().isEmpty ? null : _submit,
        ),
      ),
    ];
  }
}
