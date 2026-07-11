# Manuel de mise à jour — Violette

Ce manuel décrit comment mettre à jour Violette, selon deux points de vue :

- **Côté utilisateur** (artiste ou gérant) : installer une nouvelle version de l'application sur son téléphone Android.
- **Côté exploitant** (mainteneur du projet) : publier une nouvelle version en production (backend et application).

Pour l'installation initiale, voir le [guide d'installation](../INSTALLATION.md). Pour le détail de l'infrastructure de déploiement, voir le [manuel de déploiement](../README-deploiement.md).

---

## 1. Mise à jour côté utilisateur (artiste / gérant)

Violette n'est pas distribuée via le Play Store : les mises à jour se font en réinstallant le fichier d'installation Android (APK) de la dernière version. L'opération est simple et ne fait perdre ni le compte ni les données.

### Étapes

1. **Télécharger la dernière version.** Ouvrez le lien de téléchargement direct de la dernière version : [dernière version (téléchargement direct)](https://github.com/QuentinCAVIN/Projet-Violette/releases/latest/download/app-release.apk). Vous pouvez aussi passer par la [page des versions](https://github.com/QuentinCAVIN/Projet-Violette/releases) et prendre la version la plus haute (la plus récente).
2. **Installer par-dessus l'ancienne version.** Ouvrez le fichier téléchargé. Android propose en général **Mettre à jour** ou **Remplacer** : acceptez. L'ancienne version est remplacée par la nouvelle.
3. **Vérifier.** Ouvrez **Violette** et vérifiez que l'application démarre normalement.

> **Vos identifiants et vos données sont conservés.** La mise à jour ne recrée pas votre compte : vous restez connecté (ou vous vous reconnectez avec les mêmes identifiants), et vos disponibilités, dates et réservations sont intactes. Elles sont stockées côté serveur, pas dans l'application.

### En cas de problème

- **L'installation est bloquée (« source inconnue »)** : c'est normal hors Play Store. Suivez les boutons proposés par le téléphone (**Paramètres** → **Autoriser cette source**), puis relancez l'installation. Voir le [guide d'installation](../INSTALLATION.md) pour le détail.
- **L'application ne démarre pas après mise à jour** : redémarrez le téléphone et rouvrez Violette. Si le problème persiste, réinstallez la dernière version depuis le lien direct.
- **Message « Serveur inaccessible »** : vérifiez votre connexion Internet (Wi-Fi ou données mobiles). Ce message signale que l'application n'a pas pu joindre le service en ligne, indépendamment de la mise à jour.

---

## 2. Mise à jour côté exploitant (publication d'une nouvelle version)

Cette section s'adresse au mainteneur du projet. La publication d'une nouvelle version est **entièrement automatisée** par le pipeline CI/CD : elle se déclenche en poussant un **tag de version** `vX.Y.Z`. Le détail de l'infrastructure (Fly.io, Aiven, secrets) figure dans le [manuel de déploiement](../README-deploiement.md) ; ce manuel n'en donne que la procédure de mise à jour.

### Ce que déclenche un tag `vX.Y.Z`

Pousser un tag versionné exécute le workflow `deploy.yml`, qui enchaîne :

1. **Backend** — alignement de la version Maven sur le tag, exécution des tests, build de l'image Docker, publication sur GHCR, puis **déploiement sur Fly.io**.
2. **Base de données** — au démarrage de la nouvelle version du backend, **Flyway applique automatiquement** les migrations non encore exécutées (`quarkus.flyway.migrate-at-start=true`). Aucune commande manuelle de migration n'est nécessaire en production.
3. **Application** — build de l'APK Android de release (pointant vers le backend de production) et **publication sur la GitHub Release** du tag, d'où les utilisateurs la téléchargent.

Un simple `git push origin main` **ne déploie pas** : il ne lance que les tests et le build (intégration continue). Seul un tag `vX.Y.Z` déclenche la mise en production.

### Procédure

1. **Vérifier que `main` est prête** : la CI est verte, le `CHANGELOG.md` est à jour pour la version visée, et la version est cohérente dans le projet.
2. **Créer et pousser le tag** :

   ```bash
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```

3. **Suivre le déploiement** dans l'onglet Actions de GitHub, jusqu'à la création de la GitHub Release `vX.Y.Z`.

### Vérifications post-déploiement

- **Version du backend** :

  ```bash
  curl https://violette-back.fly.dev/api/ping
  # Attendu : {"status":"pong","version":"X.Y.Z"}
  ```

- **Migrations de base** : vérifier dans les logs Fly.io que Flyway a appliqué les migrations attendues sans erreur (`flyctl logs --app violette-back`).
- **APK publié** : vérifier que le fichier d'installation est bien attaché à la [Release du tag](https://github.com/QuentinCAVIN/Projet-Violette/releases).
- **Application** : installer l'APK de la nouvelle version sur un appareil de test et vérifier un parcours nominal (connexion, consultation du planning).

### Note sur les migrations de base de données

Les scripts de migration sont versionnés dans `violette-back/src/main/resources/db/migration/` (`V1` à `V7` à ce jour), selon la convention `V<version>__<description>.sql`. Ils sont **cumulatifs et appliqués dans l'ordre** : une base de production existante ne reçoit que les migrations qu'elle n'a pas encore. Toute nouvelle évolution de schéma doit passer par un nouveau script `V<n+1>__…` (jamais par la modification d'un script déjà appliqué), afin de préserver l'historique et la reproductibilité.

---

## 3. Récapitulatif

| Public | Ce qu'il met à jour | Comment | Effet sur les données |
|---|---|---|---|
| **Utilisateur** (artiste / gérant) | L'application sur son téléphone | Réinstaller le dernier APK par-dessus l'ancien | Aucun impact : compte et données conservés (stockés côté serveur) |
| **Exploitant** (mainteneur) | Le backend et l'application en production | Pousser un tag `vX.Y.Z` (déploiement + migrations Flyway automatiques + publication APK) | Migrations de schéma appliquées automatiquement au démarrage |
