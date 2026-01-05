# Détail de 3 Écrans Clés - Violette

Ce document fournit une description détaillée de la conception UX/UI pour trois écrans fondamentaux de l'application Violette : le Dashboard du Gérant, le Calendrier de l'Artiste, et la Feuille de Route.

---

### 1. Écran Clé : Dashboard du Gérant

L'objectif est de permettre au gérant d'identifier en quelques secondes les actions prioritaires pour finaliser ses plannings.

#### Hiérarchie Visuelle
1.  **Action Principale (FAB)** : Le bouton flottant `+ Créer une date` est l'élément le plus proéminent. Il est toujours visible et accessible pour lancer le parcours utilisateur principal du gérant.
2.  **Section "Actions Requises"** : Placée en haut de l'écran. Elle utilise des cartes avec une légère élévation et des accents de couleur primaire pour attirer l'œil. C'est ici que le gérant doit agir.
3.  **Section "Prochaines Dates"** : Vue secondaire, informationnelle. Les cartes sont plus simples, moins proéminentes, pour une consultation rapide.

#### Composants
-   **`ManagerActionCard`** : Une carte pour la section "Actions Requises".
    -   **Contenu** : Nom de l'événement, date, et un indicateur de progression visuel (ex: "3/5 artistes confirmés").
    -   **Composants internes** : `LinearProgressIndicator`, `AvatarStack` pour montrer les visages des artistes déjà confirmés, et un `PrimaryCTA` (Call To Action) "Finaliser l'équipe".
-   **`UpcomingEventCard`** : Une carte plus sobre pour la section "Prochaines Dates".
    -   **Contenu** : Nom, date, et lieu de l'événement. Le clic sur la carte mène à la Feuille de Route.
-   **`FloatingActionButton (FAB)`** : Le bouton "+" standard de Material 3, utilisant la couleur primaire du thème.

#### États de l'Écran
-   **Chargement** : Des `SkeletonLoaders` qui imitent la forme des cartes et des en-têtes de section pour donner une impression de chargement rapide et structuré.
-   **Empty State** : Une illustration élégante sur le thème du spectacle (ex: un rideau de scène entrouvert).
    -   **Titre** : "Bienvenue sur Violette !"
    -   **Message** : "Organisez votre premier spectacle en créant une nouvelle date."
    -   Le FAB est bien visible pour guider l'utilisateur.
-   **Erreur** : Un composant simple avec une icône, un message ("Oups, impossible de charger vos données.") et un bouton "Réessayer".

---

### 2. Écran Clé : Calendrier de l'Artiste

L'objectif est de permettre à l'artiste de visualiser son planning et de communiquer ses disponibilités de manière fluide et rapide.

#### Hiérarchie Visuelle
1.  **Grille du Calendrier** : L'élément central. Le jour actuel est clairement mis en évidence. Les jours avec des événements ou des statuts de disponibilité sont marqués par des points de couleur.
2.  **Barre d'Actions de Disponibilité** : Placée juste en dessous de la grille, elle est l'outil d'interaction principal pour l'artiste.
3.  **Liste d'Événements du Jour** : Quand un jour est sélectionné, un résumé des événements de ce jour apparaît sous la barre d'actions.

#### Composants
-   **`CalendarView`** : Un widget de calendrier (ex: `table_calendar`).
    -   **`DotIndicator`** : Des points de couleur sous les numéros de jour :
        -   **Violet** : Booking confirmé.
        -   **Orange** : Proposition en attente ou statut "Conditionnel".
        -   **Gris** : Jour marqué comme "Indisponible".
-   **`AvailabilityToggleChips`** : Un groupe de `ChoiceChip` ou `FilterChip` pour que l'artiste puisse définir son statut pour le(s) jour(s) sélectionné(s) : `Disponible`, `Indisponible`, `Conditionnel`.
-   **`EventSummaryCard`** : Une petite carte qui apparaît lorsqu'un jour contenant un événement est sélectionné, montrant le titre de l'événement et l'heure. Un clic mène à la Feuille de Route.

#### États de l'Écran
-   **Chargement** : Un `CircularProgressIndicator` s'affiche en superposition pendant la récupération des données.
-   **Empty State** : Le calendrier est visible et fonctionnel, mais aucun jour n'est marqué. Un petit message "pop-up" ou une info-bulle peut apparaître la première fois pour guider l'utilisateur : "Sélectionnez un ou plusieurs jours pour définir vos disponibilités."
-   **Erreur** : Une `SnackBar` (bandeau en bas de l'écran) apparaît avec le message "Erreur de synchronisation du calendrier. Vos données pourraient ne pas être à jour."

---

### 3. Écran Clé : Détail d'une Date (Feuille de Route)

Cet écran est la source unique de vérité pour un événement donné, pour les deux rôles.

#### Hiérarchie Visuelle
1.  **Informations Vitales** : Le "Quoi, Quand, Où" est affiché tout en haut, avec un statut très visible.
2.  **Liste des Participants** : Essentielle pour la coordination. Qui d'autre est sur le booking ?
3.  **Barre d'Actions (pour l'Artiste)** : L'action de réponse est fixée en bas de l'écran (`sticky`) pour être toujours accessible, peu importe le défilement.

#### Composants
-   **`HeaderInfo`** : Une zone d'en-tête non cliquable avec le nom de l'événement, la date, et un `StatusChip` proéminent (ex: "Confirmé" en vert, "En attente" en orange).
-   **`InfoRow`** : Un composant réutilisable avec une `Icon`, un `Label` et une `Value` pour les détails (Lieu, Horaires, Cachet, etc.). Le lieu peut inclure un bouton pour ouvrir une app de cartographie.
-   **`ParticipantsList`** : Une liste verticale. Chaque item contient :
    -   `CircleAvatar` de l'artiste.
    -   Le nom de l'artiste.
    -   Un `AvailabilityStatusChip` indiquant son statut de réponse.
-   **`ArtistResponseBar`** : (Visible uniquement pour l'artiste si une réponse est attendue) Une barre en bas de l'écran avec trois boutons :
    -   `FilledButton` (style primaire) : "Accepter".
    -   `OutlinedButton` : "Refuser".
    -   `TextButton` : "Conditionnel".

#### États de l'Écran
-   **Chargement** : Des `SkeletonLoaders` pour chaque section : un bloc pour l'en-tête, des lignes pour les infos, et 3-4 squelettes de `ListTile` pour la liste des participants.
-   **Empty State** : L'écran en lui-même ne peut pas être "vide". Cependant, la liste des participants peut l'être. Dans ce cas, un message s'affiche : "Aucun artiste n'a encore été invité."
-   **Erreur** : Si les données de la date ne peuvent être chargées, un message d'erreur plein écran s'affiche avec un bouton "Réessayer".
