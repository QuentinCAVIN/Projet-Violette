import 'dart:math';
import 'package:flutter/material.dart';
//!!!!!CREATION IA! code testé visuellement uniquement!!!!!//
/// Widget décoratif qui affiche des paillettes/sparkles animées
/// inspirées du monde du spectacle
class SparkleBackground extends StatelessWidget {
  final Widget child;
  final int sparkleCount;

  const SparkleBackground({
    super.key,
    required this.child,
    this.sparkleCount = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Paillettes en arrière-plan
        ...List.generate(sparkleCount, (index) {
          final random = Random(index);
          return Positioned(
            left: random.nextDouble() * MediaQuery.of(context).size.width,
            top: random.nextDouble() * MediaQuery.of(context).size.height,
            child: SparkleWidget(
              size: 2 + random.nextDouble() * 3,
              opacity: 0.3 + random.nextDouble() * 0.4,
              delay: random.nextDouble() * 3,
            ),
          );
        }),
        // Contenu principal
        child,
      ],
    );
  }
}

/// Widget individuel représentant une paillette
class SparkleWidget extends StatefulWidget {
  final double size;
  final double opacity;
  final double delay;

  const SparkleWidget({
    super.key,
    required this.size,
    required this.opacity,
    this.delay = 0,
  });

  @override
  State<SparkleWidget> createState() => _SparkleWidgetState();
}

class _SparkleWidgetState extends State<SparkleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500 + (widget.delay * 1000).toInt()),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(widget.opacity),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(widget.opacity * 0.5),
              blurRadius: widget.size * 2,
              spreadRadius: widget.size * 0.5,
            ),
          ],
        ),
      ),
    );
  }
}
