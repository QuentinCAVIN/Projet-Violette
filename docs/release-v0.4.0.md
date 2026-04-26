# Préparation release `v0.4.0`

Cette checklist rassemble les vérifications documentaires et techniques à effectuer avant de taguer `v0.4.0`.

Le changelog global reste la source d'historique des versions, mais il n'est pas modifié dans cette étape.

---

## Objectif de release

`v0.4.0` marque la sortie du frontend de Firestore pour le code métier migré :

- `user` ;
- `availability` ;
- `showDate` ;
- `booking`.

Firebase Auth reste utilisé pour l'identité et les JWT.

---

## Checklist documentation

- [ ] README racine relu : état `v0.4.0`, démarrage rapide, scénarios courants.
- [ ] README frontend relu : `API_BASE_URL`, téléphone USB, émulateur, Fly.io, APK.
- [ ] README backend relu : migrations Flyway, profils, OIDC Firebase, tests.
- [ ] Règles métier relues : `ShowDateStatus`, `AvailabilityStatus`, `BookingStatus`.
- [ ] Workflow de réservation relu : absence des anciennes valeurs `OPTIONAL`, `LOCKED`, `CONDITIONAL`.
- [ ] Documentation de tests relue : commandes backend/frontend et périmètre REST.
- [ ] Documentation de déploiement relue : tag, Fly.io, APK, version Swagger.

---

## Checklist technique avant tag

```bash
cd violette-back
./mvnw verify -DskipITs=false
```

```bash
cd violette_front
flutter analyze
flutter test
```

Vérifications manuelles :

- [ ] `curl http://localhost:8080/api/ping` répond en local.
- [ ] `curl https://violette-back.fly.dev/api/ping` répond en production.
- [ ] Swagger local affiche la version attendue après build de release.
- [ ] Swagger Fly.io affiche la version du tag après déploiement.
- [ ] L'app Flutter fonctionne avec le backend local via `adb reverse`.
- [ ] L'app Flutter fonctionne avec l'émulateur via `API_BASE_URL=http://10.0.2.2:8080`.
- [ ] L'app Flutter fonctionne avec Fly.io via `API_BASE_URL=https://violette-back.fly.dev`.

---

## Version et tag

Pendant le développement, le backend peut rester en `-SNAPSHOT`. Le workflow `deploy.yml` aligne Maven sur le tag pendant la release avec `versions:set`.

Commande de release :

```bash
git tag v0.4.0
git push origin v0.4.0
```

Après déploiement :

- [ ] GitHub Release créée.
- [ ] APK attaché à la release.
- [ ] Image GHCR publiée avec le tag `v0.4.0`.
- [ ] Fly.io déploie l'image taguée.
- [ ] `/api/ping` et Swagger exposent `0.4.0`.

---

## Points à ne pas oublier

- Régénérer le client OpenAPI si le contrat exposé par le backend a changé.
- Vérifier que `violette_api_client` ne contredit pas les enums métier actuelles avant de s'en servir comme référence.
- Ne pas réintroduire Firestore comme source métier frontend pour les domaines migrés.
- Vérifier que `API_BASE_URL` est bien fourni au build APK de production.
- Vérifier après tag que `/api/ping`, Swagger UI et les logs Quarkus affichent la version `0.4.0` (sans suffixe `-SNAPSHOT`).

---

## Limitation temporaire v0.4.0 — compagnie unique

Pour éviter de bloquer la démo et les tests de création de date (`POST /api/show-dates`) :

- le backend initialise une compagnie unique nommée `Dream's Production` si possible ;
- tout utilisateur créé avec le rôle `MANAGER` et/ou `ARTIST` est automatiquement rattaché à cette compagnie ;
- la logique est volontairement temporaire et documentée dans le code backend (bootstrap v0.4.0).
- l'exposition des dates côté artiste passe par des endpoints dédiés (`/api/show-dates/me/available` et `/api/show-dates/{id}/availabilities/me`) pour ne pas exposer les disponibilités des autres artistes.
- une action manager minimale permet de changer manuellement le statut d'une date pour tester le flux `INQUIRY -> OPTION -> CONFIRMED` (et `CONFIRMED -> STAFFED`) en v0.4.0.
- le champ frontend **Artistes nécessaires** du formulaire de création est temporairement informatif : la valeur n'est pas persistée par `POST /api/show-dates` en v0.4.0.
- dans le planning manager, un jour peut afficher plusieurs `ShowDate` ; la pastille du calendrier applique une priorité de statut simple (`CONFIRMED > OPTION > INQUIRY > STAFFED > CANCELLED > ARCHIVED`) en cas de statuts mixtes.
- côté artiste, un booking `CONFIRMED` verrouille la modification de disponibilité sur la date concernée ; l'artiste doit contacter le gérant pour se désister ou modifier son engagement.

Conséquence :

- en local H2 comme en production, la release `v0.4.0` reste testable de bout en bout sans écran de gestion de compagnie.
- le cycle de vie complet des statuts reste simplifié : seules les transitions minimales nécessaires à la démonstration E2E sont exposées côté manager.

Hors périmètre v0.4.0 :

- la création autonome de compagnie ;
- la gestion multi-compagnies ;
- le choix explicite de la compagnie active.
- le raccord du champ **Artistes nécessaires** à la création REST (modèle orienté `ShowDateSkillRequirement`).
- la gestion autonome du désistement artiste après confirmation.
- la validation complète des parcours web et iOS, la release visant prioritairement Android.

Ces fonctionnalités sont prévues pour `v0.5.0`.

---

## Risques production à surveiller

- Les tests unitaires backend utilisent H2 avec génération Hibernate (`drop-and-create`) et Flyway désactivé ; ils ne suffisent pas à valider seuls les migrations MySQL.
- Les migrations Flyway utilisent des `ENUM` MySQL et des colonnes `TEXT`. Les anciennes valeurs (`PENDING`, `OPTIONAL`, `LOCKED`, `CONDITIONAL`) sont présentes dans les migrations historiques, puis migrées vers les valeurs actuelles par V6/V7.
- Le client `violette_api_client` généré peut contenir des modèles historiques tant qu'il n'est pas régénéré ; en `v0.4.0`, il ne doit pas servir de source de vérité pour les enums `showDate` tant que l'adoption OpenAPI par domaine n'est pas finalisée.
- La régénération complète de `violette_api_client/` est reportée après `v0.4.0`. Le client généré est utilisé principalement pour `user`; `availability`, `showDate` et `booking` restent sur Dio manuel. L'incohérence potentielle `apiArtistBookingsMeGet` (DTO unique vs liste backend) n'est pas bloquante car cette méthode générée n'est pas utilisée au runtime.
- Le verrou empêchant l'artiste confirmé de modifier sa disponibilité est appliqué côté frontend. Un verrou backend équivalent reste à ajouter pour couvrir les appels directs hors application.
- Aiven peut mettre la base MySQL en pause selon le plan utilisé ; vérifier l'état du service avant une démonstration.

## Évolutions futures

- Ajouter un verrou backend sur la modification de disponibilité si booking `CONFIRMED`.
- Finaliser la gestion multi-compagnies.
- Ajouter la création et l'édition de compagnie.
- Gérer les rôles par compagnie.
- Reprendre la création de `ShowDate` autour de `ShowDateSkillRequirement` (compétences, effectifs, cachets).
- Exposer le workflow complet booking : présélection → demande de confirmation → confirmation/refus → `STAFFED`.
- Améliorer l'UX calendrier pour les jours multi-dates et les actions groupées.
- Ajouter les notifications artistes.
- Ajouter la suppression encadrée des `ShowDate` et utilisateurs.
- Automatiser le passage à `STAFFED`.
- Centraliser les règles métier frontend pour limiter la duplication entre ViewModels.
