# Projet-Violette
Plateforme web de gestion des plannings et des cachets pour gérants de compagnie artistiques et intermittents du spectacle . L'outil centralisera les disponibilités, les réservations, les vidéos de répétition et la communication entre gérants et artistes

---

## Architecture

### C4 — Contexte système

Vue d'ensemble du système Violette et de ses interactions avec les utilisateurs et services externes.

![C4 Context](docs/diagrams/c4-context.png)

### C4 — Containers

Architecture technique : frontend Flutter, backend Quarkus, bases de données et services externes.

![C4 Container](docs/diagrams/c4-container.png)

### C4 — Components (Backend)

Découpage modulaire du backend par domaine métier (violetteuser, showdate, artistbooking, cabaretcompany).

![C4 Component](docs/diagrams/c4-component.png)

### Domain-Driven Design — Bounded Contexts

Cartographie des domaines métier avec distinction Core / Supporting / Generic.

![DDD Bounded Contexts](docs/diagrams/ddd-bounded-contexts.png)

### Domain Storytelling

Flux fonctionnels principaux : déclaration de disponibilité, réservation d'artistes, gestion de compagnie.

![Domain Storytelling](docs/diagrams/domain-storytelling.png)

---

## État actuel (v0.2.0)

### Front-end (Flutter)
- Application Flutter avec architecture Stacked.
- Authentification Firebase avec gestion des rôles (gérant / artiste).
- Création et gestion des dates de spectacle (ShowDate).
- Vue Planning gérant avec calendrier et gestion des disponibilités par artiste.
- Profils utilisateurs stockés dans Firestore.
- Infrastructure de tests unitaires et intégration continue (GitHub Actions).

### Back-end (Quarkus) – v0.1.0
- Architecture modulaire par domaine (violetteuser, cabaretcompany, showdate, artistbooking).
- Stack : Quarkus 3.29, Hibernate ORM Panache, Flyway, OpenAPI/Swagger.
- Schéma SQL relationnel complet (remplace progressivement Firestore).
- Endpoint de santé : `GET /api/ping`
- Swagger UI : `http://localhost:8080/swagger-ui`
- Pas encore connecté au front (phase suivante : intégration JWT Firebase).

## Stack technique

- Front : Flutter + Stacked + Firebase Auth + Firestore
- Back : Quarkus (Java)

## Lancement rapide

Front Flutter :

```bash
cd violette_front
flutter pub get
flutter run
```

Back Quarkus :
```bash
cd violette-back
./mvnw quarkus:dev
# ou avec Maven global : mvn quarkus:dev
```

Journal des versions:

Voir le fichier [CHANGELOG.md](CHANGELOG.md)