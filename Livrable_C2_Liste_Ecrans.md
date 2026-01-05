# Liste des Écrans & Descriptions - Violette

Ce document détaille l'ensemble des écrans nécessaires pour le MVP de l'application Violette, leur fonction, leurs composants clés et leurs différents états.

---

### Écrans d'Authentification

#### 1. Écran de Connexion (Login)
- **Rôle** : Permettre aux utilisateurs existants de se connecter.
- **Contenu** : Champs email/mot de passe, bouton "Se connecter", lien "Mot de passe oublié ?", lien vers l'inscription.
- **États** :
    - **Normal** : Formulaire interactif.
    - **Chargement** : Indicateur de progression sur le bouton après soumission.
    - **Erreur** : Message d'erreur clair (ex: "Email ou mot de passe incorrect").

---

### Navigation Principale

#### 1. Accueil (Dashboard)

**1.1 Dashboard Gérant**
- **Rôle** : Donner au gérant une vue d'ensemble des actions urgentes et des dates à venir.
- **Contenu** :
    - Section "Actions requises" : cartes pour les dates nécessitant de valider l'équipe.
    - Section "Prochaines dates" : liste chronologique des événements confirmés.
    - Section "Artistes récemment contactés".
    - **Floating Action Button (FAB)** : "+ Créer une date".
- **États** :
    - **Chargement** : Skeletons pour les sections de cartes.
    - **Vide** : Message accueillant avec une illustration et un appel à l'action clair : "Vous n'avez pas encore de date planifiée. Créez votre premier événement !".
    - **Erreur** : Composant d'erreur avec un bouton "Réessayer".

**1.2 Dashboard Artiste**
- **Rôle** : Montrer à l'artiste ses engagements à venir et les nouvelles opportunités.
- **Contenu** :
    - Section "Propositions en attente" : cartes cliquables pour les nouvelles demandes de booking.
    - Section "Mes prochaines dates" : liste des bookings confirmés.
    - Raccourci vers ses statistiques de dates.
- **États** : Mêmes que pour le gérant, mais avec des messages adaptés ("Aucune nouvelle proposition pour le moment.", "Votre planning est libre !").

#### 2. Calendrier

**2.1 Vue Calendrier (Commune)**
- **Rôle** : Visualiser les dates de manière mensuelle/hebdomadaire et gérer les disponibilités.
- **Contenu** :
    - Grille de calendrier (vue mois par défaut, switch possible).
    - Jours marqués avec des points de couleur pour indiquer les événements ou les statuts.
    - (Pour l'artiste) : Une barre d'outils pour sélectionner un jour et appliquer un statut de disponibilité (Disponible, Indisponible).
- **États** :
    - **Chargement** : Indicateur de chargement superposé.
    - **Vide** : Le calendrier est affiché, mais sans aucun événement marqué.
    - **Erreur** : Snackbar/Toast indiquant une erreur de synchronisation.

#### 3. Messages

**3.1 Liste des Conversations**
- **Rôle** : Afficher toutes les conversations actives.
- **Contenu** : Liste de `ConversationCard` (Avatar, nom, dernier message, timestamp).
- **États** :
    - **Chargement** : Skeletons de listes.
    - **Vide** : Illustration et message : "Aucune conversation. Contactez un artiste depuis une feuille de route pour commencer."
    - **Erreur** : Message d'erreur avec bouton "Réessayer".

**3.2 Vue d'une Conversation**
- **Rôle** : Échanger des messages directs.
- **Contenu** : Liste de bulles de messages, champ de saisie de texte, bouton d'envoi.
- **États** :
    - **Chargement** : Indicateur de chargement au centre.
    - **Vide** : Affiche le début de la conversation, potentiellement avec un message système.

#### 4. Vidéos

**4.1 Librairie de Vidéos**
- **Rôle** : Consulter les vidéos de chorégraphies partagées par les gérants.
- **Contenu** : Grille ou liste de `VideoCard` (miniature, titre, durée). Barre de recherche.
- **États** :
    - **Chargement** : Skeletons en grille.
    - **Vide** : Message "Aucune vidéo n'a été partagée pour le moment."
    - **Erreur** : Message d'erreur.

**4.2 Lecteur Vidéo**
- **Rôle** : Visionner une vidéo.
- **Contenu** : Composant lecteur vidéo (natif Flutter), titre et description de la vidéo en dessous.
- **États** :
    - **Chargement** : Buffer du lecteur vidéo.

#### 5. Profil

**5.1 Vue Profil (Commune)**
- **Rôle** : Permettre à l'utilisateur de voir ses informations et ses statistiques.
- **Contenu** :
    - Photo de profil, nom, rôle.
    - Section "Mes informations" (email, téléphone, etc.).
    - Section "Statistiques" :
        - **Artiste** : Affiche le **compteur de dates** sur le mois/année.
        - **Gérant** : Affiche le nombre de dates organisées.
    - Bouton "Modifier le profil".
    - Bouton "Se déconnecter".

---

### Écrans de Parcours

#### 1. Création / Modification de Date (Gérant)
- **Rôle** : Formulaire pour créer ou éditer un événement.
- **Contenu** : Champs de formulaire (nom, lieu avec autocomplétion, date/heure, description, nombre d'artistes, cachet), bouton "Enregistrer et inviter".
- **États** : Gestion des erreurs de validation par champ.

#### 2. Détail de Date / Feuille de Route (Commun)
- **Rôle** : Afficher toutes les informations relatives à un événement. C'est l'écran de référence.
- **Contenu** :
    - En-tête avec nom de la date, statut (ex: "En cours de booking", "Confirmé").
    - Bloc "Informations Clés" (date, horaires, lieu avec lien vers une carte).
    - Bloc "Description / Notes".
    - Bloc "Participants" : liste des artistes avec leur statut de réponse (`AvatarStack` + `StatusChip`).
    - **(Pour l'artiste)** : Barre d'action en bas pour répondre (Accepter / Refuser / Conditionnel).
- **États** :
    - **Chargement** : Skeletons pour chaque bloc d'information.

#### 3. Notifications
- **Rôle** : Lister les notifications reçues.
- **Contenu** : Liste chronologique de `NotificationCard` (icône, message, timestamp).
- **États** :
    - **Vide** : "Vous n'avez aucune nouvelle notification."
