# Changelog – Projet Violette
Toutes les versions suivent la convention Semantic Versioning (MAJOR.MINOR.PATCH).

---

## v0.5.0 – Sécurisation OWASP, verrou métier, accessibilité et refonte visuelle
Date : 11-07-2026

### Sécurité

#### Added
- **Garde d'ownership compagnie centralisée** : `ManagerCompanyResolver` (`@ApplicationScoped`) résout
  la compagnie du gérant à partir du principal JWT courant, et expose
  `assertCurrentManagerOwnsCompany`. La garde est mutualisée pour l'ensemble des opérations manager
  (`ShowDateService`, `ArtistAvailabilityService`, `ArtistBookingService`, `CabaretCompanyService`).
- Exceptions dédiées et mappers HTTP : `ForbiddenCompanyAccessException` et
  `ForbiddenBookingAccessException`, mappées en **403** avec message neutre.
- **Cloisonnement inter-compagnies (OWASP A01)** appliqué à tous les domaines :
  - `showdate` : lecture par id et par compagnie, création, mise à jour, suppression, besoins
    artistiques et disponibilités (`loadOwnedShowDate`) ;
  - `artistbooking` : `createBooking`, `deleteBooking`, `sendConfirmationRequests`,
    `getBookingsForShowDate` ; ownership **artiste** prioritaire sur `respondToRequest` (403) ;
  - `cabaretcompany` : lecture de la compagnie, des membres et des revues (`getOwnedById`).
- **`GlobalExceptionMapper`** (`ExceptionMapper<Throwable>`) : neutralise les erreurs 500 par une
  réponse JSON sans détail technique, assortie d'un identifiant de corrélation, la stacktrace étant
  journalisée côté serveur (niveau ERROR). Les `WebApplicationException` sont préservées et les
  15 mappers métier restent prioritaires par spécificité JAX-RS.
- Suivi automatique des dépendances via **Dependabot** (backend Maven, frontend Flutter, GitHub Actions).
- Tests d'ownership dédiés : `ManagerCompanyResolverTest` (5 cas), `ShowDateControllerOwnershipTest`
  (15 cas), `ArtistBookingControllerOwnershipTest` (8 cas), `CabaretCompanyControllerOwnershipTest`
  (7 cas).

#### Changed
- Ordre des gardes uniformisé sur le patron **404 → 403 → logique métier** : une ressource
  appartenant à une autre compagnie renvoie 403, une ressource inexistante 404, sans révéler
  l'existence de la première.
- **CORS par profil** : politique permissive en `dev`/`test`, restrictive en production
  (variable `CORS_ORIGINS`, défaut restrictif) — le global `cors.origins=*` est supprimé.
- **Swagger UI et spec OpenAPI désactivés en production** : propriétés build-time à défaut restrictif,
  réactivées explicitement en `dev`/`test`. La génération du client Dart reste possible (spec exportée
  via `store-schema-directory` en profil `dev`).

### Back-end (Quarkus)

#### Added
- **Verrou de disponibilité sur booking confirmé** : `ArtistAvailabilityService.upsertMyAvailability`
  refuse la modification (**409**, `AvailabilityLockedByConfirmedBookingException` + mapper) lorsque
  l'artiste possède un booking `CONFIRMED` sur la date. Le verrou est **isolé par paire
  (date, artiste)** : le booking confirmé d'un autre artiste ne bloque pas l'artiste courant, et un
  booking `PENDING_CONFIRMATION` ne verrouille pas. *Ferme une dette documentée en `v0.4.0`.*
- **Annulation d'une réservation par le gérant** : `cancelBooking`
  (`PENDING_CONFIRMATION` | `CONFIRMED` → `CANCELLED`), avec contrôle d'ownership compagnie et
  publication d'un événement CDI. Nouvel endpoint **`PATCH /api/artist-bookings/{id}/cancel`**
  (rôle MANAGER).
- **Annulation d'une date de spectacle** : transitions `INQUIRY` | `OPTION` | `CONFIRMED` | `STAFFED`
  → `CANCELLED` autorisées (les sorties de `CANCELLED` et les transitions vers `ARCHIVED` restent
  refusées). Introduction du record `ShowDateStatusChangedEvent` (Observer CDI, symétrique à
  `BookingStatusChangedEvent`).
- **Annulation en cascade** : `ShowDateCancellationObserver` réagit à l'annulation d'une date et
  annule les bookings **actifs** (`SELECTED`, `PENDING_CONFIRMATION`, `CONFIRMED`) via
  `cancelAllActiveBookingsForShowDate`. Les bookings **terminaux** (`REFUSED`, `CANCELLED`)
  préexistants sont préservés. Aucun couplage direct entre les domaines `showdate` et `artistbooking`.
- **Re-staffing automatique** : `ShowDateRestaffingObserver` repasse une date `STAFFED` en `CONFIRMED`
  à l'annulation d'un booking, l'équipe redevenant incomplète. Découplage par
  `BookingStatusChangedEvent`. L'annulation d'une **date** `STAFFED` ne déclenche pas de re-staffing
  parasite : la date reste `CANCELLED`.
- Nouveau garde `assertShowDateCancellable` (ne bloque que `CANCELLED` et `ARCHIVED`), distinct de la
  garde de modification appliquée à `deleteBooking` et `respondToRequest`.

#### Changed
- Retrait du champ « Artistes nécessaires » du formulaire de création de date : la définition des
  besoins par compétence (`ShowDateSkillRequirement`) est reportée à une version ultérieure.

#### Fixed
- **Recyclage d'un booking terminal lors d'une re-sélection** : un artiste précédemment `REFUSED` ou
  `CANCELLED` peut de nouveau être sélectionné sur la même date. Le booking existant est recyclé
  (`resetBookingForReselection` : retour en `SELECTED`, timeline `requestedAt`/`respondedAt`
  réinitialisée, `createdAt` conservé), sans créer de seconde ligne — l'unicité
  `(show_date_id, artist_id)` est préservée. Seuls les bookings **actifs** restent bloquants.
- Réalignement des compteurs d'auto-increment H2 après le seed (`ALTER TABLE … RESTART WITH 100`),
  corrigeant une violation de clé primaire (23505) à la création d'une nouvelle date.
- Correction de la génération de schéma H2 en profils `dev` et `firebase` pour permettre le seed
  (`import.sql`).

### Front-end (Flutter)

#### Added
- **Refonte du Planning Artiste** : composants `ArtistShowDateCard` et `DateBadge` ; le ViewModel
  conserve désormais le **statut de booking complet par date** (`Map<dateId, BookingStatus>` au lieu
  d'un simple ensemble de dates confirmées), exposant `getBookingStatusForShowDate` et
  `isBookingCancelledByManager`.
- Masquage de la section disponibilité lorsque le booking est confirmé (cohérent avec le verrou
  backend).
- Compteur « Équipe : N artiste(s) » sur les plannings.
- **Fond dégradé nocturne** généralisé à l'ensemble des écrans (le dégradé violet → rose est conservé
  sur les écrans d'authentification et de chargement).
- **Refonte de l'écran d'accueil** : structuration en trois zones (identité, actions, déconnexion),
  actions transformées en cartes-lignes accessibles (icône, titre, sous-titre, sémantique bouton),
  extraction du composant `HomeActionCard`.
- **Refonte du détail de date gérant** : bandeau et liste fondus sur une carte lavande (`cardSurface`),
  lignes artiste lisibles, hiérarchisation des actions (primaire, secondaire, tertiaire).
- **`ShowDateStatusPill`** : statut de date affiché en clair (libellé, couleur, sémantique), et
  remplacement du menu générique par un **bouton d'action nommé selon la transition** (« Passer en
  option », « Confirmer la date », « Marquer l'équipe complète »).
- Refonte de l'en-tête de connexion (logo agrandi, titre sérif « VIOLETTE »).
- **Fiche de consultation d'une date (gérant)** : accessible depuis le détail inline du planning
  (bouton « Détail »), elle restitue l'intégralité de la feuille de route — heure de convocation,
  adresse complète non tronquée, contact client, description, effectif — ainsi que le statut de la
  date et la liste des artistes avec leur engagement et leur disponibilité. Ces informations étaient
  saisies à la création mais n'étaient jusqu'ici jamais restituées au gérant. Répartition des rôles :
  le détail inline reste le poste de travail (sélection, réservation, transitions de statut,
  annulation) ; la fiche plein écran est une consultation en lecture seule.
- Icône de lanceur Android.

#### Changed
- Renommage du bouton d'accès artiste en « **Planning Artiste** ».
- Renommage de l'action « Demander confirmation » en « **Réserver les artistes** », déplacée sous la
  liste des artistes pour expliciter le flux (sélectionner, puis réserver).
- Suppression du lien mort de réinitialisation de mot de passe sur l'écran de connexion (DETTE-8).

#### Fixed
- Correction du flash de transition violet et des traînées clavier entre les écrans (DETTE-18).
- Correction du contraste des cartes de planning, du bouton de disponibilité et de la carte gérant.

### Accessibilité (WCAG 2.2 AA)

#### Added
- **Parcours artiste de déclaration de disponibilité rendu accessible** : annonce du statut au lecteur
  d'écran (`liveRegion`), langue de l'interface déclarée en français, annonce des messages de
  confirmation (snackbars), en-têtes navigables. Validé par un **test manuel au lecteur d'écran
  (TalkBack)** sur appareil physique ; les écarts détectés au premier passage ont été corrigés.
- **Parcours gérant rendu accessible** : verbalisation du statut des jours du calendrier gérant,
  regroupement sémantique des lignes artiste du détail de date (nom, engagement, état de sélection),
  cibles tactiles conformes (48 dp).
- Couleurs de statut conformes au ratio de contraste AA de 4,5:1 (critère 1.4.3).
- Helper `contrastTextForStatusPill` : sélection de la teinte de texte la plus contrastée sur les
  pastilles selon la luminance du fond, couvert par des tests WCAG.

#### Changed
- Renforcement du contraste des champs de saisie (fond en verre dépoli ~45 % d'opacité, indications
  atténuées à ~80 %, texte de saisie explicite) et des pastilles de calendrier.
- Francisation de l'affichage du calendrier (locale du composant `table_calendar`).

### Qualité / Tests / CI

#### Added
- **Jeu de données de test (seed)** pour le développement local : un gérant, deux artistes et des
  dates de spectacle préremplies.
- Tests de non-régression sur les nouveaux comportements métier : cascade d'annulation via la chaîne
  réelle d'observers, verrou de disponibilité (dont isolation par artiste), `cancelBooking` et
  re-staffing (11 cas), recyclage de booking terminal (7 cas), `CabaretShowServiceTest` (5 cas).

#### Changed
- **Seuil de couverture JaCoCo relevé de 30 % à 70 %.** Couverture réelle mesurée : **81 % des lignes,
  95 % sur les services métier**.
- Uniformisation du nommage des tests frontend au format `methodName_whenCondition_expectedResult`,
  aligné sur la convention backend ; libellés `group()` homogénéisés en français ; anglicisation des
  variables locales de test restantes. La suite frontend compte 209 tests à la clôture de la version.
- Uniformisation des `@DisplayName` backend au patron « sujet — comportement attendu quand condition »
  et enrichissement de l'intention métier des tests de repository.
- Renommage FR → EN des méthodes de garde privées de `ArtistBookingService` (`validerX` → `assertX`),
  **refactor à iso-comportement** : aucun changement de logique ni du contrat API (DETTE-2).
- Nettoyage des commentaires : suppression des séparateurs décoratifs et notes personnelles,
  conversion des TODO orphelins en références de dette (DETTE-7 à DETTE-17).
- Version Flutter épinglée à **3.44.4** dans la CI pour la reproductibilité.

#### Fixed
- Alignement de Java et Kotlin sur **JVM 17** pour tous les sous-projets Android.
- Fiabilisation des notes de release générées depuis le changelog (rendu Markdown).

### Corrections issues de la campagne de recette

> Anomalies détectées lors de la campagne de recette manuelle de la `v0.5.0` et corrigées avant
> livraison. Le cycle complet (détection, qualification, analyse, correctif, vérification) est
> documenté dans [`docs/plan-correction-bogues.md`](docs/plan-correction-bogues.md).

#### Fixed
- **BOGUE-01** — Correction du blocage à la connexion d'une session Firebase sans profil backend :
  l'utilisateur restait piégé sur l'écran d'accueil, sans possibilité de déconnexion. La session est
  désormais fermée et l'utilisateur redirigé vers l'écran de connexion.
- **BOGUE-02** — Correction de la case à cocher de sélection d'artiste, invisible à l'état décoché sur
  fond clair (détail de date gérant).
- **BOGUE-03** — Correction du contraste et de l'accessibilité de la carte de demande de réservation
  (vue artiste) : titre lisible, en-tête sémantique, information regroupée pour le lecteur d'écran.
- **BOGUE-05** — Correction du bouton « Détail » (planning gérant), qui n'était pas atteignable au
  lecteur d'écran : il est désormais un arrêt de focus distinct, annoncé comme bouton et activable.
  Sans ce correctif, la fiche de consultation — et donc la description de la date — restait
  inaccessible aux utilisateurs de lecteur d'écran (WCAG 2.1.1).
- **BOGUE-06** — Correction du contraste du texte des pastilles de statut (WCAG 1.4.3). Deux défauts :
  un style « creux » dont le texte reprenait la couleur du fond, et du texte blanc codé en dur sur des
  fonds trop clairs (1,90:1 sur l'orange « Option »). La couleur du texte est désormais dérivée de la
  luminance du fond sur **toutes** les pastilles, sans couleur codée en dur, et un même statut affiché
  à deux endroits présente le même rendu.

### Documentation

#### Added
- [`docs/cahier-de-recettes.md`](docs/cahier-de-recettes.md) : cahier de recettes formalisé
  (49 scénarios — authentification, dates, disponibilités, réservation, sécurité, accessibilité),
  avec résultat attendu, résultat observé, statut et anomalie liée.
- [`docs/plan-correction-bogues.md`](docs/plan-correction-bogues.md) : plan de correction des bogues
  (barème de gravité, cycle de traitement complet par anomalie).
- [`docs/manuel-mise-a-jour.md`](docs/manuel-mise-a-jour.md) : manuel de mise à jour (utilisateur et
  exploitant).
- [`docs/securite-owasp.md`](docs/securite-owasp.md) : couverture du Top 10 OWASP (mesures, preuves,
  limites assumées).
- [`docs/accessibilite.md`](docs/accessibilite.md) : référentiel WCAG 2.2 AA, critères implémentés et
  test au lecteur d'écran.

#### Changed
- Réalignement de la documentation sur l'état réel du code (accessibilité, dette technique, règles
  métier) ; suivi des dettes DETTE-18 et DETTE-19.
- Alignement du manuel d'utilisation sur le comportement `v0.5.0` (verrou de disponibilité, Planning
  Artiste, besoins artistiques reportés).
- Ajout du démarrage rapide et des comptes de test au README.

### Known limitations
- Le client OpenAPI généré (`violette_api_client`) n'est pas régénéré : l'enum `ShowDateStatus` peut
  encore contenir des valeurs historiques. Régénération reportée en `v0.6.0` (DETTE-1).
- La définition des besoins artistiques par compétence (`ShowDateSkillRequirement`) n'est pas exposée :
  le champ « Artistes nécessaires » a été retiré du formulaire de création.
- **L'édition d'une date après création n'est pas exposée** dans l'interface gérant : une date créée
  ne peut plus être modifiée depuis l'application (correction d'une faute de frappe, changement
  d'horaire ou de lieu). La *consultation* de la feuille de route complète est désormais disponible
  (fiche de détail), mais pas sa modification. L'endpoint `PATCH /api/show-dates/{id}` existe et est
  couvert par les tests structurels ; seul le parcours d'interface reste à construire (DETTE-19,
  reporté en `v0.6.0`).
- La priorité de couleur des pastilles de calendrier reste simplifiée en cas de statuts mixtes : un
  artiste confirmé peut voir une pastille « si besoin » sur le jour concerné (BOGUE-04, différé en
  `v0.6.0`).
- La compagnie unique `Dream's Production` et le rattachement automatique des utilisateurs restent en
  place ; la gestion multi-compagnies n'est pas exposée — le cloisonnement inter-compagnies est
  néanmoins garanti et prouvé par les tests de sécurité.
- Le désistement autonome d'un artiste après confirmation reste hors périmètre : le verrou impose de
  passer par le gérant.
- La release vise prioritairement Android ; les parcours web et iOS ne sont pas validés.

---

## v0.4.0 – Migration REST frontend, consolidation métier et documentation release
Date : 25-04-2026

### Added
- Mise en place du client HTTP `DioClient` avec injection automatique du JWT Firebase dans les
  requêtes REST. Firebase Auth reste utilisé pour l'identité et l'authentification.
- Ajout du client Dart généré `violette_api_client/` via OpenAPI Generator (`dart-dio`) et de la
  configuration `openapitools.json`.
- Ajout des couches REST frontend : remote data sources, repositories et mappers pour les domaines
  `user`, `availability`, `showDate` et `booking`.
- Ajout de `UserRemoteDataSource`, `RestUserRepository` et `UserMapper` pour raccorder le profil
  utilisateur backend (`GET /api/users/me/profile`) au démarrage de l'application.
- Ajout d'endpoints backend pour les disponibilités artistes, dont la création / mise à jour de la
  disponibilité courante et la lecture des disponibilités d'une date.
- Ajout de l'identifiant `artistFirebaseUid` dans les données de disponibilité afin de sécuriser le
  rapprochement frontend entre disponibilité, artiste Firebase et profil backend.
- Ajout d'un endpoint `GET /api/companies/mine` pour résoudre la compagnie du gérant courant lors
  de la création REST des dates.
- Ajout des DTOs backend `UpdateShowDateRequestDto` et `UpsertAvailabilityRequestDto` pour les flux
  REST de mise à jour partielle et de disponibilité.
- Ajout de l'endpoint artiste `GET /api/artist-bookings/me` pour exposer les bookings de l'artiste
  authentifié et distinguer disponibilité déclarée et engagement confirmé.

### Changed
- Migration REST côté frontend des domaines `user`, `availability`, `showDate` et `booking`.
  Firestore est retiré du code métier frontend pour ces domaines, sans supprimer Firebase Auth.
- Remplacement de la persistance Firestore des dates, disponibilités et bookings par des appels au
  backend Quarkus via Dio, repositories REST et mappers dédiés.
- Nettoyage du modèle Flutter `ShowDate` : suppression des champs et méthodes Firestore
  (`fromFirestore`, `toFirestore`, disponibilités embarquées), alignement sur le DTO REST et sur
  `meetingTime`.
- Nettoyage du domaine `booking` frontend : suppression du service Firestore, raccordement de la
  sélection, désélection, envoi des demandes, réponse artiste et demandes en attente aux endpoints
  REST.
- Clarification de `ShowDateStatus` : `INQUIRY`, `OPTION`, `CONFIRMED`, `STAFFED`, `CANCELLED`,
  `ARCHIVED`, avec distinction entre demande client, option, date confirmée et équipe complète.
- Clarification de `AvailabilityStatus` : remplacement de `CONDITIONAL` par `IF_NEEDED` et libellé
  utilisateur « Si besoin ».
- Clarification de `BookingStatus` : distinction entre présélection (`SELECTED` / `preselected`),
  demande de confirmation, confirmation, refus et annulation.
- Distinction métier explicitée entre disponibilité, présélection en `OPTION` et booking ferme après
  confirmation client.
- Configuration réseau Flutter via `--dart-define=API_BASE_URL=...`, utilisée en local, sur
  émulateur, téléphone Android et APK de production.
- Export OpenAPI automatique en profils `dev` et `test`, et alignement de la version Swagger/OpenAPI
  sur le tag de release pendant le workflow de déploiement.
- Ajustement de la configuration datasource Quarkus pour isoler les profils `dev`, `test`,
  `integration` et `prod`.
- Affichage de plusieurs `ShowDate` le même jour dans les calendriers gérant et artiste, avec une
  priorité simple de couleur quand plusieurs statuts coexistent.
- Verrouillage côté frontend de la modification de disponibilité lorsqu'un booking artiste est
  `CONFIRMED` sur la date concernée.

### Removed
- Suppression des dépendances Flutter `cloud_firestore` et `fake_cloud_firestore`, ainsi que de leurs
  dépendances transitives devenues inutiles.
- Suppression des anciens services frontend Firestore `booking_service.dart`, `show_date_service.dart`
  et `violette_user_service.dart`.
- Suppression des tests frontend attachés à l'ancien service Firestore de booking.
- Suppression des reliquats de mapping Firestore dans les modèles métier frontend migrés.

### Fixed
- Correction de l'identification artiste dans le flux disponibilité / détail de date après migration
  REST, avec prise en compte des identifiants backend et du `firebaseUid` historique si nécessaire.
- Correction de l'affichage des bookings dans le détail de date manager pour l'aligner sur les données
  renvoyées par le backend REST.
- Correction des cases de sélection et de la sémantique de sélection / présélection dans le détail
  manager.
- Correction de la visibilité artiste quand plusieurs `ShowDate` existent le même jour.
- Correction de l'affichage des demandes de confirmation artiste : les actions `Confirmer` et
  `Refuser` sont visibles pour les bookings `PENDING_CONFIRMATION`.
- Correction du fallback d'affichage des demandes sans détail de date : plus aucune date factice
  n'est affichée.
- Correction de navigation artiste par retour explicite vers `HomeView` afin d'éviter une pile
  héritée incohérente.
- Correction d'un import `firebase_auth` redondant dans les tests Flutter.
- Correction d'avertissements d'analyse statique sur le domaine disponibilité.

### Tests
- Ajout de tests backend pour les contrôleurs `artistbooking`, `showdate`, `cabaretcompany` et
  `violetteuser`, dont les flux disponibilités, suppression, mise à jour et profil utilisateur.
- Ajout de tests backend de service pour `ArtistAvailabilityService` et `ShowDateService`.
- Consolidation des tests repository backend autour de `artistbooking`, `showdate` et des agrégats.
- Ajout de tests Flutter pour les remote data sources REST `booking` et `showDate`.
- Ajout de tests Flutter pour les mappers `user`, `availability`, `showDate` et `artistBooking`.
- Ajout et mise à jour de tests ViewModel (`startup`, `home`, `availability_choice`,
  `manager_planning`, `manager_date_detail`) pour les flux REST et les cas d'erreur.
- Ajout de tests widget pour `BookingRequestCard` (boutons de réponse, statut déjà traité,
  demande sans détail de date).
- Activation des tests d'intégration backend dans la CI avec `-DskipITs=false`.

### Documentation
- Ajout et mise à jour de la documentation de migration REST, de stratégie de tests et de démarrage
  frontend avec `API_BASE_URL`.
- Ajout d'une documentation métier consolidée sur les statuts, la disponibilité, la présélection et
  le booking ferme.
- Ajout d'une documentation d'architecture globale Flutter / Quarkus / Firebase Auth / REST.
- Ajout d'une checklist de préparation `v0.4.0` couvrant tests, Swagger, Fly.io et APK.
- Ajout d'une documentation de dette technique `docs/technical-debt.md` couvrant backend, frontend,
  métier, UX, tests et évolutions futures.
- Mise à jour du README racine avec une section d'installation Android destinée aux artistes et
  gérants non techniques.
- Mise à jour des README frontend, backend, déploiement, tests et documentation utilisateur pour
  refléter l'état REST actuel.

### CI/CD
- Extension des déclencheurs Flutter CI aux branches `feature/**`.
- Extension des déclencheurs backend CI aux branches `feature/**` et `refactor/**`.
- Exécution des tests d'intégration backend dans `backend-ci.yml`.
- Alignement de la version Maven sur le tag `vX.Y.Z` dans `deploy.yml` afin que Quarkus et Swagger
  exposent la version de release.
- Build APK de release avec `--dart-define=API_BASE_URL=https://violette-back.fly.dev`.
- Vérification documentée que le tag `vX.Y.Z` aligne Maven, `/api/ping`, Swagger et les logs
  backend sur la version de release.

### Known limitations
- Firebase Auth reste nécessaire : la release supprime Firestore du code métier frontend migré, mais
  ne supprime pas Firebase comme fournisseur d'identité.
- Le client OpenAPI généré est introduit et utilisé pour le domaine `user`, tandis que `availability`,
  `showDate` et `booking` utilisent encore Dio avec JSON et mappers manuels.
- Des garde-fous de compatibilité autour de `firebaseUid` restent présents pour absorber certaines
  données historiques pendant la transition vers les identifiants backend.
- Les tests générés dans `violette_api_client/test` restent des squelettes OpenAPI et ne constituent
  pas une barrière fonctionnelle complète.
- Le verrou `booking CONFIRMED -> disponibilité non modifiable` est garanti côté application
  Flutter ; le garde-fou backend équivalent reste une évolution à traiter.
- La compagnie unique `Dream's Production`, le rattachement automatique des utilisateurs et l'absence
  de compagnie active restent des limitations temporaires de `v0.4.0`.
- Le client OpenAPI généré doit être régénéré avant de servir de référence pour les enums `showDate`,
  car certains modèles historiques peuvent encore contenir d'anciennes valeurs.

---

## v0.3.2 – Correctifs OIDC production, version backend unifiée et Swagger homogénéisé en français
Date : 06-04-2026

### Sécurité
#### Fixed
- Activation explicite d'OIDC pour le profil de production via `%prod.quarkus.oidc.enabled=true`
  afin de corriger le refus d'accès (`403`) sur les endpoints `@Authenticated` en production.
  Cause racine : `quarkus.oidc.enabled` est une propriété build-time Quarkus — impossible à activer
  via variable d'environnement au runtime.

### Back-end (Quarkus) / Configuration
#### Changed
- Suppression de `QUARKUS_OIDC_ENABLED` dans `fly.toml` : variable sans effet pour une propriété
  build-time Quarkus, source de confusion supprimée.
- Clarification du comportement `build-time fixed` et séparation des paramètres OIDC :
  - build-time (dans `application.properties`) : `quarkus.oidc.enabled`, profils `%dev`/`%prod`
  - runtime (dans `fly.toml [env]`) : URL du serveur OIDC, client ID, issuer, audience
- Centralisation de la version backend dans `violette-back/pom.xml` comme unique source de vérité.
- Alignement de `quarkus.application.version` et `quarkus.smallrye-openapi.info-version`
  sur la version Maven du projet via filtrage de ressources.
- Configuration du `maven-resources-plugin` avec délimiteur `@` uniquement (`useDefaultDelimiters=false`)
  pour préserver les expressions Quarkus `${VAR:default}`.

### Documentation API (Swagger / OpenAPI)
#### Changed
- Uniformisation en français des libellés exposés dans Swagger/OpenAPI (`@Tag`, `@Operation`,
  `@APIResponse`) sur les contrôleurs backend (`violetteuser`, `cabaretcompany`, `showdate`,
  `artistbooking`, `health`).
- Harmonisation du ton et des formulations des descriptions HTTP (notamment les réponses d'erreur)
  pour une lecture cohérente côté jury et documentation technique.

### Documentation / Déploiement
#### Changed
- Mise à jour de `README-deploiement.md` pour expliciter l'activation OIDC en production,
  la distinction build-time/runtime et les vérifications de pré-soutenance associées.
- Mise à jour de `violette-back/README.md` pour clarifier le comportement du profil `firebase`
  en local et le mode d'activation OIDC en production.

---

## v0.3.1 – Pipeline de livraison, déploiement Fly.io et documentation de release
Date : 01-04-2026

### Infrastructure / Livraison
#### Added
- Déploiement backend sur Fly.io avec configuration dédiée via `fly.toml` (région Paris,
  `min_machines_running = 1`, mémoire 512 MB).
- Utilisation d'Aiven comme base de données MySQL pour l'environnement de production.
- Pipeline CI/CD principal (`deploy.yml`) avec stratégie à deux niveaux :
  - **Push sur `main`** → tests Maven + build image Docker + push GHCR (CI uniquement, pas de déploiement).
  - **Tag `v*.*.*`** → idem + déploiement Fly.io + création GitHub Release + build et publication APK Android (CD complet).
- Configuration des secrets GitHub Actions : `FLY_API_TOKEN`, `GOOGLE_SERVICES_JSON_BASE64`,
  `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
- Variables OIDC Firebase déclarées en clair dans `fly.toml [env]` (non sensibles, liées au project ID Firebase).
- Publication de l'APK Android via GitHub Releases sur les tags de version.

#### Changed
- Déclenchement du déploiement Fly.io sur tag versionné uniquement, afin de distinguer
  la CI continue de la release de production.

### Documentation / Déploiement
#### Added
- `README-deploiement.md` : guide de déploiement Fly.io + Aiven, configuration des secrets
  GitHub Actions, flux CI/CD détaillé, checklist de pré-soutenance.

#### Changed
- Harmonisation de la documentation de déploiement avec le workflow GitHub Actions réel.
- Mise à jour du `README.md` principal pour référencer explicitement le guide de déploiement.

### Front-end (Flutter)
#### Changed
- Configuration Android de release : `applicationId` aligné sur `io.violette.app`,
  préparation de la signature release et publication APK automatisée.

### Repository
#### Changed
- Sécurisation des fichiers sensibles dans `.gitignore` (`*.jks`, `*.b64`, `key.properties`,
  `google-services.json`).

---

## v0.3.0 – Architecture backend, domaines métier et documentation technique
Date : 13-03-2026

### Back-end (Quarkus)
#### Added
- Initialisation du projet Quarkus 3.x avec Hibernate ORM Panache, Flyway, Bean Validation,
  OpenAPI/Swagger et MapStruct.
- Architecture en monolithe modulaire structuré par domaine (`io.violette.<domaine>`)
  avec couches Controller → Service → Repository.
- Implémentation des 4 domaines métier : `violetteuser`, `cabaretcompany`, `showdate`, `artistbooking`.
- Schéma SQL relationnel complet avec 5 migrations Flyway (V1 à V5) : utilisateurs, compagnies,
  revues, dates de spectacle, disponibilités, réservations.
- Sécurité Firebase JWT via Quarkus OIDC : validation du token, rôles métier (`ARTIST`, `MANAGER`)
  chargés depuis la base backend.
- Endpoints sécurisés : `GET /api/users/me` (authentifié), `GET /api/users` (MANAGER uniquement).
- 3 design patterns GoF : Singleton (CDI `@ApplicationScoped`), Adapter (JWT Firebase →
  `SecurityIdentity` Quarkus), Observer (CDI Events sur les transitions de statut de réservation).
- Exceptions métier spécialisées + `ExceptionMapper` JAX-RS par domaine (12 mappers au total).
- Endpoint de santé `GET /api/ping` et documentation API Swagger UI (`/swagger-ui`).
- Logging SLF4J structuré sur tous les domaines, avec `firebaseUid` comme contexte d'identification.

#### Changed
- Migration du package racine de `com.willow.violette` vers `io.violette`.
- Renommage de `cabaret_show` en `revue` pour respecter le langage ubiquitaire DDD.

### Qualité / Tests / CI
#### Added
- 18 classes de tests unitaires et d'intégration couvrant les 4 domaines métier.
- Tests d'intégration MySQL/Flyway (`FlywayMigrationIT`, `VioletteUserRepositoryIT`).
- Couverture JaCoCo ≥ 30 % de lignes couvertes ; build fail automatique si le seuil n'est pas atteint.
- CI GitHub Actions backend (`backend-ci.yml`) : `mvn clean verify` à chaque PR.
- Séparation des pipelines CI : Flutter (`flutter-ci.yml`) et backend Quarkus (`backend-ci.yml`).

### Infrastructure / Livraison
#### Added
- `docker-compose.yml` : stack complète MySQL 8 + backend Quarkus (mode JVM) avec healthchecks
  et variables d'environnement.
- Dockerfiles fournis : JVM, native, legacy-jar, native-micro.
- Configuration multi-environnement : H2 en dev/test, MySQL en production,
  profil `firebase` pour tests locaux avec JWT réels.

### Documentation / Architecture
#### Added
- `violette-back/ARCHITECTURE.md` : architecture en couches, design patterns, sécurité JWT,
  flux de requête, décisions de modélisation par domaine.
- `violette-back/README.md` enrichi : guide de démarrage, structure des packages, commandes Maven,
  lancement Docker.
- `docs/functional-spec.md` : description fonctionnelle (acteurs, cas d'usage, workflow de réservation).
- `docs/user-manual.md` : manuel utilisateur pour les rôles gérant et artiste.
- `docs/booking-workflow.md` : workflow de réservation V1 (statuts, transitions, règles métier)
  et vision V2 (workflows configurables par compagnie).
- `docs/architecture-c4.md` : documentation des diagrammes C4 niveaux 1 à 4.
- Diagrammes C4 : contexte système, containers, composants backend, zoom niveau 4 sur `artistbooking`.
- Diagramme DDD bounded contexts et Domain Storytelling.

### Front-end (Flutter)
> Aucune nouvelle fonctionnalité ajoutée sur cette branche.
> Le frontend (v0.2.0) reste fonctionnel sur Firebase/Firestore et n'est pas encore raccordé
> aux endpoints REST du backend Quarkus. L'intégration front ↔ backend constitue l'étape suivante.

---

## v0.2.0 – Planning gérant, gestion des disponibilités et mise en place de la qualité projet
Date : 26-01-2026

### Front-end (Flutter)
#### Added
- Gestion des rôles utilisateur (gérant / artiste) avec adaptation de l'inscription et de la navigation.
- Création et sauvegarde des dates de spectacle (ShowDate) via formulaire avec persistance dans Firestore.
- Mise en place de la vue *Planning gérant* permettant de visualiser les dates et les artistes associés.
- Gestion des disponibilités par artiste (disponible, indisponible, incertain) avec affichage détaillé.
- Amélioration de la sélection et de la consultation des ShowDate.
- Intégration du thème visuel **VioletteTheme** pour homogénéiser l'interface.

#### Changed
- Refactor de la logique de gestion des disponibilités afin de clarifier l'implémentation et améliorer la maintenabilité.
- Mutualisation du composant calendrier entre les différentes vues.

#### Fixed
- Corrections mineures d'interface et de navigation améliorant la stabilité globale.

### Qualité, tests et intégration continue
#### Added
- Mise en place d'une infrastructure de tests unitaires avec une approche agile.
- Ajout de tests unitaires pour la gestion des ShowDate, du calendrier et des ViewModels associés.
- Ajout d'une pipeline **GitHub Actions** pour l'analyse statique (`flutter analyze`) et l'exécution des tests Flutter.

#### Fixed
- Correction des erreurs bloquant l'analyse Flutter dans la CI.
- Correction du nom du dossier de travail utilisé par la pipeline CI.

### Repository
#### Changed
- Nettoyage du dépôt avec suppression du dossier `.idea` du suivi Git.

---

## v0.1.0 – Première version du projet avec implémentation de l'authentification via Firebase.
Date : 05-12-2025

### Front-end (Flutter)
#### Added
- Initialisation de l'application Flutter avec architecture Stacked.
- Intégration de Firebase (configuration du projet et connexion à Firebase Auth).
- Création de la vue d'inscription (Register) avec formulaire email + mot de passe.
- Création de la vue de connexion (Login) avec formulaire géré via `@FormView` (Stacked).
- Gestion complète des messages d'erreur Firebase pour l'inscription et la connexion, rattachées aux champs concernés (email / mot de passe).
- Création d'un `UserService` côté Flutter pour lier l'utilisateur authentifié Firebase à son profil stocké dans Firestore via l'UID.
- Stockage des informations de base de l'utilisateur dans Firestore (ex. email, nom affiché minimal).
- Mise en place d'une `HomeView` affichant le nom de l'utilisateur connecté.
- Ajout d'un bouton de déconnexion permettant de revenir à l'écran de connexion.
- Mise en place d'un `StartupViewModel` qui écoute l'état d'authentification afin de rediriger automatiquement l'utilisateur vers Login ou Home.

### Back-end (Quarkus)
#### Added
- Initialisation d'un projet Quarkus (backend) qui démarre correctement, en préparation des futures API.  
  À ce stade, aucune interaction n'est encore en place entre le backend Quarkus et l'application Flutter.
