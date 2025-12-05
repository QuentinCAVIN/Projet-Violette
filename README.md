# Projet-Violette
Plateforme web de gestion des plannings et des cachets pour gérants de compagnie artistiques et intermittents du spectacle . L'outil centralisera les disponibilités, les réservations, les vidéos de répétition et la communication entre gérants et artistes

## État actuel (v0.1.0)

- Application Flutter avec architecture Stacked.
- Authentification Firebase (inscription, connexion, déconnexion).
- Messages d’erreur gérés sur les écrans Login / Register.
- Profil utilisateur stocké dans Firestore et affichage du nom dans la Home.
- Backend Quarkus initialisé (pas encore utilisé par le front).

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