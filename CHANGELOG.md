# Changelog – Projet Violette
Toutes les versions suivent la convention Semantic Versioning (MAJOR.MINOR.PATCH).

---

## [Unreleased] — travaux en cours sur main

### Front-end (Flutter) / Migration REST
#### Added
- Mise en place d'OpenAPI Generator (`openapitools.json`) avec le générateur `dart-dio` ; client Dart
  généré dans `violette_api_client/` à partir du spec OpenAPI du backend.
- `DioClient` : client HTTP Dio avec intercepteur JWT Firebase (injection automatique du Bearer token).
- `UserRemoteDataSource` : couche d'accès aux endpoints utilisateur du backend ; seul point d'import
  du client généré.
- `RestUserRepository` : implémentation de `UserRepository` via `UserRemoteDataSource` ; remplace
  `FirestoreUserRepository` pour le domaine `user`.
- `UserMapper` : conversion `VioletteUserDto` (built_value) ↔ `VioletteUser` (modèle métier Flutter).
- `docs/migration-domaine-user.md` : documentation technique complète de la migration (setup,
  flux auth, régénération client, adb reverse, dette résiduelle).

#### Changed
- `StartupViewModel` : routage initial déterministe — vérifie l'existence du profil backend au
  démarrage avant de naviguer (Firebase session + profil absent → logout + LoginView).
- `StartupView` : ajout d'un écran d'erreur avec bouton « Réessayer » si le backend est inaccessible.
- `HomeViewModel` : profil backend absent → logout + LoginView (cohérent avec StartupViewModel) ;
  suppression du dead code Stacked (scaffolding généré inutilisé).
- `RegisterViewModel` : gestion d'erreur backend explicite lors de la création du profil.
- `LoginViewModel` : navigation vers HomeView après connexion réussie.

### Back-end (Quarkus)
#### Added
- `GET /api/users/me/profile` : nouvel endpoint retournant le `VioletteUserDto` complet de
  l'utilisateur authentifié courant (200 si profil trouvé, 404 sinon).
- Export automatique du spec OpenAPI vers `target/openapi/openapi.yaml` en profils `dev` et `test`
  (propriété `quarkus.smallrye-openapi.store-schema-directory`).

---

## v0.3.2 – Correctifs OIDC production, version backend unifiée et Swagger homogénéisé en français
Date : 06-04-2026

### Sécurité
#### Fixed
- Activation explicite d'OIDC pour le profil de production via `%prod.quarkus.oidc.enabled=true`
  afin de corriger le refus d'accès (`403`) sur les endpoints `@Authenticated` en production.
  Cause racine : `quarkus.oidc.enabled` est une propriété build-time Quarkus — impossible à activer
  via variable d'environnement au runtime.

### Back-end (Quarkus) / Configuration
#### Changed
- Suppression de `QUARKUS_OIDC_ENABLED` dans `fly.toml` : variable sans effet pour une propriété
  build-time Quarkus, source de confusion supprimée.
- Clarification du comportement `build-time fixed` et séparation des paramètres OIDC :
  - build-time (dans `application.properties`) : `quarkus.oidc.enabled`, profils `%dev`/`%prod`
  - runtime (dans `fly.toml [env]`) : URL du serveur OIDC, client ID, issuer, audience
- Centralisation de la version backend dans `violette-back/pom.xml` comme unique source de vérité.
- Alignement de `quarkus.application.version` et `quarkus.smallrye-openapi.info-version`
  sur la version Maven du projet via filtrage de ressources.
- Configuration du `maven-resources-plugin` avec délimiteur `@` uniquement (`useDefaultDelimiters=false`)
  pour préserver les expressions Quarkus `${VAR:default}`.

### Documentation API (Swagger / OpenAPI)
#### Changed
- Uniformisation en français des libellés exposés dans Swagger/OpenAPI (`@Tag`, `@Operation`,
  `@APIResponse`) sur les contrôleurs backend (`violetteuser`, `cabaretcompany`, `showdate`,
  `artistbooking`, `health`).
- Harmonisation du ton et des formulations des descriptions HTTP (notamment les réponses d'erreur)
  pour une lecture cohérente côté jury et documentation technique.

### Documentation / Déploiement
#### Changed
- Mise à jour de `README-deploiement.md` pour expliciter l'activation OIDC en production,
  la distinction build-time/runtime et les vérifications de pré-soutenance associées.
- Mise à jour de `violette-back/README.md` pour clarifier le comportement du profil `firebase`
  en local et le mode d'activation OIDC en production.

---

## v0.3.1 – Pipeline de livraison, déploiement Fly.io et documentation de release
Date : 01-04-2026

### Infrastructure / Livraison
#### Added
- Déploiement backend sur Fly.io avec configuration dédiée via `fly.toml` (région Paris,
  `min_machines_running = 1`, mémoire 512 MB).
- Utilisation d'Aiven comme base de données MySQL pour l'environnement de production.
- Pipeline CI/CD principal (`deploy.yml`) avec stratégie à deux niveaux :
  - **Push sur `main`** → tests Maven + build image Docker + push GHCR (CI uniquement, pas de déploiement).
  - **Tag `v*.*.*`** → idem + déploiement Fly.io + création GitHub Release + build et publication APK Android (CD complet).
- Configuration des secrets GitHub Actions : `FLY_API_TOKEN`, `GOOGLE_SERVICES_JSON_BASE64`,
  `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
- Variables OIDC Firebase déclarées en clair dans `fly.toml [env]` (non sensibles, liées au project ID Firebase).
- Publication de l'APK Android via GitHub Releases sur les tags de version.

#### Changed
- Déclenchement du déploiement Fly.io sur tag versionné uniquement, afin de distinguer
  la CI continue de la release de production.

### Documentation / Déploiement
#### Added
- `README-deploiement.md` : guide de déploiement Fly.io + Aiven, configuration des secrets
  GitHub Actions, flux CI/CD détaillé, checklist de pré-soutenance.

#### Changed
- Harmonisation de la documentation de déploiement avec le workflow GitHub Actions réel.
- Mise à jour du `README.md` principal pour référencer explicitement le guide de déploiement.

### Front-end (Flutter)
#### Changed
- Configuration Android de release : `applicationId` aligné sur `io.violette.app`,
  préparation de la signature release et publication APK automatisée.

### Repository
#### Changed
- Sécurisation des fichiers sensibles dans `.gitignore` (`*.jks`, `*.b64`, `key.properties`,
  `google-services.json`).

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
