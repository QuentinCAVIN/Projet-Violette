# Projet-Violette
Plateforme web de gestion des plannings et des cachets pour gérants de compagnie artistiques et intermittents du spectacle . L'outil centralisera les disponibilités, les réservations, les vidéos de répétition et la communication entre gérants et artistes

---

## → Documentation architecture & backend (module architecture logicielle)

**Toute la documentation technique du projet** (architecture, design patterns, DDD, stack, démarrage, tests, Docker, manuel utilisateur) est centralisée dans le README du backend. Un seul lien pour y accéder :

**[📄 violette-back/README.md](violette-back/README.md)**

---

## Documentation

### Pour les examinateurs

| Document | Contenu | Lien |
|----------|---------|------|
| **Manuel technique backend** | Architecture, couches, packages, sécurité, démarrage, tests, commandes Maven | [violette-back/README.md](violette-back/README.md) |
| **Architecture détaillée** | Patterns, DDD, sécurité JWT, flux de requête, décisions de modélisation | [violette-back/ARCHITECTURE.md](violette-back/ARCHITECTURE.md) |
| **Description fonctionnelle** | Contexte métier, acteurs, fonctionnalités, workflow | [docs/functional-spec.md](docs/functional-spec.md) |
| **Manuel utilisateur** | Guide gérant et artiste, statuts, bonnes pratiques | [docs/user-manual.md](docs/user-manual.md) |
| **Workflow de réservation** | Statuts, transitions, règles métier détaillées | [docs/booking-workflow.md](docs/booking-workflow.md) |
| **Documentation C4** | Explication des diagrammes C4 (contexte, container, composants, zoom niveau 4) | [docs/architecture-c4.md](docs/architecture-c4.md) |
| **Guide de déploiement** | Fly.io, Aiven MySQL, pipeline CI/CD, secrets GitHub, checklist soutenance | [README-deploiement.md](README-deploiement.md) |
| **Migration domaine user** | Setup OpenAPI Generator, client Dart généré, flux REST user, adb reverse, dette résiduelle | [docs/migration-domaine-user.md](docs/migration-domaine-user.md) |
| **Changelog** | Historique des versions | [CHANGELOG.md](CHANGELOG.md) |

### Intégration continue et déploiement

Le pipeline GitHub Actions lance automatiquement `mvn clean verify` à chaque push sur `main`, incluant les tests unitaires et le rapport de couverture JaCoCo (≥ 30 % de lignes couvertes). Il construit et pousse également l'image Docker vers GHCR.

Le déploiement en production (Fly.io) et la publication de l'APK Android sont déclenchés par un tag `v*.*.*`.

→ [.github/workflows/backend-ci.yml](.github/workflows/backend-ci.yml) — CI backend (tests + couverture)  
→ [.github/workflows/deploy.yml](.github/workflows/deploy.yml) — CI/CD principal (image Docker + Fly.io + APK)

## Déploiement

Le backend Quarkus est déployé sur `Fly.io` et utilise une base `MySQL` hébergée sur `Aiven`. Le pipeline `GitHub Actions` construit et publie l'image Docker sur `GHCR`, puis déclenche le déploiement sur tag `v*.*.*`. L'APK Android de release est publié dans les `GitHub Releases`.

Le déploiement en production est déclenché uniquement via des tags versionnés afin de garantir la stabilité des versions livrées.

Pour le détail des comptes, secrets, étapes manuelles et flux CI/CD, voir [README-deploiement.md](README-deploiement.md).

---

## Architecture

### C4 — Contexte système

Vue d'ensemble du système Violette et de ses interactions avec les utilisateurs et services externes.

![C4 Context](docs/diagrams/c4-context.png)

### C4 — Containers

Architecture technique : frontend Flutter, backend Quarkus, bases de données et services externes.

![C4 Container](docs/diagrams/c4-container.png)

### C4 — Components (Backend)

Découpage modulaire du backend par domaine métier (violetteuser, showdate, artistbooking, cabaretcompany).

![C4 Component](docs/diagrams/c4-component.png)

### C4 — Zoom composant (niveau 4) — Domaine artistbooking

Détail des composants et flux à l’intérieur du domaine **artistbooking** (Controller, Service, Repository, Entity, Event, Observer, Mapper). Source : [docs/diagrams/c4-component-artistbooking.puml](docs/diagrams/c4-component-artistbooking.puml). Pour afficher le PNG : générer à partir du .puml (voir [docs/diagrams/README.md](docs/diagrams/README.md)).

![C4 Component Artistbooking](docs/diagrams/c4-component-artistbooking.png)

### Domain-Driven Design — Bounded Contexts

Cartographie des domaines métier avec distinction Core / Supporting / Generic.

![DDD Bounded Contexts](docs/diagrams/ddd-bounded-contexts.png)

### Domain Storytelling

Flux fonctionnels principaux : déclaration de disponibilité, réservation d'artistes, gestion de compagnie.

![Domain Storytelling](docs/diagrams/domain-storytelling.png)

---

## État actuel — branche `main`

> Dernière version déployée : **v0.3.2**

### Front-end (Flutter)
- Application Flutter avec architecture Stacked.
- Authentification Firebase avec gestion des rôles (gérant / artiste).
- Création et gestion des dates de spectacle (ShowDate).
- Vue Planning gérant avec calendrier et gestion des disponibilités par artiste.
- Infrastructure de tests unitaires et intégration continue (GitHub Actions).
- **Migration Firestore → REST en cours** : domaine `user` migré (POC validé — profil backend chargé depuis le backend Quarkus via client OpenAPI). Les domaines `showdate`, `booking` et `company` restent sur Firebase/Firestore dans l'attente de leur migration.

### Back-end (Quarkus)
- Monolithe modulaire structuré par domaine (`violetteuser`, `cabaretcompany`, `showdate`, `artistbooking`).
- Stack : Quarkus 3.x, Hibernate ORM Panache, Flyway (5 migrations), OpenAPI/Swagger, MapStruct.
- Schéma SQL relationnel complet (remplace progressivement Firestore).
- Sécurité Firebase JWT via Quarkus OIDC (validée en production depuis v0.3.2), rôles métier (`ARTIST`, `MANAGER`) depuis la base backend.
- Endpoint de santé : `GET /api/ping` — Swagger UI : `http://localhost:8080/swagger-ui`
- Documentation API Swagger uniformisée en français (depuis v0.3.2).
- 18 classes de tests, couverture JaCoCo ≥ 30 %, CI GitHub Actions backend.
- Déployable en local via Docker Compose (MySQL 8 + Quarkus JVM).
- Déployé en production sur Fly.io (région Paris) avec base MySQL Aiven (depuis v0.3.1).
- Pipeline CI/CD GitHub Actions : build + tests + image Docker GHCR à chaque push ; déploiement Fly.io + APK Android sur tag `v*.*.*` (depuis v0.3.1).

## Stack technique

- Front : Flutter + Stacked + Firebase Auth + Firestore (migration REST en cours)
- Back : Quarkus (Java 21), MySQL / H2
- Client API généré : `violette_api_client/` — package Dart/Dio généré depuis le spec OpenAPI du backend (voir [openapitools.json](openapitools.json))

## Lancement rapide

Front Flutter :

```bash
cd violette_front
flutter pub get
flutter run
```

Back Quarkus :
```bash
cd violette-back
./mvnw quarkus:dev
# ou avec Maven global : mvn quarkus:dev
```

> **Pour tester le POC mobile (frontend Flutter ↔ backend)** : ajouter le profil `firebase` afin d'activer la validation des JWT Firebase (sinon les endpoints protégés retournent 403). Base H2 in-memory — MySQL non requis.
>
> ```bash
> # Linux / macOS
> export FIREBASE_PROJECT_ID="violette-1f64e"
> ./mvnw quarkus:dev -Dquarkus.profile=firebase
>
> # Windows (PowerShell)
> $env:FIREBASE_PROJECT_ID="violette-1f64e"
> mvn quarkus:dev "-Dquarkus.profile=firebase"
> ```
>
> Voir [violette-back/README.md](violette-back/README.md) section « Profil Firebase et authentification JWT » pour le détail complet.

**Alternative avec Docker :** backend + MySQL en conteneurs — voir [violette-back/README.md](violette-back/README.md) section « Lancer avec Docker (docker-compose) ».

Journal des versions:

Voir le fichier [CHANGELOG.md](CHANGELOG.md)