import 'package:flutter/widgets.dart';

class AppBreakpoints {
  AppBreakpoints._();

  static const double wide = 600;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wide;
}

