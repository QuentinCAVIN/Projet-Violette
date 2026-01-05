# Architecture UX & Navigation - Violette

Ce document décrit la structure de navigation, la hiérarchie de l'information et les parcours utilisateurs principaux pour l'application Violette.

---

### 1. Modèle de Navigation Principal

Pour une accessibilité optimale et une expérience mobile-first, l'application s'articulera autour d'une **Barre de Navigation Inférieure (Bottom Navigation Bar)**. Cette barre sera persistante à travers les sections principales de l'application, offrant un accès rapide et prévisible aux fonctionnalités clés.

Les 5 onglets de la navigation sont :

1.  **Accueil (Dashboard)** : L'écran d'atterrissage qui fournit une vue d'ensemble personnalisée selon le rôle de l'utilisateur.
2.  **Calendrier** : La vue centrale pour la consultation et la gestion du planning.
3.  **Messages** : Un centre de communication direct entre gérants et artistes.
4.  **Vidéos** : La librairie de contenus pour les répétitions et le partage de chorégraphies.
5.  **Profil** : Gestion du compte, des préférences et consultation des statistiques personnelles.

---

### 2. Logique des Rôles

L'application présente des interfaces et des actions distinctes pour les deux rôles principaux. La navigation reste la même, mais le contenu et les actions disponibles dans chaque section sont adaptés.

-   **Gérant (Manager)** :
    -   **Objectif principal** : Composer et confirmer des équipes d'artistes pour des dates spécifiques.
    -   **Actions clés** : Créer/modifier des dates, inviter des artistes, suivre les réponses, valider les plannings.
    -   **Dashboard** : Centré sur les dates à venir, les équipes à compléter et les actions requises.

-   **Artiste (Danseuse)** :
    -   **Objectif principal** : Gérer ses disponibilités, répondre aux propositions et consulter ses contrats.
    -   **Actions clés** : Consulter les propositions, mettre à jour son statut de disponibilité, accéder aux feuilles de route.
    -   **Dashboard** : Centré sur les prochaines dates confirmées, les nouvelles propositions en attente de réponse et les notifications importantes.

---

### 3. Parcours Utilisateurs Clés (User Flows)

#### A. Parcours du Gérant : Création d'une date et booking

1.  **Début** : Le gérant ouvre l'application et atterrit sur son **Dashboard**. Il voit un résumé des événements à venir et un bouton d'action principal (Floating Action Button - FAB) "+ Créer une date".
2.  **Création** : Il appuie sur le FAB et accède à l'écran **"Création de Date"**. Il remplit les informations essentielles : nom, lieu, horaires, description, nombre d'artistes requis, cachet.
3.  **Invitation** : Une fois la date créée, il est dirigé vers l'écran **"Inviter des Artistes"**. Il voit une liste des artistes de sa compagnie, avec leur statut de disponibilité générale (si renseigné) et le **compteur de dates** pour l'équité. Il sélectionne les artistes à qui il veut envoyer la proposition.
4.  **Suivi** : Le gérant est redirigé vers l'écran **"Détail de la Date"**. Il voit la liste des artistes invités avec leur statut de réponse : "En attente", "Confirmé", "Conditionnel", "Refusé".
5.  **Confirmation** : À mesure que les artistes répondent, la liste se met à jour. Une fois le nombre requis d'artistes "Confirmé" atteint, le gérant peut "Valider l'équipe", ce qui envoie une notification de confirmation à tous les participants.

#### B. Parcours de l'Artiste : Réponse à une proposition

1.  **Notification** : L'artiste reçoit une notification push : "Nouvelle proposition pour la date 'Spectacle XYZ'".
2.  **Consultation (via Dashboard)** : En ouvrant l'application, elle voit sur son **Dashboard** une carte dans la section "Propositions en attente" avec les informations clés de la date.
3.  **Détail** : Elle appuie sur la carte pour accéder à l'écran **"Détail de la Date" (Feuille de Route)**. Elle y trouve toutes les informations : lieu, horaires, description, autres artistes invités (si visible), etc.
4.  **Action** : Au bas de l'écran, une barre d'actions lui propose de définir son statut :
    -   **Accepter** (Statut -> "Confirmé")
    -   **Refuser** (Statut -> "Indisponible")
    -   **Conditionnel** (Statut -> "Conditionnel"). Un champ de texte apparaît pour qu'elle puisse ajouter une note (ex: "En attente de confirmation pour une autre date").
5.  **Confirmation Visuelle (via Calendrier)** : Après avoir accepté, elle peut se rendre dans l'onglet **Calendrier**. La date apparaît maintenant avec un marqueur visuel distinct (ex: couleur vive) indiquant qu'elle est bookée. Son compteur de dates dans son **Profil** est mis à jour.
6.  **Confirmation Finale** : Lorsque le gérant valide l'équipe, elle reçoit une notification finale : "Votre booking pour 'Spectacle XYZ' est confirmé !".
