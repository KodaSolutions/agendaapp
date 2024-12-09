import 'package:flutter/material.dart';

class DiagonalCellPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  DiagonalCellPainter({required this.color1, required this.color2});


  @override
  void paint(Canvas canvas, Size size) {
    Paint paint1 = Paint()..color = color1;
    Paint paint2 = Paint()..color = color2;

    Path path1 = Path();
    path1.lineTo(size.width, 0);
    path1.lineTo(0, size.height);
    path1.close();

    Path path2 = Path();
    path2.moveTo(size.width, 0);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class HorizontalCellPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  HorizontalCellPainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint1 = Paint()..color = color1;
    Paint paint2 = Paint()..color = color2;

    Path path1 = Path();
    path1.lineTo(size.width, 0);
    path1.lineTo(size.width, size.height / 2);
    path1.lineTo(0, size.height / 2);
    path1.close();

    Path path2 = Path();
    path2.moveTo(0, size.height / 2);
    path2.lineTo(size.width, size.height / 2);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class VerticalCirclePainter extends CustomPainter {
  final Color color1;
  final Color color2;

  VerticalCirclePainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    Paint paint1 = Paint()..color = color1;
    Paint paint2 = Paint()..color = color2;

    // Dibujar el semicírculo izquierdo
    canvas.drawArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius),
      -3.14 / 2,
      3.14,
      true,
      paint1,
    );

    // Dibujar el semicírculo derecho
    canvas.drawArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius),
      3.14 / 2,
      3.14,
      true,
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
