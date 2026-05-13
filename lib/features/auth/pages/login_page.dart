import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/user_feedback_service.dart';
import '../../../core/widgets/app_logo.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_page_shell.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    final errorMsg = ref.read(authProvider).errorMessage;
    if (errorMsg != null) {
      await UserFeedbackService.error(context, message: errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider.select((s) => s.isLoggingIn));
    final colors = context.colors;

    return AuthPageShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: AppLogo.icon(size: 72)),
          const SizedBox(height: DSSpacing.xl),
          DSText(
            'Bem-vindo(a) ao\nConvoquei',
            variant: DSTextVariant.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSText(
            'A plataforma para gerir escalas e equipes.',
            variant: DSTextVariant.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DSSpacing.xxl + 8),
          Form(
            key: _formKey,
            child: Column(
              children: [
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
                    hintText: 'Senha',
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
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Informe a senha' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.xl),
          DSButton(
            label: 'Entrar',
            isLoading: isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: DSSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const DSText('Não tem conta? ', variant: DSTextVariant.bodyMedium),
              InkWell(
                onTap: isLoading
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                child: DSText(
                  'Registre-se',
                  variant: DSTextVariant.labelLarge,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
