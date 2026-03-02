import 'package:flutter/material.dart';

import '../controllers/login_controller.dart';

class RegisterPage extends StatefulWidget {
  final AuthController authController;

  const RegisterPage({super.key, required this.authController});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  AuthController get _auth => widget.authController;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onAuthChanged() => setState(() {});

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await _auth.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _auth.isRegistering;
    final errorMsg = _auth.state.errorMessage;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Bem-vindo!',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie sua conta para começar',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Informe seu nome' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Informe o e-mail' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe a senha';
                      if (v.length < 8) return 'Mínimo 8 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        errorMsg,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Criar conta'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Já tenho conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

