import 'package:flutter/material.dart';

class HomeSection extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const HomeSection({
    super.key,
    required this.title,
    this.trailing,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ?trailing,
            ],
          ),

          ...children,
        ],
      ),
    );
  }
}
