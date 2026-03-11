import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WIZARD STEP CONFIG
// ─────────────────────────────────────────────────────────────────────────────

/// Configuração de um passo do wizard.
///
/// [onNext] é chamado ao pressionar "Continuar" / "Concluir".
/// - Se for `Future`, o wizard gerencia o loading automaticamente.
/// - Retorne `true` para avançar; `false` para ficar no passo (ex: erro de API).
/// - Se `null`, avança imediatamente sem async.
///
/// [canAdvance] bloqueia o botão sem loading (ex: form inválido localmente).
/// [loadingLabel] substitui o label durante o request (ex: "Criando evento...").
///
/// ```dart
/// // Passo 1 — validação local apenas
/// WizardStepConfig(
///   canAdvance: ref.watch(step1ValidProvider),
/// )
///
/// // Passo 2 — request async com feedback no botão
/// WizardStepConfig(
///   canAdvance: ref.watch(step2ValidProvider),
///   loadingLabel: 'Criando evento...',
///   onNext: () => ref.read(eventNotifier.notifier).createEvent(),
/// )
///
/// // Último passo — salva, exibe feedback e sai
/// WizardStepConfig(
///   loadingLabel: 'Salvando...',
///   onNext: () async {
///     final ok = await ref.read(eventNotifier.notifier).save();
///     return ok; // true → onFinish é chamado; false → permanece no passo
///   },
/// )
/// ```
class WizardStepConfig {
  /// Quando `false`, o botão fica desabilitado (cinza, sem spinner).
  final bool canAdvance;

  /// Label exibido no botão durante o loading.
  /// Se `null`, o label padrão ("Continuar" / "Concluir") é mantido.
  final String? loadingLabel;

  /// Callback assíncrono ao pressionar avançar.
  /// - `true`  → wizard avança para o próximo passo (ou chama [WizardPage.onFinish]).
  /// - `false` → permanece no passo atual (trate o erro no notifier antes de retornar).
  /// - `null`  → avança imediatamente sem async.
  final Future<bool> Function()? onNext;

  const WizardStepConfig({
    this.canAdvance = true,
    this.loadingLabel,
    this.onNext,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// WIZARD PAGE
// ─────────────────────────────────────────────────────────────────────────────

/// Tela de wizard reutilizável.
///
/// ### Uso básico
/// ```dart
/// WizardPage(
///   title: 'Criar Evento',
///   steps: ['O Básico', 'Equipe e Escala', 'Regras Finais'],
///   children: [Step1Widget(), Step2Widget(), Step3Widget()],
///   stepConfigs: [
///     WizardStepConfig(canAdvance: ref.watch(step1ValidProvider)),
///     WizardStepConfig(
///       canAdvance: ref.watch(step2ValidProvider),
///       loadingLabel: 'Criando evento...',
///       onNext: () => ref.read(eventNotifier.notifier).createEvent(),
///     ),
///     WizardStepConfig(
///       loadingLabel: 'Salvando...',
///       onNext: () async {
///         final ok = await ref.read(eventNotifier.notifier).save();
///         return ok;
///       },
///     ),
///   ],
///   onFinish: () => Navigator.of(context).pop(),
/// )
/// ```
class WizardPage extends StatefulWidget {

  /// Títulos dos passos — mesmo tamanho que [children].
  final List<String> steps;

  /// Conteúdo de cada passo — mesmo tamanho que [steps].
  final List<Widget> children;

  /// Configuração por passo. Passos sem config usam o padrão (sem restrições).
  final List<WizardStepConfig>? stepConfigs;

  /// Chamado após o [WizardStepConfig.onNext] do último passo retornar `true`,
  /// ou imediatamente se o último passo não tiver [onNext].
  final VoidCallback? onFinish;

  /// Label do botão de avançar (padrão: "Continuar").
  final String nextLabel;

  /// Label do botão do último passo (padrão: "Concluir").
  final String finishLabel;

  /// Label do botão de voltar (padrão: "Voltar").
  final String backLabel;

  const WizardPage({
    super.key,
    required this.steps,
    required this.children,
    this.stepConfigs,
    this.onFinish,
    this.nextLabel = 'Continuar',
    this.finishLabel = 'Concluir',
    this.backLabel = 'Voltar',
  }) : assert(steps.length == children.length,
  'steps e children devem ter o mesmo tamanho');

  @override
  State<WizardPage> createState() => _WizardPageState();
}

class _WizardPageState extends State<WizardPage>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;

  /// `true` enquanto o [WizardStepConfig.onNext] estiver em execução.
  /// Gerenciado internamente — bloqueia voltar e o botão de avançar.
  bool _isProcessing = false;

  late final AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buildAnims(forward: true);
    _animController.value = 1.0;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  WizardStepConfig get _currentConfig {
    final configs = widget.stepConfigs;
    if (configs == null || _currentStep >= configs.length) {
      return const WizardStepConfig();
    }
    return configs[_currentStep];
  }

  bool get _isLast => _currentStep == widget.steps.length - 1;
  bool get _isFirst => _currentStep == 0;

  /// Resolve o label do botão de avançar:
  /// durante o processing usa [WizardStepConfig.loadingLabel] se disponível.
  String get _resolvedNextLabel {
    if (_isProcessing) {
      final custom = _currentConfig.loadingLabel;
      if (custom != null) return custom;
    }
    return _isLast ? widget.finishLabel : widget.nextLabel;
  }

  // ── animações ─────────────────────────────────────────────────────────────

  void _buildAnims({required bool forward}) {
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: Offset(forward ? 0.05 : -0.05, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  Future<void> _goTo(int index) async {
    _buildAnims(forward: index > _currentStep);
    _animController.value = 0.0;
    setState(() => _currentStep = index);
    _animController.forward();
  }

  // ── navegação ─────────────────────────────────────────────────────────────

  Future<void> _handleNext() async {
    final config = _currentConfig;
    if (_isProcessing || !config.canAdvance) return;

    // Sem async → avança direto
    if (config.onNext == null) {
      if (_isLast) {
        widget.onFinish?.call();
      } else {
        await _goTo(_currentStep + 1);
      }
      return;
    }

    // Com async → gerencia loading internamente
    setState(() => _isProcessing = true);
    try {
      final shouldAdvance = await config.onNext!();
      if (!mounted) return;

      if (shouldAdvance) {
        if (_isLast) {
          widget.onFinish?.call();
        } else {
          await _goTo(_currentStep + 1);
        }
      }
      // false → permanece no passo; o notifier já deve ter exibido o erro
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _handleBack() {
    if (_isProcessing) return; // bloqueado durante requests
    if (_currentStep > 0) {
      _goTo(_currentStep - 1);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final total = widget.steps.length;
    final config = _currentConfig;

    return PopScope(
      canPop: _isFirst && !_isProcessing,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isProcessing) return;
        _goTo(_currentStep - 1);
      },
      child: Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── PROGRESS HEADER ───────────────────────────────────────────────
          _WizardProgressHeader(
            stepTitle: widget.steps[_currentStep],
            stepIndex: _currentStep,
            totalSteps: total,
          ),

          // ── CONTEÚDO ──────────────────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: widget.children[_currentStep],
                ),
              ),
            ),
          ),

          // ── NAV BAR ───────────────────────────────────────────────────────
          _WizardNavBar(
            isFirst: _isFirst,
            isLast: _isLast,
            backLabel: widget.backLabel,
            nextLabel: _resolvedNextLabel,
            canAdvance: config.canAdvance,
            isProcessing: _isProcessing,
            onBack: _handleBack,
            onNext: _handleNext,
          ),
        ],
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROGRESS HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _WizardProgressHeader extends StatelessWidget {
  final String stepTitle;
  final int stepIndex;
  final int totalSteps;

  const _WizardProgressHeader({
    required this.stepTitle,
    required this.stepIndex,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${stepIndex + 1}. $stepTitle',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'Passo ${stepIndex + 1} de $totalSteps',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(totalSteps, (i) {
              final isDone = i < stepIndex;
              final isActive = i == stepIndex;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  height: 5,
                  margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppTheme.primaryColor.withValues(alpha: 0.4)
                        : isActive
                        ? AppTheme.primaryColor
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAV BAR
// ─────────────────────────────────────────────────────────────────────────────

class _WizardNavBar extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final String backLabel;
  final String nextLabel; // já vem com loadingLabel resolvido
  final bool canAdvance;
  final bool isProcessing;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _WizardNavBar({
    required this.isFirst,
    required this.isLast,
    required this.backLabel,
    required this.nextLabel,
    required this.canAdvance,
    required this.isProcessing,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          // Botão Voltar — some no passo 1, bloqueado durante processing
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: isFirst
                ? const SizedBox.shrink()
                : Row(
              children: [
                ActionButton(
                  label: backLabel,
                  outlined: true,
                  schema: ActionButtonSchema.ghost,
                  fullWidth: false,
                  onPressed: isProcessing ? null : onBack,
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),

          // Botão Avançar / Concluir
          Expanded(
            child: ActionButton(
              label: nextLabel,
              schema: isLast
                  ? ActionButtonSchema.success
                  : ActionButtonSchema.primary,
              isLoading: isProcessing,
              onPressed: canAdvance && !isProcessing ? onNext : null,
            ),
          ),
        ],
      ),
    );
  }
}