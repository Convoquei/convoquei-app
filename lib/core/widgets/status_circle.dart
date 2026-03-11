import 'package:flutter/material.dart';

/// Círculo colorido com um ícone centralizado, usado para indicar status.
class StatusCircle extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;

  const StatusCircle({
    super.key,
    required this.bgColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: Icon(icon, size: 14, color: iconColor),
    );
  }
}
