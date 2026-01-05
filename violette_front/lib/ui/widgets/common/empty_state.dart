import 'package:flutter/material.dart';
import 'package:violette_front/ui/widgets/common/primary_cta.dart';

/// Un widget réutilisable pour afficher un état vide (empty state) de manière
/// engageante et informative.
///
/// Il est conçu pour remplir les écrans sans contenu, en guidant l'utilisateur
/// sur les actions possibles.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? ctaText;
  final VoidCallback? onCtaPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.ctaText,
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            // Affiche un bouton d'appel à l'action si le texte est fourni.
            if (ctaText != null) ...[
              const SizedBox(height: 32),
              PrimaryCTA(
                text: ctaText!,
                onPressed: onCtaPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
