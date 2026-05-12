import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/base_modal_stateful_widget.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_model.dart';
import 'package:flutter/material.dart';

class CreateRoleModal extends BaseModalStatefulWidget {
  final Future<OrganizationRoleModel> Function(String name) onSubmit;

  const CreateRoleModal({super.key, required this.onSubmit});

  static Future<OrganizationRoleModel?> show(
    BuildContext context,
    Future<OrganizationRoleModel> Function(String name) onSubmit,
  ) => BaseModalStatefulWidget.show<OrganizationRoleModel>(
    context,
    CreateRoleModal(onSubmit: onSubmit),
  );

  @override
  State<CreateRoleModal> createState() => _CreateRoleModalState();
}

class _CreateRoleModalState extends BaseModalState<CreateRoleModal> {
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
      BaseModalStatefulWidget.hide(context, role);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  List<Widget> buildBody(BuildContext context) {
    final theme = Theme.of(context);

    return [
      Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nome do Papel',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    hintText: 'Ex: Administrador, Líder de Louvor...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do papel';
                    }
                    if (value.trim().length < 2) {
                      return 'Nome deve ter pelo menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Após criar, você poderá definir as permissões do papel.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _isLoading || _nameController.text.trim().isEmpty
                    ? null
                    : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFBFDBFE),
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: const Color(0x331D4ED8),
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
                : const Text('Criar Papel'),
          ),
        ),
      ),
    ];
  }
}
