import 'package:flutter/material.dart';
import 'dart:math' as Math;

class BadgeCheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.fill;

    // Drawing the octagon shape
    final path = Path();
    double angle = (2 * 3.14159265) / 8;
    double radius = size.width / 2;

    for (int i = 0; i < 8; i++) {
      double x = size.width / 2 + radius * Math.cos(angle * i);
      double y = size.height / 2 + radius * Math.sin(angle * i);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Drawing the check mark
    final checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final checkPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.55)
      ..lineTo(size.width * 0.45, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.4);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ArrowCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.fill;

    // Drawing the circular shape
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // Drawing the arrow
    final arrowPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final arrowPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.7, size.height * 0.5)
      ..moveTo(size.width * 0.5, size.height * 0.3)
      ..lineTo(size.width * 0.7, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.7);

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


