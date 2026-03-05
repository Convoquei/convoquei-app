import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:convoquei_app/core/widgets/base_modal_stateful_widget.dart';
import 'package:convoquei_app/features/organizations/members/providers/create_group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Emoji categories
// ---------------------------------------------------------------------------

const _emojiCategories = <String, List<String>>{
  'Pessoas': [
    '👤', '👥', '🧑', '👦', '👧', '👨', '👩', '🧒', '👶', '🧓',
    '👴', '👵', '🧑‍🤝‍🧑', '👫', '👬', '👭', '🙋', '🙋‍♂️', '🙋‍♀️', '🙌',
    '🤝', '👋', '💪', '🦾', '🧑‍💼', '👨‍💼', '👩‍💼', '🧑‍🎤', '👨‍🎤', '👩‍🎤',
    '🧑‍🎨', '👨‍🎨', '👩‍🎨', '🧑‍🏫', '👨‍🏫', '👩‍🏫', '🧑‍🔧', '👨‍🔧', '👩‍🔧', '🧑‍💻',
    '👨‍💻', '👩‍💻', '🧑‍⚕️', '👨‍⚕️', '👩‍⚕️', '🧑‍✈️', '👨‍✈️', '👩‍✈️', '🧑‍🍳', '👨‍🍳',
    '👩‍🍳', '🧑‍🚒', '👮', '👮‍♂️', '👮‍♀️', '💂', '🕵️', '👷', '🤴', '👸',
    '🧙', '🧚', '🧛', '🧜', '🧝', '🦸', '🦹', '🤶', '🎅', '🙏',
    '🤲', '👐', '🫶', '🤜', '🤛', '✊', '👊', '🫂', '🧑‍🤝‍🧑', '👨‍👩‍👧',
    '👨‍👩‍👦', '👨‍👩‍👧‍👦', '👁️', '👀', '🫀', '🧠', '🦷', '👣', '🫁', '❤️‍🔥',
  ],
  'Expressões': [
    '😀', '😁', '😂', '🤣', '😃', '😄', '😅', '😆', '😊', '🙂',
    '🥰', '😍', '🤩', '😘', '😗', '😙', '😚', '😋', '😛', '😜',
    '🤗', '🤭', '🫡', '🫢', '🤫', '🤔', '🤐', '😐', '😑', '😶',
    '😏', '😒', '🙄', '😬', '😮', '😯', '😲', '😳', '🥺', '😦',
    '😧', '😨', '😰', '😢', '😭', '😱', '😖', '😣', '😞', '😓',
    '😩', '😫', '🥱', '😤', '😡', '🤯', '😇', '🥳', '🤠', '🤡',
    '🫠', '🤑', '😎', '🥸', '🧐', '🤓', '😴', '💀', '👻', '😈',
  ],
  'Instrumentos Musicais': [
    '🎸', '🎹', '🥁', '🎺', '🎻', '🎷', '🪗', '🪘', '🎵', '🎶',
    '🎼', '🎤', '🎧', '🎙️', '🔔', '🔕', '🪕', '🪈', '🎚️', '🎛️',
    '📻', '🔊', '🔉', '🔈', '📯', '🪗', '🥁', '🎵', '🎶', '🎼',
  ],
  'Música & Som': [
    '🎵', '🎶', '🎼', '🎤', '🎧', '🎙️', '🎚️', '🎛️', '📻', '🔊',
    '🔉', '🔈', '🔔', '📢', '📣', '🎸', '🎹', '🥁', '🎺', '🎻',
    '🎷', '🪗', '🪘', '🪕', '🪈', '🎭', '🎬', '🎞️', '📽️', '🎊',
    '🎉', '🎈', '🪅', '🎆', '🎇', '✨', '🌟', '⭐', '🌠', '💫',
    '🎼', '🎵', '🎶', '🎤', '🎧', '🪗', '🪘', '🎷', '🎺', '🥁',
  ],
  'Igreja & Fé': [
    '✝️', '🙏', '📖', '⛪', '🕊️', '✨', '🌟', '💒', '📿', '🪔',
    '🕯️', '⭐', '🌠', '💫', '🌙', '☀️', '🌅', '🌄', '🌈', '☁️',
    '⚡', '🔥', '💧', '🌊', '🕍', '🛕', '🕌', '⛩️', '🛐', '☮️',
    '✡️', '☯️', '☪️', '🕎', '🔯', '🪬', '🧿', '📜', '📗', '📕',
    '📙', '🎺', '🕊️', '🫶', '❤️', '💛', '💙', '💜', '🤍', '🌿',
    '🍀', '🌱', '🌸', '🌻', '🌺', '🪷', '🌾', '🫧', '💦', '🌬️',
  ],
  'Tecnologia': [
    '💻', '🖥️', '🖨️', '⌨️', '🖱️', '🖲️', '💾', '💿', '📀', '📱',
    '☎️', '📞', '📟', '📠', '📡', '📺', '📷', '📸', '📹', '🎥',
    '📽️', '🎞️', '📞', '🔋', '🔌', '💡', '🔦', '🕯️', '🖥️', '⌚',
    '📡', '🛰️', '🚀', '🤖', '🦾', '🦿', '🧬', '🔬', '🔭', '⚗️',
    '🧪', '🧫', '🧲', '⚙️', '🛠️', '🔧', '🔩', '🗜️', '⛓️', '🧰',
    '🪛', '🪚', '🔑', '🗝️', '🔐', '🔒', '🔓', '🪤', '🧮', '📲',
    '💬', '📧', '📨', '📩', '📤', '📥', '📦', '📫', '📪', '📬',
    '📭', '📮', '🗳️', '✏️', '✒️', '🖊️', '🖋️', '📝', '💼', '📁',
    '📂', '🗂️', '📋', '📊', '📈', '📉', '🗒️', '🗓️', '📆', '📅',
  ],
  'Objetos & Organização': [
    '📋', '📌', '📍', '📎', '🖇️', '🗂️', '📁', '📂', '🗓️', '📅',
    '📆', '📣', '📢', '🔔', '🔑', '🗝️', '⚙️', '🛠️', '💡', '🔍',
    '🔎', '📊', '📈', '📉', '🏆', '🥇', '🎯', '🚀', '💎', '👑',
    '🎁', '🎀', '🎊', '🎉', '🎈', '🎗️', '🏅', '🥈', '🥉', '🎖️',
    '🪙', '💰', '💵', '💳', '🏧', '💹', '📊', '📋', '📝', '✅',
    '☑️', '🔲', '🔳', '▪️', '▫️', '◾', '◽', '◼️', '◻️', '🟥',
    '🟧', '🟨', '🟩', '🟦', '🟪', '⬛', '⬜', '🔶', '🔷', '🔸',
    '🔹', '🔺', '🔻', '💠', '🔘', '🔲', '🔳', '📌', '🗺️', '🧭',
  ],
  'Natureza': [
    '🌱', '🌿', '🍀', '🌸', '🌻', '🌊', '⭐', '🌙', '☀️', '🔥',
    '💧', '🌈', '🍃', '🌺', '🌴', '🌳', '🌲', '🌵', '🎋', '🎍',
    '🌾', '🍁', '🍂', '🍄', '🌰', '🌷', '🌹', '🥀', '🪷', '💐',
    '🌼', '🌞', '🌝', '🌛', '🌜', '🌚', '🌕', '🌖', '🌗', '🌘',
    '🌑', '🌒', '🌓', '🌔', '🌙', '🌟', '⭐', '🌠', '💫', '✨',
    '⚡', '🌤️', '⛅', '🌥️', '☁️', '🌦️', '🌧️', '⛈️', '🌩️', '🌨️',
    '❄️', '☃️', '⛄', '🌬️', '💨', '🌪️', '🌫️', '🌊', '🌀', '🌈',
    '🌂', '☂️', '☔', '⛱️', '⚡', '❄️', '🔥', '💧', '🌊', '🌍',
    '🌎', '🌏', '🗺️', '🏔️', '⛰️', '🌋', '🗻', '🏕️', '🏖️', '🏜️',
    '🏝️', '🏞️', '🌅', '🌄', '🌠', '🎆', '🎇', '🌃', '🏙️', '🌆',
    '🌇', '🌉', '🌌', '🌁', '🐾', '🦁', '🐯', '🦊', '🐺', '🦝',
    '🐮', '🐷', '🐸', '🐵', '🙈', '🙉', '🙊', '🦅', '🦆', '🦉',
    '🦚', '🦜', '🕊️', '🦢', '🦩', '🐝', '🦋', '🐠', '🐟', '🐬',
    '🐳', '🐋', '🦈', '🌸', '🌺', '🌻', '🌼', '🌷', '🌹', '🍀',
  ],
  'Símbolos': [
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '❤️‍🔥',
    '💔', '💕', '💞', '💓', '💗', '💖', '💘', '💝', '💟', '☮️',
    '✝️', '☯️', '✡️', '🔯', '☪️', '🕎', '☮️', '♾️', '💯', '✅',
    '❎', '🆗', '🆙', '🆒', '🆕', '🆓', '🔛', '🔜', '🔚', '🔝',
    '🔙', '⬆️', '⬇️', '⬅️', '➡️', '↗️', '↘️', '↙️', '↖️', '↕️',
    '↔️', '🔄', '🔃', '🔀', '🔁', '🔂', '▶️', '⏩', '⏭️', '⏯️',
    '◀️', '⏪', '⏮️', '⏫', '⏬', '⏸️', '⏹️', '⏺️', '🎦', '🔅',
    '🔆', '📶', '🛜', '📳', '📴', '📵', '📡', '🔞', '🔕', '🔇',
    '🔈', '🔉', '🔊', '📢', '📣', '🔔', '🔕', '🎵', '🎶', '💤',
    '🔱', '⚜️', '🏵️', '🎗️', '🎫', '🎟️', '🏷️', '💮', '🔰', '♻️',
    '✳️', '❇️', '🆚', '🉐', '💠', '🌀', '⭕', '❌', '❓', '❗',
    '‼️', '⁉️', '🔣', '🔤', '🔡', '🔠', '🆎', '🆑', '🆘', '🆔',
    '⚡', '🔥', '💧', '🌊', '💨', '❄️', '🌈', '⭐', '✨', '💫',
    '♠️', '♥️', '♦️', '♣️', '♟️', '🃏', '🀄', '🎲', '🧩', '🎮',
  ],
  'Eventos & Celebrações': [
    '🎉', '🎊', '🎈', '🎁', '🎀', '🎗️', '🎟️', '🎫', '🏆', '🥇',
    '🥈', '🥉', '🎖️', '🏅', '🎯', '🎪', '🎭', '🎬', '🎥', '📽️',
    '🎞️', '🎆', '🎇', '✨', '🌟', '⭐', '🌠', '💫', '🎂', '🍰',
    '🧁', '🍭', '🍬', '🍫', '🍷', '🥂', '🍾', '🎺', '🥁', '🎸',
    '🎵', '🎶', '🎤', '🎧', '🎙️', '🪔', '🕯️', '🔦', '💡', '🌅',
    '🌄', '🌃', '🏙️', '🌆', '🌇', '🌉', '🎠', '🎡', '🎢', '🎪',
  ],
  'Transporte & Lugares': [
    '✈️', '🚀', '🛸', '🚁', '🛩️', '⛵', '🚢', '🛳️', '🚂', '🚃',
    '🚄', '🚅', '🚆', '🚇', '🚈', '🚉', '🚊', '🚝', '🚞', '🚋',
    '🚌', '🚍', '🚎', '🚐', '🚑', '🚒', '🚓', '🚔', '🚕', '🚖',
    '🏠', '🏡', '🏢', '🏣', '🏤', '🏥', '🏦', '🏧', '🏨', '🏩',
    '🏪', '🏫', '🏬', '🏭', '🏯', '🏰', '⛪', '💒', '🕌', '🛕',
    '🗼', '🗽', '🗺️', '🌍', '🌎', '🌏', '🌐', '🏔️', '⛰️', '🌋',
  ],
  'Comida & Bebida': [
    '🍕', '🍔', '🌮', '🌯', '🥙', '🥪', '🥨', '🧀', '🥚', '🍳',
    '🥞', '🧇', '🥓', '🥩', '🍗', '🍖', '🌭', '🍟', '🍝', '🍜',
    '🍲', '🍛', '🍣', '🍱', '🥟', '🦪', '🍤', '🍙', '🍚', '🍘',
    '🍥', '🥮', '🍡', '🧁', '🍰', '🎂', '🍮', '🍭', '🍬', '🍫',
    '🍿', '🍩', '🍪', '🌰', '🥜', '🍯', '🧃', '🥤', '☕', '🍵',
    '🧋', '🍺', '🍻', '🥂', '🍷', '🍸', '🍹', '🍾', '🧊', '💧',
  ],
  'Esportes & Atividades': [
    '⚽', '🏀', '🏈', '⚾', '🥎', '🏐', '🏉', '🎾', '🏸', '🏒',
    '🥅', '⛳', '🏹', '🎣', '🤿', '🥊', '🥋', '🎽', '🛹', '🛼',
    '🛷', '⛸️', '🥌', '🎿', '⛷️', '🏂', '🪂', '🏋️', '🤼', '🤸',
    '⛹️', '🤺', '🤾', '🏌️', '🏇', '🧘', '🏄', '🏊', '🤽', '🚣',
    '🧗', '🚵', '🚴', '🏆', '🥇', '🥈', '🥉', '🏅', '🎖️', '🎗️',
    '🎯', '🎱', '🎳', '🏏', '🏑', '🏓', '🏸', '🥏', '🪁', '🎮',
  ],
  'Outros': [
    '🌐', '📍', '🔮', '🧿', '🪬', '🧲', '⚗️', '🔭', '🔬', '🧬',
    '🧪', '🧫', '🧯', '🪣', '🧴', '🧷', '🧹', '🧺', '🧻', '🪣',
    '🧼', '🫧', '🪥', '🧽', '🪤', '🪜', '🧰', '🪛', '🔑', '🗝️',
    '🔐', '🔒', '🔓', '🔨', '⛏️', '⚒️', '🛠️', '🗡️', '⚔️', '🛡️',
    '🪃', '🪖', '🦺', '📦', '🎒', '🧳', '👜', '👝', '🌂', '☂️',
    '🪆', '🪅', '🎭', '🖼️', '🎨', '🧵', '🪡', '🧶', '👓', '🕶️',
    '🥽', '🦯', '🌡️', '🧭', '🕰️', '⌛', '⏳', '📡', '🔋', '🔌',
    '💡', '🔦', '🕯️', '🪔', '🧱', '🪞', '🪟', '🛋️', '🪑', '🚪',
    '🗑️', '🛒', '🎀', '🎁', '🎊', '🎉', '🎈', '🎏', '🎐', '🎑',
    '🧧', '🎋', '🎍', '🎎', '🎃', '🎄', '🎆', '🎇', '🧨', '✨',
  ],
};

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
      length: _emojiCategories.length,
      vsync: this,
    );
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
                  child: _EmojiPreview(
                    emoji: _selectedEmoji,
                    name: _nameController.text.isEmpty
                        ? 'Nome do grupo'
                        : _nameController.text,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Nome ─────────────────────────────────────────────────
                _SectionLabel('Nome do grupo'),
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
                _SectionLabel('Emoji'),
                const SizedBox(height: 8),
                _EmojiPicker(
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

// ---------------------------------------------------------------------------
// Emoji Preview
// ---------------------------------------------------------------------------

class _EmojiPreview extends StatelessWidget {
  const _EmojiPreview({required this.emoji, required this.name});

  final String emoji;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 36)),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: const Color(0xFF94A3B8),
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Emoji Picker
// ---------------------------------------------------------------------------

class _EmojiPicker extends StatelessWidget {
  const _EmojiPicker({
    required this.tabController,
    required this.selected,
    required this.onSelect,
  });

  final TabController tabController;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final categories = _emojiCategories.entries.toList();
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tabs
          TabBar(
            controller: tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: primary,
            unselectedLabelColor: const Color(0xFF94A3B8),
            indicatorColor: primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            tabs: categories
                .map((e) => Tab(text: e.key))
                .toList(),
            dividerColor: const Color(0xFFE2E8F0),
          ),
          // Grid — fixed height so the modal doesn't overflow
          SizedBox(
            height: 180,
            child: TabBarView(
              controller: tabController,
              children: categories.map((entry) {
                final emojis = entry.value;
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: emojis.length,
                  itemBuilder: (_, i) {
                    final e = emojis[i];
                    final isSelected = e == selected;
                    return GestureDetector(
                      onTap: () => onSelect(e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? primary.withValues(alpha: 0.4)
                                : Colors.transparent,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: isSelected ? 22 : 20,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
