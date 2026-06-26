# Projet-Violette

Violette est une application Flutter + backend Quarkus pour aider les compagnies de cabaret à gérer leurs dates de spectacle, les disponibilités artistes et les réservations.

La release `v0.4.0` stabilise la sortie du code métier frontend de Firestore : les domaines `user`, `availability`, `showDate` et `booking` passent par l'API REST. Firebase Auth reste utilisé pour l'identité et les JWT ; le backend Quarkus devient la source métier principale.

---

<a id="demarrage-rapide"></a>
## Démarrage rapide (développement local)

> Environnement local : base H2 en mémoire (aucun MySQL requis), authentification Firebase,
> jeu de données de test préchargé automatiquement au démarrage.

Prérequis : Java 21, Maven, Flutter, un téléphone Android (USB avec débogage activé) ou un émulateur.

### 1. Backend (Quarkus + H2 + seed)

Depuis `violette-back/` :

```powershell
$env:FIREBASE_PROJECT_ID="violette-1f64e"
mvn quarkus:dev "-Dquarkus.profile=firebase"
```

Le backend démarre sur http://localhost:8080. Au lancement, il crée le schéma H2 et charge
automatiquement le jeu de données de test (1 gérant, 2 artistes, 4 dates de spectacle).

Vérification : `curl http://localhost:8080/api/ping`.

### 2. Frontend (Flutter)

Depuis `violette_front/`, téléphone Android branché en USB :

```powershell
adb reverse tcp:8080 tcp:8080
flutter run
```

<a id="comptes-de-test"></a>
## Comptes de test (développement local uniquement)

> Ces comptes existent uniquement sur l'environnement de développement local (base H2 jetable,
> projet Firebase de test). Ils n'ont aucune validité en production. Les mots de passe simples
> ci-dessous sont destinés au confort de test local et ne reflètent pas la politique de sécurité
> appliquée en production.

| Rôle | Email | Mot de passe | Données associées |
|------|-------|--------------|-------------------|
| Gérant | manager@violette.test | 123456 | Compagnie « Dream's Production », 4 dates de novembre 2026 |
| Artiste (danse) | artiste1@violette.test | 123456 | Membre de la compagnie, disponibilités préremplies |
| Artiste (chant) | artiste2@violette.test | 123456 | Membre de la compagnie, disponibilités préremplies |

---

## Accès rapide

> L’application est actuellement disponible uniquement sur Android.
- **Installer l'application sur mon téléphone (Android)** :
    
  - **Téléchargement le plus simple** (dernière version) : cliquez ici pour le [téléchargement direct (fichier d'installation)](#telechargement-direct-derniere-version).
  - **Guide complet pas à pas** : lisez [Installer l'application sur votre téléphone Android](#install-violette-android-telephone).
- **Démarrer en local rapidement** : voir le [démarrage rapide (développement local)](#demarrage-rapide).
- **Comptes de test local** : voir les [comptes de test](#comptes-de-test).
- **Comprendre les fonctionnalités** : voir le [manuel utilisateur](docs/user-manual.md).
- **Voir toutes les versions mises en ligne** : page des versions Violette sur le site [GitHub](https://github.com/QuentinCAVIN/Projet-Violette/releases) (le plus haut = le plus récent).
- **Développer ou tester le projet** : voir le [lancement rapide développeur](#lancement-rapide).

---
<a id="install-violette-android-telephone"></a>
## Installer l'application sur votre téléphone Android

Cette section explique, étape par étape, comment installer Violette sur un téléphone Android, même si vous n'avez jamais utilisé le site [GitHub](https://github.com) et même si vous avez l’habitude d’installer uniquement depuis le Play Store.

> **Aucune compétence technique n'est nécessaire** : suivez simplement la liste, dans l'ordre.

> **Rappel (une seule fois)** : sur Android, l'application s'installe via un type de fichier couramment appelé **APK**. Pour éviter le jargon, on dira ici simplement **fichier d'installation**.

### Où télécharger : sur le téléphone, ou sur un ordinateur

Deux parcours possibles :

- **Téléphone (recommandé)** : vous téléchargez le fichier d'installation directement sur le téléphone, puis vous l'ouvrez.
- **Ordinateur puis transfert** : vous téléchargez le fichier d'installation sur l'ordinateur, puis vous le transférez sur le téléphone (câble, e-mail, cloud, outil de transfert) avant de l'ouvrir sur le téléphone.

### 1) Télécharger l'application

#### Téléchargement recommandé (téléphone)

<a id="telechargement-direct-derniere-version"></a>
1. **Cliquez ici pour télécharger directement la dernière version** : [Télécharger le fichier d'installation (dernière version)](https://github.com/QuentinCAVIN/Projet-Violette/releases/latest/download/app-release.apk)  
2. Le téléphone va télécharger un fichier. Ouvrez la zone des notifications, ou l'app **Téléchargements** / **Fichiers** de votre téléphone, puis appuyez sur le fichier une fois le téléchargement terminé.  
3. Passez à la section [Installer l'application](#2-installer-lapplication) ci-dessous.

#### Téléchargement sur la page des versions (si vous voulez choisir une version précise)

1. Ouvrez la page : [https://github.com/QuentinCAVIN/Projet-Violette/releases](https://github.com/QuentinCAVIN/Projet-Violette/releases)  
2. **La version la plus récente est celle en haut de la page** (c'est celle qu'il faut en général).  
3. Sous le titre, faites défiler la page et repérez la section **Fichiers joints** (souvent appelée **Assets** en anglais sur le site) : c'est la liste de liens de téléchargement.  
4. Cliquez sur le **fichier d'installation** (souvent le seul gros lien de cette liste) pour lancer le téléchargement.  
5. Passez à la section [Installer l'application](#2-installer-lapplication) ci-dessous.

> Si vous avez un doute, utilisez de préférence le [téléchargement direct (dernière version)](#telechargement-direct-derniere-version).

### 2) Installer l'application

1. Ouvrez le **fichier d'installation** (depuis l'écran "Téléchargement terminé" ou via l'app **Fichiers** / **Téléchargements**).  
2. Si le téléphone affiche "Installation bloquée" ou "Source inconnue" : c'est **normal** la première fois. Ouvrez le message, puis suivez les boutons du type **Paramètres** / **Autoriser** / **Autoriser cette source** / **Revenir en arrière** pour reprendre l'installation.  
3. Lisez l'écran, puis validez **Installer**.  
4. Quand c'est fini, appuyez sur **Ouvrir** (ou ouvrez l'app **Violette** depuis l'écran d'accueil).  

> Si l'option "Mettre à jour" apparaît, acceptez : cela remplace l'ancienne version par la nouvelle, sans recréer votre compte.

### 3) Se connecter (premier lancement)

1. Ouvrez **Violette**.  
2. **Créez un compte** (si c'est la première fois) **ou** **connectez-vous** (si vous avez déjà un compte).  
3. Suivez les écrans pour compléter votre profil, puis indiquez si vous êtes **artiste** ou **gérant**.  
4. **Aucun réglage d'adresse n'est demandé** : l'application est déjà raccordée au service en ligne, vous n'avez rien à configurer.

### 4) Problèmes courants (simples)

- **L'installation est bloquée** : revenez à l'écran d'installation et acceptez d'**installer à partir d'une source autorisée** (navigateur, fichiers, e-mail) comme expliqué à l'étape 2.  
- **Le téléchargement n'avance pas / échoue** : essayez le [téléchargement direct (dernière version)](#telechargement-direct-derniere-version), repassez en Wi-Fi, ou testez le téléphone **et** l'ordinateur.  
- **Vous avez le fichier, mais "Impossible d'ouvrir"** : ouvrez le fichier depuis l'app **Fichiers** / **Téléchargements** (pas seulement depuis l'icône du navigateur).  
- **L'application ne s'ouvre pas / reste blanche** : redémarrez le téléphone, ouvrez **Violette** à nouveau, et si besoin [réinstallez la dernière version](#telechargement-direct-derniere-version).  
- **Vous n'arrivez pas à vous connecter** : vérifiez l'e-mail, le mot de passe, le Wi-Fi ou la connexion Internet (données mobiles), puis testez "mot de passe oublié" si c'est proposé.

### 5) Mettre à jour l'application

1. Téléchargez de nouveau le **fichier d'installation** (idéalement via le [téléchargement direct (dernière version)](#telechargement-direct-derniere-version)).  
2. Installez : Android propose en général **Mettre à jour** ou **Remplacer**.  
3. Ouvrez **Violette** et vérifiez que tout fonctionne.

> Vos identifiants et votre compte ne changent pas : la mise à jour ne vous oblige pas à tout refaire.

---

## → Documentation architecture & backend (module architecture logicielle)

La documentation technique backend reste détaillée dans le README du backend :

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
| **Règles métier** | Statuts, disponibilités, présélection, booking ferme | [docs/regles-metier.md](docs/regles-metier.md) |
| **Workflow de réservation** | Vue workflow et variantes futures | [docs/booking-workflow.md](docs/booking-workflow.md) |
| **Architecture globale** | Séparation Flutter / Quarkus / Firebase Auth, couches REST frontend | [docs/architecture.md](docs/architecture.md) |
| **Documentation C4** | Explication des diagrammes C4 (contexte, container, composants, zoom niveau 4) | [docs/architecture-c4.md](docs/architecture-c4.md) |
| **Guide de déploiement** | Fly.io, Aiven MySQL, pipeline CI/CD, secrets GitHub, checklist soutenance | [README-deploiement.md](README-deploiement.md) |
| **Migration domaine user** | Setup OpenAPI Generator, client Dart généré, flux REST user, adb reverse, dette résiduelle | [docs/migration-domaine-user.md](docs/migration-domaine-user.md) |
| **Stratégie de tests** | Tests frontend/backend, profils Quarkus, règles de migration REST | [docs/testing-strategy.md](docs/testing-strategy.md) |
| **Sécurité (OWASP Top 10)** | Couverture des 10 failles OWASP : mesures, preuves, limites assumées | [docs/securite-owasp.md](docs/securite-owasp.md) |
| **Accessibilité** | Référentiel WCAG 2.2 AA : choix, justification, périmètre et trajectoire | [docs/accessibilite.md](docs/accessibilite.md) |
| **Préparation v0.4.0** | Checklist documentaire, tests, tag, Swagger et APK | [docs/release-v0.4.0.md](docs/release-v0.4.0.md) |
| **Dette technique** | Limites assumées v0.4.0 et évolutions futures | [docs/technical-debt.md](docs/technical-debt.md) |
| **Changelog** | Historique des versions | [CHANGELOG.md](CHANGELOG.md) |

### Intégration continue et déploiement

Le pipeline GitHub Actions lance automatiquement les validations backend et frontend sur `main` et branches de travail. Le workflow principal construit l'image Docker backend et publie les artefacts de release sur tag.

Le déploiement en production (Fly.io) et la publication de l'APK Android sont déclenchés par un tag `v*.*.*`.

→ [.github/workflows/backend-ci.yml](.github/workflows/backend-ci.yml) — CI backend (tests + couverture)  
→ [.github/workflows/flutter-ci.yml](.github/workflows/flutter-ci.yml) — CI frontend (`flutter analyze` + `flutter test`)  
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

> Release visée : **v0.4.0**  
> Dernière version déployée connue : **v0.3.2**

### Front-end (Flutter)
- Application Flutter avec architecture Stacked.
- Authentification Firebase avec gestion des rôles (gérant / artiste).
- Création et gestion des dates de spectacle (ShowDate).
- Vue Planning gérant avec calendrier et gestion des disponibilités par artiste.
- Infrastructure de tests unitaires et intégration continue (GitHub Actions).
- **Migration Firestore → REST côté code métier** : les domaines `user`, `availability`, `showDate` et `booking` utilisent désormais l'API REST backend. Firebase Auth reste le fournisseur d'identité.

### Back-end (Quarkus)
- Monolithe modulaire structuré par domaine (`violetteuser`, `cabaretcompany`, `showdate`, `artistbooking`).
- Stack : Quarkus 3.x, Hibernate ORM Panache, Flyway (7 migrations), OpenAPI/Swagger, MapStruct.
- Schéma SQL relationnel complet pour les domaines métier migrés.
- Sécurité Firebase JWT via Quarkus OIDC (validée en production depuis v0.3.2), rôles métier (`ARTIST`, `MANAGER`) depuis la base backend.
- Endpoint de santé : `GET /api/ping` — Swagger UI : `http://localhost:8080/swagger-ui`
- Documentation API Swagger uniformisée en français (depuis v0.3.2).
- Tests backend H2 et intégration MySQL/Dev Services, couverture JaCoCo ≥ 30 %, CI GitHub Actions backend.
- Déployable en local via Docker Compose (MySQL 8 + Quarkus JVM).
- Déployé en production sur Fly.io (région Paris) avec base MySQL Aiven (depuis v0.3.1).
- Pipeline CI/CD GitHub Actions : build + tests + image Docker GHCR à chaque push ; déploiement Fly.io + APK Android sur tag `v*.*.*` (depuis v0.3.1).

## Stack technique

- Front : Flutter + Stacked + Firebase Auth + REST backend (`Dio`, remote data sources, repositories, mappers)
- Back : Quarkus (Java 21), MySQL / H2
- Client API généré : `violette_api_client/` — package Dart/Dio généré depuis la spec OpenAPI du backend (voir [openapitools.json](openapitools.json)). Aujourd'hui, le domaine `user` l'utilise directement ; les autres domaines REST passent par Dio et des mappers manuels.

## Lancement rapide

### 1. Backend local avec Firebase Auth

```powershell
cd violette-back
$env:FIREBASE_PROJECT_ID="violette-1f64e"
mvn quarkus:dev "-Dquarkus.profile=firebase"
```

Ce mode utilise H2 en mémoire : MySQL n'est pas nécessaire pour tester l'app Flutter avec JWT Firebase.

### 2. Téléphone Android physique en USB

```powershell
adb reverse tcp:8080 tcp:8080
cd violette_front
flutter pub get
flutter run
```

Le frontend utilise par défaut `http://127.0.0.1:8080`, ce qui fonctionne avec `adb reverse`.

### 3. Émulateur Android

```powershell
cd violette_front
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

### 4. Backend Fly.io

```powershell
cd violette_front
flutter run --dart-define=API_BASE_URL=https://violette-back.fly.dev
```

### 5. Tests

```powershell
cd violette-back
mvn verify

cd ../violette_front
flutter analyze
flutter test
```

## Variables principales

| Variable | Où | Rôle | Exemple |
|---|---|---|---|
| `API_BASE_URL` | Flutter `--dart-define` | URL de l'API REST utilisée par Dio | `https://violette-back.fly.dev` |
| `FIREBASE_PROJECT_ID` | Backend profil `firebase` | Project ID utilisé pour valider les JWT Firebase en local | `violette-1f64e` |
| `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD` | Backend profil `dev` | Connexion MySQL locale si le profil dev est utilisé | voir `violette-back/README.md` |
| `QUARKUS_DATASOURCE_*` | Fly.io | Connexion MySQL Aiven en production | voir `README-deploiement.md` |

## Scénarios courants

| Scénario | Commandes / documentation |
|---|---|
| Dev local téléphone USB | Backend `firebase`, puis `adb reverse`, puis `flutter run` |
| Dev local émulateur | `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080` |
| App mobile sur backend Fly.io | `flutter run --dart-define=API_BASE_URL=https://violette-back.fly.dev` |
| Build APK production | `flutter build apk --release --dart-define=API_BASE_URL=https://violette-back.fly.dev` |
| Déploiement release | Créer et pousser un tag `vX.Y.Z`, voir [README-deploiement.md](README-deploiement.md) |

Journal des versions : [CHANGELOG.md](CHANGELOG.md)