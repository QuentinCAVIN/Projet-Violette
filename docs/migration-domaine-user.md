# Migration domaine user — REST backend

## Contexte

Le domaine `user` a été le premier domaine migré de Firebase Firestore vers le backend Quarkus REST. Depuis la préparation de `v0.4.0`, les domaines `availability`, `showDate` et `booking` sont également raccordés au backend REST côté code métier frontend.

Ce document reste centré sur l'historique et les choix d'intégration du domaine `user`. Pour l'état global de la migration REST, voir le README racine et la documentation d'architecture.

Firebase Auth reste la source d'identité (création de compte, authentification, JWT).
Le backend Quarkus gère désormais les profils utilisateurs (prénom, nom, rôles, compétences).

---

## Ce qui a été mis en place

### Backend (Quarkus)

**Endpoint ajouté :** `GET /api/users/me/profile`  
Retourne le `VioletteUserDto` complet de l'utilisateur authentifié courant.
Distingue deux cas explicitement :
- `200 OK` — profil trouvé et retourné
- `401` — token absent ou invalide
- `404` — l'utilisateur Firebase n'a pas encore de profil backend

**Endpoint existant conservé :** `POST /api/users`  
Crée le profil backend à partir du JWT (firebaseUid, email) + corps de requête (firstName, lastName, roles).

### Client OpenAPI généré

Le client Dart est généré dans `violette_api_client/` via OpenAPI Generator (`dart-dio`).
La configuration est dans `openapitools.json` à la racine du monorepo.

En `v0.4.0`, ce client généré est utilisé principalement pour le domaine `user` :

- `UserRemoteDataSource` encapsule `UtilisateursApi` pour `GET /api/users/me/profile` et `POST /api/users` ;
- `UserMapper` convertit les DTOs générés vers les modèles métier Flutter ;
- les ViewModels ne manipulent jamais directement les types générés.

Les domaines `availability`, `showDate` et `booking` sont également migrés vers le backend REST, mais ils passent encore par Dio manuel, des maps JSON et des mappers dédiés. Cette décision limite le risque juste avant `v0.4.0` et évite de lier les flux critiques à un client généré encore partiellement adopté.

La régénération complète de `violette_api_client/` est reportée après `v0.4.0`. Lors de l'audit release, une incohérence potentielle a été identifiée : `apiArtistBookingsMeGet` peut être généré comme une réponse `ArtistBookingDto` unique alors que le backend renvoie une liste. Cette dette n'est pas bloquante pour `v0.4.0`, car le code runtime appelle `GET /api/artist-bookings/me` via `BookingRemoteDataSource` et Dio manuel, pas via cette méthode générée.

### Couches Flutter créées

| Classe | Fichier | Rôle |
|--------|---------|------|
| `DioClient` | `lib/core/network/dio_client.dart` | Crée une instance Dio configurée avec la base URL et l'intercepteur JWT Firebase |
| `UserRemoteDataSource` | `lib/data/remote/user_remote_data_source.dart` | Encapsule `UtilisateursApi` (code généré). Point d'accès unique au client OpenAPI pour le domaine user |
| `UserMapper` | `lib/models/mappers/user_mapper.dart` | Convertit `VioletteUserDto` (built_value) ↔ `VioletteUser` (modèle métier Flutter). Seule classe à connaître les types générés |
| `RestUserRepository` | `lib/repositories/rest_user_repository.dart` | Implémente `UserRepository` via `UserRemoteDataSource`. Absorbe les 404 (`getUser` retourne `null`) |

### Routage initial corrigé

`StartupViewModel` vérifie l'existence du profil backend au démarrage avant de naviguer :

```
Démarrage de l'app
  → Pas de session Firebase    : LoginView
  → Session + profil existant  : HomeView
  → Session + profil absent    : logout Firebase + LoginView (état cohérent)
  → Erreur réseau / backend    : écran d'erreur avec bouton "Réessayer"
```

---

## Flux d'authentification et de récupération du profil

### Inscription (nouvel utilisateur)

```
RegisterView
  1. createAccountWithEmail()          → Firebase crée le compte + connecte l'utilisateur
  2. await _userRepository.addUser()   → POST /api/users  (firebaseUid + email extraits du JWT)
  3. replaceWithHomeView()             → navigation
  4. HomeViewModel.loadUser()          → GET /api/users/me/profile → profil garanti présent
```

### Connexion (utilisateur existant)

```
LoginView
  1. loginWithEmail()                  → Firebase authentifie
  2. replaceWithHomeView()             → navigation
  3. HomeViewModel.loadUser()          → GET /api/users/me/profile → profil attendu présent
```

### Reprise de session (app rouverte)

```
StartupView
  1. currentUser Firebase != null
  2. await _userRepository.getUser()   → GET /api/users/me/profile
     → profil trouvé  : HomeView
     → profil absent  : logout + LoginView
     → erreur réseau  : écran d'erreur StartupView
```

### Injection du token Firebase

`_FirebaseJwtInterceptor` (dans `DioClient`) intercepte chaque requête Dio et ajoute :
```
Authorization: Bearer <Firebase ID Token>
```
Le token est récupéré via `FirebaseAuth.instance.currentUser?.getIdToken()`.
Si l'utilisateur n'est pas connecté Firebase, la requête part sans header d'autorisation (le backend retournera `401`).

---

## Régénérer le client OpenAPI

### Prérequis

- Node.js installé
- `@openapitools/openapi-generator-cli` installé globalement ou en local

```bash
npm install @openapitools/openapi-generator-cli -D
```

### Étapes

**1. Démarrer le backend Quarkus** (il doit tourner pour exporter le spec) :

```bash
cd violette-back
./mvnw quarkus:dev -Dquarkus.profile=firebase
# ou : mvn quarkus:dev -Dquarkus.profile=firebase (si Maven global installé)
```

Le fichier `violette-back/target/openapi/openapi.yaml` est généré automatiquement au démarrage.

**2. Générer le client Dart :**

```bash
# À la racine du monorepo
npx openapi-generator-cli generate
```

Le client est généré dans `violette_api_client/`.

**3. Reconstruire les sérialiseurs `built_value` dans le frontend :**

```bash
cd violette_front
dart run build_runner build --delete-conflicting-outputs
```

### Règles importantes

- Ne jamais modifier manuellement les fichiers dans `violette_api_client/`
- Ne jamais importer `violette_api_client` directement dans les ViewModels
- Seuls `UserRemoteDataSource` et `UserMapper` ont le droit d'utiliser les types générés

---

## Lancer le backend localement avec le profil Firebase

### Variable d'environnement requise

```bash
FIREBASE_PROJECT_ID=violette-1f64e   # ID du projet Firebase
```

Le profil `firebase` utilise H2 in-memory — **MySQL n'est pas nécessaire**.
`DB_URL`, `DB_USER`, `DB_PASSWORD` ne sont requis que pour le profil `dev` (MySQL local) ou `prod`.

### Démarrage

```bash
cd violette-back
./mvnw quarkus:dev -Dquarkus.profile=firebase
# ou : mvn quarkus:dev -Dquarkus.profile=firebase (si Maven global installé)
```

Swagger UI disponible sur : `http://localhost:8080/swagger-ui`

---

## Tester depuis un téléphone physique Android branché en USB

### 1. Configurer adb reverse

Redirige le port 8080 du PC vers le téléphone :

```bash
adb reverse tcp:8080 tcp:8080
```

À refaire si le téléphone est déconnecté/reconnecté.

### 2. URL dans DioClient

`lib/core/network/dio_client.dart` est configuré avec `http://127.0.0.1:8080`.
Avec `adb reverse`, `127.0.0.1` sur le téléphone pointe vers `localhost` du PC.

### 3. Lancer l'app sur le téléphone

```bash
# Lister les appareils disponibles
flutter devices

# Lancer sur le téléphone (remplacer par l'ID de l'appareil)
flutter run -d <DEVICE_ID>
```

### Alternatives

| Contexte | URL à utiliser |
|----------|----------------|
| Téléphone USB + adb reverse | `http://127.0.0.1:8080` (défaut actuel) |
| Émulateur Android | `http://10.0.2.2:8080` |
| Téléphone sur Wi-Fi | `http://<IP_locale_PC>:8080` (ex: `ipconfig` sur Windows) |
| Production | `https://violette-back.fly.dev` |

Pour les environnements non standards, passer explicitement l'URL au lancement :

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

---

## Limites connues et dette résiduelle

| Dette | Impact | Priorité |
|-------|--------|----------|
| `RestUserRepository.getUser(uid)` ignore le paramètre `uid` — retourne toujours le profil de l'utilisateur courant | Empêche un MANAGER de consulter le profil d'un autre utilisateur | À lever lors de la migration du domaine MANAGER |
| `LoginViewModel` ne vérifie pas l'existence du profil backend avant de naviguer vers Home | Edge case : un utilisateur Firebase sans profil backend pourrait atteindre Home ; `HomeViewModel.loadUser()` le détecte et effectue un logout | Couvert défensivement ; acceptable |
| `Future.delayed(2s)` dans `StartupViewModel` | La vérification du profil backend est retardée de 2s à chaque démarrage | Cosmétique ; le délai est intentionnel pour le splash |
| `RegisterViewModel` n'appelle pas `setBusy` pendant l'async | Le bouton de soumission reste cliquable pendant `createAccountWithEmail` + `addUser` | UX ; à corriger lors d'une passe UI |
| Tester et documenter tous les domaines REST de façon homogène | `user` utilise le client généré OpenAPI, tandis que `showDate`, `availability` et `booking` utilisent Dio + Maps + mappers manuels | À consolider dans la documentation d'architecture frontend |
| Signature générée de `apiArtistBookingsMeGet` à vérifier | Le client généré peut typer un endpoint liste comme DTO unique ; non bloquant car non utilisé au runtime v0.4.0 | Après tag v0.4.0 |
| Tests du client REST non écrits côté Flutter | `UserRemoteDataSource` et `RestUserRepository` ne sont pas couverts par des tests | À ajouter lors de la stabilisation des domaines suivants |
