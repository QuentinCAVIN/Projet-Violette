import 'package:flutter/material.dart';
import 'package:violette_front/ui/common/app_theme.dart';
import 'package:violette_front/ui/widgets/common/sparkle_background/sparkle_background.dart';

/// Fond dégradé nocturne (indigo → violet) avec particules décoratives.
/// Centralise le rendu utilisé sur les écrans à texte clair sur fond sombre.
class GradientBackground extends StatelessWidget {
  final Widget child;
  final int sparkleCount;
  final BoxDecoration? decoration;

  const GradientBackground({
    super.key,
    required this.child,
    this.sparkleCount = 25,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration ?? VioletteTheme.gradientBackground,
      child: SparkleBackground(
        sparkleCount: sparkleCount,
        child: child,
      ),
    );
  }
}
