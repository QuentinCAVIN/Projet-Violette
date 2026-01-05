# Design System Flutter - Violette

Ce document définit les fondations du design system pour l'application Violette, en accord avec les principes de Material 3 et l'identité visuelle souhaitée ("crépuscule", "paillettes", "élégance").

---

### 1. Palette de Couleurs (Color Scheme)

La palette est inspirée du crépuscule, un dégradé allant du rose poudré au bleu nuit profond, avec le violet comme couleur signature. Les "paillettes" seront traduites par des accents brillants et des effets de surbrillance.

-   **Primary (Violet Signature)** : Un violet vibrant mais élégant. Utilisé pour les actions principales (boutons, FABs) et les éléments actifs.
    -   `primary`: `#6A1B9A` (Violet Profond)
    -   `onPrimary`: `#FFFFFF` (Blanc)
    -   `primaryContainer`: `#E1BEE7` (Violet Pâle)
    -   `onPrimaryContainer`: `#311B92` (Violet Très Sombre)

-   **Secondary (Éclat Rosé)** : Un rose doux pour les accents, les sélections et les informations de second niveau.
    -   `secondary`: `#EC407A` (Rose Vif)
    -   `onSecondary`: `#FFFFFF`
    -   `secondaryContainer`: `#F8BBD0` (Rose Pâle)
    -   `onSecondaryContainer`: `#880E4F` (Rose Sombre)

-   **Tertiary (Bleu Nuit)** : Utilisé pour certains fonds ou éléments décoratifs, pour ancrer le design.
    -   `tertiary`: `#1A237E` (Bleu Indigo Profond)
    -   `onTertiary`: `#FFFFFF`

-   **Surface & Background (Toile de Fond)** : Des tons sombres et désaturés pour évoquer la nuit, tout en assurant une excellente lisibilité.
    -   `background`: `#121212` (Gris Presque Noir - pour le mode sombre par défaut)
    -   `surface`: `#1E1E1E` (Gris un peu plus clair pour les cartes)
    -   `onSurface`: `#E0E0E0` (Texte principal - Gris très clair)
    -   `onSurfaceVariant`: `#BDBDBD` (Texte secondaire - Gris moyen)

-   **Feedback Colors** :
    -   `error`: `#EF5350` (Rouge Doux)
    -   `success` (non-standard Material 3, mais utile) : `#4CAF50` (Vert)
    -   `warning` (non-standard) : `#FFCA28` (Ambre)

---

### 2. Typographie (Typography)

On choisit une police de caractères élégante et très lisible pour les titres, et une police de travail neutre et claire pour le corps du texte.

-   **Police des Titres (Display & Headline)** : `Playfair Display` (police avec empattements, élégante, pour le branding).
-   **Police du Corps de Texte (Body & Labels)** : `Roboto` (police sans empattement, standard, lisible et performante).

**Styles de Texte Material 3 (`TextTheme`)** :
-   `displayLarge`: Playfair Display, 57.0, `FontWeight.w400`
-   `headlineMedium`: Playfair Display, 28.0, `FontWeight.w400`
-   `titleLarge`: Roboto, 22.0, `FontWeight.w500` (Titres d'écran)
-   `bodyLarge`: Roboto, 16.0, `FontWeight.w400` (Corps de texte principal)
-   `bodyMedium`: Roboto, 14.0, `FontWeight.w400` (Texte secondaire)
-   `labelLarge`: Roboto, 14.0, `FontWeight.w500` (Boutons)

---

### 3. Composants Réutilisables

Voici la spécification de quelques composants clés qui formeront la base de l'UI.

#### `AvailabilityStatusChip`
-   **Rôle** : Afficher un statut de disponibilité de manière visuelle et concise.
-   **Widget Flutter** : `Chip` ou `StadiumBorder` + `Container`.
-   **Variantes** :
    -   **Disponible / Confirmé** : Fond vert (`success`), texte blanc.
    -   **Indisponible / Refusé** : Fond rouge (`error`), texte blanc.
    -   **Conditionnel** : Fond ambre (`warning`), texte noir.
    -   **En attente** : Fond gris (`onSurfaceVariant`), texte blanc.
-   **Accessibilité** : `Tooltip` avec le texte complet du statut au survol/appui long.

#### `DateCard`
-   **Rôle** : Afficher les informations d'un événement dans une liste.
-   **Widget Flutter** : `Card` avec une `ListTile` à l'intérieur.
-   **Structure** :
    -   À gauche : Un bloc vertical affichant le jour et le mois (ex: "24", "DÉC").
    -   Au centre : Titre de l'événement (style `titleMedium`), lieu (style `bodySmall`).
    -   À droite : `AvatarStack` des participants ou un chevron pour la navigation.

#### `AvatarStack`
-   **Rôle** : Afficher une liste de participants qui se chevauchent.
-   **Widget Flutter** : Une `Row` de `CircleAvatar` avec un positionnement négatif.
-   **Logique** : Affiche les 3-4 premiers avatars. Si plus, le dernier cercle est un compteur (ex: "+5").

#### `EmptyState`
-   **Rôle** : Remplir un écran vide de manière engageante.
-   **Widget Flutter** : Une `Column` centrée.
-   **Structure** : `Icon` ou `SvgPicture` (illustration), `Text` (titre, style `headlineSmall`), `Text` (message, style `bodyMedium`), et optionnellement un `FilledButton` (CTA).

#### `PrimaryCTA`
-   **Rôle** : Le bouton d'action principal d'un écran.
-   **Widget Flutter** : `FilledButton`.
-   **Style** : Utilise la couleur `primary` du thème. Le texte est en majuscules (style `labelLarge`).

---

### 4. Règles d'Accessibilité (A11y)

-   **Contrastes** : La palette de couleurs a été choisie pour respecter un ratio de contraste d'au moins 4.5:1 entre le texte et le fond, conformément aux recommandations WCAG AA. Des outils de vérification seront utilisés.
-   **Tailles Cliquables** : Toutes les zones interactives (boutons, items de liste) auront une taille minimale de 48x48dp pour être facilement cliquables.
-   **Labels** : Tous les `IconButton` auront un `tooltip` servant de label sémantique pour les lecteurs d'écran (`Semantics`).
-   **Focus** : La navigation au clavier/lecteur d'écran suivra un ordre logique et visuel. Les éléments interactifs auront un indicateur de focus visible.
