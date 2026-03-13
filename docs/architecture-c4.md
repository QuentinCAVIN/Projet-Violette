# Documentation des diagrammes C4 — Violette

## 1. Introduction

La **modélisation C4** (Context, Containers, Components, Code) permet de décrire une architecture logicielle à plusieurs niveaux d’abstraction, du système dans son environnement jusqu’aux composants internes. Violette utilise cette approche pour que les parties prenantes (équipe projet, examinateurs) comprennent rapidement le périmètre du système, son découpage technique et la structure du backend.

Les trois niveaux documentés dans ce projet sont :

- **System Context (Contexte système)** — Qui utilise Violette et avec quels systèmes externes elle interagit.
- **Container** — Comment la solution est découpée en applications et services (frontend, backend, bases de données).
- **Component** — Comment le backend est structuré en couches et en domaines métier.

Les diagrammes existants sont des PNG présents dans le dépôt ; ce document les explique et les relie à l’architecture réelle du projet.

---

## 2. Diagramme C4 — System Context

### Ce que montre le diagramme

Le diagramme de **contexte système** place **Violette** au centre : c’est l’application dans son ensemble, sans détailler encore sa composition technique. Il répond à la question : *« Qui utilise le système et quels acteurs ou systèmes externes interagissent avec lui ? »*

### Acteurs principaux

Les acteurs directs du diagramme sont les utilisateurs qui ont un compte et utilisent Violette :

- **Gérant (Manager)** — Responsable de la compagnie. Il crée les dates de spectacle, réserve les artistes, partage des contenus (ex. vidéos de répétition) et communique avec les équipes. C’est un utilisateur direct de Violette.
- **Artiste** — Membre ou collaborateur. Il propose ses disponibilités sur les dates de spectacle, consulte les contenus partagés (ex. vidéos de répétition) et communique avec l’équipe. Lui aussi utilise Violette directement.

### Système externe

- **Firebase Authentication** — Service externe utilisé par Violette pour l’authentification. Il délivre des jetons (tokens) permettant d’identifier l’utilisateur dans l’application. Violette s’appuie sur ce service pour sécuriser l’accès ; elle ne gère pas elle-même les mots de passe ni la création de comptes d’authentification.

### Place de Violette

Violette est décrite comme l’**application centralisant la planification des spectacles et la coordination entre gérants et artistes**. À ce niveau, on ne distingue pas encore le frontend (Flutter) du backend (Quarkus) : ils forment un seul système du point de vue des utilisateurs et de Firebase.

---

## 3. Diagramme C4 — Container

### Ce que montre le diagramme

Le diagramme **Container** décompose Violette en **conteneurs** : les principales applications et bases de données qui composent la solution. Chaque conteneur a une responsabilité claire et des échanges explicites avec les autres.

### Découpage principal

| Conteneur | Rôle |
|-----------|------|
| **Application mobile Flutter** | Interface pour les **artistes** : consultation et déclaration des disponibilités, réponse aux demandes de réservation, consultation du planning. Adaptée au travail nomade. |
| **Application desktop Flutter** | Interface pour les **gérants** : création des dates de spectacle, planification, réservation des artistes, partage de contenus. Adaptée au travail en bureau. |
| **Backend Java / Quarkus** | Cœur métier : API REST consommée par le mobile et le desktop. Gère les utilisateurs, les dates de spectacle, les disponibilités, les réservations, les compagnies. Communique avec la base de données et avec Firebase pour valider l’identité des utilisateurs. |
| **Base de données relationnelle (MySQL / H2 en test)** | Persistance des données métier : utilisateurs, rôles, dates de spectacle, disponibilités, réservations, compagnies, revues. |

### Échanges

- Les **gérants** utilisent l’application **desktop** ; les **artistes** utilisent l’application **mobile**. Les deux applications envoient les requêtes utilisateur au **backend** (HTTP/HTTPS, API REST).
- Le **backend** valide l’identité en s’appuyant sur **Firebase Authentication** (jetons fournis par le client applicatif). Il lit et écrit les données métier dans la **base relationnelle**.

### Cohérence avec le projet

Ce découpage reflète l’architecture réelle de la V1 : frontend Flutter (mobile et desktop), backend Quarkus exposant une API REST, une seule base relationnelle pour la donnée métier, Firebase pour l’authentification. D’éventuelles évolutions (ex. autres services ou bases) ne font pas partie de l’architecture actuelle représentée dans la vue Container.

---

## 4. Diagramme C4 — Component

### Ce que montre le diagramme

Le diagramme **Component** se concentre sur l’**intérieur du backend** Quarkus. Il met en évidence l’**architecture en couches** (Controller → Service → Repository) et les **modules métier** (domaines) qui structurent le code.

### Composant de sécurité

Un **composant Security** (ou équivalent) figure en entrée du backend : il est paramétré pour utiliser Firebase et sécurise l’accès aux endpoints. Concrètement, dans le projet, cela correspond au package `security/` : validation du JWT Firebase, enrichissement de l’identité avec les rôles chargés depuis la base, et fourniture du principal courant aux controllers.

### Domaines métier (couches Controller, Service, Repository)

Chaque domaine métier est représenté par un ensemble de composants typiques :

- **violetteuser** — Gestion des utilisateurs et des rôles (création de compte backend, chargement des rôles pour la sécurité). Données : utilisateurs, rôles.
- **showdate** — Gestion des dates de spectacle et du planning : création de dates, besoins par compétence, disponibilités des artistes. Données : dates de spectacle, besoins artistiques, disponibilités.
- **artistbooking** — Gestion des réservations des artistes : sélection, envoi des demandes de confirmation, réponses (acceptation / refus). Données : réservations et leur cycle de vie.
- **cabaretcompany** — Gestion des compagnies de cabaret et des revues associées. Données : compagnies, revues, membres.

Le diagramme peut également représenter des modules **communication** et **video** (messagerie, vidéos de répétition). Ces fonctionnalités sont prévues pour des versions ultérieures ; en V1, les domaines effectivement implémentés sont **violetteuser**, **cabaretcompany**, **showdate** et **artistbooking**.

### Lien avec le code

Cette vue est alignée avec l’organisation réelle des packages sous `io.violette` :

- Chaque domaine possède son `controller`, `service`, `repository`, ainsi que `model`, `dto`, `mapper` et `exception`.
- Le flux des requêtes respecte bien : **Controller** (HTTP, délégation) → **Service** (logique métier) → **Repository** (accès base). Les controllers ne contiennent pas de logique métier ; les repositories ne font que de la persistance.
- Les endpoints de santé (ping, liveness) sont regroupés dans un module technique type **health**, à part des domaines métier.

---

## 5. Cohérence avec le projet réel

Les diagrammes C4 sont cohérents avec l’architecture effectivement développée pour les raisons suivantes.

- **Architecture en couches** — Le backend suit strictement Controller → Service → Repository ; aucune logique métier dans le controller, aucun accès base en dehors du repository. Le diagramme Component reflète cette séparation.
- **Bounded contexts / domaines** — Les packages `violetteuser`, `cabaretcompany`, `showdate` et `artistbooking` correspondent aux contextes métier décrits dans les diagrammes. Chaque domaine est un module clairement identifié avec ses couches.
- **Séparation frontend / backend** — Le frontend Flutter (mobile et desktop) consomme une API REST exposée par le backend Quarkus ; le diagramme Container montre bien cette frontière et les échanges HTTP.
- **Firebase pour l’identité** — L’authentification repose sur Firebase (JWT) ; le backend valide le token et enrichit l’identité avec les rôles stockés en base. Le contexte et le container montrent Firebase comme système externe utilisé par Violette.
- **Base relationnelle pour la donnée métier** — En V1, une seule base relationnelle (MySQL en production, H2 en test) stocke utilisateurs, compagnies, dates de spectacle, disponibilités et réservations. La vue Container reflète cet état : aucun autre conteneur de persistance n’est présent.

Un examinateur peut donc s’appuyer sur les trois diagrammes pour comprendre le positionnement de Violette, son découpage en conteneurs et la structure modulaire du backend, tout en vérifiant la correspondance avec le code sous `violette-back` et la documentation dans `violette-back/ARCHITECTURE.md`.

---

## 6. Diagramme C4 — Zoom composant (niveau 4)

Une quatrième vue propose un **zoom** sur un domaine métier du backend : le domaine **artistbooking**. Elle répond à la question : *« À l’intérieur de ce domaine, quels composants (classes ou modules) existent et comment interagissent-ils ? »*

### Ce que montre le diagramme

- **ArtistBookingController** — couche REST (JAX-RS), endpoints de sélection, désélection, envoi de confirmations, réponses artiste.
- **ArtistBookingService** — logique métier (règles de capacité, disponibilité, transitions de statut).
- **ArtistBookingRepository** — accès BDD (Panache).
- **ArtistBookingEntity** — aggregate root (réservation, BookingTimeline, BookingStatus).
- **BookingStatusChangedEvent** — événement CDI émis à chaque transition de statut.
- **BookingStatusChangedObserver** — observateur qui réagit à l’événement (pattern Observer).
- **ArtistBookingMapper** — mapping Entity ↔ DTO (MapStruct).

Les relations (délégation, persist, fire, notifie) reflètent le flux réel du code et illustrent la séparation des couches ainsi que le découplage via l’événement CDI.

### Source et génération du PNG

Le diagramme est défini en **PlantUML** (C4-PlantUML) pour rester versionnable et reproductible. Le PNG se génère à partir du fichier source.

| Fichier source | PNG généré | Procédure |
|----------------|------------|-----------|
| `docs/diagrams/c4-component-artistbooking.puml` | `docs/diagrams/c4-component-artistbooking.png` | Voir [docs/diagrams/README.md](diagrams/README.md) (Docker, CLI, ou en ligne). |

---

## 7. Emplacement des diagrammes

Les fichiers des diagrammes C4 se trouvent dans le dépôt aux emplacements suivants :

| Niveau | Fichier | Remarque |
|--------|---------|----------|
| System Context | `docs/diagrams/c4-context.png` | — |
| Container | `docs/diagrams/c4-container.png` | — |
| Component | `docs/diagrams/c4-component.png` | — |
| Zoom composant (niveau 4) | `docs/diagrams/c4-component-artistbooking.puml` → `.png` | PNG à générer depuis le .puml (voir [docs/diagrams/README.md](diagrams/README.md)) |

Ils sont référencés dans le **README** à la racine du projet, dans la section « Architecture ». La documentation détaillée du backend (couches, packages, sécurité, patterns) est dans **`violette-back/ARCHITECTURE.md`**.
