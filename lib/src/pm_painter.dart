import 'package:flutter/rendering.dart';

/**
* Text to Path Maker
* Copyright Ashraff Hathibelagal 2019
*/

/// A [CustomPainter] subclass that can be used to quickly render a character
/// and animate it.
class PMPainter extends CustomPainter {
  Path path;
  late Paint _paint;
  late double posX;
  late double posY;
  late double scaleX;
  late double scaleY;
  Offset indicatorPosition;
  Paint indicator;
  double radius;

  PMPainter(this.path,
      {required this.indicatorPosition,
      required this.radius,
      required this.indicator}) {
    init();
  }

  void init() {
    _paint = Paint();
    _paint.strokeWidth = 3;
    _paint.color = Color.fromRGBO(0, 0, 0, 1.0);
    _paint.style = PaintingStyle.stroke;
  }

  void setPaint(Paint p) {
    _paint = p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(path, _paint);    
    canvas.drawCircle(indicatorPosition, radius, indicator);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
