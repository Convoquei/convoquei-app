import 'package:flutter/material.dart';

class Routes {
  static const initial = '/';
  static const home = '/home';

  static final map = <String, WidgetBuilder>{
    initial: (_) => const Scaffold(
      body: Center(child: Text('Splash')),
    ),
    home: (_) => const Scaffold(
      body: Center(child: Text('Home')),
    ),
  };
}