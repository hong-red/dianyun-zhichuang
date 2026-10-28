import 'package:flutter/material.dart';

class AffinityBar extends StatelessWidget {
  final int affinity;
  final bool showLabel;
  final double height;

  const AffinityBar({
    super.key,
    required this.affinity,
    this.showLabel = true,
    this.height = 8,
  });

  String get _level {
    if (affinity >= 80) return '挚友';
    if (affinity >= 60) return '友好';
    if (affinity >= 30) return '中立';
    return '冷淡';
  }

  Color get _color {
    if (affinity >= 80) return const Color(0xFFFF7043);
    if (affinity >= 60) return const Color(0xFFFFA726);
    if (affinity >= 30) return const Color(0xFF66BB6A);
    return const Color(0xFF90A4AE);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '好感度',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '$affinity / 100 · $_level',
                style: TextStyle(fontSize: 12, color: _color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        if (showLabel) const SizedBox(height: 4),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            widthFactor: affinity / 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_color.withOpacity(0.8), _color],
                ),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
