import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/brand.dart';

class HabitFlowLogo extends StatelessWidget {
  final double size;
  final bool whiteOnBrand;
  final bool tile;

  const HabitFlowLogo({
    super.key,
    this.size = 88,
    this.whiteOnBrand = false,
    this.tile = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = whiteOnBrand ? Colors.white : Brand.accentFor(context);

    final mark = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(color: fg, strokeWidth: size * 0.07),
          ),
          Icon(Icons.check_rounded, color: fg, size: size * 0.42),
          Positioned(
            top: size * 0.02,
            child: Icon(
              Icons.local_fire_department_rounded,
              color: fg,
              size: size * 0.34,
            ),
          ),
        ],
      ),
    );

    if (!tile) return mark;

    return Container(
      padding: EdgeInsets.all(size * 0.22),
      decoration: BoxDecoration(
        color: Brand.accent,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: HabitFlowLogo(size: size * 0.55, whiteOnBrand: true),
    );
  }
}

class HabitFlowLogoTile extends StatelessWidget {
  final double size;

  const HabitFlowLogoTile({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) => HabitFlowLogo(size: size, tile: true);
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _RingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(
      strokeWidth,
      strokeWidth * 1.4,
      size.width - strokeWidth * 2,
      size.height - strokeWidth * 2,
    );
    canvas.drawArc(rect, math.pi * 0.72, math.pi * 1.56, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.color != color;
}
