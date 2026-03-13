# Changelog – Projet Violette
Toutes les versions suivent la convention Semantic Versioning (MAJOR.MINOR.PATCH).

---

## v0.3.0 – Architecture backend, domaines métier et documentation technique
Date : 13-03-2026

### Back-end (Quarkus)
#### Added
- Initialisation du projet Quarkus 3.x avec Hibernate ORM Panache, Flyway, Bean Validation,
  OpenAPI/Swagger et MapStruct.
- Architecture en monolithe modulaire structuré par domaine (`io.violette.<domaine>`)
  avec couches Controller → Service → Repository.
- Implémentation des 4 domaines métier : `violetteuser`, `cabaretcompany`, `showdate`, `artistbooking`.
- Schéma SQL relationnel complet avec 5 migrations Flyway (V1 à V5) : utilisateurs, compagnies,
  revues, dates de spectacle, disponibilités, réservations.
- Sécurité Firebase JWT via Quarkus OIDC : validation du token, rôles métier (`ARTIST`, `MANAGER`)
  chargés depuis la base backend.
- Endpoints sécurisés : `GET /api/users/me` (authentifié), `GET /api/users` (MANAGER uniquement).
- 3 design patterns GoF : Singleton (CDI `@ApplicationScoped`), Adapter (JWT Firebase →
  `SecurityIdentity` Quarkus), Observer (CDI Events sur les transitions de statut de réservation).
- Exceptions métier spécialisées + `ExceptionMapper` JAX-RS par domaine (12 mappers au total).
- Endpoint de santé `GET /api/ping` et documentation API Swagger UI (`/swagger-ui`).
- Logging SLF4J structuré sur tous les domaines, avec `firebaseUid` comme contexte d'identification.

#### Changed
- Migration du package racine de `com.willow.violette` vers `io.violette`.
- Renommage de `cabaret_show` en `revue` pour respecter le langage ubiquitaire DDD.

### Qualité / Tests / CI
#### Added
- 18 classes de tests unitaires et d'intégration couvrant les 4 domaines métier.
- Tests d'intégration MySQL/Flyway (`FlywayMigrationIT`, `VioletteUserRepositoryIT`).
- Couverture JaCoCo ≥ 30 % de lignes couvertes ; build fail automatique si le seuil n'est pas atteint.
- CI GitHub Actions backend (`backend-ci.yml`) : `mvn clean verify` à chaque PR.
- Séparation des pipelines CI : Flutter (`flutter-ci.yml`) et backend Quarkus (`backend-ci.yml`).

### Infrastructure / Livraison
#### Added
- `docker-compose.yml` : stack complète MySQL 8 + backend Quarkus (mode JVM) avec healthchecks
  et variables d'environnement.
- Dockerfiles fournis : JVM, native, legacy-jar, native-micro.
- Configuration multi-environnement : H2 en dev/test, MySQL en production,
  profil `firebase` pour tests locaux avec JWT réels.

### Documentation / Architecture
#### Added
- `violette-back/ARCHITECTURE.md` : architecture en couches, design patterns, sécurité JWT,
  flux de requête, décisions de modélisation par domaine.
- `violette-back/README.md` enrichi : guide de démarrage, structure des packages, commandes Maven,
  lancement Docker.
- `docs/functional-spec.md` : description fonctionnelle (acteurs, cas d'usage, workflow de réservation).
- `docs/user-manual.md` : manuel utilisateur pour les rôles gérant et artiste.
- `docs/booking-workflow.md` : workflow de réservation V1 (statuts, transitions, règles métier)
  et vision V2 (workflows configurables par compagnie).
- `docs/architecture-c4.md` : documentation des diagrammes C4 niveaux 1 à 4.
- Diagrammes C4 : contexte système, containers, composants backend, zoom niveau 4 sur `artistbooking`.
- Diagramme DDD bounded contexts et Domain Storytelling.

### Front-end (Flutter)
> Aucune nouvelle fonctionnalité ajoutée sur cette branche.
> Le frontend (v0.2.0) reste fonctionnel sur Firebase/Firestore et n'est pas encore raccordé
> aux endpoints REST du backend Quarkus. L'intégration front ↔ backend constitue l'étape suivante.

---

## v0.2.0 – Planning gérant, gestion des disponibilités et mise en place de la qualité projet
Date : 26-01-2026

### Front-end (Flutter)
#### Added
- Gestion des rôles utilisateur (gérant / artiste) avec adaptation de l'inscription et de la navigation.
- Création et sauvegarde des dates de spectacle (ShowDate) via formulaire avec persistance dans Firestore.
- Mise en place de la vue *Planning gérant* permettant de visualiser les dates et les artistes associés.
- Gestion des disponibilités par artiste (disponible, indisponible, incertain) avec affichage détaillé.
- Amélioration de la sélection et de la consultation des ShowDate.
- Intégration du thème visuel **VioletteTheme** pour homogénéiser l'interface.

#### Changed
- Refactor de la logique de gestion des disponibilités afin de clarifier l'implémentation et améliorer la maintenabilité.
- Mutualisation du composant calendrier entre les différentes vues.

#### Fixed
- Corrections mineures d'interface et de navigation améliorant la stabilité globale.

### Qualité, tests et intégration continue
#### Added
- Mise en place d'une infrastructure de tests unitaires avec une approche agile.
- Ajout de tests unitaires pour la gestion des ShowDate, du calendrier et des ViewModels associés.
- Ajout d'une pipeline **GitHub Actions** pour l'analyse statique (`flutter analyze`) et l'exécution des tests Flutter.

#### Fixed
- Correction des erreurs bloquant l'analyse Flutter dans la CI.
- Correction du nom du dossier de travail utilisé par la pipeline CI.

### Repository
#### Changed
- Nettoyage du dépôt avec suppression du dossier `.idea` du suivi Git.

---

## v0.1.0 – Première version du projet avec implémentation de l'authentification via Firebase.
Date : 05-12-2025

### Front-end (Flutter)
#### Added
- Initialisation de l'application Flutter avec architecture Stacked.
- Intégration de Firebase (configuration du projet et connexion à Firebase Auth).
- Création de la vue d'inscription (Register) avec formulaire email + mot de passe.
- Création de la vue de connexion (Login) avec formulaire géré via `@FormView` (Stacked).
- Gestion complète des messages d'erreur Firebase pour l'inscription et la connexion, rattachées aux champs concernés (email / mot de passe).
- Création d'un `UserService` côté Flutter pour lier l'utilisateur authentifié Firebase à son profil stocké dans Firestore via l'UID.
- Stockage des informations de base de l'utilisateur dans Firestore (ex. email, nom affiché minimal).
- Mise en place d'une `HomeView` affichant le nom de l'utilisateur connecté.
- Ajout d'un bouton de déconnexion permettant de revenir à l'écran de connexion.
- Mise en place d'un `StartupViewModel` qui écoute l'état d'authentification afin de rediriger automatiquement l'utilisateur vers Login ou Home.

### Back-end (Quarkus)
#### Added
- Initialisation d'un projet Quarkus (backend) qui démarre correctement, en préparation des futures API.  
  À ce stade, aucune interaction n'est encore en place entre le backend Quarkus et l'application Flutter.
