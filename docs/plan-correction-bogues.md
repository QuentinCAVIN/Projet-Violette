# Plan de correction des bogues — Violette

> Projet Violette — Bloc 2 (C2.3.2). Détection, qualification, analyse, correction et vérification des anomalies rencontrées au cours du projet.

## Objet du document

Ce document recense les **bogues** détectés au cours du développement de Violette et décrit, pour chacun, le cycle complet de traitement : **détection → qualification → analyse → correctif → vérification**. Il constitue la preuve que les anomalies sont non seulement identifiées, mais qualifiées selon leur gravité, analysées jusqu'à leur cause racine, corrigées, puis vérifiées par un test ou un rejeu.

Ce document est **distinct de la dette technique** (`technical-debt.md`) : la dette technique décrit des choix d'architecture ou des limites assumées et planifiées ; le présent plan décrit des **défauts de fonctionnement** (comportement observé non conforme au comportement attendu) et leur résolution.

Deux catégories sont distinguées :

- **Bogues détectés en recette v0.5.0** — anomalies remontées lors de la campagne de tests manuels du cahier de recettes (`cahier-de-recettes.md`). La colonne « anomalie liée » de ce cahier référence les identifiants `BOGUE-0X` ci-dessous.
- **Bogues historiques du projet** — anomalies rencontrées et corrigées au cours des versions antérieures (jusqu'à v0.4.0), tracées dans l'historique Git et le journal des versions (`CHANGELOG.md`).

Les identifiants `BOGUE-XX` sont **uniques dans l'ensemble du document** et stables : c'est ce qui permet au cahier de recettes et au changelog de les référencer sans ambiguïté. Leur numérotation ne reflète pas un ordre chronologique.

## Barème de gravité

| Gravité | Définition | Traitement attendu |
|---|---|---|
| **Bloquant** | Empêche l'utilisation d'une fonctionnalité ; aucun contournement possible. | Correction avant la version livrée. |
| **Majeur** | Fonctionnalité dégradée, incohérence de données ou d'affichage avec impact utilisateur ; contournement possible. | Correction avant livraison si l'effort le permet, sinon différé argumenté. |
| **Mineur** | Défaut visuel ou d'ergonomie sans impact fonctionnel. | Correction ou report argumenté vers une version ultérieure. |
| **Cosmétique** | Imperfection esthétique isolée. | Report acceptable. |

---

## 1. Bogues détectés en recette v0.5.0

> Ces anomalies ont été détectées lors de la campagne de recette manuelle de la v0.5.0. Chaque entrée référence le(s) cas de recette concerné(s).

### BOGUE-01 — Impasse à la connexion d'une session Firebase orpheline

- **Détection** : recette manuelle, cas **AUTH-REC-04**. Connexion avec un compte présent dans Firebase Auth mais sans profil correspondant côté backend.
- **Qualification** : **Bloquant** · authentification (frontend, flux de démarrage) · l'utilisateur est piégé sur l'écran d'accueil sans possibilité de déconnexion, contraint de forcer la fermeture de l'application.
- **Comportement attendu** : détection de l'incohérence → déconnexion (logout) et redirection vers l'écran de connexion (Login).
- **Comportement observé** : pas de redirection vers Login ; une popup d'erreur « Profil utilisateur : impossible depuis le backend » s'affiche, puis l'écran d'accueil reste affiché avec le seul message « Utilisateur introuvable », sans bouton de déconnexion. Au relancement, l'écran d'erreur affiché diffère (« Serveur inaccessible »).
- **Analyse** : deux défauts chaînés. (1) `UserRemoteDataSource.getMyProfile()` ne tenait pas son contrat documenté (« retourne `null` sur 404 ») : il appelait le client OpenAPI généré sans capturer le `DioException`. Sur le 404 propre renvoyé par le backend (`getMyProfile` → `orElseThrow(UserNotFoundException)` → 404), l'exception remontait au lieu d'être convertie en `null`. (2) Le `catch` générique de `HomeViewModel.loadUser()` attrapait alors cette exception, affichait une popup, puis posait `currentUser = null; return;` **sans** logout ni redirection, laissant une session Firebase active et l'écran figé sur « Utilisateur introuvable » (fermeture forcée obligatoire, puis « Serveur inaccessible » au relancement).
- **Correctif** : (1) `getMyProfile` capture le `DioException` 404 et retourne `null`. (2) Le `catch` de `loadUser` déclenche désormais `logout()` + `replaceWithLoginView()`, alignant `HomeViewModel` sur le comportement déjà correct de `StartupViewModel`. Aucun chemin ne laisse de session orpheline. Branche `fix/auth-session-orpheline` (PR #104) ; commits `7a28ba7` (data source), `067c9bf` (ViewModel), `b9baa2f` (tests).
- **Vérification** : nouveau fichier `home_viewmodel_test.dart`, groupe « Résolution du profil au chargement », 2 cas de non-régression — profil absent (404 → `null`) → logout + Login ; erreur backend → popup puis logout + Login. Tests verts. Rejeu manuel du cas AUTH-REC-04 : redirection vers Login confirmée.

### BOGUE-02 — Case à cocher blanche sur fond blanc (planning gérant)

- **Détection** : recette manuelle, parcours de sélection des artistes côté planning gérant (rattaché à la Famille 2 / A11Y-REC-02). Anomalie initialement notée hors cas de test.
- **Qualification** : **Mineur** · frontend (détail de date gérant, case à cocher de sélection artiste) · la case cochée est visible, mais la case décochée disparaît visuellement (blanc sur blanc). Contournable (la sélection reste fonctionnelle), mais nuit à la lisibilité et à l'accessibilité.
- **Comportement attendu** : la case à cocher reste visible dans ses deux états (cochée et décochée), avec un contraste suffisant sur son fond.
- **Comportement observé** : la case apparaît lorsqu'elle est cochée mais devient invisible lorsqu'elle est décochée (bordure/fond blanc sur carte claire). Capture : `flutter_48.png`.
- **Analyse** : dans `manager_date_detail_body.dart`, la `Checkbox` ne définissait que `activeColor` (état coché) et `checkColor`. L'état **décoché** n'avait aucune bordure explicite : Flutter retombait sur la bordure par défaut du thème, trop claire pour contraster avec le fond clair (`cardSurface`) de la carte → case invisible une fois décochée.
- **Correctif** : ajout de `side: BorderSide(color: VioletteTheme.textOnCardSecondary, width: 2)` sur la `Checkbox`, pour forcer une bordure visible à l'état décoché, cohérente avec les tokens de carte. Branche `fix/checkbox-selection-invisible` (PR #105) ; commit `b51cdad`.
- **Vérification** : anomalie purement visuelle — validée par contrôle manuel (case décochée désormais visible sur la carte gérant). Pas de test unitaire pertinent pour ce défaut de rendu.

### BOGUE-03 — Accessibilité de la carte de demande de booking (vue artiste)

- **Détection** : recette manuelle, parcours artiste de réponse à une demande de confirmation (rattaché à A11Y-REC-01).
- **Qualification** : **Majeur** · frontend (carte de demande d'acceptation de booking, vue artiste) · défaut d'accessibilité sur un parcours déclaré conforme au lecteur d'écran (§ 4.1 de `accessibilite.md`) — l'écart entre la conformité déclarée et le défaut observé justifie la gravité.
- **Comportement attendu** : la carte de demande est correctement restituée au lecteur d'écran (éléments annoncés, actions atteignables) et lisible (contraste suffisant).
- **Comportement observé** : titre « Nouvelle proposition ! » quasi illisible (violet moyen sur fond clair translucide) et carte mal restituée au lecteur d'écran. Capture : `flutter_48.png`.
- **Analyse** : deux défauts, révélés en deux temps (la qualification initiale « purement sémantique » a été corrigée après test physique — cf. points d'amélioration § 3). (1) **Contraste (WCAG 1.4.3, défaut principal)** : `BookingRequestCard` n'avait jamais été alignée sur le système de cartes opaques v0.5.0 (tokens `cardSurface`/`textOnCard`/`cardTitle`), contrairement à ses cartes sœurs (`ArtistShowDateCard`). Elle héritait du fond translucide du thème (blanc ~45 %) avec un titre en violet moyen → titre quasi illisible sur fond clair. (2) **Sémantique (défaut secondaire)** : aucune annotation d'accessibilité (pas d'en-tête, information fragmentée au lecteur d'écran), contredisant la conformité § 4.1 déclarée pour le parcours artiste.
- **Correctif** : (1) contraste — fond `cardSurface` opaque, titres en `cardTitle`, textes en `textOnCard`, icônes en `textOnCardSecondary`. (2) sémantique — titre exposé en en-tête (`Semantics(header: true)`, critère 1.3.1) ; bloc d'information regroupé en une annonce unique (`Semantics(label:)` + `ExcludeSemantics`). Branches `fix/a11y-booking-request-card` (sémantique, PR #106) et `fix/a11y-contraste-carte-booking` (contraste) ; commits `3af1bd6` (sémantique), `892c20e` (tests), `a9dff9a` (correctif CI `flagsCollection`). Un correctif de contraste **résiduel**, sur le chemin d'affichage du statut (booking déjà répondu, hors `pendingConfirmation`), a été fermé ensuite : branche `fix/a11y-contraste-statut-booking-card` (PR #109), commit `c360d11`.
- **Vérification** : 7 tests dans `booking_request_card_test.dart` (5 existants + 2 accessibilité vérifiant l'en-tête via `flagsCollection.isHeader` et le label regroupé). Tests verts. Revalidation TalkBack physique à mener sur la version fusionnée (sémantique + contraste) lors du rejeu du cas A11Y-REC-01.

### BOGUE-04 — Incohérence pastille « si besoin » / badge « confirmé »

- **Détection** : recette manuelle, affichage d'un artiste confirmé sur une date.
- **Qualification** : **Mineur** · frontend (priorité de couleur des pastilles de calendrier) · incohérence d'affichage sans impact fonctionnel.
- **Comportement attendu** : un artiste confirmé affiche le badge « confirmé » ; la pastille du jour reflète un statut cohérent avec cet engagement.
- **Comportement observé** : un artiste confirmé voit bien le badge « confirmé » lorsqu'il a été sélectionné sur une date (le statut « si besoin » n'est plus affiché sur la fiche, comme souhaité), **mais** la pastille du jour de la date conserve la couleur « si besoin » → incohérence entre la fiche et la pastille de calendrier.
- **Analyse** : la logique de priorité de couleur des pastilles de calendrier ne reflète pas encore finement les statuts mixtes. Ce comportement rejoint une **dette technique déjà documentée** (`technical-debt.md`, section UX : « la priorité de couleur reste simplifiée et doit être améliorée »).
- **Correctif** : **différé en v0.6.0**, rattaché à la dette UX existante sur la représentation des statuts mixtes du calendrier. Report argumenté : défaut mineur, sans impact fonctionnel, dont la résolution propre suppose la refonte de la représentation des statuts mixtes déjà planifiée.
- **Vérification** : à réaliser lors du traitement de la dette UX correspondante (v0.6.0).

### BOGUE-05 — Bouton « Détail » inatteignable au lecteur d'écran

- **Détection** : test manuel au lecteur d'écran (TalkBack) du parcours gérant, mené lors de la vérification de la fiche de consultation nouvellement ajoutée (cas A11Y-REC-02).
- **Qualification** : **Majeur** · frontend (détail inline gérant, `_InlineOpenFullDetailLink`) · le bouton n'est pas atteignable au balayage : un utilisateur de lecteur d'écran ne peut pas ouvrir la fiche complète, et la description de la date — qui n'apparaît nulle part ailleurs — lui reste donc totalement inaccessible. Violation du critère **WCAG 2.1.1** sur un parcours déclaré conforme (§ 4.2 de `accessibilite.md`).
- **Comportement attendu** : le bouton est un arrêt de focus distinct, annoncé comme bouton avec son libellé, et activable au double tap.
- **Comportement observé** : le balayage TalkBack ne s'arrête pas sur le bouton ; le focus l'ignore. Le bouton reste cliquable au tactile classique.
- **Analyse** : le widget enveloppait le `TextButton` dans `Semantics(button: true, label: …)` puis `ExcludeSemantics`. Deux défauts cumulés. (1) `ExcludeSemantics` supprime la sémantique du sous-arbre, y compris l'action de tap native du bouton : le nœud parent déclarait un « bouton » **sans action associée**. (2) Le `Semantics` n'avait pas `container: true` : sans lui, Flutter **fusionne** le nœud dans un ancêtre au lieu de créer un arrêt de focus distinct. Le même patron est correct sur les lignes artiste du même fichier, car elles portent `container` **et** `onTap` — ce qui manquait ici.
- **Correctif** : ajout de `onTap` **et** de `container: true` sur le `Semantics`, alignant le widget sur le patron déjà éprouvé des lignes artiste. Branche `fix/a11y-bouton-detail-inatteignable` (PR #111). Un premier correctif partiel (ajout de `onTap` seul) avait rétabli l'action sans créer le nœud : le double tap sur la carte parente déclenchait l'ouverture, mais le bouton restait hors du parcours de focus — ce qui a permis d'identifier `container` comme la cause racine.
- **Vérification** : test widget vérifiant que le bouton expose un nœud sémantique **distinct** (`isMergedIntoParent == false`), portant le flag bouton et l'action de tap, et présent dans le parcours d'accessibilité simulé (`simulatedAccessibilityTraversal()`). Le test a été **prouvé échouant** sur le code bogué **et** sur le correctif partiel : il couvre la cause racine, pas seulement les propriétés déclarées du widget. Retest TalkBack sur appareil : bouton focalisable, annoncé, activable.

### BOGUE-06 — Contraste insuffisant des pastilles de statut

- **Détection** : contrôle visuel du planning gérant en marge de la campagne de recette. Certaines pastilles apparaissaient nettement moins lisibles que d'autres.
- **Qualification** : **Majeur** · frontend (l'ensemble des widgets de pastille de statut) · violation du critère **WCAG 1.4.3** (contraste du texte) sur des composants présents dans tous les parcours, artiste comme gérant, et déclarés conformes dans `accessibilite.md`.
- **Comportement attendu** : le texte de chaque pastille respecte le ratio AA de 4,5:1 sur son fond.
- **Comportement observé** : deux défauts distincts, révélés par la mesure. (1) `ShowDateStatusPill` et `BookingStatusPill` utilisaient un style « creux » : fond = couleur du statut à 20 % d'opacité, bordure = couleur du statut, et **texte = la même couleur du statut** — un texte coloré sur un fond de la même teinte délavée, dont le ratio ne peut structurellement pas atteindre 4,5:1. (2) `ManagerShowDateSummaryCard` et `AvailabilityStatusPill` forçaient `Colors.white` en dur sur des fonds trop clairs : blanc sur l'orange « Option » (`#FFAB00`) = **1,90:1** ; blanc sur l'orange « Si besoin » (`#E65100`) = **3,79:1**. Le commentaire du code affirmant une « palette compatible WCAG AA (texte blanc ≥ 4,5:1) » était faux.
- **Analyse** : cause racine commune — **la couleur du texte des pastilles n'était pas dérivée de la luminance de leur fond**. Chaque widget appliquait sa propre règle (couleur du statut, ou blanc en dur), sans mesure. La divergence la plus visible opposait deux affichages du **même statut** : la carte résumée du planning dupliquait le rendu de la pastille avec du blanc codé en dur, tandis que le détail inline utilisait `ShowDateStatusPill` — même fond, deux couleurs de texte.
- **Correctif** : fond opaque et couleur de texte déterminée par le helper existant `contrastTextForStatusPill(color)` (qui choisit blanc ou texte foncé selon la luminance du fond) sur **toutes** les pastilles de statut ; plus aucune couleur de texte codée en dur. `ManagerShowDateSummaryCard` réutilise désormais `ShowDateStatusPill` au lieu de dupliquer le rendu, ce qui empêche structurellement une nouvelle divergence entre deux affichages du même statut. Branche `fix/a11y-contraste-pastilles-creuses` (PR #112).
- **Vérification** : ratios recalculés sur l'ensemble des couleurs de `ShowDateStatus`, `BookingStatus` et `AvailabilityStatus` — chaque pastille atteint désormais au moins 4,5:1. Contrôle visuel sur appareil. Le helper `contrastTextForStatusPill` était déjà couvert par des tests WCAG dédiés.

---

## 2. Bogues historiques du projet (jusqu'à v0.4.0)

> Ces anomalies ont été rencontrées et corrigées au cours du développement antérieur. Elles sont tracées dans l'historique Git et le journal des versions (`CHANGELOG.md`), et illustrent le cycle de traitement des bogues sur des natures variées : navigation/plateforme, affichage/données, logique métier.

### BOGUE-07 — Pile de navigation Android incohérente au retour de la vue artiste

- **Détection** : rencontrée au cours du développement de la v0.4.0 (parcours artiste, retour Android depuis la vue de déclaration de disponibilité).
- **Qualification** : **Majeur** · frontend (navigation, vue artiste) · le retour matériel Android laissait une pile de navigation héritée incohérente, dégradant le parcours de l'artiste.
- **Analyse** : le bouton retour Android ne nettoyait pas correctement la pile de navigation en revenant vers `HomeView`, laissant une pile héritée dans un état incohérent.
- **Correctif** : fiabilisation du retour Android de la vue artiste vers `HomeView` via `PopScope` et nettoyage explicite de la pile de navigation. Commit `e2405a0` (`fix(ui): corriger la sélection manager IF_NEEDED et le retour de la vue artiste`).
- **Vérification** : tests ViewModel ajoutés dans le même commit (`availability_choice_viewmodel_test.dart`, `manager_date_detail_viewmodel_test.dart`).

### BOGUE-08 — Affichage des demandes de confirmation artiste (date factice + actions manquantes)

- **Détection** : rencontrée lors de la stabilisation du flux artiste pour la v0.4.0 (carte de demande de confirmation, `BookingRequestCard`). Deux symptômes liés au même composant, corrigés ensemble.
- **Qualification** : **Majeur** · frontend (carte de demande de confirmation artiste) · deux défauts d'affichage sur le parcours de réponse de l'artiste, avec impact utilisateur direct.
- **Analyse** :
  - Symptôme 1 (date factice) : une demande sans détail de date résolu affichait une date de repli (fallback) factice au lieu de la date réelle.
  - Symptôme 2 (actions manquantes) : les actions « Confirmer » et « Refuser » n'apparaissaient pas de façon fiable pour les bookings en statut `PENDING_CONFIRMATION`.
- **Correctif** : résolution des fiches de demande via `getMyAvailableShowDates` (suppression de la date factice) et affichage conditionnel correct des boutons « Confirmer » / « Refuser » sur le statut `PENDING_CONFIRMATION`, dans `booking_request_card.dart`. Commit `2587e34` (`feat(availability): stabiliser le flux artiste pour la v0.4.0`), mergé via PR #39 (`fix/v0.4.0`) avant le tag `v0.4.0`.
- **Vérification** : tests widget ajoutés dans le même commit (`booking_request_card_test.dart` : boutons de réponse, statut déjà traité, demande sans détail de date).

### BOGUE-09 — Impossible de re-sélectionner un artiste après un booking terminal

- **Détection** : rencontrée au cours du développement du domaine booking (v0.4.0). Après un refus ou une annulation, le gérant ne pouvait plus re-sélectionner l'artiste sur la même date.
- **Qualification** : **Majeur** · backend (domaine `artistbooking`, service de création de booking) · règle métier bloquant une action légitime du gérant ; impact fonctionnel direct.
- **Analyse** : la contrainte d'unicité sur la paire `(show_date, artist)` empêchait la création d'un nouveau booking lorsqu'un booking terminal (`REFUSED` ou `CANCELLED`) existait déjà pour cette paire. La tentative de re-sélection échouait alors qu'elle devait être autorisée.
- **Correctif** : `createBooking` détecte un booking terminal existant et le **recycle** au lieu d'en créer un nouveau (`resetBookingForReselection`) : le statut repasse à `SELECTED`, la timeline est réinitialisée (`requestedAt`/`respondedAt` remis à null), le `createdAt` est conservé et l'`updatedAt` rafraîchi. Un booking **actif** (`SELECTED`, `PENDING_CONFIRMATION`, `CONFIRMED`) reste, lui, bloquant (`assertNotActivelyBooked`). Commits `0741312` puis `c422e60` (`fix(booking): recycler un booking terminal lors d'une re-selection`), PR #72.
- **Vérification** : tests de service dédiés dans `ArtistBookingServiceTest` — recyclage après `REFUSED`, recyclage après `CANCELLED`, réinitialisation de la timeline (avec conservation du `createdAt`), réaffectation du `skillRequirement` et du `agreedNetFee`, unicité de la ligne pour la paire.

---

## 3. Points d'amélioration consignés

> Enseignements tirés du traitement des bogues ci-dessus, conservés comme axes de vigilance pour la suite du projet.

- **Contrat de couche non tenu (BOGUE-01)** : un commentaire de `getMyProfile` affirmait un comportement (« retourne `null` sur 404 ») que le code n'implémentait pas. Vérifier systématiquement que les contrats documentés d'une couche sont couverts par un test.
- **Tokens de design non généralisés (BOGUE-02, BOGUE-03)** : plusieurs widgets antérieurs au refactor v0.5.0 n'avaient pas basculé sur les tokens de carte opaque. Le chemin résiduel de `BookingRequestCard` (affichage du statut hors `pendingConfirmation`) a été fermé (commit `c360d11`) ; auditer les widgets restants sur fond clair.
- **Qualification initiale à affiner (BOGUE-03)** : le défaut avait été qualifié « sémantique » sans validation physique préalable, alors que le défaut principal était un contraste. Toujours confronter la qualification à un test réel sur appareil avant de figer la nature de l'anomalie.
- **Mesurer avant de corriger un contraste (BOGUE-06)** : l'intuition visuelle suggérait d'uniformiser les pastilles en texte blanc. La mesure a montré l'inverse — le blanc était précisément la violation (1,90:1 sur l'orange « Option »), et le texte foncé la solution conforme (9,15:1). Sur un critère quantifié comme WCAG 1.4.3, calculer le ratio avant de trancher, plutôt que de se fier au rendu perçu.
- **Un test peut valider la mauvaise chose (BOGUE-05)** : le premier test d'accessibilité du bouton passait alors que le bogue persistait. Il vérifiait les propriétés du widget `Semantics`, quand l'API de test remontait jusqu'au nœud parent fusionné — exactement le défaut à détecter. Systématiquement **vérifier qu'un test de non-régression échoue sur le code bogué** avant de le considérer comme une preuve.
- **Gestion de branches sur un même fichier (BOGUE-03)** : les deux volets (sémantique et contraste) ont été développés sur deux branches distinctes tirées de `main` à des moments différents, créant une divergence sur le même fichier, résolue par rebase et fusion manuelle. Leçon : quand plusieurs correctifs touchent le même fichier, enchaîner sur une branche unique ou merger le premier avant de dériver le second.

---

## 4. Traçabilité avec le cahier de recettes

Les bogues détectés en recette (section 1) sont référencés depuis la colonne « anomalie liée » du cahier de recettes (`cahier-de-recettes.md`) pour chaque cas en statut **KO**. Une fois le correctif appliqué et vérifié, le résultat observé du cas concerné est mis à jour (KO → OK) avec mention du `BOGUE-0X` correspondant.
