# Changelog – Projet Violette
Toutes les versions suivent la convention Semantic Versioning (MAJOR.MINOR.PATCH).

---

## v0.1.0 – Première version du projet avec implémentation de l'authentification via Firebase.
Date : 05-12-2025

### Front-end (Flutter)
#### Added
- Initialisation de l’application Flutter avec architecture Stacked.
- Intégration de Firebase (configuration du projet et connexion à Firebase Auth).
- Création de la vue d’inscription (Register) avec formulaire email + mot de passe.
- Création de la vue de connexion (Login) avec formulaire géré via `@FormView` (Stacked).
- Gestion complète des messages d’erreur Firebase pour l’inscription et la connexion, rattachées aux champs concernés (email / mot de passe).
- Création d’un `UserService` côté Flutter pour lier l’utilisateur authentifié Firebase à son profil stocké dans Firestore via l’UID.
- Stockage des informations de base de l’utilisateur dans Firestore (ex. email, nom affiché minimal).
- Mise en place d’une `HomeView` affichant le nom de l’utilisateur connecté.
- Ajout d’un bouton de déconnexion permettant de revenir à l’écran de connexion.
- Mise en place d’un `StartupViewModel` qui écoute l’état d’authentification afin de rediriger automatiquement l’utilisateur vers Login ou Home.

### Back-end (Quarkus)
#### Added
- Initialisation d’un projet Quarkus (backend) qui démarre correctement, en préparation des futures API.  
  À ce stade, aucune interaction n’est encore en place entre le backend Quarkus et l’application Flutter.

---

## v0.2.0 – Planning gérant, gestion des disponibilités et mise en place de la qualité projet
Date : 26-01-2026

### Front-end (Flutter)
#### Added
- Gestion des rôles utilisateur (gérant / artiste) avec adaptation de l’inscription et de la navigation.
- Création et sauvegarde des dates de spectacle (ShowDate) via formulaire avec persistance dans Firestore.
- Mise en place de la vue *Planning gérant* permettant de visualiser les dates et les artistes associés.
- Gestion des disponibilités par artiste (disponible, indisponible, incertain) avec affichage détaillé.
- Amélioration de la sélection et de la consultation des ShowDate.
- Intégration du thème visuel **VioletteTheme** pour homogénéiser l’interface.

#### Changed
- Refactor de la logique de gestion des disponibilités afin de clarifier l’implémentation et améliorer la maintenabilité.
- Mutualisation du composant calendrier entre les différentes vues.

#### Fixed
- Corrections mineures d’interface et de navigation améliorant la stabilité globale.

### Qualité, tests et intégration continue
#### Added
- Mise en place d’une infrastructure de tests unitaires avec une approche agile.
- Ajout de tests unitaires pour la gestion des ShowDate, du calendrier et des ViewModels associés.
- Ajout d’une pipeline **GitHub Actions** pour l’analyse statique (`flutter analyze`) et l’exécution des tests.

#### Fixed
- Correction des erreurs bloquant l’analyse Flutter dans la CI.
- Correction du nom du dossier de travail utilisé par la pipeline CI.

### Repository
#### Changed
- Nettoyage du dépôt avec suppression du dossier `.idea` du suivi Git.