import 'package:flutter/material.dart';

class SpringCardFan extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double initialAngle;

  const SpringCardFan({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    this.initialAngle = -0.05,
  });

  @override
  State<SpringCardFan> createState() => _SpringCardFanState();
}

class _SpringCardFanState extends State<SpringCardFan>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _rotation = Tween<double>(begin: widget.initialAngle, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
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
        return Transform.rotate(
          angle: _rotation.value,
          child: Transform.scale(
            scale: _scale.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
