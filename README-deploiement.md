# Guide de déploiement — Violette

Stack de production : **Fly.io** (backend Quarkus) + **Aiven** (MySQL) + **GitHub Releases** (APK Android).

---

## Architecture de déploiement

```
Push sur main
    │
    └─► deploy.yml (Job 1 : deploy-backend)
            │
            ├─ mvnw clean verify -B        (tests + JaCoCo)
            ├─ docker build (linux/amd64)  (Dockerfile.jvm)
            ├─ push → ghcr.io/quentincavin/violette-back:sha-XXXXXXX
            ├─ push → ghcr.io/quentincavin/violette-back:latest
            └─ flyctl deploy --image ...  → violette-back.fly.dev

Push d'un tag v*.*.*
    │
    ├─► deploy.yml (Job 1 : deploy-backend)  [idem push main + crée GitHub Release]
    │
    └─► deploy.yml (Job 2 : release-apk)    [après succès Job 1]
            │
            ├─ flutter build apk --release
            └─ upload app-release.apk → GitHub Release vX.Y.Z
```

---

## Structure du dépôt

```
Projet-Violette/
├── .github/
│   └── workflows/
│       ├── deploy.yml           ← Pipeline CD principal (Fly.io + APK)
│       ├── backend-ci.yml       ← CI backend (inchangé)
│       ├── flutter-ci.yml       ← CI Flutter (inchangé)
│       ├── backend-cd.yml       ← ARCHIVÉ (Oracle Cloud) — ne pas utiliser
│       └── flutter-cd.yml       ← ARCHIVÉ (Oracle Cloud) — ne pas utiliser
├── violette-back/
│   ├── fly.toml                 ← Configuration Fly.io
│   ├── src/main/docker/
│   │   └── Dockerfile.jvm       ← Image Docker (Quarkus JVM, Java 21)
│   └── src/main/resources/
│       └── application.properties
├── violette_front/              ← Application Flutter
├── setup-fly.sh                 ← Script de première configuration
├── docker-compose.yml           ← Docker Compose local (dev)
└── docker-compose.prod.yml      ← ARCHIVÉ (Oracle Cloud)
```

---

## Actions manuelles — dans l'ordre chronologique

### Étape 1 — Créer un compte Aiven (base MySQL)

1. Aller sur [https://aiven.io](https://aiven.io) → **Start free**
2. Créer un projet (ex: `violette`)
3. Créer un service **MySQL** :
   - Plan : **Free** (1 CPU, 1 GB RAM, 5 GB stockage)
   - Version : **MySQL 8**
   - Région : **Google Cloud Europe West** (ou AWS Frankfurt)
4. Attendre que le service soit en état **Running**
5. Dans **Overview → Connection information**, noter :
   - **Host** (ex: `mysql-xxxx-xxxx.aivencloud.com`)
   - **Port** (ex: `12345`)
   - **User** : `avnadmin`
   - **Password** : (généré automatiquement)
   - **Database** : créer une base `violette_db` dans l'onglet **Databases**
6. Aiven impose SSL — c'est déjà pris en charge par le paramètre `sslMode=REQUIRED` dans `setup-fly.sh`

### Étape 2 — Créer un compte Fly.io

1. Aller sur [https://fly.io](https://fly.io) → **Sign up**
2. Vérifier l'email
3. Installer flyctl sur ta machine :
   ```powershell
   # Windows (PowerShell admin)
   iwr https://fly.io/install.ps1 -useb | iex
   ```
4. S'authentifier :
   ```bash
   flyctl auth login
   ```

### Étape 3 — Lancer le script de première configuration

Depuis la racine du repo (sur WSL, Git Bash, ou macOS/Linux) :

```bash
bash setup-fly.sh
```

Le script :
1. Crée l'application `violette-back` sur Fly.io
2. Injecte les secrets MySQL Aiven
3. Effectue le premier déploiement (image GHCR `:latest`)
4. Génère et affiche le `FLY_API_TOKEN`

**⚠ Note Windows :** si tu es sur PowerShell pur, exécute les commandes manuellement (cf. section ci-dessous).

#### Commandes manuelles équivalentes (Windows PowerShell)

```powershell
# 1. Créer l'app
flyctl apps create violette-back --machines

# 2. Injecter les secrets (remplacer les valeurs)
flyctl secrets set `
  "QUARKUS_DATASOURCE_JDBC_URL=jdbc:mysql://HOST:PORT/violette_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&sslMode=REQUIRED" `
  "QUARKUS_DATASOURCE_USERNAME=avnadmin" `
  "QUARKUS_DATASOURCE_PASSWORD=MOT_DE_PASSE_AIVEN" `
  --app violette-back

# 3. Premier déploiement (depuis le dossier violette-back)
cd violette-back
flyctl deploy --wait-timeout 180
cd ..

# 4. Générer le token CI/CD
flyctl tokens create deploy --name "github-actions-violette-back" --app violette-back
```

### Étape 4 — Configurer les secrets GitHub Actions

Dans **GitHub → Settings → Secrets and variables → Actions → New repository secret** :

| Nom du secret | Description | Comment l'obtenir |
|---|---|---|
| `FLY_API_TOKEN` | Token de déploiement Fly.io | Résultat de `setup-fly.sh` (étape 4) ou `flyctl tokens create deploy` |
| `GOOGLE_SERVICES_JSON_BASE64` | `google-services.json` encodé en base64 | `base64 -w0 violette_front/android/app/google-services.json` |
| `ANDROID_KEYSTORE_BASE64` | Keystore de signature Android en base64 | `base64 -w0 violette-release.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Mot de passe du keystore | Choisi lors de `keytool -genkey` |
| `ANDROID_KEY_PASSWORD` | Mot de passe de la clé | Choisi lors de `keytool -genkey` |
| `ANDROID_KEY_ALIAS` | Alias de la clé | Ex: `violette-key` |

#### Générer un keystore Android (si pas encore fait)

```bash
keytool -genkey -v \
  -keystore violette-release.jks \
  -alias violette-key \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Encoder pour GitHub :

```bash
# Linux / macOS / Git Bash
base64 -w0 violette-release.jks

# PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("violette-release.jks"))
```

---

## Premier déploiement

Après `setup-fly.sh`, vérifier que le backend répond :

```bash
curl https://violette-back.fly.dev/api/ping
# Attendu : {"status":"pong","version":"0.3.0"}
```

Swagger UI : [https://violette-back.fly.dev/swagger-ui](https://violette-back.fly.dev/swagger-ui)

Pour forcer un redéploiement manuel :

```bash
cd violette-back
flyctl deploy
```

---

## Déclencher la première release APK

```bash
git tag v0.3.0
git push origin v0.3.0
```

Cela déclenche `deploy.yml` avec les deux jobs :
1. **deploy-backend** : redéploie le backend + crée la GitHub Release `v0.3.0`
2. **release-apk** : build l'APK + l'uploade sur la release

Résultat : [https://github.com/quentincavin/Projet-Violette/releases](https://github.com/quentincavin/Projet-Violette/releases)

---

## Déploiement continu (day-to-day)

| Action | Déclencheur | Résultat |
|---|---|---|
| `git push origin main` | Push sur `main` | Backend redéployé sur Fly.io |
| `git tag vX.Y.Z && git push origin vX.Y.Z` | Tag `v*.*.*` | Backend redéployé + APK publié sur GitHub Releases |

---

## Logs et monitoring Fly.io

```bash
# Logs en temps réel
flyctl logs --app violette-back

# Statut des machines
flyctl status --app violette-back

# SSH dans le container (debug)
flyctl ssh console --app violette-back

# Redémarrer l'app
flyctl apps restart violette-back
```

---

## Gestion des secrets Fly.io

```bash
# Lister les secrets (noms seulement)
flyctl secrets list --app violette-back

# Mettre à jour un secret (ex: nouveau mot de passe BDD)
flyctl secrets set QUARKUS_DATASOURCE_PASSWORD="nouveau_mot_de_passe" --app violette-back

# Supprimer un secret
flyctl secrets unset NOM_SECRET --app violette-back
```

---

## Mise à l'échelle (soutenance)

Pour garantir la disponibilité pendant la soutenance, passer à `min_machines_running = 1` est déjà configuré dans `fly.toml`. Si besoin de plus de RAM :

```bash
flyctl scale memory 512 --app violette-back
```

Pour revenir en mode économique après la soutenance :

```bash
# Éditer fly.toml : min_machines_running = 0
flyctl deploy  # applique la config
```

---

## Checklist pré-soutenance

- [ ] `curl https://violette-back.fly.dev/api/ping` répond `{"status":"pong","version":"0.3.0"}`
- [ ] Swagger UI accessible : `https://violette-back.fly.dev/swagger-ui`
- [ ] `flyctl status --app violette-back` affiche **1 machine running**
- [ ] Dernier tag déployé vérifié : `flyctl releases --app violette-back`
- [ ] APK Android de la dernière release téléchargeable depuis GitHub Releases
- [ ] APK installé sur l'appareil de démo et fonctionnel
- [ ] Authentification Firebase opérationnelle sur l'APK de release
- [ ] Secret `FLY_API_TOKEN` non expiré dans GitHub (tokens → vérifier validity)
- [ ] Aiven MySQL en état **Running** (pas en pause automatique)

> **Aiven free tier** : les bases MySQL passent en **pause** après 30 jours d'inactivité.
> Réactiver depuis la console Aiven si nécessaire.

---

## Variables d'environnement — référence complète

### Secrets Fly.io (sensibles — jamais en clair)

| Variable Fly.io | Correspond à | Valeur |
|---|---|---|
| `QUARKUS_DATASOURCE_JDBC_URL` | `quarkus.datasource.jdbc.url` | `jdbc:mysql://HOST:PORT/violette_db?...&sslMode=REQUIRED` |
| `QUARKUS_DATASOURCE_USERNAME` | `quarkus.datasource.username` | Utilisateur Aiven |
| `QUARKUS_DATASOURCE_PASSWORD` | `quarkus.datasource.password` | Mot de passe Aiven |

### Variables publiques Fly.io (dans `fly.toml [env]`)

| Variable | Valeur |
|---|---|
| `QUARKUS_OIDC_ENABLED` | `true` |
| `QUARKUS_OIDC_APPLICATION_TYPE` | `service` |
| `QUARKUS_OIDC_AUTH_SERVER_URL` | `https://securetoken.google.com/violette-1f64e` |
| `QUARKUS_OIDC_CLIENT_ID` | `violette-1f64e` |
| `QUARKUS_OIDC_TOKEN_ISSUER` | `https://securetoken.google.com/violette-1f64e` |
| `QUARKUS_OIDC_TOKEN_AUDIENCE` | `violette-1f64e` |
| `QUARKUS_LOG_LEVEL` | `INFO` |
