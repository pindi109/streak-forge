
import 'package:flutter/material.dart';

class ColorPickerRow extends StatelessWidget {
  final String selectedColor;
  final ValueChanged<String> onColorSelected;

  static const List<String> colors = [
    '#7C3AED',
    '#3B82F6',
    '#22C55E',
    '#F97316',
    '#EF4444',
    '#EC4899',
    '#FBBF24',
    '#14B8A6',
    '#8B5CF6',
    '#06B6D4',
  ];

  const ColorPickerRow({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = selectedColor == color;
          final parsedColor =
              Color(int.parse(color.replaceFirst('#', '0xFF')));

          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: parsedColor,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2.5)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: parsedColor.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          );
        },
      ),
    );
  }
}