import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Easter Egg 1: Interactive Wiggling Sprout & Honeybee Companion
class WigglingCropCompanion extends StatefulWidget {
  const WigglingCropCompanion({super.key});

  @override
  State<WigglingCropCompanion> createState() => _WigglingCropCompanionState();
}

class _WigglingCropCompanionState extends State<WigglingCropCompanion> with SingleTickerProviderStateMixin {
  late AnimationController _wiggleController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.18), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.18, end: 0.18), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.18, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _wiggleController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
  }

  void _onTapCompanion() {
    _wiggleController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapCompanion,
      child: Tooltip(
        message: 'Tap the Farmer Sprout Companion for Agricultural Wisdom!',
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.straw, width: 1.2),
                ),
                child: const Icon(
                  Icons.grass,
                  color: AppColors.straw,
                  size: 20,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Easter Egg 2: Secret Soil pH & Earth Moisture Diagnostic Telemetry Dialog
class SoilHealthDiagnosticDialog extends StatelessWidget {
  const SoilHealthDiagnosticDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SoilHealthDiagnosticDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.straw, width: 1.5),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.eco, color: AppColors.leaf, size: 24),
                SizedBox(width: 10),
                Text(
                  'SECRET SOIL & EARTH DIAGNOSTIC',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFootlight,
                    fontSize: 18.0,
                    color: AppColors.paper,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.border, height: 24),

            _buildMetricRow('Soil pH Balance', '6.8 (Optimal Cauvery Clay)', AppColors.leaf, Icons.science_outlined),
            const SizedBox(height: 10),
            _buildMetricRow('Moisture Saturation', '78% · Trickling Flow Normal', AppColors.waterBlueLight, Icons.water_drop_outlined),
            const SizedBox(height: 10),
            _buildMetricRow('Organic Soil Carbon', '0.72% (Rich Loam Horizon)', AppColors.earthLight, Icons.terrain_outlined),
            const SizedBox(height: 10),
            _buildMetricRow('Earth Temperature', '28.4°C · Root Friendly', AppColors.accentOrange, Icons.thermostat_outlined),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.leaf, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Agro-Telemetry Verdict: High microbial soil health! Paddy irrigation schedule active.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.foregroundMuted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.straw,
                  foregroundColor: AppColors.background,
                ),
                child: const Text('CLOSE DIAGNOSTIC'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11.0, color: AppColors.foregroundSubtle)),
              Text(value, style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Easter Egg 3: Monsoon Rain & Trickling Water Screen Overlay
class MonsoonOverlay extends StatefulWidget {
  final Widget child;
  final bool isMonsoonActive;
  final VoidCallback onCloseMonsoon;

  const MonsoonOverlay({
    super.key,
    required this.child,
    required this.isMonsoonActive,
    required this.onCloseMonsoon,
  });

  @override
  State<MonsoonOverlay> createState() => _MonsoonOverlayState();
}

class _MonsoonOverlayState extends State<MonsoonOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _rainController;

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isMonsoonActive)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: Stack(
                children: [
                  // Rain particles animation
                  AnimatedBuilder(
                    animation: _rainController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: MonsoonRainPainter(progress: _rainController.value),
                      );
                    },
                  ),
                  // Banner notification
                  Positioned(
                    top: 60,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        border: Border.all(color: AppColors.waterBlueLight, width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.water_drop, color: AppColors.waterBlueLight, size: 28),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '🌧️ MONSOON EASTER EGG UNLOCKED!',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFootlight,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.paper,
                                  ),
                                ),
                                Text(
                                  'Abundant irrigation water flow activated across Cauvery Delta! 🌾💧',
                                  style: TextStyle(fontSize: 11.5, color: AppColors.waterBlueLight),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.paper, size: 20),
                            onPressed: widget.onCloseMonsoon,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class MonsoonRainPainter extends CustomPainter {
  final double progress;

  MonsoonRainPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(123);
    final paint = Paint()
      ..color = AppColors.waterBlueLight.withValues(alpha: 0.45)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const count = 70;
    for (int i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final speed = 0.5 + random.nextDouble() * 0.8;
      final y = ((progress * speed + random.nextDouble()) % 1.0) * size.height;
      final length = 12.0 + random.nextDouble() * 16.0;

      canvas.drawLine(Offset(x, y), Offset(x - 2, y + length), paint);
    }
  }

  @override
  bool shouldRepaint(covariant MonsoonRainPainter oldDelegate) => true;
}
