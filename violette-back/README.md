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


| Domaine          | Type DDD   | Périmètre                                                                    |
| ---------------- | ---------- | ---------------------------------------------------------------------------- |
| `violetteuser`   | Core       | Gestion des utilisateurs (artistes, gérants), rôles, compétences artistiques |
| `cabaretcompany` | Supporting | Compagnies de cabaret, membres, revues (shows)                               |
| `showdate`       | Core       | Dates de spectacle, feuille de route, disponibilités artistes                |
| `artistbooking`  | Core       | Réservation d'artistes, confirmation, historique des statuts                 |


### Hors périmètre V1

- Messagerie interne (`communication`)
- Partage de vidéos de répétition (`video`)
- Répartition des cachets

---

## 3. Stack technique

### Langage & Runtime


| Élément | Version |
| ------- | ------- |
| Java    | 21      |
| Quarkus | 3.29.3  |


### Frameworks & Librairies


| Librairie                               | Rôle                                                        |
| --------------------------------------- | ----------------------------------------------------------- |
| `quarkus-rest` + `quarkus-rest-jackson` | Endpoints REST JAX-RS, sérialisation JSON Jackson           |
| `quarkus-hibernate-orm-panache`         | ORM Hibernate 6 avec le pattern Repository (Panache)        |
| `quarkus-hibernate-validator`           | Validation des DTOs (`@NotNull`, `@Size`, etc.)             |
| `quarkus-flyway`                        | Migrations de schéma SQL versionnées                        |
| `quarkus-oidc`                          | Validation des JWT Firebase (Bearer token, OIDC)            |
| `quarkus-security`                      | Annotations de sécurité (`@RolesAllowed`, `@Authenticated`) |
| `quarkus-smallrye-openapi`              | Génération OpenAPI 3.0 + Swagger UI                         |
| `mapstruct` 1.6.3                       | Mapping automatique Entity ↔ DTO                            |


### Dépendances externes


| Service           | Rôle                                                 |
| ----------------- | ---------------------------------------------------- |
| **Firebase Auth** | Authentification des utilisateurs (frontend Flutter) |
| **MySQL 8+**      | Base de données principale                           |


### Bases de données par environnement


| Environnement | Base de données |
| ------------- | --------------- |
| Dev / Prod    | MySQL 8+        |
| Tests JUnit   | H2 in-memory    |


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


| Pattern                      | Type      | Localisation                                                     | Problème résolu                                                                                                                                                                                                                                               |
| ---------------------------- | --------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Adapter / Enrichissement** | Structure | `security.VioletteSecurityAugmentor` + `VioletteRolesAugmentor` | Firebase fournit l'identité (JWT validé par OIDC). Les rôles métier (ARTIST, MANAGER) viennent de la base Violette et sont injectés dans la `SecurityIdentity` via un `SecurityIdentityAugmentor`, afin que `@RolesAllowed("MANAGER")` fonctionne au runtime. |


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
  Entities       : ShowDateSkillRequirement, ArtistAvailability
  Value Objects  : ArtistAvailabilityId (clé composite)

artistbooking (à venir)
  Aggregate Root : ArtistBooking
  Value Objects  : BookingTimeline (timestamps du cycle de vie)
```

---

## 5. Organisation des packages

```
io.violette
│
├── health/
│   └── PingResource.java                        ← Endpoint technique de santé
│
├── security/
│   ├── CurrentUserContextProvider.java          ← Principal JWT → JwtPrincipalInfo (contexte métier)
│   ├── JwtPrincipalExtractor.java               ← Extraction des claims JWT (sub, email, name)
│   ├── JwtPrincipalInfo.java                    ← Record : firebaseUid, email, name
│   ├── VioletteSecurityAugmentor.java           ← SecurityIdentityAugmentor : branche les rôles backend
│   └── VioletteRolesAugmentor.java              ← Charge les rôles depuis la BDD et les ajoute à l'identité
│
├── violetteuser/
│   ├── controller/VioletteUserController.java
│   ├── service/VioletteUserService.java
│   ├── repository/VioletteUserRepository.java
│   ├── model/
│   │   ├── VioletteUserEntity.java              ← @Entity, Aggregate Root
│   │   ├── UserRole.java                        ← Enum : ARTIST, MANAGER
│   │   └── ArtistSkill.java                     ← Enum : DANCE, SINGING, STILT_WALKING, ACROBATICS
│   ├── dto/
│   │   ├── VioletteUserDto.java
│   │   ├── AuthenticatedUserDto.java
│   │   └── CreateUserRequestDto.java
│   ├── mapper/
│   │   └── VioletteUserMapper.java
│   └── exception/
│       ├── UserAlreadyExistsException.java
│       ├── UserNotFoundException.java
│       └── mapper/
│           ├── UserExceptionMapper.java          (409 Conflict)
│           └── UserNotFoundExceptionMapper.java  (404 Not Found)
│
├── cabaretcompany/
│   ├── controller/CabaretCompanyController.java
│   ├── service/
│   │   ├── CabaretCompanyService.java
│   │   └── CabaretShowService.java
│   ├── repository/
│   │   ├── CabaretCompanyRepository.java
│   │   ├── CabaretShowRepository.java
│   │   └── CompanyMemberRepository.java
│   ├── model/
│   │   ├── CabaretCompanyEntity.java            ← @Entity, Aggregate Root
│   │   ├── CabaretShowEntity.java               ← @Entity (Revue, table : revue)
│   │   ├── CompanyMemberEntity.java             ← @Entity, clé composite
│   │   └── CompanyMemberId.java                 ← @Embeddable, clé composite (companyId, artistId)
│   ├── dto/
│   │   ├── CabaretCompanyDto.java
│   │   ├── CabaretShowDto.java
│   │   ├── CompanyMemberDto.java
│   │   ├── CreateCabaretCompanyRequestDto.java
│   │   └── CreateCabaretShowRequestDto.java
│   ├── mapper/
│   │   ├── CabaretCompanyMapper.java
│   │   ├── CabaretShowMapper.java
│   │   └── CompanyMemberMapper.java
│   └── exception/
│       ├── CabaretCompanyNotFoundException.java
│       ├── CabaretShowNotFoundException.java
│       └── mapper/
│           ├── CabaretCompanyNotFoundExceptionMapper.java  (404 Not Found)
│           └── CabaretShowNotFoundExceptionMapper.java     (404 Not Found)
│
├── showdate/
│   ├── controller/ShowDateController.java
│   ├── service/ShowDateService.java
│   ├── repository/
│   │   ├── ShowDateRepository.java
│   │   ├── ShowDateSkillRequirementRepository.java
│   │   └── ArtistAvailabilityRepository.java
│   ├── model/
│   │   ├── ShowDateEntity.java                  ← @Entity, Aggregate Root
│   │   ├── ShowDateSkillRequirementEntity.java  ← @Entity (besoin par compétence)
│   │   ├── ArtistAvailabilityEntity.java        ← @Entity (disponibilité artiste)
│   │   ├── ArtistAvailabilityId.java            ← @Embeddable, clé composite (showDateId, artistId)
│   │   ├── ShowDateStatus.java                  ← Enum : PENDING, OPTIONAL, CONFIRMED, LOCKED, CANCELLED
│   │   └── AvailabilityStatus.java              ← Enum : PENDING, AVAILABLE, CONDITIONAL, UNAVAILABLE
│   ├── dto/
│   │   ├── ShowDateDto.java
│   │   ├── CreateShowDateRequestDto.java
│   │   ├── ShowDateSkillRequirementDto.java
│   │   ├── CreateSkillRequirementRequestDto.java
│   │   └── ArtistAvailabilityDto.java
│   ├── mapper/
│   │   ├── ShowDateMapper.java
│   │   ├── ShowDateSkillRequirementMapper.java
│   │   └── ArtistAvailabilityMapper.java
│   └── exception/
│       ├── ShowDateNotFoundException.java
│       └── mapper/
│           └── ShowDateNotFoundExceptionMapper.java  (404 Not Found)
│
└── artistbooking/
    ├── controller/ArtistBookingController.java
    ├── service/ArtistBookingService.java
    ├── repository/ArtistBookingRepository.java
    ├── model/
    │   ├── ArtistBookingEntity.java             ← @Entity, Aggregate Root
    │   ├── BookingStatus.java                   ← Enum : SELECTED, PENDING_CONFIRMATION, CONFIRMED, REFUSED, CANCELLED
    │   └── BookingTimeline.java                 ← @Embeddable, Value Object (timestamps du cycle de vie)
    ├── dto/
    │   ├── ArtistBookingDto.java
    │   ├── CreateBookingRequestDto.java
    │   └── RespondToBookingRequestDto.java
    ├── mapper/
    │   └── ArtistBookingMapper.java
    └── exception/
        ├── ArtistBookingNotFoundException.java
        ├── ArtistNotAvailableException.java
        ├── BookingAlreadyExistsException.java
        ├── BookingCapacityExceededException.java
        ├── InvalidBookingTransitionException.java
        ├── ShowDateNotModifiableException.java
        ├── SkillRequirementNotFoundException.java
        └── mapper/
            ├── ArtistBookingNotFoundExceptionMapper.java     (404 Not Found)
            ├── ArtistNotAvailableExceptionMapper.java        (409 Conflict)
            ├── BookingAlreadyExistsExceptionMapper.java      (409 Conflict)
            ├── BookingCapacityExceededExceptionMapper.java   (409 Conflict)
            ├── InvalidBookingTransitionExceptionMapper.java  (409 Conflict)
            ├── ShowDateNotModifiableExceptionMapper.java     (409 Conflict)
            └── SkillRequirementNotFoundExceptionMapper.java  (404 Not Found)
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
# {"status":"pong","version":"0.1.0"}
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

### Profil Firebase et authentification JWT

Par défaut, OIDC est **désactivé** (`quarkus.oidc.enabled=false`). Les endpoints protégés (`/api/users/me`, `POST /api/users`) répondent alors **403**. Pour valider les JWT Firebase en local, activez le profil **firebase** et définissez le Project ID Firebase.

#### Variables d'environnement


| Variable              | Obligatoire (profil firebase) | Rôle                                                                                                                                                                       |
| --------------------- | ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `FIREBASE_PROJECT_ID` | Oui                           | ID du projet Firebase (ex. `violette-1f64e`). Utilisé pour l'URL du serveur OIDC, l'issuer et l'audience du token. Ce n'est pas un secret mais il doit rester externalisé. |


#### Rôle du profil `firebase`

Le fichier `application-firebase.properties` est chargé lorsque le profil `firebase` est actif. Il active OIDC et configure la validation des tokens Firebase (issuer, audience, auth-server-url). Il force aussi une **datasource H2 en mémoire** : aucun MySQL n'est requis pour lancer le backend en local avec Firebase. Sans ce profil, le backend utilise la config par défaut (OIDC désactivé, MySQL).

#### Différence entre `-Dquarkus.profile=firebase` et `QUARKUS_PROFILE=firebase`

- `**-Dquarkus.profile=firebase`** : option Maven/JVM passée au lancement (ex. `mvn quarkus:dev -Dquarkus.profile=firebase`). Le profil est actif pour cette exécution.
- `**QUARKUS_PROFILE=firebase**` : variable d'environnement reconnue par Quarkus au démarrage. Même effet que `-Dquarkus.profile=firebase` si vous définissez la variable avant de lancer.

Les deux peuvent être utilisés. Sous Windows PowerShell, l'option `-D` doit être entre guillemets si elle contient un `=` pour éviter que le shell ne découpe l'argument.

#### Lancement local avec Firebase

**Windows (PowerShell)** :

```powershell
# Définir le Project ID (obligatoire pour le profil firebase)
$env:FIREBASE_PROJECT_ID="q"

# Option 1 : profil via variable d'environnement
$env:QUARKUS_PROFILE="firebase"
mvn quarkus:dev

# Option 2 : profil via option Maven (depuis le répertoire violette-back)
mvn quarkus:dev "-Dquarkus.profile=firebase"
```

**Linux / macOS** :

```bash
export FIREBASE_PROJECT_ID="violette-1f64e"
export QUARKUS_PROFILE="firebase"
./mvnw quarkus:dev
```

Alternative avec option Maven :

```bash
export FIREBASE_PROJECT_ID="violette-1f64e"
./mvnw quarkus:dev -Dquarkus.profile=firebase
```

Avec le profil `firebase`, la base est déjà H2 en mémoire : **MySQL n'est pas nécessaire** pour tester l'authentification et les endpoints utilisateur en local.

#### Tester l'API sécurisée

Une fois le backend lancé avec le profil firebase (`FIREBASE_PROJECT_ID` défini), utilisez un JWT Firebase valide (obtenu côté client Flutter ou via la console Firebase).

**GET /api/users/me** (contexte utilisateur depuis le JWT) :

```bash
curl -H "Authorization: Bearer VOTRE_JWT_FIREBASE" http://localhost:8080/api/users/me
```

- Avec token valide : **200** et JSON `{"firebaseUid":"...","email":"...","name":"..."}`.
- Sans header `Authorization` ou token invalide : **401** ou **403**.

**POST /api/users** (création du profil backend) :

```bash
curl -X POST -H "Authorization: Bearer VOTRE_JWT_FIREBASE" \
  -H "Content-Type: application/json" \
  http://localhost:8080/api/users \
  -d '{"firstName":"Jean","lastName":"Dupont"}'
```

- Création réussie : **201** et JSON utilisateur (id, firebaseUid, email, firstName, lastName, roles, etc.).
- Utilisateur déjà existant (même firebaseUid ou email) : **409 Conflict**.
- Body invalide (ex. firstName manquant) : **400 Bad Request**.
- Sans token : **401** ou **403**.

#### Rôles métier et sécurité par rôle

- **Firebase fournit l'identité** : le JWT est validé par Quarkus OIDC ; le principal (claim `sub`) identifie l'utilisateur.
- **La base backend Violette fournit les rôles** : la source de vérité des rôles (ARTIST, MANAGER) est la table `violette_user` / `user_role`, pas les custom claims Firebase.
- **Mécanisme d'enrichissement** : après validation du JWT, un `SecurityIdentityAugmentor` (`VioletteSecurityAugmentor`) récupère le `firebaseUid` (claim `sub`), charge l'utilisateur en base via `VioletteUserRepository`, et ajoute ses rôles à la `SecurityIdentity`. Les annotations `@RolesAllowed("MANAGER")` deviennent ainsi effectives.
- **Endpoints concernés** :
  - `GET /api/users/me` et `POST /api/users` : tout utilisateur **authentifié** (JWT valide).
  - `GET /api/users/{id}`, `GET /api/users/by-firebase/{firebaseUid}`, `GET /api/users?page=&size=` : **MANAGER** uniquement (403 si l'utilisateur n'a pas le rôle MANAGER en base).

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

### Console H2 (profils dev et firebase)

Lorsque le backend tourne avec une base H2 en mémoire (profil `dev` ou `firebase`), la **console web H2** permet de faire des ajustements manuels (lecture, INSERT, etc.).

1. Lancer l’application avec le profil concerné : `./mvnw quarkus:dev` (profil dev) ou avec `-Dquarkus.profile=firebase`.
2. Ouvrir dans le navigateur : **[http://localhost:8080/h2/](http://localhost:8080/h2/)**.
3. Se connecter avec :
  - **JDBC URL** : `jdbc:h2:mem:violette_dev;DB_CLOSE_DELAY=-1` (profil dev) ou `jdbc:h2:mem:violette_firebase;DB_CLOSE_DELAY=-1` (profil firebase) ;
  - **User** : `sa` ;
  - **Password** : (laisser vide).
4. Cliquer sur **Connect** puis exécuter du SQL (ex. `SELECT * FROM violette_user ;`).

---

## 8. Migrations Flyway

Flyway s'exécute **automatiquement au démarrage** de l'application (`quarkus.flyway.migrate-at-start=true`).

### Emplacement des scripts

```
src/main/resources/db/migration/
  V1__init.sql                        ← Schéma initial : violette_user, user_role, artist_skill, cabaret_company, company_member, revue
  V2__refactor_user_roles.sql         ← Refactoring des tables de rôles utilisateur
  V3__cabaretcompany_add_updated_at.sql ← Ajout de la colonne updated_at sur cabaret_company
  V4__create_showdate_tables.sql      ← Tables show_date, show_date_skill_requirement, artist_availability (domaine showdate)
  V5__create_artist_booking_table.sql ← Table artist_booking (domaine artistbooking)
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


| URL                                | Description                           |
| ---------------------------------- | ------------------------------------- |
| `http://localhost:8080/swagger-ui` | Interface Swagger UI interactive      |
| `http://localhost:8080/q/openapi`  | Spécification OpenAPI 3.0 (JSON/YAML) |


### Appel à GET /api/users/me (protégé par JWT)

L'endpoint retourne le contexte utilisateur authentifié (firebaseUid, email, name) extrait du JWT.  
Pour activer la validation Firebase : profil `firebase` et variable `FIREBASE_PROJECT_ID` (voir `application-firebase.properties` et [docs/testing-and-security.md](docs/testing-and-security.md)).

```bash
export FIREBASE_PROJECT_ID=your-firebase-project-id
./mvnw quarkus:dev -Dquarkus.profile=firebase
# Puis, avec un token Firebase :
curl -s -H "Authorization: Bearer YOUR_FIREBASE_JWT" http://localhost:8080/api/users/me
```

Exemple de réponse (200) : `{"firebaseUid":"abc123","email":"user@example.com","name":"Jean Dupont"}`.  
Sans token ou token invalide : 401 ou 403.

---

## 10. Exécuter les tests

```bash
# Tests unitaires et d'intégration (H2 in-memory, sans MySQL)
./mvnw test

# Tests d'intégration natifs (après build)
./mvnw verify
```

Si `mvn clean test` échoue (résolution du bean MapStruct `VioletteUserMapper`), exécuter d'abord `mvn compile` puis `mvn test`, ou lancer `mvn clean install -DskipTests` puis `mvn test`.

### Tests automatiques liés à la sécurité par rôle

- `**VioletteRolesAugmentorTest**` : vérifie que l'augmentor charge les rôles depuis la base et les ajoute à la `SecurityIdentity` (utilisateur avec MANAGER → identité a le rôle MANAGER ; utilisateur avec ARTIST uniquement → identité a ARTIST mais pas MANAGER ; utilisateur absent de la base → aucun rôle ajouté).
- Les tests de controller et de service existants ne simulent pas un JWT Firebase ; en profil test OIDC est désactivé. La chaîne complète (JWT → OIDC → augmentor → @RolesAllowed) doit être vérifiée manuellement avec le profil `firebase`.

### Vérifications manuelles (profil firebase)

Pour confirmer que `@RolesAllowed("MANAGER")` fonctionne en conditions réelles :

1. Lancer le backend avec le profil `firebase` et un `FIREBASE_PROJECT_ID` valide.
2. Créer en base (ou via `POST /api/users`) un utilisateur avec le rôle **MANAGER**, dont le `firebase_uid` correspond au `sub` du JWT que vous utiliserez.
3. Avec un token Firebase de cet utilisateur MANAGER : appeler `GET /api/users`, `GET /api/users/{id}` ou `GET /api/users/by-firebase/{firebaseUid}` → **200** attendu.
4. Avec un token Firebase d'un utilisateur ayant uniquement le rôle **ARTIST** (ou pas encore de profil en base) : appeler les mêmes endpoints → **403 Forbidden** attendu.

Les tests utilisent le profil `test` défini dans `src/test/resources/application.properties` :

- Base de données H2 in-memory
- Schéma généré automatiquement par Hibernate (`drop-and-create`)
- Flyway désactivé
- OIDC désactivé

---

## 11. Prochaines phases

### Phase 2 — Sécurité Firebase JWT (en place)

- OIDC activé avec le profil `firebase` ; validation des tokens Firebase (issuer, audience).
- `VioletteSecurityAugmentor` + `VioletteRolesAugmentor` : enrichissement de la `SecurityIdentity` avec les rôles chargés depuis la base Violette (ARTIST, MANAGER).
- Endpoints protégés : `@Authenticated` pour `/me` et `POST /users` ; `@RolesAllowed("MANAGER")` pour les GET de lecture utilisateur.

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

### Phase 5 — Domaine `showdate` ✓ (implémenté)

- Entités `ShowDateEntity` (aggregate root), `ShowDateSkillRequirementEntity`, `ArtistAvailabilityEntity`
- Feuille de route logistique : `eventDate`, `meetingTime`, `venueName`, `address`, contacts client
- Besoins artistiques par compétence : `skill`, `requiredCount`, `netFee` (montant net en `BigDecimal`)
- Disponibilités artistes avec clé composite `(show_date_id, artist_id)`
- Controller REST : 6 endpoints, sécurisés `@RolesAllowed("MANAGER")`
- Migration Flyway V4 : refonte `show_date`, création `show_date_skill_requirement`, restructuration `artist_availability`

### Phase 6 — Domaine `artistbooking` ✓ (implémenté)

- Entité `ArtistBookingEntity` + Value Object `BookingTimeline` (@Embeddable)
- `BookingStatus` : `SELECTED → PENDING_CONFIRMATION → CONFIRMED | REFUSED | CANCELLED`
- Règles métier : capacité par compétence, disponibilité artiste, unicité de réservation
- Controller REST : sélection, déselection, envoi des confirmations, réponse artiste, consultation

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


| Règle                      | Détail                                                                                         |
| -------------------------- | ---------------------------------------------------------------------------------------------- |
| Unicité de disponibilité   | Un artiste ne peut déclarer qu'une seule disponibilité par date (clé composite show_date/artist) |
| Unicité de la réservation  | Un artiste ne peut être réservé qu'une fois par date de spectacle (domaine `artistbooking`)    |
| Statuts d'une date         | `PENDING` → `OPTIONAL` → `CONFIRMED` → `LOCKED` ou `CANCELLED`                                |
| Statuts d'une disponibilité| `PENDING` → `AVAILABLE` ou `CONDITIONAL` ou `UNAVAILABLE`                                     |
| Statuts d'une réservation  | `SELECTED` → `PENDING_CONFIRMATION` → `CONFIRMED` ou `REFUSED` (domaine `artistbooking`)      |
| Compagnie                  | Doit avoir au moins un gérant                                                                  |


