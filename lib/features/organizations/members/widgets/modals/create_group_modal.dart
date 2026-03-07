import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:convoquei_app/core/widgets/base_modal_stateful_widget.dart';
import 'package:convoquei_app/core/widgets/emoji_picker_widget.dart';
import 'package:convoquei_app/features/organizations/members/providers/create_group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Modal
// ---------------------------------------------------------------------------

class CreateGroupModal extends BaseModalStatefulWidget {
  const CreateGroupModal({super.key, required this.organizationId});

  final String organizationId;

  static Future<bool?> show(BuildContext context, String organizationId) =>
      BaseModalStatefulWidget.show<bool>(
        context,
        CreateGroupModal(organizationId: organizationId),
      );

  @override
  State<CreateGroupModal> createState() => _CreateGroupModalState();
}

class _CreateGroupModalState extends BaseModalState<CreateGroupModal>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedEmoji = '👥';
  late final TabController _tabController;
  bool _isLoading = false;

  @override
  String? get titleText => 'Novo grupo';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: emojiCategories.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: const Color(0xFF94A3B8),
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(createGroupProvider.notifier).create(
            organizationId: widget.organizationId,
            name: _nameController.text.trim(),
            emoji: _selectedEmoji,
          );
      if (!mounted) return;
      BaseModalStatefulWidget.hide(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  List<Widget> buildBody(BuildContext context) {
    return [
      Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Preview ──────────────────────────────────────────────
                Center(
                  child: EmojiPreview(
                    emoji: _selectedEmoji,
                    name: _nameController.text.isEmpty
                        ? 'Nome do grupo'
                        : _nameController.text,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Nome ─────────────────────────────────────────────────
                _buildSectionLabel('Nome do grupo'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Ex: Vocal, Instrumental, Mídia…',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe um nome para o grupo';
                    }
                    if (v.trim().length < 2) return 'Mínimo de 2 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Emoji picker ─────────────────────────────────────────
                _buildSectionLabel('Emoji'),
                const SizedBox(height: 8),
                EmojiPicker(
                  tabController: _tabController,
                  selected: _selectedEmoji,
                  onSelect: (e) => setState(() => _selectedEmoji = e),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      const Divider(height: 1),
      Consumer(
        builder: (context, ref, _) {
          final loading =
              _isLoading || ref.watch(createGroupProvider).isLoading;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: ActionButton(
              label: 'Criar grupo',
              isLoading: loading,
              onPressed: loading ? null : () => _submit(ref),
            ),
          );
        },
      ),
    ];
  }
}
