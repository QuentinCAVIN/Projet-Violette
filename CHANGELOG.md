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
