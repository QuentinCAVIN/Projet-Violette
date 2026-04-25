# violette_front

Application Flutter de la plateforme **Violette**.

## Architecture frontend

Le frontend utilise Flutter avec Stacked (MVVM).

```text
View -> ViewModel -> Repository -> RemoteDataSource -> Dio / client généré
                                      |
                                    Mapper
```

Firebase Auth reste responsable de la connexion et du JWT. Les domaines métier migrés (`user`, `availability`, `showDate`, `booking`) passent par le backend REST.

Le domaine `user` utilise le client `violette_api_client` généré depuis OpenAPI. Les autres domaines REST utilisent aujourd'hui Dio et des mappers manuels, en gardant la même frontière : les ViewModels consomment des repositories et ne manipulent pas de JSON brut.

## Configuration des environnements (URL du backend REST)

Le client HTTP est centralisé dans `DioClient` (`lib/core/network/dio_client.dart`).  
Cette section décrit **comment pointer l’application vers le bon backend** selon le contexte (machine locale, téléphone, émulateur, production).

---

### 1. Principe

- L’URL du backend est **injectée au moment du lancement ou du build** Flutter via `--dart-define`.
- La clé utilisée est **`API_BASE_URL`**.
- Dans le code, la valeur est lue avec `String.fromEnvironment` (voir `DioClient`) :

  ```dart
  String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  )
  ```

- **Pourquoi `--dart-define` ?**  
  Cela permet de **changer l’URL sans modifier le code** entre le développement local, les tests sur appareil et la production, et d’éviter de versionner des secrets ou des URLs figées dans les sources.

- **Valeur par défaut** : `http://127.0.0.1:8080` — adaptée au scénario **téléphone Android physique + USB + `adb reverse`** (voir ci-dessous).

### Variables utiles

| Variable | Obligatoire | Rôle |
|---|---:|---|
| `API_BASE_URL` | Non, sauf cible non standard | URL du backend REST injectée via `--dart-define` |

---

### 2. Cas d’usage — développement local

#### Téléphone Android physique (USB) et `adb reverse`

1. Démarrer le backend Quarkus en local (port **8080** par défaut).
2. Brancher le téléphone en USB, activer le **débogage USB**.
3. Sur le PC, rediriger le port du téléphone vers le backend local :

   ```bash
   adb reverse tcp:8080 tcp:8080
   ```

   - Traduire : le **port 8080 sur l’appareil** est mappé vers le **port 8080 de la machine hôte** qui exécute Quarkus.
   - **Pourquoi `http://127.0.0.1:8080` fonctionne alors ?**  
     Avec `adb reverse`, `127.0.0.1` **côté téléphone** désigne en pratique le **localhost du PC** pour ce port — l’app Flutter peut donc utiliser la même URL que sur le desktop.

4. Lancer l’app **sans** `--dart-define` (défaut) :

   ```bash
   flutter run
   ```

> **Astuce** : si la commande ne prend pas effet, débrancher/rebrancher l’USB ou relancer `adb reverse`.

#### Émulateur Android

Sur l’émulateur, `127.0.0.1` pointe vers **l’émulateur lui-même**, pas vers votre PC. Pour joindre le Quarkus tournant sur le PC, utiliser l’alias spécial **`10.0.2.2`** (réseau virtuel de l’AVD vers la machine hôte) :

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

#### Téléphone sur le même Wi-Fi (sans `adb reverse`)

1. Récupérer l’**adresse IP locale** du PC sur le LAN (ex. sous Windows : `ipconfig`, chercher l’IPv4 du Wi-Fi).
2. Lancer l’app en passant explicitement l’URL (adapter l’IP et le port) :

   ```bash
   flutter run --dart-define=API_BASE_URL=http://192.168.1.42:8080
   ```

- Le backend doit accepter les connexions sur cette interface (pare-feu, Quarkus en écoute sur `0.0.0.0` / machine joignable).

---

### 3. Utilisation avec le backend déployé (Fly.io)

Backend public : **https://violette-back.fly.dev**

```bash
flutter run --dart-define=API_BASE_URL=https://violette-back.fly.dev
```

- Utiliser **HTTPS** (pas d’`http` en production pour ce host).
- S’assurer que le **JWT Firebase** est valide côté app et que l’environnement OIDC du backend est correct (hors scope de ce README).

---

### 4. Build APK de production

La variable **`API_BASE_URL` doit être fournie au build** : elle est figée dans l’APK (valeurs `fromEnvironment` évaluées **à la compilation**).

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://violette-back.fly.dev
```

- **CI/CD** : le workflow `.github/workflows/deploy.yml` (job *Build release APK*) exécute cette commande avec l’URL Fly.io — pas besoin de repasser le `--dart-define` manuellement pour l’artefact généré en release GitHub, sauf configuration locale différente.

---

### 5. Bonnes pratiques

- **Ne pas** dupliquer des URLs de backend en dur dans le code des écrans ou des repositories — tout passe par `DioClient` / client généré branché sur la même `baseUrl`.
- **Toujours** passer l’URL via `--dart-define=API_BASE_URL=...` pour les cibles non standard (émulateur, autre IP LAN, autre backend).
- **Éviter le slash final** dans l’URL (ex. préférer `https://host` et non `https://host/`) — les chemins d’API commencent déjà par `/api/...` dans le code.
- En cas d’échec réseau, **vérifier d’abord** la constante lue par `DioClient` (nom de clé, défaut) et l’URL réellement passée au `flutter run` / `build`.

---

### 6. Debug rapide

- **Vérifier que le backend répond** (sur la machine cible) :

  ```bash
  curl http://127.0.0.1:8080/api/ping
  ```

  (adapter l’hôte/port pour l’IP LAN ou Fly.io : `https://violette-back.fly.dev/api/ping`.)

- **Confirmer l’URL utilisée par l’app** : ajouter **temporairement** un `debugPrint` au démarrage (dans un point d’entrée ou après création de `Dio`) en affichant la même `String.fromEnvironment` — **penser à retirer** avant commit si ce n’est pas souhaité en repo.

- **Téléphone physique** : si `127.0.0.1` ne répond pas, retester `adb reverse` et s’assurer que Quarkus tourne sur le port 8080.

---

## Golden tests

Pour lancer l'analyse et les tests frontend :

```bash
flutter analyze
flutter test
```

Les golden tests sont déjà en place. Pour mettre à jour les fichiers de référence :

```bash
flutter test --update-goldens
```

Les captures sont stockées sous `test/golden/`.
