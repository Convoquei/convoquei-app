import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'auth_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Convoquei',
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}