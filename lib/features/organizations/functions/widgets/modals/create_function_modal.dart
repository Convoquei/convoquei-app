import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/widgets/emoji_picker_widget.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/functions/providers/create_function_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateFunctionModal extends DSBaseModal {
  const CreateFunctionModal({super.key, required this.organizationId});

  final String organizationId;

  static Future<bool?> show(BuildContext context, String organizationId) =>
      DSBaseModal.show<bool>(context, CreateFunctionModal(organizationId: organizationId));

  @override
  State<CreateFunctionModal> createState() => _CreateFunctionModalState();
}

class _CreateFunctionModalState extends DSBaseModalState<CreateFunctionModal>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedEmoji = '🎵';
  late final TabController _tabController;
  bool _isLoading = false;

  @override
  String? get titleText => 'Nova função';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: emojiCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(createFunctionProvider.notifier).create(
        organizationId: widget.organizationId,
        name: _nameController.text.trim(),
        emoji: _selectedEmoji,
      );
      if (!mounted) return;
      DSBaseModal.hide(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
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
            DSSpacing.xl, DSSpacing.sm, DSSpacing.xl, 0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: EmojiPreview(
                    emoji: _selectedEmoji,
                    name: _nameController.text.isEmpty ? 'Nome da função' : _nameController.text,
                  ),
                ),
                const SizedBox(height: DSSpacing.xl),
                DSText('NOME DA FUNÇÃO', variant: DSTextVariant.labelSmall, color: context.colors.textSecondary),
                const SizedBox(height: DSSpacing.sm),
                TextFormField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Ex: Vocalista, Guitarrista, Mídia…'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe um nome para a função';
                    if (v.trim().length < 2) return 'Mínimo de 2 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: DSSpacing.xl),
                DSText('EMOJI', variant: DSTextVariant.labelSmall, color: context.colors.textSecondary),
                const SizedBox(height: DSSpacing.sm),
                EmojiPicker(
                  tabController: _tabController,
                  selected: _selectedEmoji,
                  onSelect: (e) => setState(() => _selectedEmoji = e),
                ),
                const SizedBox(height: DSSpacing.sm),
              ],
            ),
          ),
        ),
      ),
      const DSDivider(),
      Consumer(
        builder: (context, ref, _) {
          final loading = _isLoading || ref.watch(createFunctionProvider).isLoading;
          return Padding(
            padding: const EdgeInsets.fromLTRB(DSSpacing.xl, DSSpacing.lg, DSSpacing.xl, DSSpacing.xl),
            child: DSButton(
              label: 'Criar função',
              isLoading: loading,
              onPressed: loading ? null : () => _submit(ref),
            ),
          );
        },
      ),
    ];
  }
}
