// Famílias tipográficas e escala base.
// Cor e height são aplicados em DSTextStyles (theme/).
abstract final class DSTypography {
  static const String displayFamily = 'Poppins'; // títulos, display, AppBar
  static const String bodyFamily    = 'Inter';   // corpo, labels, UI

  // Scale — tamanhos em dp
  static const double sizeDisplay  = 32;
  static const double sizeHeading  = 24;
  static const double sizeTitleLg  = 20;
  static const double sizeTitleMd  = 16;
  static const double sizeTitleSm  = 14;
  static const double sizeLabelLg  = 14;
  static const double sizeLabelMd  = 13;
  static const double sizeLabelSm  = 11;
  static const double sizeBodyLg   = 14;
  static const double sizeBodyMd   = 14;
  static const double sizeBodySm   = 12;
}
