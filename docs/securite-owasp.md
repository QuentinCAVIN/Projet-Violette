# Sécurité — Couverture OWASP Top 10

> Projet Violette — Bloc 2 (C2.2.3). Audit du backend Quarkus au regard de l'OWASP Top 10 (2021).
> Méthode : pour chaque catégorie, on indique le risque, la mesure en place dans Violette, la preuve, et le cas échéant la limite assumée.
> Échelle de statut : **Couvert** · **Partiel** · **Non applicable** · **Risque assumé** (limite documentée, hors périmètre V1).

## Synthèse

| # | Catégorie OWASP 2021 | Statut | Mesure principale |
|---|---|---|---|
| A01 | Broken Access Control | **Couvert** | Garde d'ownership compagnie centralisée + tests d'accès inter-compagnies |
| A02 | Cryptographic Failures | **Couvert** | TLS de bout en bout (Fly.io, Aiven), secrets hors code, pas de crypto maison |
| A03 | Injection | **Couvert** | Requêtes paramétrées Panache, validation Bean Validation, ORM |
| A04 | Insecure Design | **Partiel** | Séparation des couches, règles métier au service, modèle de rôles |
| A05 | Security Misconfiguration | **Couvert** | CORS restreint par profil, Swagger/OpenAPI désactivés en prod |
| A06 | Vulnerable & Outdated Components | **Partiel** | Versions récentes (Quarkus 3.29.3, Java 21) ; suivi automatisé via Dependabot (Maven, pub, actions) + alertes CVE |
| A07 | Identification & Auth Failures | **Couvert** | Firebase Auth + OIDC, validation JWT (signature/issuer/audience) |
| A08 | Software & Data Integrity Failures | **Partiel** | CI/CD sur tag, secrets GitHub, signature APK ; SBOM non formalisé |
| A09 | Logging & Monitoring Failures | **Couvert** (logs) · monitoring Bloc 4 | Logging SLF4J structuré + mapper d'exception global (réponses 500 neutralisées) ; alerting prévu Bloc 4 |
| A10 | Server-Side Request Forgery (SSRF) | **Non applicable** | Pas de requête sortante pilotée par une entrée utilisateur |

---

## Détail par catégorie

### A01 — Broken Access Control · Couvert

**Risque.** Un utilisateur agit sur des ressources hors de son périmètre (ici : un gérant accède aux données d'une autre compagnie).

**Mesure.** Contrôle d'appartenance (ownership) appliqué côté service sur l'ensemble des opérations sensibles, via une garde centralisée `ManagerCompanyResolver.assertCurrentManagerOwnsCompany(companyId)`. Tout accès inter-compagnies renvoie HTTP 403 ; l'ordre est systématiquement 404 (ressource inexistante) puis 403 (ressource d'autrui). La résolution part du JWT : `firebaseUid → utilisateur backend → compagnie`. Côté artiste, `respondToRequest` vérifie que le booking appartient bien à l'artiste authentifié (403 sinon).

**Périmètre couvert.** Domaines `showdate` (lecture, mutation, création, besoins, disponibilités), `artistbooking` (sélection, désélection, confirmations, lecture manager, réponse artiste) et `cabaretcompany` (lecture compagnie, membres, revues).

**Preuve.** Suite de tests d'autorisation dédiée (`*OwnershipTest`) : pour chaque endpoint, un cas « propre compagnie → succès » et un cas « autre compagnie → 403 », sur des fixtures réelles à deux compagnies/deux managers (seul le JWT est simulé ; la chaîne de résolution s'exécute réellement). Les refus de mutation vérifient l'absence d'effet de bord (aucune ligne créée/supprimée). Voir l'inventaire de couverture en annexe.

**Limite assumée.** Une règle transitoire rattache les managers à une compagnie par défaut unique ; le multi-compagnie n'est donc pas exerçable de bout en bout en production aujourd'hui. La cloison est néanmoins prouvée par les tests. L'onboarding compagnie (écrans de création) est une évolution post-V1 (voir dette technique).

### A02 — Cryptographic Failures · Couvert

**Risque.** Données sensibles exposées en clair (transit ou repos), usage de cryptographie faible ou maison.

**Mesure.** Les échanges sont chiffrés de bout en bout : HTTPS/TLS entre le client et le backend (Fly.io), TLS entre le backend et la base MySQL managée (Aiven). Le projet n'implémente aucune cryptographie maison : la validation des JWT s'appuie sur les clés publiques Firebase (JWKS) via la bibliothèque OIDC. Aucun mot de passe applicatif n'est stocké côté backend : l'authentification est déléguée à Firebase Auth, le backend ne gère que des profils et des rôles. Les secrets (identifiants base, clés de signature) ne sont pas dans le code : ils sont injectés via les secrets GitHub Actions et les variables d'environnement Fly.io, et les fichiers sensibles (`*.jks`, `*.b64`, `key.properties`, `google-services.json`) sont exclus du dépôt par `.gitignore`.

**Limite.** Les données personnelles stockées (nom, e-mail, rôles) ne sont pas chiffrées au repos au niveau applicatif (seul le chiffrement au niveau de l'hébergeur s'applique) — acceptable pour la sensibilité des données V1, à réévaluer si des données plus sensibles sont ajoutées.

### A03 — Injection · Couvert

**Risque.** Injection SQL, de commande, ou d'expression via des entrées non maîtrisées.

**Mesure.** L'accès aux données passe exclusivement par Hibernate ORM Panache avec des **requêtes paramétrées** : les valeurs utilisateur sont liées par paramètres nommés ou positionnels (`find("company.id", companyId)`, `setParameter("showDateId", …)`), jamais concaténées dans une requête. Aucune requête SQL native construite par concaténation de chaîne n'est utilisée. Les entrées sont validées en amont par Bean Validation (Hibernate Validator, `@Valid` + contraintes Jakarta au niveau des contrôleurs). La sérialisation JSON est gérée par Jackson via `quarkus-rest-jackson`.

**Preuve.** Repositories Panache du projet (requêtes paramétrées uniquement) ; contraintes de validation sur les DTOs d'entrée.

### A04 — Insecure Design · Partiel

**Risque.** Défauts de conception (absence de contrôle par design, logique métier exploitable).

**Mesure.** Architecture en couches stricte (Controller → Service → Repository) : aucune logique métier dans les contrôleurs, aucun accès base hors repository, les entités JPA ne sortent pas de la couche service (DTOs en frontière). Les règles d'autorisation sont placées au niveau service (et non au contrôleur), ce qui évite les contournements par appel direct. Le modèle de rôles (`ARTIST`, `MANAGER`) a sa source de vérité en base backend, pas dans les claims Firebase (qui pourraient être manipulés côté client).

**Limite assumée.** Pas de modélisation formelle des menaces (threat modeling) ni de revue de conception sécurité documentée à ce stade ; la conception sécurisée repose sur l'application cohérente des patterns d'architecture. À formaliser comme axe d'amélioration.

### A05 — Security Misconfiguration · Couvert

**Risque.** Configuration permissive en production (CORS ouvert, surfaces de debug exposées).

**Mesure.** Configuration par profil Quarkus :
- **CORS** : permissif en dev/test, restreint en production via la variable `CORS_ORIGINS` (défaut restrictif, jamais `*`). L'APK Android natif n'est pas soumis à CORS ; la restriction protège le futur front web.
- **Swagger UI / OpenAPI** : désactivés en production. `swagger-ui.always-include` et `smallrye-openapi.enable` sont `false` par défaut (propriétés build-time), réactivés uniquement en dev/test. L'image de production étant construite en profil par défaut, ni l'UI `/swagger-ui` ni la spec `/q/openapi` ne sont exposées en prod.
- **OIDC** : activé uniquement en profil prod ; en profil par défaut, les endpoints authentifiés renvoient 403 sans token.

**Vérification post-déploiement.** Au prochain tag de release : `/swagger-ui` et `/q/openapi` doivent renvoyer 404 ; une requête avec une origine illégitime ne doit pas recevoir d'en-tête `Access-Control-Allow-Origin`.

### A06 — Vulnerable and Outdated Components · Partiel

**Risque.** Usage de dépendances obsolètes ou vulnérables.

**Mesure.** Les composants principaux sont récents (Quarkus 3.29.3, Java 21, MapStruct 1.6.3). Les dépendances sont gérées par le BOM Quarkus (versions cohérentes et alignées) et par `pubspec.lock` côté Flutter (versions verrouillées). La CI build et teste à chaque modification. Un suivi automatisé des dépendances est en place via **Dependabot** (`.github/dependabot.yml`), couvrant trois écosystèmes — Maven (backend), pub (Flutter) et github-actions (workflows) — avec un scan hebdomadaire qui ouvre des pull requests de mise à jour. Les **alertes de sécurité Dependabot** (basées sur la GitHub Advisory Database / CVE) sont activées sur le dépôt, ainsi que les mises à jour de sécurité automatiques.

**Limite assumée.** Le suivi des versions et la détection des CVE connues sont désormais outillés. Il reste à formaliser le **processus de traitement** des PR Dependabot (cadence de revue, critères de merge, gestion des montées de version majeures) ; il n'y a pas de scan SAST/DAST applicatif au-delà de l'analyse de dépendances. Axe d'amélioration identifié.

### A07 — Identification and Authentication Failures · Couvert

**Risque.** Authentification faible, gestion de session défaillante.

**Mesure.** L'authentification est déléguée à **Firebase Auth** (fournisseur d'identité éprouvé) : création de compte, connexion et émission du JWT côté client. Le backend ne gère pas de mots de passe. Les JWT sont validés par Quarkus OIDC : vérification de la signature via les clés publiques Firebase (JWKS), de l'`issuer`, de l'`audience` et de l'expiration. Les rôles métier sont chargés depuis la base backend (source de vérité) et non depuis des claims côté client, via un augmentor d'identité. Les endpoints sont protégés par `@RolesAllowed` / `@Authenticated`.

**Preuve.** Flux d'authentification documenté (`violette-back/ARCHITECTURE.md`) ; configuration OIDC par profil ; tests d'accès par rôle (un ARTIST sur un endpoint MANAGER reçoit 403).

### A08 — Software and Data Integrity Failures · Partiel

**Risque.** Altération de l'intégrité de la chaîne de build/déploiement.

**Mesure.** Le déploiement de production est déclenché uniquement par un **tag versionné** (`v*.*.*`), distinguant la CI continue de la release. L'image Docker est construite et publiée sur GHCR par GitHub Actions (chaîne reproductible). L'APK Android est **signé** (keystore en secret GitHub) et publié via GitHub Releases. Les secrets de signature et de déploiement sont stockés comme secrets GitHub Actions, hors du dépôt.

**Limite assumée.** Pas de SBOM (Software Bill of Materials) ni de signature/attestation des artefacts (type Sigstore) à ce stade. La vérification d'intégrité repose sur la chaîne GitHub Actions et la signature APK. À formaliser comme axe d'amélioration.

### A09 — Security Logging and Monitoring Failures · Couvert (logging) / monitoring renvoyé au Bloc 4

**Risque.** Absence de traces exploitables en cas d'incident, détection tardive, ou fuite d'information technique via les messages d'erreur.

**Mesure.**
- **Journalisation** : logging SLF4J structuré sur l'ensemble des domaines, avec le `firebaseUid` comme contexte d'identification, et journalisation des refus d'accès (les gardes d'ownership loggent les tentatives inter-compagnies). Les niveaux de log sont paramétrés par profil. Aucune donnée sensible (token, mot de passe) n'est journalisée.
- **Neutralisation des erreurs internes** : un mapper d'exception global (`GlobalExceptionMapper`, `ExceptionMapper<Throwable>` de priorité basse) intercepte les exceptions non gérées et renvoie une réponse HTTP 500 **neutre** (corps JSON sans détail technique, avec un identifiant de corrélation), tandis que la stacktrace complète est journalisée côté serveur (niveau ERROR) avec ce même identifiant. Cela évite toute fuite d'information technique au client (recoupement avec A01) tout en conservant la traçabilité serveur. Les exceptions JAX-RS portant leur propre statut (`WebApplicationException`, ex. 400/404/409) ne sont pas transformées : leur réponse d'origine est relayée. Les 15 mappers métier restent prioritaires (sélection par spécificité de type JAX-RS).

**Preuve.** `GlobalExceptionMapperTest` vérifie qu'une exception non mappée renvoie 500 sans détail technique, qu'un `BadRequestException` reste en 400, et qu'une exception métier (`ShowDateNotFoundException`) conserve son 404 — non-régression validée en CI (197 tests verts).

**Limite assumée (renvoyée au Bloc 4).** Le logging sert le diagnostic et la neutralisation des erreurs, mais la **détection de sécurité active** — monitoring centralisé, alerting, journal d'audit dédié aux événements de sécurité — relève du **Bloc 4** (supervision, alerting, consignation des anomalies). C'est une suite identifiée, pas un oubli.

### A10 — Server-Side Request Forgery (SSRF) · Non applicable

**Risque.** Le serveur est amené à émettre des requêtes vers des URL contrôlées par l'attaquant.

**Analyse.** Le backend n'effectue pas de requête HTTP sortante dont la cible serait dérivée d'une entrée utilisateur. Les seules connexions sortantes sont vers des cibles fixes et configurées (base MySQL Aiven, clés publiques Firebase JWKS). La catégorie ne s'applique donc pas au périmètre actuel. À réévaluer si une fonctionnalité d'import par URL ou d'appel à un service tiers piloté par l'utilisateur était ajoutée.

---

## Bilan

Les dix catégories de l'OWASP Top 10 (2021) ont été passées en revue. Sept sont couvertes (A01, A02, A03, A05, A07, A09 sur son volet logging, et A10 par non-applicabilité) ; trois sont partiellement couvertes avec des limites explicitement documentées et renvoyées vers des axes d'amélioration ou le Bloc 4 (A04, A06, A08). Les deux failles qui présentaient un risque concret au démarrage du projet — A01 (contrôle d'accès) et A05 (configuration) — ont fait l'objet de corrections dédiées, testées et tracées. La couverture privilégie l'honnêteté (statut nuancé, limites assumées) à une conformité de façade.

## Annexe — Inventaire de couverture des tests d'autorisation (A01)

| Domaine | Endpoint | Test | Codes vérifiés |
|---|---|---|---|
| showdate | `GET /show-dates/{id}` | `ShowDateControllerOwnershipTest` | 200 / 403 / 404 |
| showdate | `GET /show-dates/company/{id}` | idem | 200 / 403 |
| showdate | `DELETE /show-dates/{id}` | idem | 204 / 403 |
| showdate | `PATCH /show-dates/{id}` | idem | 200 / 403 |
| showdate | `POST /show-dates` | idem | 201 / 403 (+ aucune création) |
| showdate | `POST/GET /show-dates/{id}/skill-requirements` | idem | 201/200 / 403 |
| showdate | `GET /show-dates/{id}/availabilities` | idem | 200 / 403 |
| artistbooking | `POST /artist-bookings` | `ArtistBookingControllerOwnershipTest` | 201 / 403 (+ aucun booking) |
| artistbooking | `DELETE /artist-bookings/{id}` | idem | 204 / 403 (+ booking conservé) |
| artistbooking | `POST …/send-confirmations` | idem | 200 / 403 |
| artistbooking | `GET …/show-dates/{id}` | idem | 200 / 403 |
| artistbooking | `PATCH /artist-bookings/{id}/respond` | idem | 200 / 403 (+ statut inchangé) |
| cabaretcompany | `GET /companies/{id}` | `CabaretCompanyControllerOwnershipTest` | 200 / 403 / 404 |
| cabaretcompany | `GET /companies/{id}/members` | idem | 200 / 403 |
| cabaretcompany | `GET /companies/{id}/shows` | idem | 200 / 403 |

Mécanique commune : seul le contexte JWT (`CurrentUserContextProvider`) est simulé ; la résolution de compagnie s'exécute réellement sur des fixtures à deux compagnies, ce qui garantit que les tests prouvent la fermeture réelle de la faille et non un mock complaisant.
