import 'package:flutter/material.dart';

/// Un widget de bouton réutilisable pour les actions principales de l'application.
///
/// Il utilise `FilledButton` de Material 3, stylisé avec les couleurs primaires
/// du thème de l'application pour garantir la cohérence visuelle.
class PrimaryCTA extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const PrimaryCTA({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Utilise un FilledButton pour une action à forte emphase.
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        // Utilise la couleur primaire du thème.
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Affiche une icône si elle est fournie.
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(text),
        ],
      ),
    );
  }
}
