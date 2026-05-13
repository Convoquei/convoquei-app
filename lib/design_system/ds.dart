// Barrel do Design System — único ponto de import para features.
//
// Use:
//   import 'package:convoquei_app/design_system/ds.dart';
//
// Nunca importe de subpastas (tokens/, theme/, foundations/, components/) diretamente.

// ── Tokens (sem DSColorsPrimitive e DSTypography — primitivos não vazam) ──────
export 'tokens/ds_spacing.dart';
export 'tokens/ds_radius.dart';
export 'tokens/ds_elevation.dart';
export 'tokens/ds_motion.dart';

// ── Theme ─────────────────────────────────────────────────────────────────────
export 'theme/ds_colors.dart';
export 'theme/ds_text_styles.dart';
export 'theme/ds_theme.dart';
export 'theme/ds_context_extensions.dart';

// ── Foundations ───────────────────────────────────────────────────────────────
export 'foundations/ds_spinner.dart';
export 'foundations/ds_skeleton.dart';
export 'foundations/ds_avatar.dart';
export 'foundations/ds_badge.dart';
export 'foundations/ds_divider.dart';
export 'foundations/ds_icon.dart';
export 'foundations/ds_text.dart';

// ── Components: buttons ───────────────────────────────────────────────────────
export 'components/buttons/ds_button.dart';
export 'components/buttons/ds_icon_button.dart';

// ── Components: inputs ────────────────────────────────────────────────────────
export 'components/inputs/ds_search_input.dart';

// ── Components: feedback ──────────────────────────────────────────────────────
export 'components/feedback/ds_alert_banner.dart';
export 'components/feedback/ds_info_banner.dart';
export 'components/feedback/ds_error_retry_state.dart';
export 'components/feedback/ds_loading_screen.dart';

// ── Components: cards ─────────────────────────────────────────────────────────
export 'components/cards/ds_card.dart';
export 'components/cards/ds_action_card.dart';

// ── Components: lists ─────────────────────────────────────────────────────────
export 'components/lists/ds_selectable_tile.dart';
export 'components/lists/ds_timeline_group.dart';

// ── Components: overlays ──────────────────────────────────────────────────────
export 'components/overlays/ds_modal.dart';
export 'components/overlays/ds_modal_header.dart';
export 'components/overlays/ds_multi_select_modal.dart';
