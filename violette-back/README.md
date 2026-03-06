# Violette Backend

Backend REST de la plateforme **Violette**, conçu avec Java 21 et Quarkus.

---

## Table des matières

1. [Présentation du projet](#1-présentation-du-projet)
2. [Périmètre fonctionnel — V1](#2-périmètre-fonctionnel--v1)
3. [Stack technique](#3-stack-technique)
4. [Architecture backend](#4-architecture-backend)
5. [Organisation des packages](#5-organisation-des-packages)
6. [Lancer le projet en local](#6-lancer-le-projet-en-local)
7. [Configuration de la base de données](#7-configuration-de-la-base-de-données)
8. [Migrations Flyway](#8-migrations-flyway)
9. [Documentation API — Swagger](#9-documentation-api--swagger)
10. [Exécuter les tests](#10-exécuter-les-tests)
11. [Prochaines phases](#11-prochaines-phases)
12. [Manuel utilisateur](#12-manuel-utilisateur)

---

## 1. Présentation du projet

**Violette** est une plateforme de gestion de compagnies de cabaret (fixes ou itinérantes).  
Elle permet à des gérants et des artistes de coordonner les dates de spectacle, les disponibilités et les réservations d'artistes.

Ce backend est l'API REST centrale de la plateforme. Il remplace progressivement Firebase (Firestore + Auth) utilisé dans l'application Flutter existante.

L'authentification reste assurée par **Firebase Auth** côté frontend : le frontend obtient un JWT Firebase et l'envoie dans chaque requête. Le backend valide ce token et maintient sa propre base utilisateur (rôles, profils, données applicatives).

---

## 2. Périmètre fonctionnel — V1

### Domaines développés

| Domaine | Type DDD | Périmètre |
|---|---|---|
| `violetteuser` | Core | Gestion des utilisateurs (artistes, gérants), rôles, compétences artistiques |
| `cabaretcompany` | Supporting | Compagnies de cabaret, membres, revues (shows) |
| `showdate` | Core | Dates de spectacle, feuille de route, disponibilités artistes |
| `artistbooking` | Core | Réservation d'artistes, confirmation, historique des statuts |

### Hors périmètre V1

- Messagerie interne (`communication`)
- Partage de vidéos de répétition (`video`)
- Répartition des cachets

---

## 3. Stack technique

### Langage & Runtime

| Élément | Version |
|---|---|
| Java | 21 |
| Quarkus | 3.29.3 |

### Frameworks & Librairies

| Librairie | Rôle |
|---|---|
| `quarkus-rest` + `quarkus-rest-jackson` | Endpoints REST JAX-RS, sérialisation JSON Jackson |
| `quarkus-hibernate-orm-panache` | ORM Hibernate 6 avec le pattern Repository (Panache) |
| `quarkus-hibernate-validator` | Validation des DTOs (`@NotNull`, `@Size`, etc.) |
| `quarkus-flyway` | Migrations de schéma SQL versionnées |
| `quarkus-oidc` | Validation des JWT Firebase (Bearer token, OIDC) |
| `quarkus-security` | Annotations de sécurité (`@RolesAllowed`, `@Authenticated`) |
| `quarkus-smallrye-openapi` | Génération OpenAPI 3.0 + Swagger UI |
| `mapstruct` 1.6.3 | Mapping automatique Entity ↔ DTO |

### Dépendances externes

| Service | Rôle |
|---|---|
| **Firebase Auth** | Authentification des utilisateurs (frontend Flutter) |
| **MySQL 8+** | Base de données principale |

### Bases de données par environnement

| Environnement | Base de données |
|---|---|
| Dev / Prod | MySQL 8+ |
| Tests JUnit | H2 in-memory |

---

## 4. Architecture backend

### Principe général

Le backend est un **monolithe modulaire** découpé par domaine fonctionnel. Chaque domaine est autonome et peut évoluer vers un microservice indépendant.

### Couches par domaine

```
Controller  →  Service  →  Repository  →  Base de données
    ↓               ↓
   DTO           Model (Entity)
    ↕
  Mapper (MapStruct)
```

**Règles d'architecture :**
- Le `Controller` ne contient aucune logique métier. Il reçoit les requêtes HTTP, délègue au `Service` et retourne la réponse.
- Le `Service` contient toute la logique métier. Il utilise le `Repository` pour persister.
- Le `Repository` (Panache) est la seule couche qui accède à la base de données.
- Les `DTO` sont les objets d'entrée/sortie exposés via l'API. Les `Model` (entités JPA) ne sortent jamais du `Service`.

### Design Patterns

| Pattern | Type | Localisation | Problème résolu |
|---|---|---|---|
| **Builder** | Création | `showdate.builder.ShowDateBuilder` | `ShowDate` a 9+ champs dont optionnels. Le Builder garantit la construction d'objets valides en centralisant la validation des invariants (durée ≤ 12H, artistsCount > 0). |
| **Adapter** | Structure | `security.FirebaseTokenValidator` | Firebase émet des JWT OIDC mais encode les rôles applicatifs dans des custom claims. L'Adapter traduit ces claims vers le `SecurityIdentity` Quarkus standard. |
| **Observer (CDI Events)** | Comportement | `artistbooking.event.BookingStatusChangedEvent` | Quand un artiste refuse une réservation, la date doit libérer une place. Le `ArtistBookingService` fire un CDI Event ; le `ShowDateService` l'observe. Les domaines restent découplés. |

### Modélisation DDD

```
violetteuser
  Aggregate Root : VioletteUser
  Value Objects  : UserProfile, ArtistSkill

cabaretcompany
  Aggregate Root : CabaretCompany
  Entities       : Revue, CompanyMember

showdate
  Aggregate Root : ShowDate
  Value Objects  : TimeSlot (validation durée ≤ 12H), Fee
  Entities       : ArtistAvailability

artistbooking
  Aggregate Root : ArtistBooking
  Value Objects  : BookingTimeline (timestamps du cycle de vie)
```

---

## 5. Organisation des packages

```
io.violette
│
├── health/
│   └── PingResource.java                   ← Endpoint technique de santé
│
├── security/
│   ├── FirebaseTokenValidator.java         ← Adapter : JWT Firebase → SecurityIdentity
│   └── VioletteSecurityAugmentor.java      ← Enrichissement du contexte de sécurité
│
├── violetteuser/
│   ├── controller/VioletteUserController.java
│   ├── service/VioletteUserService.java
│   ├── repository/VioletteUserRepository.java
│   ├── model/
│   │   ├── VioletteUser.java               ← @Entity, Aggregate Root
│   │   ├── UserRole.java                   ← Enum : ARTIST, MANAGER
│   │   └── ArtistSkill.java                ← Enum : DANCE, SINGING, STILT_WALKING, ACROBATICS
│   └── dto/
│       ├── UserRegistrationDto.java
│       ├── UserResponseDto.java
│       └── UserUpdateDto.java
│
├── cabaretcompany/
│   ├── controller/CabaretCompanyController.java
│   ├── service/CabaretCompanyService.java
│   ├── repository/
│   │   ├── CabaretCompanyRepository.java
│   │   └── RevueRepository.java
│   ├── model/
│   │   ├── CabaretCompany.java             ← @Entity, Aggregate Root
│   │   └── CabaretShow.java                ← @Entity (Revue)
│   └── dto/
│       ├── CreateCompanyDto.java
│       ├── CompanyResponseDto.java
│       ├── CreateRevueDto.java
│       └── RevueResponseDto.java
│
├── showdate/
│   ├── controller/ShowDateController.java
│   ├── service/
│   │   ├── ShowDateService.java
│   │   └── ShowDateDomainService.java      ← Domain Service : transitions de statut
│   ├── repository/
│   │   ├── ShowDateRepository.java
│   │   └── ArtistAvailabilityRepository.java
│   ├── builder/ShowDateBuilder.java        ← Builder pattern
│   ├── model/
│   │   ├── ShowDate.java                   ← @Entity, Aggregate Root
│   │   ├── ArtistAvailability.java         ← @Entity (remplace la Map Firestore)
│   │   ├── TimeSlot.java                   ← @Embeddable, Value Object
│   │   ├── ShowDateStatus.java             ← Enum : PENDING, OPTIONAL, CONFIRMED, CANCELLED, LOCKED
│   │   └── AvailabilityStatus.java         ← Enum : PENDING, AVAILABLE, CONDITIONAL, UNAVAILABLE
│   └── dto/
│       ├── CreateShowDateDto.java
│       ├── ShowDateResponseDto.java
│       ├── ShowDateSummaryDto.java
│       └── UpdateAvailabilityDto.java
│
└── artistbooking/
    ├── controller/ArtistBookingController.java
    ├── service/
    │   ├── ArtistBookingService.java
    │   └── BookingDomainService.java       ← Domain Service : règles de réservation
    ├── repository/ArtistBookingRepository.java
    ├── event/BookingStatusChangedEvent.java ← Observer pattern (CDI Event)
    ├── model/
    │   ├── ArtistBooking.java              ← @Entity, Aggregate Root
    │   ├── BookingStatus.java              ← Enum : SELECTED, PENDING_CONFIRMATION, CONFIRMED, REFUSED
    │   └── BookingTimeline.java            ← @Embeddable, Value Object
    └── dto/
        ├── BookingResponseDto.java
        └── BookingStatusUpdateDto.java
```

---

## 6. Lancer le projet en local

### Prérequis

- Java 21
- Maven 3.9+
- MySQL 8+ en cours d'exécution (voir section 7)

### Mode développement (live reload)

```bash
./mvnw quarkus:dev
```

L'application démarre sur `http://localhost:8080`.

Vérification :

```bash
curl http://localhost:8080/api/ping
# {"status":"pong","version":"1.0.0"}
```

### Variables d'environnement (optionnel en dev)

Les valeurs par défaut du profil dev (`localhost:3306`, user `violette`, password `violette`) sont configurées dans `application.properties`. Pour les surcharger :

```bash
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=violette_db
export DB_USERNAME=violette
export DB_PASSWORD=violette

./mvnw quarkus:dev
```

---

## 7. Configuration de la base de données

### Création de la base MySQL

```sql
CREATE DATABASE violette_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'violette'@'localhost' IDENTIFIED BY 'violette';
GRANT ALL PRIVILEGES ON violette_db.* TO 'violette'@'localhost';
FLUSH PRIVILEGES;
```

### Via Docker (alternative rapide)

```bash
docker run -d \
  --name violette-mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=violette_db \
  -e MYSQL_USER=violette \
  -e MYSQL_PASSWORD=violette \
  -p 3306:3306 \
  mysql:8.0
```

---

## 8. Migrations Flyway

Flyway s'exécute **automatiquement au démarrage** de l'application (`quarkus.flyway.migrate-at-start=true`).

### Emplacement des scripts

```
src/main/resources/db/migration/
  V1__init.sql       ← Schéma initial complet (V1)
  V2__xxx.sql        ← Prochaines migrations (à venir)
```

### Convention de nommage

```
V<version>__<description_en_snake_case>.sql
```

Exemple : `V2__add_company_logo.sql`

### Exécuter manuellement (si nécessaire)

```bash
./mvnw flyway:migrate -Dflyway.url=jdbc:mysql://localhost:3306/violette_db \
  -Dflyway.user=violette -Dflyway.password=violette
```

---

## 9. Documentation API — Swagger

Une fois l'application démarrée :

| URL | Description |
|---|---|
| `http://localhost:8080/swagger-ui` | Interface Swagger UI interactive |
| `http://localhost:8080/q/openapi` | Spécification OpenAPI 3.0 (JSON/YAML) |

---

## 10. Exécuter les tests

```bash
# Tests unitaires et d'intégration (H2 in-memory, sans MySQL)
./mvnw test

# Tests d'intégration natifs (après build)
./mvnw verify
```

Les tests utilisent le profil `test` défini dans `src/test/resources/application.properties` :
- Base de données H2 in-memory
- Schéma généré automatiquement par Hibernate (`drop-and-create`)
- Flyway désactivé
- OIDC désactivé

---

## 11. Prochaines phases

### Phase 2 — Sécurité Firebase JWT

- `FirebaseTokenValidator.java` : validation des tokens Firebase via OIDC
- `VioletteSecurityAugmentor.java` : enrichissement du `SecurityIdentity` avec les rôles applicatifs
- Activation de `quarkus.oidc.enabled=true`
- Protection des endpoints avec `@RolesAllowed`

### Phase 3 — Domaine `violetteuser`

Génération complète du domaine :
- Entité `VioletteUser` + enums `UserRole`, `ArtistSkill`
- DTOs d'enregistrement et de réponse
- Service + Repository
- Controller REST (`POST /users`, `GET /users/{id}`, `PUT /users/{id}`)

### Phase 4 — Domaine `cabaretcompany`

- Entités `CabaretCompany`, `Revue`
- Gestion des membres de la compagnie
- Controller REST CRUD

### Phase 5 — Domaine `showdate`

- Entités `ShowDate`, `ArtistAvailability`
- Value Objects `TimeSlot`, `Fee` (avec validation métier)
- Builder pattern `ShowDateBuilder`
- Domain Service : transitions de statut, règle 12H
- Controller REST + endpoints de gestion des disponibilités

### Phase 6 — Domaine `artistbooking`

- Entité `ArtistBooking` + Value Object `BookingTimeline`
- CDI Events : `BookingStatusChangedEvent` (Observer pattern)
- Domain Service : règles de capacité, workflow de réservation
- Controller REST : sélection, confirmation, réponse artiste

---

## 12. Manuel utilisateur

### Description fonctionnelle

Violette permet à des compagnies de cabaret de gérer leurs spectacles de bout en bout.

**En tant que gérant :**
- Créer et gérer une compagnie de cabaret
- Ajouter des artistes à la compagnie
- Créer des revues (shows) associées à la compagnie
- Créer des dates de spectacle avec leur feuille de route (lieu, horaires, cachet, artistes requis)
- Consulter les disponibilités déclarées par les artistes
- Sélectionner les artistes disponibles et envoyer des demandes de confirmation
- Suivre l'état des réservations

**En tant qu'artiste :**
- Rejoindre une compagnie de cabaret
- Consulter les dates de spectacle à venir
- Déclarer sa disponibilité (disponible, incertain, indisponible) sur chaque date
- Répondre aux demandes de confirmation de réservation envoyées par le gérant

### Règles métier importantes

| Règle | Détail |
|---|---|
| Durée max d'une date | 12 heures (norme cachet d'intermittence) |
| Unicité de la réservation | Un artiste ne peut être réservé qu'une fois par date de spectacle |
| Capacité | Le nombre d'artistes réservés ne peut pas dépasser `required_artists_count` |
| Statuts d'une date | `PENDING` → `OPTIONAL` → `CONFIRMED` → `LOCKED` ou `CANCELLED` |
| Statuts d'une réservation | `SELECTED` → `PENDING_CONFIRMATION` → `CONFIRMED` ou `REFUSED` |
| Compagnie | Doit avoir au moins un gérant et au moins une revue |
