import 'package:flutter/material.dart';

/// A custom-painted fiery streak icon with red/orange flame gradients.
/// Use [size] to control the overall dimensions.
class StreakFireIcon extends StatelessWidget {
  final double size;

  const StreakFireIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(size: Size(size, size), painter: _FirePainter()),
    );
  }
}

class _FirePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // -- Outer flame (red → deep orange gradient) --
    final outerPath = Path()
      ..moveTo(w * 0.50, h * 0.02)
      ..cubicTo(w * 0.42, h * 0.18, w * 0.15, h * 0.28, w * 0.14, h * 0.52)
      ..cubicTo(w * 0.13, h * 0.72, w * 0.26, h * 0.92, w * 0.50, h * 0.98)
      ..cubicTo(w * 0.74, h * 0.92, w * 0.87, h * 0.72, w * 0.86, h * 0.52)
      ..cubicTo(w * 0.85, h * 0.28, w * 0.58, h * 0.18, w * 0.50, h * 0.02)
      ..close();

    final outerGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFF1744), // Vivid red
        const Color(0xFFFF5722), // Deep orange
        const Color(0xFFFF9100), // Orange
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    canvas.drawPath(
      outerPath,
      Paint()
        ..shader = outerGradient.createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.fill,
    );

    // -- Middle flame (orange → amber) --
    final midPath = Path()
      ..moveTo(w * 0.50, h * 0.22)
      ..cubicTo(w * 0.44, h * 0.34, w * 0.26, h * 0.42, w * 0.26, h * 0.58)
      ..cubicTo(w * 0.26, h * 0.76, w * 0.36, h * 0.88, w * 0.50, h * 0.92)
      ..cubicTo(w * 0.64, h * 0.88, w * 0.74, h * 0.76, w * 0.74, h * 0.58)
      ..cubicTo(w * 0.74, h * 0.42, w * 0.56, h * 0.34, w * 0.50, h * 0.22)
      ..close();

    final midGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFF6D00), // Orange accent
        const Color(0xFFFFAB00), // Amber
      ],
    );

    canvas.drawPath(
      midPath,
      Paint()
        ..shader = midGradient.createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.fill,
    );

    // -- Inner flame (yellow-orange → bright yellow) --
    final innerPath = Path()
      ..moveTo(w * 0.50, h * 0.42)
      ..cubicTo(w * 0.46, h * 0.50, w * 0.36, h * 0.56, w * 0.36, h * 0.66)
      ..cubicTo(w * 0.36, h * 0.78, w * 0.42, h * 0.86, w * 0.50, h * 0.88)
      ..cubicTo(w * 0.58, h * 0.86, w * 0.64, h * 0.78, w * 0.64, h * 0.66)
      ..cubicTo(w * 0.64, h * 0.56, w * 0.54, h * 0.50, w * 0.50, h * 0.42)
      ..close();

    final innerGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFFAB00), // Amber
        const Color(0xFFFFD600), // Bright yellow
      ],
    );

    canvas.drawPath(
      innerPath,
      Paint()
        ..shader = innerGradient.createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
