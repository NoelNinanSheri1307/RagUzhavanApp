import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A custom painter that draws organic soil specks, fine earth grain, and warm loam gradient depth.
class SoilTexturePainter extends CustomPainter {
  final Color soilColor;
  final Color speckColor;
  final Color accentGrainColor;

  SoilTexturePainter({
    this.soilColor = AppColors.background,
    this.speckColor = AppColors.surfaceElevated,
    this.accentGrainColor = AppColors.earthLight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Warm Soil Gradient Base
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          soilColor,
          AppColors.surface,
          soilColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, gradientPaint);

    // 2. Organic Soil Grain Specks
    final random = math.Random(42); // Fixed seed for reproducible organic pattern
    final speckPaint = Paint()..style = PaintingStyle.fill;

    const speckCount = 180;
    for (int i = 0; i < speckCount; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = 0.6 + random.nextDouble() * 1.8;
      final alpha = 0.08 + random.nextDouble() * 0.22;

      final isAccent = i % 7 == 0;
      speckPaint.color = (isAccent ? accentGrainColor : speckColor).withValues(alpha: alpha);

      canvas.drawCircle(Offset(dx, dy), radius, speckPaint);
    }

    // 3. Subtle Earth Stratum Rulings / Fine Soil Waves
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = AppColors.border.withValues(alpha: 0.15);

    final path = Path();
    for (double y = 40; y < size.height; y += 70) {
      path.reset();
      path.moveTo(0, y);
      path.quadraticBezierTo(
        size.width * 0.5,
        y + (random.nextDouble() - 0.5) * 12,
        size.width,
        y,
      );
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SoilTexturePainter oldDelegate) => false;
}

/// A wrapper widget that provides a warm soil-like texture background for screens or containers.
class SoilTextureBackground extends StatelessWidget {
  final Widget child;
  final Color? soilColor;

  const SoilTextureBackground({
    super.key,
    required this.child,
    this.soilColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SoilTexturePainter(
        soilColor: soilColor ?? AppColors.background,
      ),
      child: child,
    );
  }
}
