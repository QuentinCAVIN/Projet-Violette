# Architecture globale — Violette v0.4.0

Ce document résume l'architecture d'ensemble utilisée par Violette avant la release `v0.4.0`.

Pour le détail backend, voir [../violette-back/README.md](../violette-back/README.md). Pour les diagrammes C4, voir [architecture-c4.md](architecture-c4.md).

---

## Vue d'ensemble

```text
Flutter
  -> Firebase Auth
  -> JWT Firebase
  -> API REST Quarkus
  -> MySQL
```

| Couche | Technologie | Rôle |
|---|---|---|
| Frontend | Flutter + Stacked | UI mobile, ViewModels, navigation, état d'écran |
| Authentification | Firebase Auth | Création de compte, connexion, émission du JWT |
| API métier | Quarkus REST | Règles métier, sécurité par rôle, DTO REST |
| Persistance | MySQL + Hibernate ORM Panache | Source de vérité relationnelle |
| Migrations | Flyway | Versionnement du schéma SQL |
| Documentation API | SmallRye OpenAPI + Swagger UI | Contrat REST consultable et générable |

Firebase Auth est conservé uniquement pour l'identité. Les rôles, profils, disponibilités, dates de spectacle et bookings sont gérés par le backend.

---

## Monorepo

```text
Projet-Violette/
  README.md
  README-deploiement.md
  docs/
  violette-back/
  violette_front/
  violette_api_client/
```

| Dossier | Rôle |
|---|---|
| `violette-back/` | Backend Quarkus, entités, services, repositories, migrations Flyway |
| `violette_front/` | Application Flutter, ViewModels Stacked, repositories REST, mappers |
| `violette_api_client/` | Client Dart/Dio généré depuis OpenAPI |
| `docs/` | Documentation durable : architecture, règles métier, tests, workflow |

---

## Backend Quarkus

Le backend suit une architecture en couches par domaine :

```text
Controller -> Service -> Repository -> Base de données
     |          |
    DTO      Entity
     |
   Mapper
```

Principes :

- les contrôleurs exposent les endpoints REST et délèguent ;
- les services portent l'orchestration et les règles métier ;
- les repositories Panache sont la seule couche d'accès base ;
- les entités JPA ne sortent pas de la couche service ;
- les DTO sont le contrat d'API ;
- MapStruct est utilisé pour le mapping Entity ↔ DTO côté backend.

Domaines principaux :

- `violetteuser` : utilisateurs, rôles, compétences ;
- `showdate` : dates de spectacle, besoins artistiques, disponibilités ;
- `artistbooking` : sélection, demandes, réponses artistes ;
- `cabaretcompany` : compagnies, membres, revues.

---

## Frontend Flutter

Le frontend suit l'architecture Stacked :

```text
View -> ViewModel -> Repository -> RemoteDataSource -> Dio / client généré
                                      |
                                    Mapper
```

Principes :

- les vues restent centrées sur l'affichage ;
- les ViewModels orchestrent navigation, état écran et appels repositories ;
- les repositories exposent une interface métier au reste de l'application ;
- les remote data sources encapsulent les appels HTTP ;
- les mappers convertissent JSON/DTO API vers modèles Flutter.

---

## REST et client OpenAPI

Deux stratégies coexistent aujourd'hui :

| Domaine frontend | Accès API actuel |
|---|---|
| `user` | `violette_api_client` généré OpenAPI + `UserRemoteDataSource` + `UserMapper` (usage principal du client généré) |
| `showDate` | Dio manuel + `ShowDateRemoteDataSource` + `ShowDateMapper` |
| `availability` | Dio manuel + remote data source + mapper |
| `booking` | Dio manuel + `BookingRemoteDataSource` + `ArtistBookingMapper` |

Cette coexistence est volontaire à court terme. La règle d'architecture reste la même : les types générés ou JSON bruts ne doivent pas remonter dans les ViewModels.

En `v0.4.0`, les flux critiques `availability`, `showDate` et `booking` n'utilisent pas le client généré au runtime : ils passent par `DioClient`, des endpoints explicites et des mappers manuels. Les endpoints récents du domaine booking, dont `GET /api/artist-bookings/me`, sont donc appelés par Dio manuel.

La régénération complète de `violette_api_client/` est reportée après `v0.4.0` pour éviter un diff généré large juste avant tag. Une incohérence potentielle a été observée lors de l'audit : la méthode générée `apiArtistBookingsMeGet` peut être typée comme un DTO unique alors que le backend renvoie une liste. Cette dette n'est pas bloquante pour `v0.4.0`, car ce endpoint généré n'est pas utilisé par le code frontend exécuté.

À terme, chaque domaine peut soit adopter le client généré, soit conserver une couche Dio manuelle si elle reste mieux maîtrisée. Dans les deux cas, le repository et les mappers doivent rester la frontière métier.

---

## Configuration réseau frontend

Le frontend lit l'URL API via `--dart-define=API_BASE_URL=...`.

| Scénario | URL |
|---|---|
| Téléphone Android USB + `adb reverse` | `http://127.0.0.1:8080` |
| Émulateur Android | `http://10.0.2.2:8080` |
| Téléphone sur Wi-Fi | `http://<IP_locale_PC>:8080` |
| Production Fly.io | `https://violette-back.fly.dev` |

La valeur par défaut du code est `http://127.0.0.1:8080`.

---

## Sécurité

1. L'utilisateur se connecte dans Flutter via Firebase Auth.
2. Firebase fournit un ID token JWT.
3. `DioClient` ajoute `Authorization: Bearer <token>` aux requêtes.
4. Quarkus OIDC valide le token.
5. Le backend charge le profil Violette par `firebaseUid`.
6. Les rôles backend (`ARTIST`, `MANAGER`) enrichissent la `SecurityIdentity`.

Les rôles ne doivent pas être considérés comme une vérité côté Firebase custom claims : la base backend est la source de vérité des rôles métier.

---

## CI/CD

| Workflow | Rôle |
|---|---|
| `.github/workflows/backend-ci.yml` | Build backend, tests, ITs, JaCoCo sur `main`, `feature/**`, `refactor/**` |
| `.github/workflows/flutter-ci.yml` | `flutter analyze` et `flutter test` sur `main`, `feature/**` |
| `.github/workflows/deploy.yml` | Build image GHCR sur `main`, déploiement Fly.io + APK sur tag `v*.*.*` |

Le déploiement de production doit passer par un tag versionné.

---

## Sources de vérité

| Sujet | Document |
|---|---|
| Démarrage rapide et navigation | [../README.md](../README.md) |
| Frontend et `API_BASE_URL` | [../violette_front/README.md](../violette_front/README.md) |
| Backend Quarkus | [../violette-back/README.md](../violette-back/README.md) |
| Règles métier | [regles-metier.md](regles-metier.md) |
| Tests | [testing-strategy.md](testing-strategy.md) |
| Déploiement | [../README-deploiement.md](../README-deploiement.md) |
| Dette technique | [technical-debt.md](technical-debt.md) |
