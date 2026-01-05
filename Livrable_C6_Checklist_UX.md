# Checklist UX - Violette

Ce document est une checklist pragmatique des points de vigilance UX à respecter tout au long du développement de l'application Violette pour garantir une expérience utilisateur de haute qualité.

---

### ✅ 1. Réduire la Charge Cognitive

L'interface doit être épurée et aller droit au but. L'utilisateur ne doit jamais se sentir submergé d'informations.

-   [ ] **Dashboards focalisés** : Le premier écran vu par l'utilisateur (Dashboard) montre-t-il immédiatement les 2-3 informations ou actions les plus critiques ? (ex: "Actions requises" pour le gérant).
-   [ ] **Formulaires concis** : Lors de la création d'une date, ne demander que les informations strictement nécessaires pour la V1. Éviter les champs optionnels superflus.
-   [ ] **"Progressive Disclosure"** : Les informations détaillées sont-elles masquées par défaut et accessibles sur demande ? (ex: on ne voit tous les détails d'une date qu'en cliquant dessus, pas dans la liste).
-   [ ] **Un seul objectif par écran** : Chaque écran a-t-il un et un seul objectif principal clair ? (ex: l'écran Calendrier sert à visualiser et gérer les dispos, rien d'autre).

### ✅ 2. Prioriser et Clarifier les Actions Primaires

Les actions les plus importantes doivent être les plus visibles et les plus faciles à atteindre.

-   [ ] **FAB pour l'action principale** : Le Gérant a-t-il toujours un accès visible et immédiat à la création de date via un Floating Action Button sur son dashboard ?
-   [ ] **Barre d'action persistante** : Pour l'Artiste, les boutons pour répondre à une offre (Accepter/Refuser) sont-ils toujours visibles en bas de l'écran de la feuille de route, même en faisant défiler ?
-   [ ] **Hiérarchie des boutons** : Le bouton de l'action la plus probable est-il visuellement plus lourd (ex: `FilledButton`) que les actions secondaires (`OutlinedButton`, `TextButton`) ?

### ✅ 3. Fournir un Feedback Utilisateur Constant

L'application doit communiquer en permanence avec l'utilisateur pour qu'il sache ce qu'il se passe.

-   [ ] **Confirmation des actions** : Chaque action importante (mise à jour d'une dispo, envoi d'une invitation, confirmation d'un booking) est-elle suivie d'un feedback immédiat et clair (ex: `SnackBar` "Disponibilité mise à jour !") ?
-   [ ] **Indicateurs de chargement utiles** : Les écrans utilisant des données distantes affichent-ils des `SkeletonLoaders` qui préfigurent la structure de l'interface, donnant une impression de vitesse ?
-   [ ] **Notifications pertinentes** : Les notifications push sont-elles utilisées à bon escient pour les événements importants (nouvelle proposition, confirmation, annulation) et sont-elles configurables ?

### ✅ 4. Prévenir les Erreurs de Planning

Le coût d'une erreur de planning est élevé. L'UI doit aider à les prévenir.

-   [ ] **Dialogues de confirmation** : Une confirmation est-elle demandée avant toute action irréversible ou aux conséquences importantes (ex: "Êtes-vous sûr de vouloir refuser cette date ?", "Confirmer l'équipe et envoyer les notifications ?") ?
-   [ ] **Verrouillage des statuts** : Une fois qu'une date est "Confirmée" par le gérant, les options de changement de statut pour l'artiste sont-elles désactivées pour éviter les annulations accidentelles ? (Elles doivent passer par une "demande d'annulation").
-   [ ] **Distinction visuelle forte** : Les couleurs et labels des statuts (`AvailabilityStatusChip`) sont-ils suffisamment distincts pour éviter toute confusion entre "Conditionnel", "Confirmé" et "En attente" ?

### ✅ 5. Assurer la Lisibilité et l'Accessibilité

Le design "crépuscule" doit servir l'expérience, pas la dégrader.

-   [ ] **Test de contraste** : Toutes les combinaisons de couleurs (texte sur fond) ont-elles été vérifiées avec un outil pour garantir un ratio minimum de 4.5:1 (WCAG AA) ?
-   [ ] **Taille de police minimale** : Le corps du texte (`bodyMedium`) ne descend-il jamais en dessous de 14sp pour garantir une lecture confortable ?
-   [ ] **Zones cliquables** : Tous les éléments interactifs (boutons, icônes, items de liste) respectent-ils la taille minimale recommandée de 48x48dp ?
-   [ ] **Labels sémantiques** : Les `IconButtons` ont-ils des `tooltips` pour les utilisateurs de lecteurs d'écran ?

### ✅ 6. Transparence de la Fonctionnalité d'Équité

La fonctionnalité de compteur de dates doit être claire et perçue comme juste.

-   [ ] **Visibilité du compteur** : Le compteur est-il facilement accessible pour l'artiste dans son profil ? Est-il clairement visible pour le gérant lors de la sélection des artistes à inviter ?
-   [ ] **Explication du calcul** : Une brève explication du fonctionnement du compteur est-elle disponible via une icône d'information `(i)` pour éviter toute ambiguïté ?
