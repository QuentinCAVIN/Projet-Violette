# Projet-Violette
Plateforme web de gestion des plannings et des cachets pour gérants de compagnie artistiques et intermittents du spectacle . L'outil centralisera les disponibilités, les réservations, les vidéos de répétition et la communication entre gérants et artistes

## État actuel (v0.2.0)

- Application Flutter avec architecture Stacked.
- Authentification Firebase avec gestion des rôles (gérant / artiste).
- Création et gestion des dates de spectacle (ShowDate).
- Vue Planning gérant avec calendrier et gestion des disponibilités par artiste.
- Profils utilisateurs stockés dans Firestore.
- Infrastructure de tests unitaires et intégration continue (GitHub Actions).
- Backend Quarkus initialisé (pas encore connecté au front).

## Stack technique

- Front : Flutter + Stacked + Firebase Auth + Firestore
- Back : Quarkus (Java)

## Lancement rapide

Front Flutter :

```bash
cd front
flutter pub get
flutter run
```

Back Quarkus:
```bash
cd back
./mvnw quarkus:dev
```

Journal des versions:

Voir le fichier [CHANGELOG.md](CHANGELOG.md)