import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_function_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';
import 'package:convoquei_app/features/organizations/events/models/event_form_step3_data.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/create_organization_event_request.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/update_organization_event_request.dart';
import 'package:convoquei_app/features/organizations/events/providers/create_event_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_event_details_by_id_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/update_event_provider.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_model.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_functions_request.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_groups_request.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_functions_repository.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_groups_repository.dart';
import 'package:convoquei_app/features/organizations/home/providers/next_assigned_event_provider.dart';
import 'package:convoquei_app/features/organizations/home/providers/next_pending_availability_event_provider.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Paleta de cores de vestimentas ─────────────────────────────────────────

const _kDressCodeColors = [
  ('Preto', Color(0xFF0F172A)),
  ('Branco', Color(0xFFFFFFFF)),
  ('Azul', Color(0xFF2563EB)),
  ('Vermelho', Color(0xFFEF4444)),
  ('Verde', Color(0xFF10B981)),
  ('Laranja', Color(0xFFF97316)),
  ('Roxo', Color(0xFF7C3AED)),
  ('Cinza', Color(0xFF64748B)),
];

// ─── Dado de grupo selecionado ───────────────────────────────────────────────

class _SelectedGroup {
  const _SelectedGroup({
    required this.id,
    required this.name,
    required this.emoji,
  });

  final String id;
  final String name;
  final String emoji;
}

// ─── Estado do formulário (único para os 3 passos) ───────────────────────────

class _WizardFormData {
  // Passo 1
  String name;
  String location;
  String description;
  DateTime? startAt;
  DateTime? endAt;
  String? dressCodeDescription;
  List<Color> dressCodeColors;

  // Passo 2
  OrganizationEventAssignmentMode assignmentMode;
  OrganizationEventCallMode callMode;
  List<_SelectedGroup> selectedGroups;

  // Passo 3
  bool autoCloseEnabled;
  int autoCloseHours;
  OrganizationEventFunctionCallMode? restrictionMode;
  List<FunctionRuleData> functionRules;

  _WizardFormData({
    required this.name,
    required this.location,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.dressCodeDescription,
    required this.dressCodeColors,
    required this.assignmentMode,
    required this.callMode,
    required this.selectedGroups,
    required this.autoCloseEnabled,
    required this.autoCloseHours,
    required this.restrictionMode,
    required this.functionRules,
  });

  factory _WizardFormData.empty() => _WizardFormData(
    name: '',
    location: '',
    description: '',
    startAt: null,
    endAt: null,
    dressCodeDescription: null,
    dressCodeColors: const [],
    assignmentMode: OrganizationEventAssignmentMode.manual,
    callMode: OrganizationEventCallMode.allOrganizationMembers,
    selectedGroups: const [],
    autoCloseEnabled: false,
    autoCloseHours: 4,
    restrictionMode: null,
    functionRules: const [],
  );

  factory _WizardFormData.fromDetails(OrganizationEventDetailsModel d) {
    final lock = d.availabilityLockBeforeStartInMinutes;
    final lockHours = (lock / 60).round().clamp(1, 999);

    final groups = d.calledGroups
        .map((g) => _SelectedGroup(id: g.id, name: g.name, emoji: g.icon))
        .toList();

    final rules = d.calledFunctions
        .map(
          (fn) => FunctionRuleData(
            functionId: fn.functionId,
            name: fn.functionName,
            emoji: fn.icon,
            min: fn.minMembers,
            max: fn.maxMembers,
            assignmentMode: fn.assignmentMode,
          ),
        )
        .toList();

    final savedColors = (d.dressCodeColors ?? [])
        .map(_hexToColor)
        .whereType<Color>()
        .toList();

    return _WizardFormData(
      name: d.name,
      location: d.location,
      description: d.description,
      startAt: d.startAt,
      endAt: d.endAt,
      dressCodeDescription: d.dressCodeDescription,
      dressCodeColors: savedColors,
      assignmentMode: d.assignmentMode,
      callMode: d.callMode,
      selectedGroups:
          d.callMode == OrganizationEventCallMode.allOrganizationMembers
          ? const []
          : groups,
      autoCloseEnabled: lock > 0,
      autoCloseHours: lock > 0 ? lockHours : 4,
      restrictionMode: rules.isEmpty ? null : d.functionCallMode,
      functionRules: rules,
    );
  }

  bool get step1IsValid =>
      name.trim().isNotEmpty &&
      location.trim().isNotEmpty &&
      startAt != null &&
      endAt != null &&
      endAt!.isAfter(startAt!);

  bool get step2IsValid =>
      callMode == OrganizationEventCallMode.allOrganizationMembers ||
      selectedGroups.isNotEmpty;

  List<String>? get _dressCodeColorsHex => dressCodeColors.isEmpty
      ? null
      : dressCodeColors.map(_colorToHex).toList();

  CreateOrganizationEventRequest toCreateRequest() {
    final lockMinutes = autoCloseEnabled ? autoCloseHours * 60 : 0;
    final hasFunctionRules =
        restrictionMode != null && functionRules.isNotEmpty;

    return CreateOrganizationEventRequest.fromFields(
      name: name.trim(),
      description: description.trim(),
      location: location.trim(),
      assignmentMode: assignmentMode,
      callMode: callMode,
      functionCallMode: hasFunctionRules ? restrictionMode : null,
      availabilityLockBeforeStartInMinutes: lockMinutes,
      calledFunctionIds: hasFunctionRules
          ? functionRules
                .map(
                  (r) => CalledFunctionPayload(
                    id: r.functionId,
                    minMembers: r.min,
                    maxMembers: r.max,
                    assignmentMode: r.assignmentMode,
                  ),
                )
                .toList()
          : const [],
      calledGroupIds:
          callMode == OrganizationEventCallMode.allOrganizationMembers
          ? const []
          : selectedGroups.map((g) => g.id).toList(),
      startDate: startAt!,
      endDate: endAt!,
      dressCodeDescription: dressCodeDescription?.trim().isEmpty == true
          ? null
          : dressCodeDescription?.trim(),
      dressCodeColors: _dressCodeColorsHex,
    );
  }

  UpdateOrganizationEventRequest toUpdateRequest() {
    final lockMinutes = autoCloseEnabled ? autoCloseHours * 60 : 0;
    final hasFunctionRules =
        restrictionMode != null && functionRules.isNotEmpty;

    return UpdateOrganizationEventRequest.fromFields(
      name: name.trim(),
      description: description.trim(),
      location: location.trim(),
      assignmentMode: assignmentMode,
      callMode: callMode,
      functionCallMode: hasFunctionRules ? restrictionMode : null,
      availabilityLockBeforeStartInMinutes: lockMinutes,
      calledFunctionIds: hasFunctionRules
          ? functionRules
                .map(
                  (r) => CalledFunctionPayload(
                    id: r.functionId,
                    minMembers: r.min,
                    maxMembers: r.max,
                    assignmentMode: r.assignmentMode,
                  ),
                )
                .toList()
          : const [],
      calledGroupIds:
          callMode == OrganizationEventCallMode.allOrganizationMembers
          ? const []
          : selectedGroups.map((g) => g.id).toList(),
      startDate: startAt!,
      endDate: endAt!,
      dressCodeDescription: dressCodeDescription?.trim().isEmpty == true
          ? null
          : dressCodeDescription?.trim(),
      dressCodeColors: _dressCodeColorsHex,
    );
  }
}

Color? _hexToColor(String hex) {
  try {
    final clean = hex.replaceAll('#', '').padLeft(8, 'FF');
    return Color(int.parse(clean, radix: 16));
  } catch (_) {
    return null;
  }
}

String _colorToHex(Color c) =>
    c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();

// ─── Página principal ────────────────────────────────────────────────────────

class OrgEventConfigurationWizardPage extends ConsumerStatefulWidget {
  const OrgEventConfigurationWizardPage({
    super.key,
    required this.organizationId,
    this.eventId,
  });

  final String organizationId;
  final String? eventId;

  @override
  ConsumerState<OrgEventConfigurationWizardPage> createState() =>
      _OrgEventConfigurationWizardPageState();
}

class _OrgEventConfigurationWizardPageState
    extends ConsumerState<OrgEventConfigurationWizardPage> {
  _WizardFormData? _form;
  bool _initialized = false;

  bool get _isEdit => widget.eventId != null;

  @override
  void initState() {
    super.initState();
    if (!_isEdit) {
      _form = _WizardFormData.empty();
      _initialized = true;
    }
  }

  Future<bool> _submit() async {
    final form = _form!;
    try {
      if (_isEdit) {
        await ref
            .read(updateEventProvider.notifier)
            .save(
              organizationId: widget.organizationId,
              eventId: widget.eventId!,
              request: form.toUpdateRequest(),
            );
        ref.invalidate(
          findEventDetailsByIdProvider(
            organizationId: widget.organizationId,
            eventId: widget.eventId!,
          ),
        );
        if (mounted) {
          ToastFeedbackService.showToast(
            context,
            'Evento atualizado com sucesso!',
            ToastType.success,
          );
        }
      } else {
        await ref
            .read(createEventProvider.notifier)
            .create(
              organizationId: widget.organizationId,
              request: form.toCreateRequest(),
            );

        ref.invalidate(
          nextPendingAvailabilityEventProvider(widget.organizationId),
        );

        if (mounted) {
          ToastFeedbackService.showToast(
            context,
            'Evento criado com sucesso!',
            ToastType.success,
          );
        }
      }
      return true;
    } on ApiException catch (e) {
      if (mounted) {
        ToastFeedbackService.showToast(context, e.userMessage, ToastType.error);
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canUseAutoSchedule =
        ref.watch(selectedOrganizationProvider)?.hasAutoScheduleFeature ??
        false;

    if (_isEdit) {
      final detailsProvider = findEventDetailsByIdProvider(
        organizationId: widget.organizationId,
        eventId: widget.eventId!,
      );

      final detailsAsync = ref.watch(detailsProvider);

      // Inicializa o form assim que os dados chegam (inclusive se já estiver
      // cacheado — ref.listen só dispara em mudanças, não no valor inicial).
      if (!_initialized) {
        detailsAsync.whenData((details) {
          _form = _WizardFormData.fromDetails(details);
          _initialized = true;
        });
      }

      if (!_initialized) {
        return detailsAsync.when(
          loading: () => const DSLoadingScreen(
            label: 'Carregando evento...',
            description: 'Buscando dados para edição',
            skeleton: DSLoadingSkeleton.details,
          ),
          error: (error, _) => Scaffold(
            appBar: AppBar(),
            body: DSErrorRetryState(
              icon: Icons.event_busy_rounded,
              message: 'Não foi possível carregar o evento',
              description: 'Verifique sua conexão e tente novamente.',
              onRetry: () => ref.invalidate(detailsProvider),
            ),
          ),
          data: (_) => const DSLoadingScreen(
            label: 'Carregando evento...',
            description: 'Preparando formulário',
            skeleton: DSLoadingSkeleton.details,
          ),
        );
      }

      final canManageEvents =
          ref
              .watch(
                currentUserMembershipOrganizationProvider(
                  widget.organizationId,
                ),
              )
              .asData
              ?.value
              .hasPermission(OrganizationPermissionEnum.manageEvents) ??
          false;

      final eventStatus = ref.watch(detailsProvider).asData?.value.status;

      final readOnly =
          !canManageEvents || eventStatus != OrganizationEventStatus.scheduled;

      final readOnlyMessage = _readOnlyMessage(eventStatus, canManageEvents);

      return _buildWizard(
        canUseAutoSchedule: canUseAutoSchedule,
        readOnly: readOnly,
        readOnlyMessage: readOnlyMessage,
      );
    }

    return _buildWizard(canUseAutoSchedule: canUseAutoSchedule);
  }

  Widget _buildWizard({
    required bool canUseAutoSchedule,
    bool readOnly = false,
    String? readOnlyMessage,
  }) {
    final form = _form!;

    return DSWizardPage(
      pageTitle: _isEdit ? 'Editar Evento' : 'Criar Evento',
      finishLabel: _isEdit ? 'Salvar Alterações' : 'Publicar Evento',
      readOnly: readOnly,
      readOnlyMessage: readOnlyMessage,
      onFinish: _submit,
      steps: [
        DSWizardStep(
          title: 'O Básico',
          subtitle: 'Identifique o evento e defina o tempo.',
          canAdvance: () => form.step1IsValid,
          builder: (_) => _BasicInfoStep(
            name: form.name,
            location: form.location,
            description: form.description,
            startAt: form.startAt,
            endAt: form.endAt,
            dressCodeDescription: form.dressCodeDescription,
            dressCodeColors: form.dressCodeColors,
            onNameChanged: (v) => setState(() => form.name = v),
            onLocationChanged: (v) => setState(() => form.location = v),
            onDescriptionChanged: (v) => setState(() => form.description = v),
            onStartAtChanged: (v) => setState(() => form.startAt = v),
            onEndAtChanged: (v) => setState(() => form.endAt = v),
            onDressCodeDescriptionChanged: (v) =>
                setState(() => form.dressCodeDescription = v),
            onDressCodeColorsChanged: (v) =>
                setState(() => form.dressCodeColors = v),
          ),
        ),
        DSWizardStep(
          title: 'Convocação',
          subtitle: 'Quem deve receber o aviso deste evento?',
          canAdvance: () => form.step2IsValid,
          builder: (_) => _SummonStep(
            organizationId: widget.organizationId,
            canUseAutoSchedule: canUseAutoSchedule,
            assignmentMode: form.assignmentMode,
            callMode: form.callMode,
            selectedGroups: form.selectedGroups,
            onAssignmentModeChanged: (v) =>
                setState(() => form.assignmentMode = v),
            onCallModeChanged: (v) => setState(() {
              form.callMode = v;
              if (v == OrganizationEventCallMode.allOrganizationMembers) {
                form.selectedGroups = const [];
              }
            }),
            onGroupsChanged: (v) => setState(() => form.selectedGroups = v),
          ),
        ),
        DSWizardStep(
          title: 'Inteligência',
          subtitle: 'Configure restrições e automações por função.',
          canAdvance: () => true,
          builder: (_) => _IntelligenceStep(
            organizationId: widget.organizationId,
            canUseAutoSchedule: canUseAutoSchedule,
            autoCloseEnabled: form.autoCloseEnabled,
            autoCloseHours: form.autoCloseHours,
            restrictionMode: form.restrictionMode,
            functionRules: form.functionRules,
            onAutoCloseEnabledChanged: (v) => setState(() {
              form.autoCloseEnabled = v;
              if (!v) {
                // Desabilitar SORTEIO se fecho desativado — reseta para MANUAL
                // (não há SORTEIO no enum atual, então apenas garante consistência)
                form.functionRules = form.functionRules
                    .map((r) => r.copyWith(assignmentMode: r.assignmentMode))
                    .toList();
              }
            }),
            onAutoCloseHoursChanged: (v) =>
                setState(() => form.autoCloseHours = v),
            onRestrictionModeChanged: (v) => setState(() {
              form.restrictionMode = v;
              if (v == null) form.functionRules = const [];
            }),
            onFunctionRulesChanged: (v) =>
                setState(() => form.functionRules = v),
          ),
        ),
      ],
    );
  }

  static String? _readOnlyMessage(
    OrganizationEventStatus? status,
    bool canManageEvents,
  ) {
    if (!canManageEvents) {
      return 'Você não tem permissão para editar este evento.';
    }
    return switch (status) {
      OrganizationEventStatus.scheduled => null,
      OrganizationEventStatus.inProgress =>
        'Não é possível editar um evento em andamento.',
      OrganizationEventStatus.completed =>
        'Não é possível editar um evento já finalizado.',
      OrganizationEventStatus.canceled =>
        'Não é possível editar um evento cancelado.',
      null => null,
    };
  }
}

// ─── Passo 1: O Básico ───────────────────────────────────────────────────────

class _BasicInfoStep extends StatefulWidget {
  const _BasicInfoStep({
    required this.name,
    required this.location,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.dressCodeDescription,
    required this.dressCodeColors,
    required this.onNameChanged,
    required this.onLocationChanged,
    required this.onDescriptionChanged,
    required this.onStartAtChanged,
    required this.onEndAtChanged,
    required this.onDressCodeDescriptionChanged,
    required this.onDressCodeColorsChanged,
  });

  final String name;
  final String location;
  final String description;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? dressCodeDescription;
  final List<Color> dressCodeColors;

  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<DateTime?> onStartAtChanged;
  final ValueChanged<DateTime?> onEndAtChanged;
  final ValueChanged<String?> onDressCodeDescriptionChanged;
  final ValueChanged<List<Color>> onDressCodeColorsChanged;

  @override
  State<_BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<_BasicInfoStep> {
  late final TextEditingController _nameCtr;
  late final TextEditingController _locationCtr;
  late final TextEditingController _descCtr;
  late final TextEditingController _dressDescCtr;
  late final TextEditingController _startCtr;
  late final TextEditingController _endCtr;

  @override
  void initState() {
    super.initState();
    _nameCtr = TextEditingController(text: widget.name);
    _locationCtr = TextEditingController(text: widget.location);
    _descCtr = TextEditingController(text: widget.description);
    _dressDescCtr = TextEditingController(
      text: widget.dressCodeDescription ?? '',
    );
    _startCtr = TextEditingController(
      text: widget.startAt != null ? _fmt(widget.startAt!) : '',
    );
    _endCtr = TextEditingController(
      text: widget.endAt != null ? _fmt(widget.endAt!) : '',
    );
  }

  @override
  void didUpdateWidget(_BasicInfoStep old) {
    super.didUpdateWidget(old);
    if (old.startAt != widget.startAt) {
      _startCtr.text = widget.startAt != null ? _fmt(widget.startAt!) : '';
    }
    if (old.endAt != widget.endAt) {
      _endCtr.text = widget.endAt != null ? _fmt(widget.endAt!) : '';
    }
  }

  @override
  void dispose() {
    _nameCtr.dispose();
    _locationCtr.dispose();
    _descCtr.dispose();
    _dressDescCtr.dispose();
    _startCtr.dispose();
    _endCtr.dispose();
    super.dispose();
  }

  static String _fmt(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m  $h:$min';
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final firstDate = !isStart && widget.startAt != null
        ? DateTime(
            widget.startAt!.year,
            widget.startAt!.month,
            widget.startAt!.day,
          )
        : todayStart;

    DateTime initial;
    if (isStart) {
      initial =
          widget.startAt ??
          DateTime(now.year, now.month, now.day, now.hour + 1);
    } else {
      initial =
          widget.endAt ??
          (widget.startAt?.add(const Duration(hours: 1)) ??
              DateTime(now.year, now.month, now.day, now.hour + 2));
    }
    if (initial.isBefore(firstDate)) initial = firstDate;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5),
      helpText: isStart ? 'DATA DE INÍCIO' : 'DATA DE FIM',
      confirmText: 'PRÓXIMO',
    );
    if (date == null || !mounted) return;

    TimeOfDay initialTime = TimeOfDay.fromDateTime(initial);

    while (true) {
      final time = await showTimePicker(
        context: context,
        initialTime: initialTime,
        helpText: isStart ? 'HORÁRIO DE INÍCIO' : 'HORÁRIO DE FIM',
        confirmText: 'CONFIRMAR',
      );
      if (time == null || !mounted) return;

      final combined = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      if (isStart && combined.isBefore(now)) {
        initialTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute);
        _showSnack('Selecione um horário a partir de agora.');
        continue;
      }
      if (!isStart &&
          widget.startAt != null &&
          !combined.isAfter(widget.startAt!)) {
        final s = widget.startAt!;
        initialTime = TimeOfDay(hour: (s.hour + 1) % 24, minute: s.minute);
        _showSnack(
          'O horário de fim deve ser após ${s.hour.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')}.',
        );
        continue;
      }

      if (isStart) {
        widget.onStartAtChanged(combined);
      } else {
        widget.onEndAtChanged(combined);
      }
      break;
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: context.colors.danger,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleColor(Color color) {
    final current = List<Color>.from(widget.dressCodeColors);
    if (current.any((c) => c.toARGB32() == color.toARGB32())) {
      current.removeWhere((c) => c.toARGB32() == color.toARGB32());
    } else {
      current.add(color);
    }
    widget.onDressCodeColorsChanged(current);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Campos principais
        DSCard(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameCtr,
                onChanged: widget.onNameChanged,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome do Evento *',
                  hintText: 'Ex: Culto de Domingo, Ensaio Geral...',
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
              TextField(
                controller: _locationCtr,
                onChanged: widget.onLocationChanged,
                decoration: const InputDecoration(
                  labelText: 'Local *',
                  hintText: 'Onde será o evento?',
                  prefixIcon: Icon(Icons.location_on_rounded, size: 18),
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
              TextField(
                controller: _descCtr,
                onChanged: widget.onDescriptionChanged,
                maxLines: 2,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Observações (Opcional)',
                  hintText: 'Alguma recomendação para a equipe?',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.lg),

        // Datas
        DSCard(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DSText('Quando?', variant: DSTextVariant.titleSmall),
              const SizedBox(height: DSSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startCtr,
                      readOnly: true,
                      showCursor: false,
                      onTap: () => _pickDateTime(isStart: true),
                      decoration: const InputDecoration(
                        labelText: 'Início *',
                        hintText: 'Selecionar',
                        prefixIcon: Icon(
                          Icons.play_circle_outline_rounded,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _endCtr,
                      readOnly: true,
                      showCursor: false,
                      onTap: () => _pickDateTime(isStart: false),
                      decoration: const InputDecoration(
                        labelText: 'Fim *',
                        hintText: 'Selecionar',
                        prefixIcon: Icon(Icons.stop_circle_outlined, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.lg),

        // Vestimentas (opcional)
        DSExpandableCard(
          leading: Icon(
            Icons.palette_outlined,
            color: colors.primary,
            size: 24,
          ),
          title: 'Vestimentas',
          description: 'Cores e orientações (opcional)',
          children: [
            const SizedBox(height: DSSpacing.sm),
            TextField(
              controller: _dressDescCtr,
              onChanged: (v) => widget.onDressCodeDescriptionChanged(
                v.trim().isEmpty ? null : v,
              ),
              maxLines: 2,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descrição do traje',
                hintText: 'Ex: Social, Esporte fino...',
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
            DSText(
              'Cores',
              variant: DSTextVariant.labelSmall,
              color: colors.textSecondary,
            ),
            const SizedBox(height: DSSpacing.sm),
            Wrap(
              spacing: DSSpacing.md,
              runSpacing: DSSpacing.sm,
              children: _kDressCodeColors.map((entry) {
                final (label, color) = entry;
                final isSelected = widget.dressCodeColors.any(
                  (c) => c.toARGB32() == color.toARGB32(),
                );
                return GestureDetector(
                  onTap: () => _toggleColor(color),
                  child: AnimatedContainer(
                    duration: DSMotion.fast,
                    curve: DSMotion.standard,
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? colors.primary : colors.border,
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: isSelected ? DSElevation.sm : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: _isDark(color)
                                ? Colors.white
                                : Colors.black87,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  bool _isDark(Color color) {
    final luminance = color.computeLuminance();
    return luminance < 0.4;
  }
}

// ─── Passo 2: Convocação ─────────────────────────────────────────────────────

class _SummonStep extends ConsumerWidget {
  const _SummonStep({
    required this.organizationId,
    required this.canUseAutoSchedule,
    required this.assignmentMode,
    required this.callMode,
    required this.selectedGroups,
    required this.onAssignmentModeChanged,
    required this.onCallModeChanged,
    required this.onGroupsChanged,
  });

  final String organizationId;
  final bool canUseAutoSchedule;
  final OrganizationEventAssignmentMode assignmentMode;
  final OrganizationEventCallMode callMode;
  final List<_SelectedGroup> selectedGroups;

  final ValueChanged<OrganizationEventAssignmentMode> onAssignmentModeChanged;
  final ValueChanged<OrganizationEventCallMode> onCallModeChanged;
  final ValueChanged<List<_SelectedGroup>> onGroupsChanged;

  Future<void> _openGroupsPicker(BuildContext context, WidgetRef ref) async {
    await DSMultiSelectModal.show<OrganizationGroupModel>(
      context,
      title: 'Selecionar Grupos',
      subtitle: 'Quem poderá se disponibilizar?',
      fetcher: (r) async {
        final repo = r.read(organizationGroupsRepositoryProvider);
        final result = await repo.findAllGroups(
          organizationId,
          FindAllOrganizationGroupsRequest(page: 0, size: 100),
        );
        return result.items;
      },
      idExtractor: (g) => g.id,
      initialSelectedIds: selectedGroups.map((g) => g.id).toSet(),
      itemBuilder: (g, isSelected, onTap) => DSSelectableTile(
        title: '${g.emoji}  ${g.name}',
        description: '${g.participantCount} membros',
        isSelected: isSelected,
        onTap: onTap,
      ),
      onSave: (ids) async {
        final repo = ref.read(organizationGroupsRepositoryProvider);
        final result = await repo.findAllGroups(
          organizationId,
          FindAllOrganizationGroupsRequest(page: 0, size: 100),
        );
        final mapped = result.items
            .where((g) => ids.contains(g.id))
            .map((g) => _SelectedGroup(id: g.id, name: g.name, emoji: g.emoji))
            .toList();
        onGroupsChanged(mapped);
      },
      saveLabel: 'Confirmar grupos',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isGroupMode =
        callMode == OrganizationEventCallMode.onlySpecifiedGroupMembers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Regra de aprovação
        DSCard(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DSText(
                'Regra de Aprovação Padrão',
                variant: DSTextVariant.titleSmall,
              ),
              const SizedBox(height: DSSpacing.md),
              _AssignmentCard(
                icon: Icons.shield_rounded,
                iconColor: colors.primary,
                title: 'Aprovação Manual',
                description: 'Você revisa e decide quem entra na escala final.',
                selected:
                    assignmentMode == OrganizationEventAssignmentMode.manual,
                locked: false,
                onTap: () => onAssignmentModeChanged(
                  OrganizationEventAssignmentMode.manual,
                ),
              ),
              const SizedBox(height: DSSpacing.sm),
              _AssignmentCard(
                icon: Icons.rocket_launch_rounded,
                iconColor: colors.success,
                title: 'Escala Automática',
                description:
                    'Membros que aceitarem são escalados automaticamente.',
                selected:
                    assignmentMode == OrganizationEventAssignmentMode.automatic,
                locked: !canUseAutoSchedule,
                onTap: canUseAutoSchedule
                    ? () => onAssignmentModeChanged(
                        OrganizationEventAssignmentMode.automatic,
                      )
                    : null,
              ),
              if (!canUseAutoSchedule) ...[
                const SizedBox(height: DSSpacing.sm),
                DSInfoBanner(
                  bgColor: colors.warningTint,
                  borderColor: colors.warning,
                  icon: Icons.lock_outline_rounded,
                  iconColor: colors.warning,
                  label: 'Recurso premium',
                  sublabel:
                      'A escala automática está disponível em planos avançados.',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.lg),

        // Quem será convocado
        DSCard(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DSText('Quem será convocado?', variant: DSTextVariant.titleSmall),
              const SizedBox(height: DSSpacing.md),
              // Segmented buttons
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: DSRadius.allMd,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentButton(
                        label: 'Todos',
                        selected: !isGroupMode,
                        onTap: () => onCallModeChanged(
                          OrganizationEventCallMode.allOrganizationMembers,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _SegmentButton(
                        label: 'Grupos',
                        selected: isGroupMode,
                        onTap: () => onCallModeChanged(
                          OrganizationEventCallMode.onlySpecifiedGroupMembers,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isGroupMode) ...[
                const SizedBox(height: DSSpacing.lg),
                if (selectedGroups.isNotEmpty) ...[
                  Wrap(
                    spacing: DSSpacing.sm,
                    runSpacing: DSSpacing.sm,
                    children: selectedGroups
                        .map(
                          (g) => DSBadge(
                            label: '${g.emoji}  ${g.name}',
                            color: colors.primary,
                            variant: DSBadgeVariant.soft,
                            size: DSBadgeSize.md,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: DSSpacing.md),
                ],
                DSButton(
                  label: selectedGroups.isEmpty
                      ? 'Selecionar Grupos'
                      : 'Alterar Grupos',
                  icon: Icons.group_add_rounded,
                  schema: DSButtonSchema.primary,
                  outlined: true,
                  onPressed: () => _openGroupsPicker(context, ref),
                ),
                if (selectedGroups.isEmpty) ...[
                  const SizedBox(height: DSSpacing.sm),
                  DSText(
                    'Selecione ao menos um grupo para continuar.',
                    variant: DSTextVariant.bodySmall,
                    color: colors.primary,
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Passo 3: Inteligência ───────────────────────────────────────────────────

class _IntelligenceStep extends ConsumerStatefulWidget {
  const _IntelligenceStep({
    required this.organizationId,
    required this.canUseAutoSchedule,
    required this.autoCloseEnabled,
    required this.autoCloseHours,
    required this.restrictionMode,
    required this.functionRules,
    required this.onAutoCloseEnabledChanged,
    required this.onAutoCloseHoursChanged,
    required this.onRestrictionModeChanged,
    required this.onFunctionRulesChanged,
  });

  final String organizationId;
  final bool canUseAutoSchedule;
  final bool autoCloseEnabled;
  final int autoCloseHours;
  final OrganizationEventFunctionCallMode? restrictionMode;
  final List<FunctionRuleData> functionRules;

  final ValueChanged<bool> onAutoCloseEnabledChanged;
  final ValueChanged<int> onAutoCloseHoursChanged;
  final ValueChanged<OrganizationEventFunctionCallMode?>
  onRestrictionModeChanged;
  final ValueChanged<List<FunctionRuleData>> onFunctionRulesChanged;

  @override
  ConsumerState<_IntelligenceStep> createState() => _IntelligenceStepState();
}

class _IntelligenceStepState extends ConsumerState<_IntelligenceStep> {
  bool _showHelp = false;
  late final TextEditingController _hoursCtr;

  @override
  void initState() {
    super.initState();
    _hoursCtr = TextEditingController(text: widget.autoCloseHours.toString());
  }

  @override
  void didUpdateWidget(_IntelligenceStep old) {
    super.didUpdateWidget(old);
    if (old.autoCloseHours != widget.autoCloseHours) {
      _hoursCtr.text = widget.autoCloseHours.toString();
    }
  }

  @override
  void dispose() {
    _hoursCtr.dispose();
    super.dispose();
  }

  Future<void> _openFunctionsPicker() async {
    final existingIds = widget.functionRules.map((r) => r.functionId).toSet();

    await DSMultiSelectModal.show<OrganizationFunctionModel>(
      context,
      title: 'Funções',
      subtitle: 'Selecione funções para adicionar regras',
      fetcher: (r) async {
        final repo = r.read(organizationFunctionsRepositoryProvider);
        final result = await repo.findAllFunctions(
          widget.organizationId,
          FindAllOrganizationFunctionsRequest(page: 0, size: 100),
        );
        return result.items;
      },
      idExtractor: (f) => f.id,
      initialSelectedIds: existingIds,
      itemBuilder: (f, isSelected, onTap) => DSSelectableTile(
        title: '${f.emoji}  ${f.name}',
        description: '${f.memberCount} membros',
        isSelected: isSelected,
        onTap: onTap,
      ),
      onSave: (ids) async {
        final repo = ref.read(organizationFunctionsRepositoryProvider);
        final result = await repo.findAllFunctions(
          widget.organizationId,
          FindAllOrganizationFunctionsRequest(page: 0, size: 100),
        );

        // Mantém regras existentes, adiciona novas, remove as desmarcadas
        final updated = <FunctionRuleData>[];
        for (final id in ids) {
          final existing = widget.functionRules
              .where((r) => r.functionId == id)
              .firstOrNull;
          if (existing != null) {
            updated.add(existing);
          } else {
            final fn = result.items.where((f) => f.id == id).firstOrNull;
            if (fn != null) {
              updated.add(
                FunctionRuleData(
                  functionId: fn.id,
                  name: fn.name,
                  emoji: fn.emoji,
                ),
              );
            }
          }
        }
        widget.onFunctionRulesChanged(updated);
      },
      saveLabel: 'Confirmar funções',
    );
  }

  void _updateRule(int index, FunctionRuleData updated) {
    final list = List<FunctionRuleData>.from(widget.functionRules);
    list[index] = updated;
    widget.onFunctionRulesChanged(list);
  }

  void _removeRule(int index) {
    final list = List<FunctionRuleData>.from(widget.functionRules);
    list.removeAt(index);
    widget.onFunctionRulesChanged(list);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasFunctionRules = widget.restrictionMode != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fecho automático
        DSCard(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            DSText(
                              'Fecho Automático',
                              variant: DSTextVariant.titleSmall,
                            ),
                            if (!widget.canUseAutoSchedule) ...[
                              const SizedBox(width: DSSpacing.sm),
                              DSBadge(
                                label: 'Premium',
                                color: colors.primary,
                                variant: DSBadgeVariant.filled,
                                size: DSBadgeSize.sm,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: DSSpacing.xs),
                        DSText(
                          'Bloqueia respostas antes do evento.',
                          variant: DSTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: widget.autoCloseEnabled,
                    onChanged: widget.canUseAutoSchedule
                        ? widget.onAutoCloseEnabledChanged
                        : null,
                    activeThumbColor: colors.primary,
                  ),
                ],
              ),
              if (widget.autoCloseEnabled) ...[
                const SizedBox(height: DSSpacing.lg),
                TextField(
                  controller: _hoursCtr,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) {
                    final h = int.tryParse(v);
                    if (h != null && h > 0) widget.onAutoCloseHoursChanged(h);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Horas antes do evento',
                    hintText: '4',
                    suffixText: 'horas',
                  ),
                ),
              ],
              if (!widget.canUseAutoSchedule) ...[
                const SizedBox(height: DSSpacing.sm),
                DSInfoBanner(
                  bgColor: colors.infoTint,
                  borderColor: colors.info,
                  icon: Icons.info_outline_rounded,
                  iconColor: colors.info,
                  label: 'Recurso premium',
                  sublabel:
                      'O fecho automático está disponível em planos avançados.',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.lg),

        // Restrição de participação
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DSText(
                  'Restrição de Participação',
                  variant: DSTextVariant.labelSmall,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: DSSpacing.sm),
                GestureDetector(
                  onTap: () => setState(() => _showHelp = !_showHelp),
                  child: Icon(
                    Icons.help_outline_rounded,
                    size: 16,
                    color: _showHelp ? colors.primary : colors.textSecondary,
                  ),
                ),
              ],
            ),
            if (_showHelp) ...[
              const SizedBox(height: DSSpacing.sm),
              DSInfoBanner(
                bgColor: colors.primaryTint,
                borderColor: colors.primary,
                icon: Icons.auto_awesome_rounded,
                iconColor: colors.primary,
                label: 'Regras de função',
                sublabel:
                    'Regras por função sempre sobrescrevem a regra padrão do evento. '
                    'Use "Mista" para que todos participem mas funções específicas tenham limites ou aprovação diferente.',
              ),
            ],
            const SizedBox(height: DSSpacing.sm),
            DSCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _RestrictionOption(
                    title: 'Escala livre',
                    subtitle: 'Todos podem se disponibilizar livremente.',
                    selected: widget.restrictionMode == null,
                    onTap: () => widget.onRestrictionModeChanged(null),
                  ),
                  DSDivider(indent: DSSpacing.lg, endIndent: DSSpacing.lg),
                  _RestrictionOption(
                    title: 'Escala restrita a funções',
                    subtitle: 'Membros sem estas funções não serão convocados.',
                    selected:
                        widget.restrictionMode ==
                        OrganizationEventFunctionCallMode
                            .onlyMembersWithListedFunctions,
                    onTap: () => widget.onRestrictionModeChanged(
                      OrganizationEventFunctionCallMode
                          .onlyMembersWithListedFunctions,
                    ),
                  ),
                  DSDivider(indent: DSSpacing.lg, endIndent: DSSpacing.lg),
                  _RestrictionOption(
                    title: 'Escala aberta com restrições',
                    subtitle:
                        'Todos participam, mas funções específicas têm regras.',
                    selected:
                        widget.restrictionMode ==
                        OrganizationEventFunctionCallMode
                            .allMembersWithFunctionLimits,
                    onTap: () => widget.onRestrictionModeChanged(
                      OrganizationEventFunctionCallMode
                          .allMembersWithFunctionLimits,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Regras de função (quando restrição ativa)
        if (hasFunctionRules) ...[
          const SizedBox(height: DSSpacing.xl),
          Row(
            children: [
              Expanded(
                child: DSText(
                  'Regras de Função',
                  variant: DSTextVariant.labelSmall,
                  color: colors.textSecondary,
                ),
              ),
              TextButton.icon(
                onPressed: _openFunctionsPicker,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Adicionar'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  textStyle: context.textStyles.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          if (widget.functionRules.isEmpty)
            DSEmptyState(
              icon: Icons.tune_rounded,
              title: 'Nenhuma função configurada',
              description:
                  'Adicione funções para definir regras de participação.',
            )
          else
            ...widget.functionRules.asMap().entries.map((entry) {
              final i = entry.key;
              final rule = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.md),
                child: _FunctionRuleCard(
                  rule: rule,
                  canUseAutoSchedule: widget.canUseAutoSchedule,
                  autoCloseEnabled: widget.autoCloseEnabled,
                  onChanged: (updated) => _updateRule(i, updated),
                  onRemove: () => _removeRule(i),
                ),
              );
            }),
        ],
      ],
    );
  }
}

// ─── Helpers de UI ───────────────────────────────────────────────────────────

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.selected,
    required this.locked,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool selected;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Opacity(
      opacity: locked ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: locked ? null : onTap,
        child: AnimatedContainer(
          duration: DSMotion.fast,
          curve: DSMotion.standard,
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: selected ? colors.primaryTint : colors.surface,
            borderRadius: DSRadius.allMd,
            border: Border.all(
              color: selected ? colors.primary : colors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? colors.primary : iconColor,
                size: 22,
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSText(title, variant: DSTextVariant.titleSmall),
                    const SizedBox(height: 2),
                    DSText(
                      description,
                      variant: DSTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              if (locked)
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: colors.textSecondary,
                )
              else
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 18,
                  color: selected ? colors.primary : colors.border,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DSMotion.fast,
        curve: DSMotion.standard,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.surface : Colors.transparent,
          borderRadius: DSRadius.allSm,
          boxShadow: selected ? DSElevation.sm : null,
        ),
        child: Center(
          child: DSText(
            label,
            variant: DSTextVariant.labelMedium,
            color: selected ? colors.primary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RestrictionOption extends StatelessWidget {
  const _RestrictionOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DSMotion.fast,
        curve: DSMotion.standard,
        color: selected ? colors.primaryTint : Colors.transparent,
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20,
              color: selected ? colors.primary : colors.border,
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSText(title, variant: DSTextVariant.titleSmall),
                  const SizedBox(height: 2),
                  DSText(
                    subtitle,
                    variant: DSTextVariant.bodySmall,
                    color: colors.textSecondary,
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

class _FunctionRuleCard extends StatelessWidget {
  const _FunctionRuleCard({
    required this.rule,
    required this.canUseAutoSchedule,
    required this.autoCloseEnabled,
    required this.onChanged,
    required this.onRemove,
  });

  final FunctionRuleData rule;
  final bool canUseAutoSchedule;
  final bool autoCloseEnabled;
  final ValueChanged<FunctionRuleData> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DSCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(rule.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSText(rule.name, variant: DSTextVariant.titleSmall),
                    DSText(
                      rule.assignmentMode ==
                              OrganizationEventAssignmentMode.manual
                          ? 'Aprovação manual'
                          : 'Escala automática',
                      variant: DSTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              DSIconButton(
                icon: Icons.delete_outline_rounded,
                onPressed: onRemove,
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // Min/Max
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSText(
                      'Mínimo',
                      variant: DSTextVariant.labelSmall,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    _Counter(
                      value: rule.min,
                      min: 1,
                      onDecrement: rule.min > 1
                          ? () => onChanged(rule.copyWith(min: rule.min - 1))
                          : null,
                      onIncrement: () =>
                          onChanged(rule.copyWith(min: rule.min + 1)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DSSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSText(
                      'Máximo',
                      variant: DSTextVariant.labelSmall,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    _Counter(
                      value: rule.max,
                      min: rule.min,
                      onDecrement: rule.max != null && rule.max! > rule.min
                          ? () => onChanged(rule.copyWith(max: rule.max! - 1))
                          : rule.max != null
                          ? () => onChanged(rule.copyWith(clearMax: true))
                          : null,
                      onIncrement: rule.max == null
                          ? null
                          : () => onChanged(rule.copyWith(max: rule.max! + 1)),
                      isInfinity: rule.max == null,
                      onInfinityTap: rule.max == null
                          ? () => onChanged(rule.copyWith(max: rule.min))
                          : () => onChanged(rule.copyWith(clearMax: true)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // Modo de aprovação
          DSText(
            'Escalação desta função',
            variant: DSTextVariant.labelSmall,
            color: colors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: DSRadius.allSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    label: 'MANUAL',
                    selected:
                        rule.assignmentMode ==
                        OrganizationEventAssignmentMode.manual,
                    onTap: () => onChanged(
                      rule.copyWith(
                        assignmentMode: OrganizationEventAssignmentMode.manual,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _ModeButton(
                    label: 'AUTO',
                    selected:
                        rule.assignmentMode ==
                        OrganizationEventAssignmentMode.automatic,
                    enabled: canUseAutoSchedule,
                    onTap: canUseAutoSchedule
                        ? () => onChanged(
                            rule.copyWith(
                              assignmentMode:
                                  OrganizationEventAssignmentMode.automatic,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.value,
    required this.min,
    required this.onDecrement,
    required this.onIncrement,
    this.isInfinity = false,
    this.onInfinityTap,
  });

  final int? value;
  final int min;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final bool isInfinity;
  final VoidCallback? onInfinityTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.xs,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: DSRadius.allSm,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DSIconButton(
            icon: Icons.remove_rounded,
            onPressed: isInfinity ? onInfinityTap : onDecrement,
            backgroundColor: colors.surface,
          ),
          GestureDetector(
            onTap: isInfinity ? onInfinityTap : null,
            child: DSText(
              isInfinity ? '∞' : '${value ?? min}',
              variant: DSTextVariant.titleSmall,
            ),
          ),
          DSIconButton(
            icon: Icons.add_rounded,
            onPressed: isInfinity ? null : onIncrement,
            backgroundColor: colors.surface,
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: DSMotion.fast,
          curve: DSMotion.standard,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? colors.surface : Colors.transparent,
            borderRadius: DSRadius.allSm,
            boxShadow: selected ? DSElevation.sm : null,
          ),
          child: Center(
            child: DSText(
              label,
              variant: DSTextVariant.labelSmall,
              color: selected ? colors.primary : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
