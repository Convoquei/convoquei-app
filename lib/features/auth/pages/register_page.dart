import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/user_feedback_service.dart';
import '../../../core/widgets/app_logo.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_page_shell.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).register(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
    if (!mounted) return;
    final errorMsg = ref.read(authProvider).errorMessage;
    if (errorMsg != null) {
      await UserFeedbackService.error(context, message: errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider.select((s) => s.isRegistering));
    final colors = context.colors;

    return PopScope(
      canPop: false,
      child: AuthPageShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: AppLogo.icon(size: 72)),
            const SizedBox(height: DSSpacing.xl),
            const DSText(
              'Crie sua conta',
              variant: DSTextVariant.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.sm),
            const DSText(
              'Junte-se ao Convoquei e simplifique\nsua organização.',
              variant: DSTextVariant.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.xxl + 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Seu nome completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Informe seu nome' : null,
                  ),
                  const SizedBox(height: DSSpacing.md),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Endereço de e-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Informe o e-mail' : null,
                  ),
                  const SizedBox(height: DSSpacing.md),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: 'Senha (mínimo 8 caracteres)',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe a senha';
                      if (v.length < 8) return 'Mínimo 8 caracteres';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.xl),
            DSButton(
              label: 'Criar conta',
              isLoading: isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: DSSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const DSText('Já tem conta? ', variant: DSTextVariant.bodyMedium),
                InkWell(
                  onTap: isLoading ? null : () => Navigator.of(context).pop(),
                  child: DSText(
                    'Entrar',
                    variant: DSTextVariant.labelLarge,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
