import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Animated Water Trickle Widget that renders flowing irrigation streams or trickling water droplets.
class WaterTrickleWidget extends StatefulWidget {
  final double height;
  final bool animate;
  final Color waterColor;
  final Widget? child;

  const WaterTrickleWidget({
    super.key,
    this.height = 24.0,
    this.animate = true,
    this.waterColor = AppColors.waterBlue,
    this.child,
  });

  @override
  State<WaterTrickleWidget> createState() => _WaterTrickleWidgetState();
}

class _WaterTrickleWidgetState extends State<WaterTrickleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(WaterTrickleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: WaterTricklePainter(
            progress: _controller.value,
            waterColor: widget.waterColor,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class WaterTricklePainter extends CustomPainter {
  final double progress;
  final Color waterColor;

  WaterTricklePainter({
    required this.progress,
    required this.waterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Water Stream Gradient Background
    final streamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          waterColor.withValues(alpha: 0.05),
          waterColor.withValues(alpha: 0.18),
          AppColors.waterBlueLight.withValues(alpha: 0.08),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, streamPaint);

    // 2. Animated Flowing Wave Line
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = waterColor.withValues(alpha: 0.6);

    final wavePath = Path();
    final waveLength = size.width / 3;
    final phaseShift = progress * 2 * math.pi * 2;

    wavePath.moveTo(0, size.height * 0.5);
    for (double x = 0; x <= size.width; x += 5) {
      final y = size.height * 0.5 + math.sin((x / waveLength) * 2 * math.pi + phaseShift) * (size.height * 0.25);
      wavePath.lineTo(x, y);
    }
    canvas.drawPath(wavePath, wavePaint);

    // 3. Trickling Water Droplets
    final dropPaint = Paint()..style = PaintingStyle.fill;

    const dropletCount = 6;
    for (int i = 0; i < dropletCount; i++) {
      final dropProgress = (progress + (i / dropletCount)) % 1.0;
      final dx = (i + 0.5) * (size.width / dropletCount) + math.sin(dropProgress * math.pi * 2) * 8;
      final dy = dropProgress * size.height;

      dropPaint.color = AppColors.waterBlueLight.withValues(alpha: (1.0 - dropProgress) * 0.8);
      canvas.drawCircle(Offset(dx, dy), 2.2, dropPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WaterTricklePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.waterColor != waterColor;
  }
}
