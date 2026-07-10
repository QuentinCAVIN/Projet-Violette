# Cahier de recettes — Violette

> Projet Violette — Bloc 2 (C2.3.1). Recette fonctionnelle, structurelle et de sécurité de la version livrée.
> Référentiel de plan de test : [`docs/testing-strategy.md`](testing-strategy.md). Couverture sécurité détaillée : [`docs/securite-owasp.md`](securite-owasp.md). Plan de correction des anomalies : [`docs/plan-correction-bogues.md`](plan-correction-bogues.md).

## Objet du document

Ce cahier de recettes formalise les scénarios de test de l'application Violette, leurs **préconditions**, leurs **étapes**, le **résultat attendu** et le **résultat observé**, afin de détecter les anomalies de fonctionnement et les régressions. Conformément au critère d'évaluation, il distingue le résultat attendu (spécification) du résultat observé (exécution réelle) : c'est cette distinction qui en fait une **preuve de recette** et non un simple plan de test.

Le périmètre couvre **l'ensemble des fonctionnalités attendues** de la version livrée et les **trois natures de test** exigées :

- **Fonctionnels** — parcours métier des deux acteurs (gérant, artiste) : authentification, gestion des dates de spectacle, disponibilités, booking et confirmation.
- **Structurels** — comportement interne du contrat REST : codes HTTP, transitions de statut, règles d'unicité et de capacité, validations.
- **Sécurité** — contrôle d'accès (cloisonnement inter-compagnies, rôles), repris du harnais d'autorisation documenté dans `securite-owasp.md`.

## Méthode et conventions

### Colonnes

Chaque scénario est décrit par : **ID** · **préconditions** · **étapes** · **résultat attendu** · **résultat observé** · **statut (OK/KO)** · **anomalie liée** (référence vers le plan de correction des bogues si KO).

### Provenance du « résultat observé »

| Type de scénario | Mode d'exécution | Source du résultat observé |
|---|---|---|
| Sécurité / structurel automatisé | Tests `@QuarkusTest` (H2) exécutés en CI | Sortie de la suite de tests GitHub Actions (`backend-ci.yml`) |
| Fonctionnel manuel (UI Flutter) | Rejeu manuel sur le seed de dev | Observation réelle sur appareil/émulateur, comptes de test |

Le résultat observé des scénarios automatisés référence l'exécution CI réelle (suite verte). Le résultat observé des scénarios manuels est renseigné après rejeu effectif sur l'environnement de développement ; aucune valeur n'y est anticipée ou fabriquée.

### Environnement de recette

- **Backend** : Quarkus 3.x, profil `dev`/`firebase` (schéma `drop-and-create` + `import.sql`) en local, profil `test` (H2) pour la suite automatisée.
- **Frontend** : Flutter (APK Android), `API_BASE_URL` pointant vers le backend local (`adb reverse`) ou Fly.io.
- **Jeu de données seed** (`import.sql`) : 1 compagnie (`Dream's Production`), 1 gérant, 2 artistes, 4 dates de spectacle de novembre 2026.

### Comptes de test

| Rôle | E-mail | Mot de passe |
|---|---|---|
| Gérant | `manager@violette.test` | `123456` |
| Artiste 1 | `artiste1@violette.test` | `123456` |
| Artiste 2 | `artiste2@violette.test` | `123456` |

### Cycle de vie métier (rappel)

- **Date de spectacle** : `INQUIRY → OPTION → CONFIRMED → STAFFED` (ou `CANCELLED`, `ARCHIVED`).
- **Disponibilité** : `PENDING → AVAILABLE | IF_NEEDED | UNAVAILABLE`.
- **Réservation** : `SELECTED → PENDING_CONFIRMATION → CONFIRMED | REFUSED | CANCELLED`.

### Limites de périmètre v0.4.0 assumées (recettées telles quelles)

Ces limites sont documentées et **font partie du comportement attendu** de la version livrée. Elles sont recettées en tant que telles, sans être traitées comme des anomalies :

- Le champ « Artistes nécessaires » du formulaire de création de date est informatif : sa valeur n'est pas persistée par `POST /api/show-dates`.
- Une compagnie unique par défaut (`Dream's Production`) ; pas d'écran de création de compagnie ni de gestion multi-compagnies (le cloisonnement reste néanmoins prouvé par les tests de sécurité).
- Un booking `CONFIRMED` verrouille la modification de disponibilité de l'artiste sur la date concernée.

---

## Famille 1 — Authentification et gestion des rôles

> Nature : fonctionnel. Source du plan : `testing-strategy.md` (recettes manuelles USER-REC-01 à 04). Acteurs : gérant et artiste.

| ID | Préconditions | Étapes | Résultat attendu | Résultat observé | Statut | Anomalie |
|---|---|---|---|---|---|---|
| **AUTH-REC-01** | Profil backend déjà créé (compte seed `manager@violette.test`). Application installée, réseau disponible. | 1. Lancer l'application. 2. Saisir l'e-mail et le mot de passe du compte seed. 3. Valider la connexion. | Authentification Firebase réussie, profil backend résolu via `firebaseUid`, navigation automatique vers l'écran d'accueil (Home) correspondant au rôle. | _(à compléter — rejeu manuel)_ | | |
| **AUTH-REC-02** | Aucun profil backend pour le compte cible. Réseau disponible. | 1. Lancer l'application. 2. Effectuer une inscription avec un nouvel e-mail. 3. Renseigner le profil (rôle). 4. Fermer puis relancer l'application. | Profil créé côté backend (`POST /users`). Au relancement, session reconnue et navigation directe vers Home sans nouvelle inscription. | _(à compléter — rejeu manuel)_ | | |
| **AUTH-REC-03** | Compte valide. Réseau **coupé** au démarrage. | 1. Désactiver le réseau. 2. Lancer l'application avec une session existante. | Écran d'erreur explicite affiché. **Aucune navigation silencieuse** vers Home ; l'utilisateur n'est pas faussement considéré comme connecté. | _(à compléter — rejeu manuel)_ | | |
| **AUTH-REC-04** | Session Firebase active mais **sans** profil backend correspondant. | 1. Lancer l'application avec une session Firebase orpheline (profil backend absent). | Détection de l'incohérence : déconnexion (logout) et redirection vers l'écran de connexion (Login). Pas d'accès à Home. | _(à compléter — rejeu manuel)_ | | |
| **AUTH-REC-05** | Compte artiste seed (`artiste1@violette.test`). | 1. Se connecter avec le compte artiste. 2. Observer l'écran d'accueil et les actions disponibles. | Accueil et navigation propres au rôle ARTIST (consultation des dates à venir, déclaration de disponibilité). Aucune action réservée au gérant n'est proposée. | _(à compléter — rejeu manuel)_ | | |
| **AUTH-REC-06** | Compte gérant seed (`manager@violette.test`). | 1. Se connecter avec le compte gérant. 2. Observer l'écran d'accueil et les actions disponibles. | Accueil et navigation propres au rôle MANAGER (planning, création/gestion de dates, sélection d'artistes). | _(à compléter — rejeu manuel)_ | | |

---

## Famille 2 — Gestion des dates de spectacle (gérant)

> Nature : fonctionnel + structurel. Acteur : gérant. Domaine `showdate`. Cycle de vie `INQUIRY → OPTION → CONFIRMED → STAFFED`.

| ID | Préconditions | Étapes | Résultat attendu | Résultat observé | Statut | Anomalie |
|---|---|---|---|---|---|---|
| **DATE-REC-01** | Gérant connecté. Compagnie `Dream's Production`. | 1. Ouvrir le formulaire de création de date. 2. Renseigner lieu, horaires, cachet et autres champs de la feuille de route. 3. Valider. | Date créée et rattachée à la compagnie du gérant (`POST /api/show-dates` → 201). La date apparaît dans le planning. **Conformément à la limite v0.4.0**, le champ « Artistes nécessaires » est informatif et n'est pas persisté. | _(à compléter — rejeu manuel)_ | | |
| **DATE-REC-02** | Gérant connecté. Au moins une date existante (seed). | 1. Ouvrir le planning gérant. 2. Sélectionner une date dans le calendrier. | Le planning affiche les dates de la compagnie. La pastille du calendrier reflète le statut ; en cas de statuts mixtes sur un même jour, la priorité d'affichage `CONFIRMED > OPTION > INQUIRY > STAFFED > CANCELLED > ARCHIVED` s'applique. | _(à compléter — rejeu manuel)_ | | |
| **DATE-REC-03** | Gérant connecté. Date existante de sa compagnie. | 1. Ouvrir le détail d'une date. 2. Modifier un champ (ex. lieu ou horaire). 3. Enregistrer. | Mise à jour partielle appliquée (`PATCH /api/show-dates/{id}` → 200). Les champs non renseignés restent inchangés. | _(à compléter — rejeu manuel)_ | | |
| **DATE-REC-04** | Gérant connecté. Date existante de sa compagnie. | 1. Ouvrir le détail d'une date. 2. Déclencher la suppression. 3. Confirmer. | Date supprimée (`DELETE /api/show-dates/{id}` → 204). La date disparaît du planning. | _(à compléter — rejeu manuel)_ | | |
| **DATE-REC-05** | Gérant connecté. Date en statut `INQUIRY`. | 1. Faire évoluer le statut de la date `INQUIRY → OPTION → CONFIRMED` via l'action de changement de statut. | Les transitions du cycle de vie sont appliquées et reflétées dans le planning. Le flux minimal `INQUIRY → OPTION → CONFIRMED` (et `CONFIRMED → STAFFED`) est exécutable de bout en bout. | _(à compléter — rejeu manuel)_ | | |

---

## Famille 3 — Disponibilités artiste

> Nature : fonctionnel + structurel. Acteur : artiste. Domaine `showdate` (sous-ressource `availabilities`). Statuts `AVAILABLE | IF_NEEDED | UNAVAILABLE`.

### 3.1 — Scénarios fonctionnels (UI)

| ID | Préconditions | Étapes | Résultat attendu | Résultat observé | Statut | Anomalie |
|---|---|---|---|---|---|---|
| **DISPO-REC-01** | Artiste connecté (`artiste1@violette.test`). Dates à venir présentes (seed). | 1. Ouvrir la liste des dates disponibles côté artiste. | Seules les dates pertinentes pour l'artiste sont exposées (`GET /api/show-dates/me/available`) ; les dispos des autres artistes ne sont pas visibles. | _(à compléter — rejeu manuel)_ | | |
| **DISPO-REC-02** | Artiste connecté. Date sans disponibilité déclarée. | 1. Ouvrir une date. 2. Déclarer la disponibilité `AVAILABLE`. 3. Valider. | Disponibilité créée (`PUT /api/show-dates/{id}/availabilities/me` → 200), statut `AVAILABLE` confirmé à l'écran et annoncé (accessibilité). | _(à compléter — rejeu manuel)_ | | |
| **DISPO-REC-03** | Artiste connecté. Disponibilité `AVAILABLE` déjà déclarée sur une date. | 1. Rouvrir la date. 2. Changer la disponibilité en `UNAVAILABLE`. 3. Valider. | Disponibilité mise à jour (upsert), nouveau statut reflété. La clé composite `(show_date, artist)` garantit l'unicité : pas de doublon créé. | _(à compléter — rejeu manuel)_ | | |
| **DISPO-REC-04** | Artiste connecté. Date sur laquelle l'artiste a un booking `CONFIRMED`. | 1. Ouvrir la date concernée. 2. Tenter de modifier la disponibilité. | La modification est verrouillée (comportement v0.4.0 attendu) ; l'artiste est invité à contacter le gérant pour tout désistement. | _(à compléter — rejeu manuel)_ | | |

### 3.2 — Scénarios structurels (contrat REST, automatisés)

| ID | Préconditions | Étapes | Résultat attendu | Résultat observé | Statut | Anomalie |
|---|---|---|---|---|---|---|
| **DISPO-REC-05** | Principal JWT artiste simulé. Date existante. | `PUT /api/show-dates/{id}/availabilities/me` avec `status = AVAILABLE`. | Réponse 200, corps reflétant `showDateId`, `artistId`, `artistFirebaseUid`, `status = AVAILABLE`. | CI verte — `ShowDateControllerAvailabilitiesTest` | | |
| **DISPO-REC-06** | Aucune ligne de disponibilité pour l'artiste sur la date. | `GET /api/show-dates/{id}/availabilities/me`. | Réponse 200 avec statut logique `PENDING` (aucune ligne persistée n'est nécessaire). | CI verte — `ShowDateControllerAvailabilitiesTest` | | |
| **DISPO-REC-07** | Principal JWT artiste simulé. | `PUT /api/show-dates/{id}/availabilities/me` avec `status = PENDING`. | Réponse 400 : le statut `PENDING` ne peut pas être envoyé explicitement (réservé à l'initialisation). | CI verte — `ShowDateControllerAvailabilitiesTest` | | |
| **DISPO-REC-08** | Principal **manager** (mauvais rôle). | `PUT /api/show-dates/{id}/availabilities/me`. | Réponse 403 : endpoint réservé au rôle ARTIST. | CI verte — `ShowDateControllerAvailabilitiesTest` | | |

---

## Famille 4 — Booking et confirmation

> Nature : fonctionnel + structurel. Acteurs : gérant (sélection, envoi) et artiste (réponse). Domaine `artistbooking`. Cycle de vie `SELECTED → PENDING_CONFIRMATION → CONFIRMED | REFUSED`.

### 4.1 — Scénarios fonctionnels (UI)

| ID | Préconditions | Étapes | Résultat attendu | Résultat observé | Statut | Anomalie |
|---|---|---|---|---|---|---|
| **BOOK-REC-01** | Gérant connecté. Date en statut `OPTION`. Artiste `AVAILABLE` sur cette date. | 1. Ouvrir la date. 2. Présélectionner l'artiste disponible. | Réservation créée en statut `SELECTED` (`POST /api/artist-bookings` → 201). Présélection sans engagement : l'artiste n'est pas encore notifié. | _(à compléter — rejeu manuel)_ | | |
| **BOOK-REC-02** | Gérant connecté. Date en statut `CONFIRMED`. Au moins un booking `SELECTED`. | 1. Ouvrir la date. 2. Déclencher l'envoi des demandes de confirmation. | Tous les bookings `SELECTED` de la date passent en `PENDING_CONFIRMATION` (`POST …/send-confirmations` → 200). | _(à compléter — rejeu manuel)_ | | |
| **BOOK-REC-03** | Artiste connecté. Une demande `PENDING_CONFIRMATION` le concernant. | 1. Ouvrir la demande. 2. Accepter. | Booking passe en `CONFIRMED` (`PATCH /api/artist-bookings/{id}/respond` → 200). Engagement de l'artiste enregistré et affiché. | _(à compléter — rejeu manuel)_ | | |
| **BOOK-REC-04** | Artiste connecté. Une demande `PENDING_CONFIRMATION` le concernant. | 1. Ouvrir la demande. 2. Refuser. | Booking passe en `REFUSED`. L'état est reflété côté gérant. | _(à compléter — rejeu manuel)_ | | |
| **BOOK-REC-05** | Gérant connecté. Un booking en statut `SELECTED`. | 1. Ouvrir la date. 2. Désélectionner l'artiste. | Booking supprimé (`DELETE /api/artist-bookings/{id}` → 204). L'artiste n'est plus présélectionné. | _(à compléter — rejeu manuel)_ | | |
| **BOOK-REC-06** | Gérant connecté. Une date avec plusieurs bookings. | 1. Ouvrir la date. 2. Consulter la liste des réservations. | La liste des bookings de la date est affichée avec leurs statuts (`GET …/show-dates/{id}` → 200). | _(à compléter — rejeu manuel)_ | | |

### 4.2 — Scénarios structurels (règles métier, contrat REST)

| ID | Préconditions | Étapes | Résultat attendu | Résultat observé | Statut | Anomalie |
|---|---|---|---|---|---|---|
| **BOOK-REC-07** | Date en statut `INQUIRY` ou `STAFFED`. | `POST /api/artist-bookings` (présélection). | Sélection refusée : la présélection n'est autorisée que sur une date `OPTION` ou `CONFIRMED` (réponse d'erreur métier, pas de booking créé). | CI verte — tests service `artistbooking` | | |
| **BOOK-REC-08** | Date non `CONFIRMED` (ex. `OPTION`) avec bookings `SELECTED`. | `POST …/send-confirmations`. | Envoi refusé : les demandes fermes ne sont autorisées que sur une date `CONFIRMED`. | CI verte — tests service `artistbooking` | | |
| **BOOK-REC-09** | Artiste déjà réservé une fois sur la date. | Seconde tentative de booking du même artiste sur la même date. | Réservation refusée (409) : unicité de réservation par date garantie. | CI verte — tests service `artistbooking` | | |
| **BOOK-REC-10** | Booking dont le statut n'est plus `SELECTED`. | `DELETE /api/artist-bookings/{id}`. | Désélection refusée (409) : la suppression n'est possible qu'en statut `SELECTED`. | CI verte — tests service `artistbooking` | | |

---

## Famille 5 — Sécurité et tests structurels d'autorisation

> Nature : sécurité + structurel. Couvre OWASP A01 (Broken Access Control). Harnais automatisé `*OwnershipTest` exécuté en CI sur des **fixtures réelles à deux compagnies** (seul le JWT est simulé ; la chaîne de résolution `firebaseUid → utilisateur → compagnie` s'exécute réellement). Inventaire endpoint→test détaillé en annexe de [`docs/securite-owasp.md`](securite-owasp.md). Ordre de vérification systématique : **404** (ressource inexistante) → **403** (ressource d'autrui) → métier.

Les scénarios ci-dessous sont regroupés par domaine pour la lisibilité ; chaque ligne correspond à un ensemble de cas d'autorisation couverts par la classe de test indiquée. Le détail endpoint par endpoint figure dans l'annexe OWASP, à laquelle ce cahier renvoie.

| ID | Préconditions | Étapes | Résultat attendu | Résultat observé | Statut | Anomalie |
|---|---|---|---|---|---|---|
| **SEC-REC-01** | Deux compagnies A et B avec leurs gérants. Gérant A authentifié. Domaine `showdate`. | Pour chaque endpoint `showdate` (lecture, liste par compagnie, modification, suppression, création, besoins, disponibilités) : viser une ressource de la compagnie A, puis une ressource de la compagnie B. | Ressource propre (A) → succès (200/201/204). Ressource d'autrui (B) → **403**. Ressource inexistante → **404** (avant le contrôle d'ownership). Aucune mutation indésirable. | CI verte — `ShowDateControllerOwnershipTest` | | |
| **SEC-REC-02** | Deux compagnies A et B. Gérant A authentifié. Domaine `artistbooking`. | Pour chaque endpoint `artistbooking` (sélection, désélection, envoi des confirmations, lecture des bookings d'une date) : viser une date de A, puis une date de B. | Date propre (A) → succès. Date d'autrui (B) → **403**. Les refus de mutation ne laissent **aucun effet de bord** (aucun booking créé / booking conservé). | CI verte — `ArtistBookingControllerOwnershipTest` | | |
| **SEC-REC-03** | Booking appartenant à un autre artiste. Artiste authentifié distinct. | `PATCH /api/artist-bookings/{id}/respond` sur un booking d'autrui. | Réponse **403** : un artiste ne peut répondre qu'à ses propres demandes. Statut du booking inchangé. | CI verte — `ArtistBookingControllerOwnershipTest` | | |
| **SEC-REC-04** | Deux compagnies A et B. Gérant A authentifié. Domaine `cabaretcompany`. | Pour chaque endpoint `cabaretcompany` (lecture compagnie, membres, revues) : viser la compagnie A, puis la compagnie B. | Compagnie propre (A) → succès. Compagnie d'autrui (B) → **403**. Compagnie inexistante → **404**. | CI verte — `CabaretCompanyControllerOwnershipTest` | | |
| **SEC-REC-05** | Gérant A authentifié. Création de date avec un `companyId` falsifié pointant vers la compagnie B. | `POST /api/show-dates` avec un `companyId` ne correspondant pas à la compagnie du gérant. | La compagnie est dérivée du token, pas du paramètre client : le `companyId` incohérent est rejeté, **aucune date n'est créée** dans la compagnie tierce. | CI verte — `ShowDateControllerOwnershipTest` | | |
| **SEC-REC-06** | Utilisateur avec mauvais rôle (ex. artiste ciblant un endpoint MANAGER, ou inverse). | Appel d'un endpoint protégé par `@RolesAllowed` avec un rôle non autorisé. | Réponse **403** : le contrôle de rôle s'ajoute au contrôle d'ownership. | CI verte — tests de sécurité par contrôleur | | |
| **SEC-REC-07** | Requête non authentifiée (sans JWT valide). | Appel d'un endpoint protégé sans jeton. | Réponse **401** : accès refusé en l'absence d'authentification. | CI verte — tests contrôleur (cas 401) | | |
| **SEC-REC-08** | Exception non gérée provoquée côté serveur. | Déclencher une erreur interne non mappée. | Réponse **500 neutre** (corps JSON sans détail technique, identifiant de corrélation) ; les exceptions JAX-RS (400/404/409) conservent leur statut d'origine. Pas de fuite d'information technique au client. | CI verte — `GlobalExceptionMapperTest` | | |

---

## Synthèse de couverture

### Couverture des fonctionnalités attendues

| Fonctionnalité (version livrée) | Famille / scénarios |
|---|---|
| Authentification et résolution de profil | Famille 1 (AUTH-REC-01 à 04) |
| Distinction des rôles gérant / artiste | Famille 1 (AUTH-REC-05, 06) ; Famille 5 (SEC-REC-06) |
| Création / consultation / modification / suppression de dates | Famille 2 (DATE-REC-01 à 04) |
| Cycle de vie des statuts de date | Famille 2 (DATE-REC-05) |
| Consultation du planning gérant | Famille 2 (DATE-REC-02) |
| Consultation des dates côté artiste | Famille 3 (DISPO-REC-01) |
| Déclaration et mise à jour de disponibilité | Famille 3 (DISPO-REC-02, 03, 05 à 08) |
| Verrouillage de disponibilité après confirmation | Famille 3 (DISPO-REC-04) |
| Présélection d'artiste (booking) | Famille 4 (BOOK-REC-01, 07) |
| Envoi des demandes de confirmation | Famille 4 (BOOK-REC-02, 08) |
| Réponse artiste (accepter / refuser) | Famille 4 (BOOK-REC-03, 04) |
| Désélection | Famille 4 (BOOK-REC-05, 10) |
| Consultation des réservations d'une date | Famille 4 (BOOK-REC-06) |
| Unicité de réservation et de disponibilité | Famille 3 (DISPO-REC-03) ; Famille 4 (BOOK-REC-09) |
| Cloisonnement inter-compagnies (A01) | Famille 5 (SEC-REC-01 à 05) |
| Authentification / autorisation HTTP | Famille 5 (SEC-REC-06, 07) |
| Neutralisation des erreurs serveur | Famille 5 (SEC-REC-08) |

### Couverture par nature de test (conformité au plan défini)

| Nature | Plan de référence (`testing-strategy.md`) | Scénarios |
|---|---|---|
| **Fonctionnel** | Recettes manuelles USER-REC + parcours métier des deux acteurs | Familles 1, 2, 3.1, 4.1 |
| **Structurel** | Tests contrôleur (happy path 200, 404, 401) + tests service (règles métier, transitions, unicité, capacité) | Familles 3.2, 4.2, et volet structurel de la Famille 5 |
| **Sécurité** | Harnais d'autorisation `*OwnershipTest` (cf. `securite-owasp.md`) | Famille 5 |

---

## Traçabilité des anomalies

Tout scénario en statut **KO** est qualifié, analysé et traité dans le plan de correction des bogues ([`docs/plan-correction-bogues.md`](plan-correction-bogues.md)). La colonne « anomalie liée » de chaque tableau référence l'identifiant de l'anomalie correspondante.
