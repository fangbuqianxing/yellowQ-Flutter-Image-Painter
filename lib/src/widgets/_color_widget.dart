import 'package:flutter/material.dart';

class ColorItem extends StatelessWidget {
  const ColorItem({Key? key, this.onTap, this.isSelected, required this.color})
      : super(key: key);
  final VoidCallback? onTap;
  final bool? isSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSelected! ? 30 : 30,
        height: isSelected! ? 30 : 30,
        decoration: BoxDecoration(
          color: isSelected! ? Colors.white70 : Colors.transparent,
          border: Border.all(
              color: isSelected! ? Colors.black : Colors.grey[200]!),
        ),
        child: ColoredBox(color: color),
      ),
    );
  }
}

const List<Color> editorColors = [
  Colors.red,
  Colors.pink,
  Colors.greenAccent,
  Colors.green,
  Colors.teal,
  Colors.cyan,
  Colors.blue,
  Colors.blueAccent,
  Colors.yellow,
  Colors.orange,
  Colors.brown,
  Colors.grey,
  Colors.black,
  Colors.white,
];
