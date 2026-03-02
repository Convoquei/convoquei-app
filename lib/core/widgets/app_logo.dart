import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// AppLogo – Variants
// ---------------------------------------------------------------------------
//
// • AppLogo.icon        – Square icon (blue background + white arcs).
//                         Always the same colours (brand consistency in stores).
// • AppLogo.signature   – Horizontal lockup (icon mark + "convoquei" text).
//                         Icon and text colours adapt to the ambient Brightness.
// ---------------------------------------------------------------------------

class AppLogo extends StatelessWidget {
  /// Size of the square icon, or height of the horizontal signature.
  final double size;

  final _AppLogoVariant _variant;

  // ── Private constructors ─────────────────────────────────────────────────

  const AppLogo._icon({this.size = 64}) : _variant = _AppLogoVariant.icon;

  const AppLogo._signature({this.size = 40})
      : _variant = _AppLogoVariant.signature;

  // ── Named constructors (public API) ──────────────────────────────────────

  /// Square app icon: blue background, white arcs. Always the same colours.
  const factory AppLogo.icon({double size}) = AppLogo._icon;

  /// Horizontal signature: icon mark + "convoquei" text.
  /// Arc/text colours adapt to the ambient [Brightness].
  const factory AppLogo.signature({double size}) = AppLogo._signature;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return switch (_variant) {
      _AppLogoVariant.icon => _buildIcon(),
      _AppLogoVariant.signature => _buildSignature(context),
    };
  }

  // ── Icon variant ──────────────────────────────────────────────────────────

  Widget _buildIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: SvgPicture.asset(
        'assets/svg/logo_icon.svg',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  // ── Signature variant ────────────────────────────────────────────────────

  Widget _buildSignature(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final markAsset = isDark
        ? 'assets/svg/logo_mark_dark.svg'
        : 'assets/svg/logo_mark_light.svg';

    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    // Keep the mark proportional: same height as the requested `size`.
    final markSize = size;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          markAsset,
          width: markSize,
          height: markSize,
          fit: BoxFit.contain,
        ),
        SizedBox(width: markSize * 0.28),
        Text(
          'convoquei',
          style: GoogleFonts.poppins(
            fontSize: markSize * 0.72,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Internal enum
// ---------------------------------------------------------------------------

enum _AppLogoVariant { icon, signature }

