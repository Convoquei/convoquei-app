import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';

const double _kGradientHeight = 260;
const double _kCardPadding = 40;

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isWide = AppBreakpoints.isWide(context);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          Container(
            height: _kGradientHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.primary.withValues(alpha: 0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 0 : DSSpacing.xl,
                  vertical: DSSpacing.huge,
                ),
                child: isWide
                    ? SizedBox(
                        width: 420,
                        child: DSCard(
                          padding: const EdgeInsets.all(_kCardPadding),
                          hasBorder: false,
                          hasElevation: true,
                          child: child,
                        ),
                      )
                    : child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
