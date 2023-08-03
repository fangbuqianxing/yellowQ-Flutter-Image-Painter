import 'dart:ui';

import 'package:flutter/material.dart' hide Image;

import '_controller.dart';

///Handles all the painting ongoing on the canvas.
class DrawImage extends CustomPainter {
  ///Converted image from [ImagePainter] constructor.
  final Image? image;

  ///Flag for triggering signature mode.
  final bool isSignature;

  ///The background for signature painting.
  final Color? backgroundColor;

  //Controller is a listenable with all of the paint details.
  late Controller _controller;

  ///Constructor for the canvas
  DrawImage({
    required Controller controller,
    this.image,
    this.isSignature = false,
    this.backgroundColor,
  }) : super(repaint: controller) {
    _controller = controller;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (isSignature) {
      ///Paints background for signature.
      canvas.drawRect(
          Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
          Paint()
            ..style = PaintingStyle.fill
            ..color = backgroundColor!);
    } else {
      ///paints [ui.Image] on the canvas for reference to draw over it.
      paintImage(
        canvas: canvas,
        image: image!,
        filterQuality: FilterQuality.high,
        rect: Rect.fromPoints(
          const Offset(0, 0),
          Offset(size.width, size.height),
        ),
      );
    }

    ///paints all the previoud paintInfo history recorded on [PaintHistory]
    for (var item in _controller.paintHistory) {
      final _offset = item.offset;
      final _painter = item.paint;
      switch (item.mode) {
        case PaintMode.rect:
          canvas.drawRect(
              Rect.fromPoints(_offset![0]!, _offset[1]!), _painter!);
          break;
        case PaintMode.line:
          canvas.drawLine(_offset![0]!, _offset[1]!, _painter!);
          break;
        case PaintMode.circle:
          final path = Path();
          path.addOval(
            Rect.fromCircle(
                center: _offset![1]!,
                radius: (_offset[0]! - _offset[1]!).distance),
          );
          canvas.drawPath(path, _painter!);
          break;
        case PaintMode.arrow:
          drawArrow(canvas, _offset![0]!, _offset[1]!, _painter!);
          break;
        case PaintMode.dashLine:
          final path = Path()
            ..moveTo(_offset![0]!.dx, _offset[0]!.dy)
            ..lineTo(_offset[1]!.dx, _offset[1]!.dy);
          canvas.drawPath(_dashPath(path, _painter!.strokeWidth), _painter);
          break;
        case PaintMode.freeStyle:
          for (var i = 0; i < _offset!.length - 1; i++) {
            if (_offset[i] != null && _offset[i + 1] != null) {
              final _path = Path()
                ..moveTo(_offset[i]!.dx, _offset[i]!.dy)
                ..lineTo(_offset[i + 1]!.dx, _offset[i + 1]!.dy);
              canvas.drawPath(_path, _painter!..strokeCap = StrokeCap.round);
            } else if (_offset[i] != null && _offset[i + 1] == null) {
              canvas.drawPoints(PointMode.points, [_offset[i]!],
                  _painter!..strokeCap = StrokeCap.round);
            }
          }
          break;
        case PaintMode.text:
          item.textPainter.paint(canvas, item.textOffset());
          break;
        case PaintMode.mosaic:
          for (var i = 0; i < _offset!.length; i++) {
            if (_offset[i] != null) {
              paintMosaic(canvas, _offset[i]!, _painter!.strokeWidth);
            }
          }
          break;
        default:
      }
    }

    ///Draws ongoing action on the canvas while indrag.
    if (_controller.busy) {
      final _start = _controller.start;
      final _end = _controller.end;
      final _paint = _controller.brush;
      switch (_controller.mode) {
        case PaintMode.rect:
          canvas.drawRect(Rect.fromPoints(_start!, _end!), _paint);
          break;
        case PaintMode.line:
          canvas.drawLine(_start!, _end!, _paint);
          break;
        case PaintMode.circle:
          final path = Path();
          path.addOval(Rect.fromCircle(
              center: _end!, radius: (_end - _start!).distance));
          canvas.drawPath(path, _paint);
          break;
        case PaintMode.arrow:
          drawArrow(canvas, _start!, _end!, _paint);
          break;
        case PaintMode.dashLine:
          final path = Path()
            ..moveTo(_start!.dx, _start.dy)
            ..lineTo(_end!.dx, _end.dy);
          canvas.drawPath(_dashPath(path, _paint.strokeWidth), _paint);
          break;
        case PaintMode.freeStyle:
          final points = _controller.offsets;
          for (var i = 0; i < _controller.offsets.length - 1; i++) {
            if (points[i] != null && points[i + 1] != null) {
              canvas.drawLine(
                  Offset(points[i]!.dx, points[i]!.dy),
                  Offset(points[i + 1]!.dx, points[i + 1]!.dy),
                  _paint..strokeCap = StrokeCap.round);
            } else if (points[i] != null && points[i + 1] == null) {
              canvas.drawPoints(PointMode.points,
                  [Offset(points[i]!.dx, points[i]!.dy)], _paint);
            }
          }
          break;
        case PaintMode.mosaic:
          for (var i = 0; i < _controller.offsets.length; i++) {
            if (_controller.offsets[i]!= null) {
              paintMosaic(canvas, _controller.offsets[i]!, _paint.strokeWidth);
            }
          }
          break;
        default:
      }
    }

    ///Draws all the completed actions of painting on the canvas.
  }

  ///Draws line as well as the arrowhead on top of it.
  ///Uses [strokeWidth] of the painter for sizing.
  void drawArrow(Canvas canvas, Offset start, Offset end, Paint painter) {
    final arrowPainter = Paint()
      ..color = painter.color
      ..strokeWidth = painter.strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, painter);
    final _pathOffset = painter.strokeWidth / 15;
    var path = Path()
      ..lineTo(-15 * _pathOffset, 10 * _pathOffset)
      ..lineTo(-15 * _pathOffset, -10 * _pathOffset)
      ..close();
    canvas.save();
    canvas.translate(end.dx, end.dy);
    canvas.rotate((end - start).direction);
    canvas.drawPath(path, arrowPainter);
    canvas.restore();
  }

  ///Draws dashed path.
  ///It depends on [strokeWidth] for space to line proportion.
  Path _dashPath(Path path, double width) {
    final dashPath = Path();
    final dashWidth = 10.0 * width / 5;
    final dashSpace = 10.0 * width / 5;
    var distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    return dashPath;
  }

  //for draw [DrawStyle.mosaic]
  void paintMosaic(Canvas canvas, Offset center, double mosaicWidth) {
    const black1 = Color(0xFE808080);
    const black2 = Color(0xCDA9A9A9);
    final  paint = Paint()..color = black1..blendMode = BlendMode.srcOver;
    final size = mosaicWidth;
    final halfSize = size * 0.5;
    final b1 = Rect.fromCenter(center: center.translate(-halfSize, -halfSize),width: size,height: size);
    //0,0
    canvas.drawRect(b1, paint);
    //[black87], [black54], [black45], [black38], [black26], [black12]
    paint.color = black2;
    //0,1
    canvas.drawRect(b1.translate(0, size), paint);
    paint.color = black1;
    //0,2
    canvas.drawRect(b1.translate(0, size*2), paint);
    paint.color = black2;
    //1,0
    canvas.drawRect(b1.translate(size, 0), paint);
    paint.color = black1;
    //1,1
    canvas.drawRect(b1.translate(size, size), paint);
    paint.color = black2;
    //1,2
    canvas.drawRect(b1.translate(size, size*2), paint);
    paint.color = black1;
    //2,0
    canvas.drawRect(b1.translate(size*2, 0), paint);
    paint.color = black2;
    //2,1
    canvas.drawRect(b1.translate(size*2, size), paint);
    paint.color = black1;
    //2,2
    canvas.drawRect(b1.translate(size*2, size*2), paint);
  }

  @override
  bool shouldRepaint(DrawImage oldInfo) {
    return oldInfo._controller != _controller;
  }
}

///All the paint method available for use.

enum PaintMode {
  ///Prefer using [None] while doing scaling operations.
  none,

  ///Allows for drawing freehand shapes or text.
  freeStyle,

  ///Allows to draw line between two points.
  line,

  ///Allows to draw rectangle.
  rect,

  ///Allows to write texts over an image.
  text,

  ///Allows us to draw line with arrow at the end point.
  arrow,

  ///Allows to draw circle from a point.
  circle,

  ///Allows to draw dashed line between two point.
  dashLine,

  /// Allows to draw mosaic
  mosaic,
}

///[PaintInfo] keeps track of a single unit of shape, whichever selected.
class PaintInfo {
  ///Mode of the paint method.
  PaintMode? mode;

  ///Used to save specific paint utils used for the specific shape.
  Paint? paint;

  ///Used to save offsets.
  ///Two point in case of other shapes and list of points for [FreeStyle].
  List<Offset?>? offset;

  ///Used to save text in case of text type.
  String? text;

  /// Drawing image size
  Size? maxSize;

  late TextSpan textSpan;
  late TextPainter textPainter;

  ///In case of string, it is used to save string value entered.
  PaintInfo({
    this.offset,
    this.paint,
    this.text,
    this.mode,
    this.maxSize,
  }) {
    if (mode == PaintMode.text && text != null) {
      textSpan = TextSpan(
        text: text,
        style: TextStyle(
            color: paint?.color,
            fontSize: 6 * (paint?.strokeWidth ?? 3),
            fontWeight: FontWeight.bold),
      );
      textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: (maxSize?.width ?? 100));
      maxSize ??= Size.zero;
    }
  }

  Offset textOffset() {
    return (offset?.isEmpty ?? true)
        ? Offset(maxSize!.width / 2, maxSize!.height / 2)
        : Offset(offset![0]!.dx, offset![0]!.dy);
  }

  Rect textRect() => Rect.fromCenter(
        center: textOffset(),
        width: textPainter.width,
        height: textPainter.height);
}

@immutable

///Records realtime updates of ongoing [PaintInfo] when inDrag.
class UpdatePoints {
  ///Records the first tap offset,
  final Offset? start;

  ///Records all the offset after first one.
  final Offset? end;

  ///Records [Paint] method of the ongoing painting.
  final Paint? paint;

  ///Records [PaintMode] of the ongoing painting.
  final PaintMode? mode;

  ///Constructor for ongoing painthistory.
  UpdatePoints({this.start, this.end, this.paint, this.mode});

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is UpdatePoints &&
        o.start == start &&
        o.end == end &&
        o.paint == paint &&
        o.mode == mode;
  }

  @override
  int get hashCode {
    return start.hashCode ^ end.hashCode ^ paint.hashCode ^ mode.hashCode;
  }
}
