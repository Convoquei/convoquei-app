import 'package:flutter/material.dart';

class AlertBanner extends StatelessWidget {
  const AlertBanner({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final IconData icon;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: color.withValues(alpha: 0.85),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}