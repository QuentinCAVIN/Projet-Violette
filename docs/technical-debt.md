# Dette technique — Violette v0.5.0

Ce document recense les dettes connues à l'approche de la release `v0.5.0`. Il ne
remplace pas le changelog : il sert à expliciter les limites assumées et à orienter
les prochaines itérations. Les points résorbés depuis `v0.4.0` sont conservés dans
la section « Résorbé depuis v0.4.0 » pour tracer l'évolution.

---

## Backend

- Le bootstrap crée une compagnie unique `Dream's Production` pour garder la démonstration de bout en bout opérationnelle.
- Les utilisateurs `MANAGER` et `ARTIST` sont rattachés automatiquement à cette compagnie unique.
- Le modèle multi-compagnies existe partiellement, mais il n'y a pas encore de vraie gestion multi-compagnies côté produit.
- Il n'existe pas encore de notion de compagnie active pour un utilisateur membre de plusieurs compagnies.
- Le verrou `booking CONFIRMED -> disponibilité non modifiable` est appliqué côté frontend, et désormais également garanti côté backend sur l'endpoint de modification de disponibilité (`AvailabilityLockedByConfirmedBookingException`).
- Les tests unitaires backend utilisent H2 avec génération Hibernate ; les migrations Flyway MySQL sont validées séparément par les tests d'intégration et doivent rester surveillées.

## Frontend

- **DETTE-7 — Widget partagé pour les messages d'erreur globaux (login/register).** Le même bloc d'affichage d'erreur est dupliqué dans `login_form.dart` et `register_form.dart`.
- **DETTE-8 — Réinitialisation du mot de passe.** Le bouton « Mot de passe oublié » est inactif ; fonctionnalité Firebase à implémenter.
- **DETTE-9 — Mapper les erreurs Firebase Auth.** Messages utilisateur neutres (éviter de révéler qu'un compte existe déjà). Voir `login_viewmodel.dart` et `register_viewmodel.dart`.
- **DETTE-10 — Bouton « 2 weeks » du calendrier TableCalendar.** Contrôle mort dans `availability_calendar.dart` ; retirer ou activer.
- **DETTE-11 — Thème pour les couleurs de texte des jours colorés.** `day_cell.dart` utilise encore `Colors.white` en dur.
- **DETTE-12 — Affichage multi-rôles sur l'écran d'accueil.** Seul `roles[0]` est affiché dans `home_view.dart`.
- **DETTE-13 — Stream temps réel pour le planning manager.** `loadShowDates()` interroge le repository à chaque chargement (acceptable MVP).
- **DETTE-14 — Plafond d'artistes inférieur aux sélections existantes.** Comportement UI à définir dans `manager_date_detail_viewmodel.dart`.
- **DETTE-15 — Sémantique visuelle preselected vs confirmed.** Clarifier les pills selon le contexte manager/artiste (`booking_status_pill.dart`).
- **DETTE-16 — Sous-types artiste.** Différencier chanteur, danseur, échassier, etc. (`role.dart`).
- **DETTE-17 — Statut `postponed` pour les dates reportées.** Cas de force majeure avec client engagé (`show_date_status.dart`).
- La navigation stack n'est pas encore totalement maîtrisée : certains retours utilisent `clearStackAndShow` comme correction temporaire.
- Les couches REST manuelles (`Dio`, remote data sources, mappers) coexistent avec le client OpenAPI généré.
- Le client OpenAPI généré `violette_api_client/` est utilisé principalement pour le domaine `user`. Les domaines `availability`, `showDate` et `booking` utilisent encore Dio manuel, JSON et mappers dédiés.
- Une incohérence potentielle existe dans le client généré : `apiArtistBookingsMeGet` semble typé comme un DTO unique alors que le backend renvoie une liste. Ce n'est pas bloquant, car le runtime Flutter appelle `GET /api/artist-bookings/me` via Dio manuel.
- Certaines compatibilités avec des identifiants historiques `firebaseUid` restent présentes pendant la transition vers les identifiants backend.

## Métier

- Les transitions de `ShowDateStatus` exposées dans l'app restent simplifiées pour la démonstration.
- La gestion des besoins artistiques par compétence (`ShowDateSkillRequirement` : compétences, effectifs, cachets) n'est pas raccordée à l'UI. Le champ frontend informatif **Artistes nécessaires** a été retiré du formulaire de création (voir « Résorbé depuis v0.4.0 »). La définition fine des effectifs par compétence est reportée à une version ultérieure.
- `IF_NEEDED` est sélectionnable, mais l'UI ne priorise pas encore finement les artistes `AVAILABLE` par rapport aux artistes `IF_NEEDED`.
- Le désistement autonome d'un artiste après confirmation est hors périmètre : l'artiste doit contacter le gérant.

### Écarts terrain identifiés (compagnie pilote) — reportés

Deux comportements ont été identifiés lors des tests avec la compagnie pilote et
documentés comme choix assumés pour `v0.5.0` (détail dans `regles-metier.md`).

- **DETTE-5 — Signalement gérant « présélectionné devenu indisponible » (v0.6.0).**
  Un artiste présélectionné (`SELECTED`) qui passe `UNAVAILABLE` conserve sa
  présélection et continue de compter dans l'effectif. Découplage volontaire
  (protège la décision du gérant). Évolution envisagée : signaler visuellement au
  gérant sans désélection automatique.
- **DETTE-6 — Autoriser l'engagement ferme dès `OPTION` (v0.6.0 / v0.7.0).**
  Retour terrain : les compagnies engagent les artistes dès le stade `OPTION`.
  Le workflow actuel réserve l'envoi des demandes fermes aux dates `CONFIRMED`.
  Impact à traiter : assouplissement de la garde `assertDateConfirmed` dans
  `sendConfirmationRequests`, révision de la sémantique de `PENDING_CONFIRMATION`,
  tests associés et comptage de la capacité sur les bookings confirmés.

## UX

- Le calendrier multi-dates applique des règles simples de priorité de couleur au lieu d'une représentation visuelle dédiée aux statuts mixtes.
- Le planning manager et la vue artiste affichent plusieurs dates le même jour, mais la priorité de couleur reste simplifiée et doit être améliorée.
- Il n'y a pas encore de notifications artistes pour les demandes de confirmation.
- Les actions groupées sur plusieurs dates d'un même jour ne sont pas encore proposées.
- La release cible prioritairement Android ; les parcours web et iOS restent hors périmètre de validation.
- Refonte graphique globale (thème night-sky, gradient `primaryGradient` non branché en fond de Scaffold, harmonisation complète des pills) reportée en v0.6.0. La mise en conformité contraste WCAG AA des cartes de planning a été traitée en v0.5.0 (voir « Résorbé depuis v0.4.0 »).
- **DETTE-18 — Micro-flash violet en transition d'écran (résorbé v0.5.0).**
  Deux causes distinctes sous un seul ticket :
  1. Flash (~200 ms) de `colorScheme.surface` (violet historique) peint par le
     `PageTransitionsBuilder` Android pendant l'animation de route, en dehors de
     tout Scaffold — d'ou l'inefficacite des deux premieres tentatives
     (alignement `scaffoldBackgroundColor`, inversion `GradientBackground`/
     `Scaffold`). Corrige via `pageTransitionsTheme` avec
     `PredictiveBackPageTransitionsBuilder(fallbackColor: backgroundGradientTop)`.
  2. Trainee a l'ouverture du clavier : le Scaffold expose sa propre
     `backgroundColor` pendant le resize du body (`create_show_date`, `login`,
     `register`). Corrige en fixant cette couleur sur la teinte basse du
     gradient de chaque ecran (`darkPurple` / `pinkAccent`).
- **DETTE-19 — Consultation du détail complet d'une date (gérant).** Le détail de
  date gérant n'existe qu'en inline dans le planning et n'affiche pas les
  informations complètes de la date (adresse entière, description). La
  `ManagerShowDateSummaryCard` tronque le titre et l'adresse ; il n'existe pas de
  vue détail plein écran routée. Choix assumé pour `v0.5.0` : le parcours de
  démonstration ne passera pas par la consultation détaillée. Options envisagées
  pour la suite : enrichir le bloc inline (adresse complète + description) ou
  créer une vue détail plein écran avec navigation depuis le planning.
  **Périmètre : v0.6.0.**
  

## Dette outillage

> Les numéros de DETTE servent d'identifiants stables (référencés dans le suivi de
> sprint et les commits) ; les trous éventuels sont normaux. DETTE-1 (régénération
> du client API) est traitée dans le sprint `v0.5.0` courant et suivie hors de ce
> registre. DETTE-2 (nommage FR->EN des méthodes de garde back) est résorbée en
> `v0.5.0` (voir « Résorbé depuis v0.4.0 »).

- **DETTE-3 — Audit trail dédié des transitions de statut.** Table d'historique pour tracer les transitions booking/date. Infrastructure Observer déjà prête. Reporté lot 2/3.
- **DETTE-4 — Retirer `StackedFormGenerator` (`@FormView`)** au profit de formulaires manuels. Abstraction fuyante (cf. « approche hybride » documentée dans `register_form.dart` : controllers passés manuellement au constructeur). Coût de cérémonie disproportionné pour le peu de formulaires du projet. Retrait incrémental, un formulaire à la fois, jamais en big-bang. **Périmètre : v0.7.0.**

## Tests

- Il n'y a pas encore de tests E2E automatisés couvrant le parcours complet gérant -> artiste -> booking confirmé.
- Le client OpenAPI généré n'a pas de tests fonctionnels dédiés.
- La cohérence entre la spec OpenAPI, le client généré et les wrappers frontend n'est pas encore testée automatiquement.
- Les scénarios de production MySQL restent principalement couverts par migrations et tests d'intégration ciblés, pas par toute la suite frontend/backend.

## Résorbé depuis v0.4.0

- **Champ « Artistes nécessaires » retiré** du formulaire de création de date : il était informatif et non raccordé au backend. La définition des effectifs par compétence reste reportée (voir « Métier »).
- **Workflow de présélection visible côté artiste** : la refonte « Planning Artiste » affiche l'état d'engagement (présélectionné, confirmé, annulé par le gérant) sur des cartes structurées.
- **Différenciation visuelle disponibilité / présélection / confirmation** : traitée par la refonte des cartes (statut d'engagement, disponibilité, verrou) et la mise en conformité contraste.
- **Contraste WCAG 2.2 AA des cartes de planning** : tokens de couleur centralisés dans `VioletteTheme` (`cardSurface`, `textOnCard`, `textOnCardSecondary`, `cardTitle`), appliqués aux cartes artiste et gérant. Bascule des autres écrans sur ces tokens reportée en v0.6.0.
- **Verrou backend disponibilité / booking `CONFIRMED`** : désormais garanti côté serveur, plus seulement côté frontend.
- **DETTE-2 — Nommage FR→EN des méthodes de garde privées (backend)** : les gardes métier de `ArtistBookingService` (`validerDateBookable`, `validerDateConfirmee`, `validerDateModifiable`, `validerDisponibiliteArtiste`, `validerCapacite`) ont été renommées avec les préfixes anglais `assert*`, pour s'aligner sur les méthodes `assert*`/`is*` déjà anglaises de la même classe. Renommage via rename-symbol IDE, sans changement de logique ni du contrat API ; 227 tests verts.

## Évolutions futures

- Finaliser la gestion multi-compagnies (compagnie active, création/édition de compagnie, rôles par compagnie).
- Reprendre la création de date autour de `ShowDateSkillRequirement` (compétences, effectifs, cachets).
- Améliorer l'UX calendrier : multi-date, statuts mixtes, actions groupées.
- Ajouter des notifications artistes.
- Ajouter la suppression encadrée des `ShowDate` et utilisateurs.
- Automatiser le passage à `STAFFED` quand la capacité confirmée est atteinte.
- Centraliser davantage les règles métier frontend pour éviter leur duplication dans plusieurs ViewModels.
