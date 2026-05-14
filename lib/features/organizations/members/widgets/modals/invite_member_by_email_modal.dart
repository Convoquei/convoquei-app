import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:convoquei_app/core/widgets/base_modal_stateful_widget.dart';
import 'package:convoquei_app/features/organizations/members/providers/invite_member_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InviteMemberByEmailModal extends BaseModalStatefulWidget {
  final String orgId;

  const InviteMemberByEmailModal({super.key, required this.orgId});

  static Future<bool?> show(
    BuildContext context,
    String orgId,
  ) => BaseModalStatefulWidget.show<bool>(
    context,
    InviteMemberByEmailModal(orgId: orgId),
  );

  @override
  State<InviteMemberByEmailModal> createState() =>
      _InviteMemberByEmailModalState();
}

class _InviteMemberByEmailModalState
    extends BaseModalState<InviteMemberByEmailModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  String? get titleText => 'Convidar por e-mail';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final container = ProviderScope.containerOf(context);
      await container
          .read(inviteOrganizationMemberProvider.notifier)
          .invite(organizationId: widget.orgId, email: _emailController.text.trim());

      if (!mounted) return;
      ToastFeedbackService.showToast(
        context,
        'Convite enviado com sucesso!',
        ToastType.success,
      );
      BaseModalStatefulWidget.hide(context, true);
    } catch (e) {
      if (!mounted) return;
      if (e is ApiException) {
        UserFeedbackService.error(context, message: e.message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  List<Widget> buildBody(BuildContext context) {
    final theme = Theme.of(context);

    return [
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
                  "E-mail do membro",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: "Ex: joao@email.com",
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o e-mail do membro';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Informe um e-mail válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _NewUserInfoCard(),
                const SizedBox(height: 12),
                _BulkInviteLinkHint(),
              ],
            ),
          ),
        ),
      ),

      const Divider(height: 1),

      // FOOTER
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            ActionButton(
              label: 'Enviar convite',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            Text(
              "O convite ficará disponível por 7 dias.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ];
  }
}

class _NewUserInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Caso o e-mail informado não possua uma conta no Convoquei, a pessoa receberá um convite para criar uma conta e já ingressar na organização.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF92400E),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulkInviteLinkHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Icon(
          Icons.people_outline_rounded,
          size: 14,
          color: Color(0xFF94A3B8),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: "Quer convidar várias pessoas de uma vez? ",
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF94A3B8),
              ),
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: abrir gerador de link de convite
                    },
                    child: Text(
                      "Gerar link de convite",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                TextSpan(
                  text: ".",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}