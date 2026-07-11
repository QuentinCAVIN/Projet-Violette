# Démarrage local — Violette

Ce guide permet de lancer l'application complète sur sa machine — backend, base de données et application mobile — avec un jeu de données de test, en partant d'un simple clone du dépôt.

Trois briques interviennent :

- le **backend Quarkus**, lancé en local avec une base **H2 en mémoire** (aucun MySQL requis) et un **jeu de données de test** chargé automatiquement au démarrage ;
- **Firebase Authentication**, service cloud qui gère l'identité : il faut un projet Firebase joignable, même en local ;
- l'**application Flutter**, sur un téléphone Android branché en USB ou sur un émulateur.

> **Point clé** : le jeu de données backend (`import.sql`) et les comptes Firebase sont créés séparément. Le lien entre les deux est le champ `firebase_uid` : si l'UID d'un compte Firebase ne correspond pas à celui du seed, la connexion aboutit à une session sans profil et l'application ramène à l'écran de connexion. La section 2 explique comment les aligner.

---

## 1. Prérequis

| Outil | Détail | Vérification |
|---|---|---|
| JDK 21 | Requis par le backend | `java -version` |
| Flutter SDK | Canal stable (la CI utilise la 3.44.4) avec la toolchain Android | `flutter doctor` |
| `adb` | Fourni avec Android Studio / platform-tools ; requis pour le téléphone USB (inutile avec un émulateur) | `adb devices` |
| Un téléphone Android (débogage USB activé) **ou** un émulateur | — | — |
| Un compte Google | Pour la console Firebase (cas B ci-dessous) | — |

Maven n'est **pas** requis : le wrapper `mvnw` est fourni dans `violette-back/`.

---

## 2. Configuration Firebase

L'application lit sa configuration Firebase dans deux fichiers :

- `violette_front/android/app/google-services.json` — **non versionné** (exclu par `.gitignore`, c'est normal : il est propre à chaque projet Firebase). **Sans lui, le build Android échoue.**
- `violette_front/lib/firebase_options.dart` — versionné, pointe vers le projet Firebase du mainteneur (`violette-1f64e`). C'est **ce fichier** que l'application utilise au démarrage (`main.dart`).

### Cas A — vous avez accès au projet Firebase du mainteneur (`violette-1f64e`)

1. Récupérez `google-services.json` auprès du mainteneur (il ne peut pas être fourni dans le dépôt).
2. Placez-le dans `violette_front/android/app/`.
3. C'est tout : les comptes de test et le seed sont déjà alignés. Passez à la section 3.

Comptes de test du projet mainteneur :

| Rôle | E-mail | Mot de passe |
|---|---|---|
| Gérant | `manager@violette.test` | `123456` |
| Artiste (danse) | `artiste1@violette.test` | `123456` |
| Artiste (chant) | `artiste2@violette.test` | `123456` |

### Cas B — vous créez votre propre projet Firebase

1. **Créer le projet** : [console.firebase.google.com](https://console.firebase.google.com) → *Créer un projet* (nom libre, Analytics facultatif). Notez le **Project ID** (visible dans *Paramètres du projet*).

2. **Activer l'authentification par e-mail** : menu *Authentication* → *Get started* → onglet *Sign-in method* → activer **E-mail/Mot de passe**.

3. **Créer les trois comptes de test** : onglet *Users* → *Add user* :
   - `manager@violette.test`
   - `artiste1@violette.test`
   - `artiste2@violette.test`

   Mot de passe libre (6 caractères minimum ; `123456` par convention du projet).

4. **Récupérer les UID générés** : toujours dans *Authentication → Users*, chaque ligne affiche une colonne **UID utilisateur** (icône de copie au survol). Copiez les trois UID.

5. **Reporter les UID dans le seed** : ouvrez `violette-back/src/main/resources/import.sql` et remplacez la valeur `firebase_uid` (première chaîne après l'`id`) des trois `INSERT INTO violette_user` :
   - ligne 22 (`manager@violette.test`) → UID de votre compte gérant ;
   - ligne 26 (`artiste1@violette.test`) → UID de votre compte artiste 1 ;
   - ligne 30 (`artiste2@violette.test`) → UID de votre compte artiste 2.

   Exemple pour la ligne 22 :

   ```sql
   VALUES (1, 'VOTRE_UID_MANAGER_ICI', 'manager@violette.test', 'Marie', 'Gérant', ...
   ```

   > ⚠️ Modification locale de développement : ne la committez pas.

6. **Déclarer l'application Android** : *Paramètres du projet* → *Vos applications* → *Ajouter une application* → Android. Dans le champ *Nom du package Android*, saisissez **exactement** :

   ```
   io.violette.app
   ```

   C'est l'`applicationId` défini dans `violette_front/android/app/build.gradle.kts` (ligne 32). **Si le package ne correspond pas, rien ne fonctionnera** : Firebase refusera silencieusement l'application. Téléchargez ensuite **`google-services.json`** et placez-le dans `violette_front/android/app/`.

7. **Régénérer `firebase_options.dart` pour votre projet** — sinon l'application continuerait de viser `violette-1f64e` :

   ```bash
   # Une fois : installer les CLI
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli

   # Depuis violette_front/
   flutterfire configure --project=<votre-project-id>
   ```

   > ⚠️ Modification locale de développement : ne la committez pas.

---

## 3. Lancer le backend

Depuis `violette-back/` :

**Windows (PowerShell)** :

```powershell
$env:FIREBASE_PROJECT_ID="violette-1f64e"   # cas B : votre Project ID
.\mvnw.cmd quarkus:dev "-Dquarkus.profile=firebase"
```

**Linux / macOS** :

```bash
export FIREBASE_PROJECT_ID="violette-1f64e"   # cas B : votre Project ID
./mvnw quarkus:dev -Dquarkus.profile=firebase
```

Le backend démarre sur `http://localhost:8080`. À chaque démarrage, la base H2 est recréée et le seed est chargé automatiquement : 1 compagnie (« Dream's Production »), 1 gérant, 2 artistes, 4 dates de spectacle en novembre 2026.

**Vérification** :

```bash
curl http://localhost:8080/api/ping
# Attendu : {"status":"pong","version":"..."}
```

---

## 4. Lancer le frontend

### Téléphone Android en USB (recommandé)

Téléphone branché, débogage USB activé :

```powershell
adb reverse tcp:8080 tcp:8080
cd violette_front
flutter pub get
flutter run
```

`adb reverse` fait pointer le `127.0.0.1:8080` du téléphone vers le backend de votre machine : aucune autre configuration n'est nécessaire.

### Émulateur Android

```powershell
cd violette_front
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

(`10.0.2.2` est l'alias de la machine hôte vu depuis l'émulateur.)

---

## 5. Vérifier que tout fonctionne

1. Sur l'écran de connexion, connectez-vous avec `manager@violette.test` et le mot de passe du compte (cas A : `123456`).
2. L'écran d'accueil affiche le prénom du gérant (« Marie »). Ouvrez le **Planning** : les 4 dates de novembre 2026 apparaissent dans le calendrier.
3. Déconnectez-vous, puis connectez-vous avec `artiste1@violette.test` : le **Planning Artiste** montre les dates avec des disponibilités préremplies.

---

## 6. Problèmes courants

| Symptôme | Cause probable | Correction |
|---|---|---|
| Build Android : `File google-services.json is missing` | Le fichier n'est pas versionné (volontairement) | Section 2, cas A ou B |
| Connexion Firebase acceptée, puis retour immédiat à l'écran de connexion | UID Firebase ≠ `firebase_uid` du seed → session sans profil backend | Cas B, étapes 4–5 : réalignez les UID dans `import.sql` |
| Idem, alors que les UID sont corrects | L'app vise encore le projet `violette-1f64e` | Cas B, étape 7 : régénérez `firebase_options.dart` |
| `403` sur tous les endpoints authentifiés | Profil `firebase` non actif ou `FIREBASE_PROJECT_ID` non défini | Relancez le backend (section 3) |
| `adb reverse` : `no devices/emulators found` | Débogage USB non autorisé sur le téléphone | Acceptez l'invite sur l'écran du téléphone, rebranchez |
| L'app ne joint pas le backend sur émulateur | `127.0.0.1` pointe vers l'émulateur lui-même | Utilisez `--dart-define=API_BASE_URL=http://10.0.2.2:8080` |

---

## Pour aller plus loin

- Configuration détaillée du backend (profils, Docker, MySQL, console H2) : [../violette-back/README.md](../violette-back/README.md)
- Configuration réseau du frontend (`API_BASE_URL`, Wi-Fi local, backend de production) : [../violette_front/README.md](../violette_front/README.md)
