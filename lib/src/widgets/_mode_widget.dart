import 'package:flutter/material.dart';

import '../../image_painter.dart';

// class SelectionItems extends StatelessWidget {
//   final bool? isSelected;
//   final ModeData? data;
//   final VoidCallback? onTap;
//
//   const SelectionItems({Key? key, this.isSelected, this.data, this.onTap})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 2.0),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4.0),
//           color: isSelected! ? Colors.blue : Colors.transparent),
//       child: ListTile(
//         leading: IconTheme(
//           data: const IconThemeData(opacity: 1.0),
//           child: Icon(data!.icon,
//               color: isSelected! ? Colors.white : Colors.black),
//         ),
//         title: Text(
//           data!.label!,
//           style: Theme.of(context).textTheme.subtitle1!.copyWith(
//               color: isSelected!
//                   ? Colors.white
//                   : Theme.of(context).textTheme.bodyText1!.color),
//         ),
//         onTap: onTap,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
//         selected: isSelected!,
//       ),
//     );
//   }
// }

// List<ModeData> paintModes(TextDelegate textDelegate) => [
//       ModeData(
//           icon: Icons.zoom_out_map,
//           mode: PaintMode.none,
//           label: textDelegate.noneZoom),
//       ModeData(
//           icon: Icons.horizontal_rule,
//           mode: PaintMode.line,
//           label: textDelegate.line),
//       ModeData(
//           icon: Icons.rectangle_outlined,
//           mode: PaintMode.rect,
//           label: textDelegate.rectangle),
//       ModeData(
//           icon: Icons.edit,
//           mode: PaintMode.freeStyle,
//           label: textDelegate.drawing),
//       ModeData(
//           icon: Icons.lens_outlined,
//           mode: PaintMode.circle,
//           label: textDelegate.circle),
//       ModeData(
//           icon: Icons.arrow_right_alt_outlined,
//           mode: PaintMode.arrow,
//           label: textDelegate.arrow),
//       ModeData(
//           icon: Icons.power_input,
//           mode: PaintMode.dashLine,
//           label: textDelegate.dashLine),
//       ModeData(
//           icon: Icons.text_format,
//           mode: PaintMode.text,
//           label: textDelegate.text),
//     ];

List<ModeData> paintModes2(TextDelegate textDelegate) => [
  ModeData(
      icon: AssetImage(textDelegate.rectangleAssetName),
      mode: PaintMode.rect,
      label: textDelegate.rectangle),
  ModeData(
      icon: AssetImage(textDelegate.circleAssetName),
      mode: PaintMode.circle,
      label: textDelegate.circle),
  ModeData(
      icon: AssetImage(textDelegate.arrowAssetName),
      mode: PaintMode.arrow,
      label: textDelegate.arrow),
  ModeData(
      icon: AssetImage(textDelegate.lineAssetName),
      mode: PaintMode.line,
      label: textDelegate.line),
  ModeData(
      icon: AssetImage(textDelegate.drawingAssetName),
      mode: PaintMode.freeStyle,
      label: textDelegate.drawing),
  ModeData(
      icon: AssetImage(textDelegate.textAssetName),
      mode: PaintMode.text,
      label: textDelegate.text),
  ModeData(
      icon: AssetImage(textDelegate.mosaicAssetName),
      mode: PaintMode.mosaic,
      label: textDelegate.mosaicName),
];

@immutable
class ModeData {
  final ImageProvider icon;
  final PaintMode? mode;
  final String? label;
  const ModeData({
    required this.icon,
    this.mode,
    this.label,
  });
}
