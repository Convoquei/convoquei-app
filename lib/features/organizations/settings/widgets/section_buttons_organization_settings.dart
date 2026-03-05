import 'package:flutter/material.dart';

class SectionButtonsOrganizationSettings extends StatelessWidget {
  const SectionButtonsOrganizationSettings({
    super.key,
    required this.title,
    required this.widgets,
    this.visible
  });

  final String title;
  final List<Widget> widgets;
  final bool? visible;

  @override
  Widget build(BuildContext context) {
    if (visible != null && !visible!) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              letterSpacing: 0.4,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: _buildDividedList(widgets),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDividedList(List<Widget> items) {
    if (items.isEmpty) return [];

    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFF1F5F9),
          indent: 0,
          endIndent: 0,
        ));
      }
    }
    return result;
  }
}