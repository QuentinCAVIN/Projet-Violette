# Guide de déploiement — Violette

Stack de production : **Fly.io** (backend Quarkus) + **Aiven** (MySQL) + **GitHub Releases** (APK Android).

---

## Architecture CI/CD

```
Push sur main  (ou PR vers main)
    │
    └─► deploy.yml — Job : deploy-backend
            │
            ├─ mvnw clean verify -B           (tests + JaCoCo)
            ├─ docker build linux/amd64       (Dockerfile.jvm)
            ├─ push → ghcr.io/quentincavin/violette-back:tag basé sur le commit SHA (ex: sha-abc1234)
            └─ push → ghcr.io/quentincavin/violette-back:latest
            ↳ Fly.io NON déployé sur push main — build CI uniquement

Tag v*.*.*
    │
    ├─► deploy.yml — Job : deploy-backend
    │       │
    │       ├─ mvnw clean verify -B
    │       ├─ docker build + push GHCR       (tag vX.Y.Z + latest)
    │       ├─ flyctl deploy → violette-back.fly.dev   ← déploiement prod
    │       └─ gh release create vX.Y.Z
    │
    └─► deploy.yml — Job : release-apk        (après succès deploy-backend)
            │
            ├─ flutter build apk --release
            └─ upload app-release.apk → GitHub Release vX.Y.Z
```

**Résumé de la stratégie :**

| Déclencheur | Ce qui s'exécute |
|---|---|
| Push sur `main` | Tests Maven + build image Docker + push GHCR (CI) |
| PR vers `main` | Tests + build (sans push GHCR garanti) |
| Tag `v*.*.*` | Idem + déploiement Fly.io + GitHub Release + APK (CD complet) |

Cette séparation entre `push main` et `tag v*.*.*` permet de sécuriser les déploiements et de distinguer clairement la **CI** (validation continue) de la **CD** (release maîtrisée).

---

## 🔄 Fonctionnement du pipeline

### Push sur `main`

- Exécuter les tests Maven (`./mvnw clean verify -B`)
- Construire l'image Docker du backend
- Publier l'image sur GHCR (`tag basé sur le commit SHA`, par exemple `sha-abc1234`, + `latest`)
- Ne pas déployer sur Fly.io

### Tag `v*.*.*`

- Exécuter les tests Maven
- Construire et publier l'image Docker sur GHCR
- Déployer le backend sur Fly.io
- Créer la GitHub Release
- Construire l'APK Flutter
- Publier l'APK sur la GitHub Release

| Déclencheur | Backend | GHCR | Fly.io | GitHub Release | APK |
|---|---|---|---|---|---|
| Push sur `main` | Tests + build | Oui | Non | Non | Non |
| PR vers `main` | Tests + build | Sans push GHCR garanti | Non | Non | Non |
| Tag `v*.*.*` | Tests + build | Oui | Oui | Oui | Oui |

---

## Structure du dépôt

```
Projet-Violette/
├── .github/
│   └── workflows/
│       ├── deploy.yml           ← Pipeline CI/CD principal
│       ├── backend-ci.yml       ← CI backend indépendant (tests + couverture)
│       └── flutter-ci.yml       ← CI Flutter indépendant (analyze + tests)
├── violette-back/
│   ├── fly.toml                 ← Configuration Fly.io
│   ├── src/main/docker/
│   │   └── Dockerfile.jvm       ← Image Docker (Quarkus JVM, Java 21)
│   └── src/main/resources/
│       └── application.properties
├── violette_front/              ← Application Flutter
└── docker-compose.yml           ← Docker Compose local (dev uniquement)
```

---

## 🔐 Comptes et secrets utilisés

### Comptes externes

- `GitHub` : héberge le code, exécute GitHub Actions, publie les Releases et stocke les images Docker dans GHCR
- `Fly.io` : héberge le backend Quarkus en production ; `min_machines_running = 1` permet d'éviter les cold starts
- `Aiven` : fournit la base de données MySQL utilisée par le backend
- `Firebase` : gère l'authentification et la configuration mobile Android

### Secrets GitHub Actions

| Nom | Utilité | Utilisé dans |
|---|---|---|
| `FLY_API_TOKEN` | Authentifier `flyctl deploy` depuis GitHub Actions | `deploy.yml` → job `deploy-backend` |
| `GOOGLE_SERVICES_JSON_BASE64` | Reconstruire `google-services.json` pendant le build Android | `deploy.yml` → job `release-apk` |
| `ANDROID_KEYSTORE_BASE64` | Reconstruire le keystore de signature Android | `deploy.yml` → job `release-apk` |
| `ANDROID_KEYSTORE_PASSWORD` | Ouvrir le keystore Android | `deploy.yml` → job `release-apk` |
| `ANDROID_KEY_ALIAS` | Sélectionner l'alias de signature | `deploy.yml` → job `release-apk` |
| `ANDROID_KEY_PASSWORD` | Déverrouiller la clé de signature | `deploy.yml` → job `release-apk` |

### Secrets Fly.io

| Variable | Rôle |
|---|---|
| `QUARKUS_DATASOURCE_JDBC_URL` | URL JDBC complète vers MySQL Aiven avec `sslMode=REQUIRED` |
| `QUARKUS_DATASOURCE_USERNAME` | Nom d'utilisateur MySQL Aiven |
| `QUARKUS_DATASOURCE_PASSWORD` | Mot de passe MySQL Aiven |

---

## Actions manuelles — dans l'ordre chronologique

### Étape 1 — Créer un compte Aiven (base MySQL)

1. Aller sur [https://aiven.io](https://aiven.io) → **Start free**
2. Créer un projet (ex: `violette`)
3. Créer un service **MySQL 8** — vérifier les limites actuelles du plan gratuit directement sur [aiven.io/pricing](https://aiven.io/pricing), elles sont susceptibles de changer
4. Choisir une région **Google Cloud Europe West** ou **AWS Frankfurt**
5. Attendre que le service soit en état **Running**
6. Dans **Overview → Connection information**, noter :
   - **Host** (ex: `mysql-xxxx-xxxx.aivencloud.com`)
   - **Port** (ex: `12345`)
   - **User** (ex: `avnadmin`)
   - **Password** (généré automatiquement)
7. Dans l'onglet **Databases**, créer une base `violette_db`

> **Note Aiven :** les services du plan gratuit passent en **pause automatique** après une période d'inactivité.
> Réactiver depuis la console Aiven avant chaque démo ou soutenance.
> ⚠️ Le plan gratuit Aiven peut mettre la base en pause après une période d'inactivité.

---

### Étape 2 — Créer un compte Fly.io

1. Aller sur [https://fly.io](https://fly.io) → **Sign up**
2. Vérifier l'email
3. Installer flyctl :
   ```powershell
   # Windows (PowerShell admin)
   iwr https://fly.io/install.ps1 -useb | iex
   ```
4. S'authentifier :
   ```bash
   flyctl auth login
   ```

> **Note Fly.io :** vérifier les limites et conditions du plan gratuit sur [fly.io/docs/about/pricing](https://fly.io/docs/about/pricing). Avec `min_machines_running = 1` et `memory = 512mb`, la machine tourne en permanence — ce qui peut dépasser le quota gratuit selon la politique tarifaire en vigueur. Prévoir ~5 $/mois si nécessaire.

---

### Étape 3 — Première configuration Fly.io

Depuis le dossier `violette-back/` :

```bash
# Créer l'application
flyctl apps create violette-back --machines

# Injecter les secrets MySQL Aiven (remplacer les valeurs réelles)
flyctl secrets set \
  "QUARKUS_DATASOURCE_JDBC_URL=jdbc:mysql://HOST:PORT/violette_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&sslMode=REQUIRED" \
  "QUARKUS_DATASOURCE_USERNAME=avnadmin" \
  "QUARKUS_DATASOURCE_PASSWORD=MOT_DE_PASSE_AIVEN" \
  --app violette-back

# Premier déploiement (depuis violette-back/ où fly.toml est présent)
flyctl deploy --wait-timeout 180
```

Vérifier que le backend répond :

```bash
curl https://violette-back.fly.dev/api/ping
# Attendu : {"status":"pong","version":"0.3.0"}
```

Swagger UI : [https://violette-back.fly.dev/swagger-ui](https://violette-back.fly.dev/swagger-ui)

**Commandes équivalentes sous Windows PowerShell :**

```powershell
flyctl apps create violette-back --machines

flyctl secrets set `
  "QUARKUS_DATASOURCE_JDBC_URL=jdbc:mysql://HOST:PORT/violette_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&sslMode=REQUIRED" `
  "QUARKUS_DATASOURCE_USERNAME=avnadmin" `
  "QUARKUS_DATASOURCE_PASSWORD=MOT_DE_PASSE_AIVEN" `
  --app violette-back

cd violette-back
flyctl deploy --wait-timeout 180
```

---

### Étape 4 — Configurer les secrets GitHub Actions

Dans **GitHub → Settings → Secrets and variables → Actions → New repository secret** :

| Nom du secret | Description | Comment l'obtenir |
|---|---|---|
| `FLY_API_TOKEN` | Token de déploiement Fly.io | `flyctl tokens create deploy --name "github-actions" --app violette-back` |
| `GOOGLE_SERVICES_JSON_BASE64` | `google-services.json` encodé en base64 | `base64 -w0 violette_front/android/app/google-services.json` |
| `ANDROID_KEYSTORE_BASE64` | Keystore de signature Android en base64 | `base64 -w0 violette-release.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Mot de passe du keystore | Choisi lors de `keytool -genkey` |
| `ANDROID_KEY_PASSWORD` | Mot de passe de la clé | Choisi lors de `keytool -genkey` |
| `ANDROID_KEY_ALIAS` | Alias de la clé | Ex: `violette-key` |

> **FLY_API_TOKEN :** la commande `flyctl tokens create deploy` génère un token de déploiement dédié au scope de l'application. C'est la méthode recommandée pour GitHub Actions, à préférer au token personnel (`flyctl auth token`).

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

> Le fichier `violette-release.jks` est protégé par `.gitignore` — ne jamais le commiter.

---

## Déclencher la première release complète (APK + déploiement)

```bash
git tag v0.3.0
git push origin v0.3.0
```

Cela déclenche `deploy.yml` avec les deux jobs en séquence :
1. **deploy-backend** : tests + build image + push GHCR + déploiement Fly.io + création GitHub Release `v0.3.0`
2. **release-apk** : build APK Flutter + upload sur la release (démarre après succès du job 1)

Résultat visible sur : [https://github.com/QuentinCAVIN/Projet-Violette/releases](https://github.com/QuentinCAVIN/Projet-Violette/releases)

---

## Déploiement continu (day-to-day)

| Action | Déclencheur | Ce qui s'exécute |
|---|---|---|
| `git push origin main` | Push sur `main` | Tests + build image Docker + push GHCR (**pas** de déploiement Fly.io) |
| `git tag vX.Y.Z && git push origin vX.Y.Z` | Tag `v*.*.*` | Tests + build + push GHCR + **déploiement Fly.io** + APK sur GitHub Releases |

Pour forcer un redéploiement manuel sans créer de tag :

```bash
cd violette-back
flyctl deploy
```

---

## Logs et monitoring Fly.io

```bash
# Logs en temps réel
flyctl logs --app violette-back

# Statut des machines
flyctl status --app violette-back

# Historique des déploiements
flyctl releases --app violette-back

# SSH dans le container (debug)
flyctl ssh console --app violette-back

# Redémarrer l'app
flyctl apps restart violette-back
```

---

## Gestion des secrets Fly.io

```bash
# Lister les secrets configurés (noms uniquement)
flyctl secrets list --app violette-back

# Mettre à jour un secret
flyctl secrets set QUARKUS_DATASOURCE_PASSWORD="nouveau_mot_de_passe" --app violette-back

# Supprimer un secret
flyctl secrets unset NOM_SECRET --app violette-back
```

---

## Mise à l'échelle (soutenance)

`fly.toml` est configuré avec `min_machines_running = 1` — la machine reste active en permanence. Si la mémoire 512 MB ne suffit pas (OOM visible dans les logs) :

```bash
flyctl scale memory 1024 --app violette-back
```

Pour passer en mode économique après la soutenance (machine s'arrête si pas de trafic) :

```bash
# Éditer violette-back/fly.toml : min_machines_running = 0
# Puis redéployer :
cd violette-back
flyctl deploy
```

---

## Checklist pré-soutenance

- [ ] `curl https://violette-back.fly.dev/api/ping` répond `{"status":"pong","version":"0.3.0"}`
- [ ] Swagger UI accessible : `https://violette-back.fly.dev/swagger-ui`
- [ ] `flyctl status --app violette-back` affiche **1 machine running**
- [ ] Dernier déploiement listé : `flyctl releases --app violette-back`
- [ ] Service Aiven MySQL en état **Running** (pas en pause)
- [ ] APK de la dernière release téléchargeable depuis GitHub Releases
- [ ] APK installé et fonctionnel sur l'appareil de démo
- [ ] Authentification Firebase opérationnelle sur l'APK de release
- [ ] Secret `FLY_API_TOKEN` présent dans GitHub Actions

---

## Variables d'environnement — référence complète

### Secrets Fly.io (sensibles — injectés via `flyctl secrets set`)

| Variable Fly.io | Propriété Quarkus correspondante | Rôle |
|---|---|---|
| `QUARKUS_DATASOURCE_JDBC_URL` | `quarkus.datasource.jdbc.url` | URL JDBC complète vers Aiven avec `sslMode=REQUIRED` |
| `QUARKUS_DATASOURCE_USERNAME` | `quarkus.datasource.username` | Utilisateur MySQL Aiven |
| `QUARKUS_DATASOURCE_PASSWORD` | `quarkus.datasource.password` | Mot de passe MySQL Aiven |

### Variables publiques Fly.io (déclarées dans `violette-back/fly.toml [env]`)

| Variable | Valeur configurée |
|---|---|
| `QUARKUS_OIDC_ENABLED` | `true` |
| `QUARKUS_OIDC_APPLICATION_TYPE` | `service` |
| `QUARKUS_OIDC_AUTH_SERVER_URL` | `https://securetoken.google.com/violette-1f64e` |
| `QUARKUS_OIDC_CLIENT_ID` | `violette-1f64e` |
| `QUARKUS_OIDC_TOKEN_ISSUER` | `https://securetoken.google.com/violette-1f64e` |
| `QUARKUS_OIDC_TOKEN_AUDIENCE` | `violette-1f64e` |
| `QUARKUS_LOG_LEVEL` | `INFO` |
