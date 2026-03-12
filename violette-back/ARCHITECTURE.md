# Architecture Backend — Violette

## Vue d'ensemble

Le backend Violette est un **monolithe modulaire** construit avec Quarkus 3.x.
Il remplace progressivement Firebase comme source de vérité pour les données métier.

### Stack technique

| Couche           | Technologie                              |
|------------------|------------------------------------------|
| Langage          | Java 21                                  |
| Framework        | Quarkus 3.x                              |
| ORM              | Hibernate ORM 6 + Panache                |
| Base principale  | MySQL 8+                                 |
| Migrations       | Flyway (`src/main/resources/db/migration/`) |
| Validation       | Hibernate Validator                      |
| API Docs         | SmallRye OpenAPI + Swagger UI (`/swagger-ui`) |
| Sécurité         | OIDC (Firebase JWT en Bearer token)      |
| Tests            | H2 in-memory (Flyway désactivé en test)  |
| Mapping          | MapStruct (Entity ↔ DTO)                 |
| Logging          | SLF4J                                    |

---

## Architecture en couches

```
HTTP Request
     │
     ▼
┌─────────────┐
│  Controller │  ← HTTP uniquement : routing, validation de la forme, délégation
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Service   │  ← Logique métier, orchestration, gestion des cas fonctionnels
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Repository  │  ← Accès aux données, aucune logique métier (Panache)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Database   │  ← MySQL (prod) / H2 (tests)
└─────────────┘
```

### Responsabilités détaillées

#### Controller
- Reçoit les requêtes HTTP et extrait les paramètres (path, query, body)
- Valide la **forme** des entrées (`@Valid`, contraintes Jakarta)
- Délègue **toute la logique** au Service
- Retourne une réponse HTTP (`Response`) avec le DTO approprié
- Ne contient **aucune logique métier**
- Ne lit jamais directement le repository
- Gère uniquement le contexte sécurité HTTP (via `CurrentUserContextProvider`)

#### Service
- Contient toute la **logique applicative**
- Orchestre les appels repository et les transformations de données
- Gère les cas fonctionnels : utilisateur déjà existant, entité introuvable…
- Lance les **exceptions métier** (`UserAlreadyExistsException`, `UserNotFoundException`)
- Utilise le mapper pour convertir Entity ↔ DTO
- Ne retourne **jamais** d'entités JPA — uniquement des DTOs

#### Repository
- **Seule** couche autorisée à accéder à la base de données
- Étend `PanacheRepository<Entity>` (Hibernate/Panache)
- Expose des requêtes nommées ou JPQL personnalisées
- Aucune logique métier, aucune manipulation de DTO

---

## Organisation des packages

```
io.violette
 ├── health/                      ← Endpoints techniques (ping, liveness)
 ├── security/                    ← Infrastructure sécurité JWT Firebase
 │    ├── VioletteSecurityAugmentor.java   (SecurityIdentityAugmentor Quarkus)
 │    ├── VioletteRolesAugmentor.java      (chargement des rôles depuis la BDD)
 │    ├── CurrentUserContextProvider.java  (extraction du principal courant)
 │    ├── JwtPrincipalExtractor.java       (extraction des claims JWT)
 │    └── JwtPrincipalInfo.java            (record : firebaseUid, email, name)
 ├── violetteuser/                ← Domaine métier : utilisateurs (modèle de référence)
 │    ├── controller/              ← VioletteUserController.java
 │    ├── service/                 ← VioletteUserService.java
 │    ├── repository/              ← VioletteUserRepository.java
 │    ├── model/                   ← VioletteUserEntity.java, UserRole.java, ArtistSkill.java
 │    ├── dto/                     ← VioletteUserDto.java, CreateUserRequestDto.java, AuthenticatedUserDto.java
 │    ├── mapper/                  ← VioletteUserMapper.java (MapStruct)
 │    └── exception/
 │         ├── UserAlreadyExistsException.java
 │         ├── UserNotFoundException.java
 │         └── mapper/
 │              ├── UserExceptionMapper.java         (409 Conflict)
 │              └── UserNotFoundExceptionMapper.java (404 Not Found)
 ├── cabaretcompany/              ← Domaine : compagnies, revues, membres
 │    ├── controller/              ← CabaretCompanyController.java
 │    ├── service/                 ← CabaretCompanyService.java, CabaretShowService.java
 │    ├── repository/              ← CabaretCompanyRepository.java, CabaretShowRepository.java, CompanyMemberRepository.java
 │    ├── model/                   ← CabaretCompanyEntity.java, CabaretShowEntity.java
 │    │                               CompanyMemberEntity.java, CompanyMemberId.java (@Embeddable, clé composite)
 │    ├── dto/                     ← CabaretCompanyDto.java, CabaretShowDto.java, CompanyMemberDto.java
 │    │                               CreateCabaretCompanyRequestDto.java, CreateCabaretShowRequestDto.java
 │    ├── mapper/                  ← CabaretCompanyMapper.java, CabaretShowMapper.java, CompanyMemberMapper.java
 │    └── exception/
 │         ├── CabaretCompanyNotFoundException.java
 │         ├── CabaretShowNotFoundException.java
 │         └── mapper/
 │              ├── CabaretCompanyNotFoundExceptionMapper.java    (404 Not Found)
 │              └── CabaretShowNotFoundExceptionMapper.java       (404 Not Found)
 ├── showdate/                    ← Domaine : dates de spectacle, feuille de route, disponibilités
 │    ├── controller/              ← ShowDateController.java
 │    ├── service/                 ← ShowDateService.java
 │    ├── repository/              ← ShowDateRepository.java, ShowDateSkillRequirementRepository.java, ArtistAvailabilityRepository.java
 │    ├── model/                   ← ShowDateEntity.java, ShowDateSkillRequirementEntity.java
 │    │                               ArtistAvailabilityEntity.java, ArtistAvailabilityId.java (@Embeddable, clé composite)
 │    │                               ShowDateStatus.java, AvailabilityStatus.java
 │    ├── dto/                     ← ShowDateDto.java, CreateShowDateRequestDto.java
 │    │                               ShowDateSkillRequirementDto.java, CreateSkillRequirementRequestDto.java
 │    │                               ArtistAvailabilityDto.java
 │    ├── mapper/                  ← ShowDateMapper.java, ShowDateSkillRequirementMapper.java, ArtistAvailabilityMapper.java
 │    └── exception/
 │         ├── ShowDateNotFoundException.java
 │         └── mapper/ShowDateNotFoundExceptionMapper.java  (404 Not Found)
 └── artistbooking/               ← Domaine : réservations artistes, workflow de confirmation
      ├── controller/              ← ArtistBookingController.java
      ├── service/                 ← ArtistBookingService.java
      ├── repository/              ← ArtistBookingRepository.java
      ├── model/                   ← ArtistBookingEntity.java, BookingStatus.java
      │                               BookingTimeline.java (@Embeddable, Value Object)
      ├── dto/                     ← ArtistBookingDto.java, CreateBookingRequestDto.java
      │                               RespondToBookingRequestDto.java
      ├── mapper/                  ← ArtistBookingMapper.java (MapStruct)
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

**Règle de nommage pour les nouveaux domaines :**
```
io.violette.<domain>.{controller, service, repository, model, dto, mapper, exception}
```

---

## Flux typique d'une requête

### Exemple : `POST /api/users`

```
1. HTTP POST /api/users  (Bearer token Firebase)
       │
       ▼
2. Quarkus OIDC valide le JWT Firebase
       │
       ▼
3. VioletteSecurityAugmentor.augment()
       └── VioletteRolesAugmentor.augment()
            └── charge les rôles depuis la BDD → SecurityIdentity enrichie
       │
       ▼
4. VioletteUserController.createUser(@Valid CreateUserRequestDto)
       └── currentUserContextProvider.getCurrentPrincipal()  → JwtPrincipalInfo
       └── violetteUserService.createUser(principal, request)
       │
       ▼
5. VioletteUserService.createUser()
       ├── vérifie l'unicité (firebaseUid, email) → UserAlreadyExistsException si doublon
       ├── construit VioletteUserEntity
       └── violetteUserRepository.persist(entity)
       │
       ▼
6. VioletteUserMapper.toDto(entity)
       │
       ▼
7. Response 201 Created  { VioletteUserDto }
```

---

## Gestion des erreurs

### Principe

Les erreurs métier remontent via des **exceptions spécialisées**, jamais via des `Response` construites dans le Service.

```
Service
  └── throw UserAlreadyExistsException()
         │
         ▼
  UserExceptionMapper (jakarta.ws.rs.ext.ExceptionMapper)
         │
         ▼
  Response 409 Conflict  { message }
```

### Mappers d'exceptions actuels

| Exception                           | Mapper                                    | Code HTTP        |
|-------------------------------------|-------------------------------------------|------------------|
| `UserAlreadyExistsException`        | `UserExceptionMapper`                     | `409 Conflict`   |
| `UserNotFoundException`             | `UserNotFoundExceptionMapper`             | `404 Not Found`  |
| `CabaretCompanyNotFoundException`   | `CabaretCompanyNotFoundExceptionMapper`   | `404 Not Found`  |
| `CabaretShowNotFoundException`      | `CabaretShowNotFoundExceptionMapper`      | `404 Not Found`  |
| `ShowDateNotFoundException`         | `ShowDateNotFoundExceptionMapper`         | `404 Not Found`  |
| `ArtistBookingNotFoundException`    | `ArtistBookingNotFoundExceptionMapper`    | `404 Not Found`  |
| `SkillRequirementNotFoundException` | `SkillRequirementNotFoundExceptionMapper` | `404 Not Found`  |
| `ArtistNotAvailableException`       | `ArtistNotAvailableExceptionMapper`       | `409 Conflict`   |
| `BookingAlreadyExistsException`     | `BookingAlreadyExistsExceptionMapper`     | `409 Conflict`   |
| `BookingCapacityExceededException`  | `BookingCapacityExceededExceptionMapper`  | `409 Conflict`   |
| `InvalidBookingTransitionException` | `InvalidBookingTransitionExceptionMapper` | `409 Conflict`   |
| `ShowDateNotModifiableException`    | `ShowDateNotModifiableExceptionMapper`    | `409 Conflict`   |

### Règle pour les nouveaux domaines

Chaque domaine crée ses propres exceptions métier dans `exception/` et ses mappers dans `exception/mapper/`.

---

## Sécurité

### Principe général

```
Firebase Auth  →  JWT Bearer token  →  Identité Quarkus  +  Rôles backend
```

Firebase est la source de vérité de **l'identité** (qui est l'utilisateur).
La base Violette est la source de vérité des **rôles métier** (ce que l'utilisateur peut faire).

### Flux d'authentification

```
1. Le client Flutter obtient un JWT Firebase (ID token)

2. Le client envoie : Authorization: Bearer <firebase_jwt>

3. Quarkus OIDC valide le JWT :
   - signature via les clés publiques Firebase (JWKS)
   - audience, expiration, issuer

4. VioletteSecurityAugmentor est invoqué automatiquement

5. VioletteRolesAugmentor.augment(identity) :
   a. Extrait le firebaseUid depuis jwt.getSubject() (claim "sub")
   b. Cherche l'utilisateur en base par firebaseUid
   c. Ajoute ses rôles (ARTIST, MANAGER) à la SecurityIdentity

6. @RolesAllowed("MANAGER") devient effectif sur les endpoints protégés
```

### Rôles métier actuels

| Rôle      | Description                                   |
|-----------|-----------------------------------------------|
| `ARTIST`  | Artiste — consulte ses disponibilités/réservations |
| `MANAGER` | Gestionnaire — accès administration complet   |

### Configuration requise

**`application.properties`** (profil par défaut) :
```properties
# OIDC désactivé — les endpoints @Authenticated retournent 403 sans token
quarkus.oidc.enabled=false
```

**`application-firebase.properties`** (chargé automatiquement avec `-Dquarkus.profile=firebase`) :
```properties
# Validation réelle des JWT Firebase
quarkus.oidc.enabled=true
quarkus.oidc.auth-server-url=https://securetoken.google.com/${FIREBASE_PROJECT_ID}
quarkus.oidc.client-id=${FIREBASE_PROJECT_ID}
quarkus.oidc.token.issuer=https://securetoken.google.com/${FIREBASE_PROJECT_ID}
quarkus.oidc.token.audience=${FIREBASE_PROJECT_ID}
quarkus.oidc.application-type=service

# H2 in-memory (test local sans MySQL)
quarkus.datasource.db-kind=h2
quarkus.datasource.jdbc.url=jdbc:h2:mem:violette_firebase;DB_CLOSE_DELAY=-1
quarkus.hibernate-orm.schema-management.strategy=drop-and-create
quarkus.flyway.enabled=false
```

**Variable d'environnement requise avec le profil firebase :**
```
FIREBASE_PROJECT_ID=<votre-projet-firebase>
```

---

## Conventions de logging

Le logging utilise **SLF4J** (`org.slf4j.Logger`).

### Niveaux

| Niveau  | Usage                                                            |
|---------|------------------------------------------------------------------|
| `INFO`  | Événements métier importants (création, modification, erreur métier) |
| `DEBUG` | Détails techniques (rôles chargés, branches conditionnelles)     |
| `WARN`  | Situations anormales mais récupérables                           |
| `ERROR` | Erreurs inattendues nécessitant attention                        |

### Déclaration standard

```java
private static final Logger LOG = LoggerFactory.getLogger(MaClasse.class);
```

### Exemples attendus par domaine

```java
// Service — opération de création
LOG.info("Creating backend user for firebaseUid={}", principal.firebaseUid());
LOG.info("User already exists for firebaseUid={}", principal.firebaseUid());

// Augmentor — chargement des rôles
LOG.info("Loading roles for firebaseUid={}", firebaseUid);
LOG.info("Roles loaded for firebaseUid={}: {}", firebaseUid, user.getRoles());
```

---

## Design Patterns — actifs

Le projet implémente trois design patterns GoF, un par catégorie.

| Pattern | Catégorie | Emplacement principal |
|---|---|---|
| **Singleton** | Création | Tous les `@ApplicationScoped` (services, repositories, security) |
| **Adapter** | Structurel | `security/VioletteSecurityAugmentor.java` + `VioletteRolesAugmentor.java` |
| **Observer** | Comportemental | `artistbooking/event/BookingStatusChangedEvent.java` + `BookingStatusChangedObserver.java` |

---

### Singleton — Création

**Principe :** une seule instance d'un composant est créée et partagée pour toute la durée de vie de l'application.

**Dans Violette :** tous les beans annotés `@ApplicationScoped` sont instanciés une seule fois par le conteneur CDI Quarkus. C'est le comportement exact du pattern Singleton : instance unique, accessible globalement via injection de dépendances.

**Exemples :** `ArtistBookingService`, `VioletteUserService`, `ArtistBookingRepository`, `VioletteSecurityAugmentor`, `VioletteRolesAugmentor`, `CurrentUserContextProvider`…

---

### Adapter — Structurel

**Principe :** convertir l'interface d'un composant en une autre interface attendue par le client.

**Dans Violette :** Firebase fournit l'identité (JWT, claim `sub`) mais Quarkus attend une `SecurityIdentity` avec des rôles pour que `@RolesAllowed("MANAGER")` fonctionne. L'Adapter traduit ces deux interfaces incompatibles.

```
[Firebase JWT / OIDC]           [Quarkus Security]
   → firebaseUid (claim sub)    ← @RolesAllowed("MANAGER")
   → pas de rôles métier        ← SecurityIdentity avec rôles

        VioletteSecurityAugmentor  (implements SecurityIdentityAugmentor)
        └── VioletteRolesAugmentor
              ├── charge VioletteUserEntity par firebaseUid
              └── ajoute ARTIST / MANAGER à SecurityIdentity
```

**Fichiers :**
```
src/main/java/io/violette/security/VioletteSecurityAugmentor.java
src/main/java/io/violette/security/VioletteRolesAugmentor.java
```

---

### Observer — Comportemental

**Principe :** un objet (observateur) est notifié automatiquement quand un autre objet (sujet) change d'état, sans couplage direct entre eux.

**Dans Violette :** `ArtistBookingService` publie un événement CDI `BookingStatusChangedEvent` à chaque transition de statut de booking. Les observateurs réagissent sans que le service les connaisse.

```
ArtistBookingService
  └── bookingStatusChangedEvent.fire(new BookingStatusChangedEvent(...))
              │
              ▼  [routage CDI — aucun couplage direct]
BookingStatusChangedObserver
  └── onBookingStatusChanged(@Observes event)
        └── journalisation de la transition
```

**Transitions couvertes :**
- `sendConfirmationRequests()` → SELECTED → PENDING_CONFIRMATION
- `respondToRequest()` → PENDING_CONFIRMATION → CONFIRMED ou REFUSED

**Point d'extension :** l'observateur est le seul point à modifier pour ajouter notifications, synchronisation entre domaines, audit trail, workflows V2.

**Fichiers :**
```
src/main/java/io/violette/artistbooking/event/BookingStatusChangedEvent.java
src/main/java/io/violette/artistbooking/event/BookingStatusChangedObserver.java
src/main/java/io/violette/artistbooking/service/ArtistBookingService.java
```

---

## Règles d'architecture à respecter

### 1. Séparation des couches
- `Controller` = HTTP uniquement, **aucune logique métier**
- `Service` = logique applicative et règles métier
- `Repository` = accès base uniquement, **aucune logique**

### 2. DTOs obligatoires
- Les entités JPA **ne sortent jamais** du Service
- Tout endpoint expose uniquement des DTOs
- MapStruct est utilisé pour toutes les conversions Entity ↔ DTO

### 3. Gestion des erreurs
- Les cas d'erreur métier sont des **exceptions spécialisées** (pas de `Response` dans le Service)
- Chaque exception est mappée en HTTP par un `ExceptionMapper` dédié (`@Provider`)

### 4. Sécurité
- L'identité vient de Firebase (JWT validé par OIDC)
- Les rôles viennent **toujours** de la base backend (jamais des custom claims Firebase)
- `@RolesAllowed` s'applique au niveau du Controller

### 5. Logging
- SLF4J sur toutes les opérations importantes (création, erreur métier, chargement de rôles)
- Niveau INFO pour les événements métier, DEBUG pour les détails techniques
- Toujours logger le firebaseUid comme contexte d'identification

### 6. Migrations SQL
- Fichiers Flyway nommés `V<n>__<description_snake_case>.sql`
- Jamais de DDL manuel en dehors de Flyway

---

## Commandes principales

### Build

```bash
mvn compile
```

### Tests

```bash
mvn test
```

Les tests s'exécutent sur H2 in-memory. Flyway est désactivé en profil test ; le schéma est géré par `quarkus.hibernate-orm.schema-management.strategy=drop-and-create`.

### Couverture (JaCoCo)

```bash
mvn verify
```

Génère le rapport JaCoCo (HTML + XML dans `target/site/jacoco/`) et applique le seuil minimal de 30 % de lignes couvertes ; le build échoue si le seuil n'est pas atteint.

### Mode développement (hot reload)

```bash
mvn quarkus:dev
```

L'OIDC Firebase est désactivé en dev (`quarkus.oidc.enabled=false`). La base de données est H2 in-memory. **Attention : les endpoints annotés `@Authenticated` retournent 403** — ils ne sont pas ouverts, la sécurité Quarkus reste active même sans validation JWT.

### Profil Firebase (validation réelle des JWT, H2 in-memory)

```bash
mvn quarkus:dev -Dquarkus.profile=firebase
```

Active la validation des JWT Firebase via OIDC. Utilise **H2 in-memory** (pas MySQL) — ce profil est destiné aux **tests locaux** avec de vrais tokens Firebase, sans nécessiter Docker ni MySQL.

Requiert la variable d'environnement `FIREBASE_PROJECT_ID`.

### Package

```bash
mvn package
```

---

## Décisions de modélisation — domaine `showdate`

### Rôle du domaine

`ShowDate` modélise la **feuille de route logistique** d'une date de prestation : lieu, heure de rendez-vous, contacts client, revue jouée (optionnelle). Ce n'est pas un planning artistique — c'est un document organisationnel.

### Décisions structurantes

| Décision | Justification |
|---|---|
| Pas de `TimeSlot` (startTime/endTime) | `meetingTime` suffit comme information logistique. La validation durée ≤ 12h serait prématurée sans cas d'usage confirmé. |
| `meetingTime` remplace start/end | Heure de rendez-vous : simple, non ambigu, pas de validation de durée requise à ce stade. |
| `ShowDateSkillRequirement` séparé | Un show peut nécessiter plusieurs compétences avec des cachets nets différents. Relation `1-N` propre. |
| `ArtistAvailabilityEntity` avec clé composite | Remplace la `Map<userId, status>` Firestore dénormalisée. Unicité garantie par la PK. |
| `netFee` en `BigDecimal` | Précision monétaire correcte — pas de `double` pour les montants. |
| `selectedCount` absent | Jamais stocké — calculé par `COUNT(*)` si besoin. |

### Frontière avec `artistbooking`

Le domaine `showdate` **ne gère pas** les artistes effectivement retenus ni les confirmations de réservation.
Ces responsabilités appartiennent au domaine `artistbooking` :

```
showdate                         artistbooking
─────────────────────────────    ────────────────────────────────
ShowDate (feuille de route)  →   ArtistBooking (artiste retenu)
ArtistAvailability (déclaré)      BookingStatus (SELECTED, CONFIRMED…)
ShowDateSkillRequirement          BookingTimeline (timestamps cycle de vie)
```

---

## Domaine de référence

Le domaine `violetteuser` est le **modèle de référence** pour tous les domaines backend (`showdate`, `artistbooking`, `cabaretcompany`).

Pour tout nouveau domaine, s'assurer de respecter :
1. La structure de packages décrite ci-dessus
2. L'architecture en couches Controller → Service → Repository
3. Les conventions DTO / MapStruct
4. Les exceptions métier + ExceptionMapper
5. Le logging SLF4J aux bons niveaux
