import 'package:convoquei_app/design_system/components/buttons/ds_button.dart';
import 'package:convoquei_app/design_system/components/feedback/ds_alert_banner.dart';
import 'package:convoquei_app/design_system/foundations/ds_text.dart';
import 'package:convoquei_app/design_system/theme/ds_context_extensions.dart';
import 'package:convoquei_app/design_system/tokens/ds_motion.dart';
import 'package:convoquei_app/design_system/tokens/ds_spacing.dart';
import 'package:flutter/material.dart';

/// Um passo dentro de um [DSWizardPage].
class DSWizardStep {
  const DSWizardStep({
    required this.title,
    required this.subtitle,
    required this.builder,
    required this.canAdvance,
  });

  /// Título exibido no topo do passo (ex: "O Básico").
  final String title;

  /// Subtítulo descritivo exibido abaixo do título.
  final String subtitle;

  /// Constrói o corpo do passo.
  final WidgetBuilder builder;

  /// Retorna true se o usuário pode avançar para o próximo passo.
  final bool Function() canAdvance;
}

/// Layout genérico de wizard com header de progresso, corpo animado e footer de ação.
///
/// Uso:
/// ```dart
/// DSWizardPage(
///   pageTitle: 'Criar evento',
///   steps: [
///     DSWizardStep(title: 'O Básico', subtitle: '...', builder: (_) => _BasicInfoStep(...), canAdvance: () => form.step1Valid),
///     DSWizardStep(title: 'Convocação', subtitle: '...', builder: (_) => _SummonStep(...), canAdvance: () => true),
///   ],
///   onFinish: _submit,
///   finishLabel: 'Publicar evento',
/// )
/// ```
class DSWizardPage extends StatefulWidget {
  const DSWizardPage({
    super.key,
    required this.pageTitle,
    required this.steps,
    required this.onFinish,
    this.finishLabel = 'Concluir',
    this.isSubmitting = false,
    this.readOnly = false,
    this.readOnlyMessage,
  });

  final String pageTitle;
  final List<DSWizardStep> steps;

  /// Chamado ao pressionar o botão no último passo. Deve retornar `true` se
  /// a operação foi bem-sucedida (a tela será fechada automaticamente).
  final Future<bool> Function() onFinish;
  final String finishLabel;
  final bool isSubmitting;
  final bool readOnly;
  final String? readOnlyMessage;

  @override
  State<DSWizardPage> createState() => _DSWizardPageState();
}

class _DSWizardPageState extends State<DSWizardPage> {
  int _currentIndex = 0;
  bool _isSubmitting = false;

  DSWizardStep get _current => widget.steps[_currentIndex];
  bool get _isLast => _currentIndex == widget.steps.length - 1;

  bool get _canAdvance =>
      !widget.readOnly &&
      !_isSubmitting &&
      !widget.isSubmitting &&
      _current.canAdvance();

  void _onBack() {
    if (_currentIndex == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _currentIndex--);
    }
  }

  void _onNext() {
    if (_isLast) {
      _finish();
    } else {
      setState(() => _currentIndex++);
    }
  }

  Future<void> _finish() async {
    setState(() => _isSubmitting = true);
    try {
      final ok = await widget.onFinish();
      if (ok && mounted) Navigator.of(context).maybePop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = widget.steps.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            _currentIndex == 0
                ? Icons.close_rounded
                : Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
          onPressed: _onBack,
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.pageTitle, style: context.textStyles.titleSmall),
            const SizedBox(height: 1),
            Text(
              'Passo ${_currentIndex + 1} de $total',
              style: context.textStyles.labelSmall.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: progress),
            duration: DSMotion.normal,
            curve: DSMotion.standard,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              backgroundColor: colors.surfaceSubtle,
              color: colors.primary,
              minHeight: 3,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (widget.readOnly && widget.readOnlyMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.lg,
                DSSpacing.md,
                DSSpacing.lg,
                0,
              ),
              child: DSAlertBanner(
                text: widget.readOnlyMessage!,
                icon: Icons.lock_outline_rounded,
                color: colors.warning,
              ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: DSMotion.normal,
              child: SingleChildScrollView(
                key: ValueKey(_currentIndex),
                padding: const EdgeInsets.fromLTRB(
                  DSSpacing.lg,
                  DSSpacing.xl,
                  DSSpacing.lg,
                  DSSpacing.huge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DSText(
                      _current.title,
                      variant: DSTextVariant.displayMedium,
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    DSText(
                      _current.subtitle,
                      variant: DSTextVariant.bodyLarge,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: DSSpacing.xl),
                    _current.builder(context),
                  ],
                ),
              ),
            ),
          ),
          _WizardFooter(
            label: _isLast ? widget.finishLabel : 'Próximo',
            icon: _isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
            schema: _isLast ? DSButtonSchema.success : DSButtonSchema.primary,
            isLoading: _isSubmitting || widget.isSubmitting,
            enabled: _canAdvance,
            onPressed: _onNext,
          ),
        ],
      ),
    );
  }
}

class _WizardFooter extends StatelessWidget {
  const _WizardFooter({
    required this.label,
    required this.icon,
    required this.schema,
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final DSButtonSchema schema;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        DSSpacing.lg,
        DSSpacing.md,
        DSSpacing.lg,
        DSSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: DSButton(
        label: label,
        icon: icon,
        schema: schema,
        isLoading: isLoading,
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}
