# Dette technique — Violette v0.4.0

Ce document recense les dettes connues avant la release `v0.4.0`. Il ne remplace pas le changelog : il sert à expliciter les limites assumées et à orienter les prochaines itérations.

---

## Backend

- Le bootstrap crée une compagnie unique `Dream's Production` pour garder la démonstration de bout en bout opérationnelle.
- Les utilisateurs `MANAGER` et `ARTIST` sont rattachés automatiquement à cette compagnie unique.
- Le modèle multi-compagnies existe partiellement, mais il n'y a pas encore de vraie gestion multi-compagnies côté produit.
- Il n'existe pas encore de notion de compagnie active pour un utilisateur membre de plusieurs compagnies.
- Le verrou `booking CONFIRMED -> disponibilité non modifiable` est appliqué côté frontend en `v0.4.0`, mais pas encore garanti côté backend sur l'endpoint de modification de disponibilité.
- Les tests unitaires backend utilisent H2 avec génération Hibernate ; les migrations Flyway MySQL sont validées séparément par les tests d'intégration et doivent rester surveillées.

## Frontend

- La navigation stack n'est pas encore totalement maîtrisée : certains retours utilisent `clearStackAndShow` comme correction temporaire.
- Les couches REST manuelles (`Dio`, remote data sources, mappers) coexistent avec le client OpenAPI généré.
- Le client OpenAPI généré `violette_api_client/` est utilisé principalement pour le domaine `user`. Les domaines `availability`, `showDate` et `booking` utilisent encore Dio manuel, JSON et mappers dédiés.
- La régénération complète de `violette_api_client/` a été auditée puis reportée après `v0.4.0` pour éviter un diff généré risqué juste avant tag.
- Une incohérence potentielle existe dans le client généré : `apiArtistBookingsMeGet` semble typé comme un DTO unique alors que le backend renvoie une liste. Ce n'est pas bloquant pour `v0.4.0`, car le runtime Flutter appelle `GET /api/artist-bookings/me` via Dio manuel.
- Certaines compatibilités avec des identifiants historiques `firebaseUid` restent présentes pendant la transition vers les identifiants backend.

## Métier

- Les transitions de `ShowDateStatus` exposées dans l'app restent simplifiées pour la démonstration `v0.4.0`.
- Le champ `ShowDateSkillRequirement` n'est pas encore raccordé au formulaire de création de date : le champ frontend **Artistes nécessaires** reste informatif en `v0.4.0`.
- `IF_NEEDED` est sélectionnable, mais l'UI ne priorise pas encore finement les artistes `AVAILABLE` par rapport aux artistes `IF_NEEDED`.
- Le workflow complet de présélection n'est pas encore visible côté artiste.
- Le désistement autonome d'un artiste après confirmation est hors périmètre : l'artiste doit contacter le gérant.

## UX

- Le calendrier multi-dates applique des règles simples de priorité de couleur au lieu d'une représentation visuelle dédiée aux statuts mixtes.
- Le planning manager et la vue artiste affichent plusieurs dates le même jour, mais la priorité de couleur reste simplifiée et doit être améliorée.
- Il n'y a pas encore de notifications artistes pour les demandes de confirmation.
- La différenciation visuelle entre disponibilité, présélection, demande en attente et confirmation reste minimaliste.
- Les actions groupées sur plusieurs dates d'un même jour ne sont pas encore proposées.
- La release `v0.4.0` cible prioritairement Android ; les parcours web et iOS restent hors périmètre de validation.

## Tests

- Il n'y a pas encore de tests E2E automatisés couvrant le parcours complet gérant -> artiste -> booking confirmé.
- Le client OpenAPI généré n'a pas de tests fonctionnels dédiés.
- La cohérence entre la spec OpenAPI, le client généré et les wrappers frontend n'est pas encore testée automatiquement.
- Les scénarios de production MySQL restent principalement couverts par migrations et tests d'intégration ciblés, pas par toute la suite frontend/backend.

## Évolutions futures

- Ajouter un verrou backend sur la modification de disponibilité si l'artiste possède un booking `CONFIRMED` sur la date.
- Régénérer et vérifier `violette_api_client/`, puis corriger la signature générée de `GET /api/artist-bookings/me` si nécessaire.
- Finaliser la gestion multi-compagnies.
- Ajouter la création et l'édition de compagnie.
- Gérer les rôles par compagnie.
- Reprendre la création de date autour de `ShowDateSkillRequirement` (compétences, effectifs, cachets).
- Exposer le workflow complet booking : présélection -> demande de confirmation -> confirmation/refus -> `STAFFED`.
- Améliorer l'UX calendrier : multi-date, statuts mixtes, actions groupées.
- Ajouter des notifications artistes.
- Ajouter la suppression encadrée des `ShowDate` et utilisateurs.
- Automatiser le passage à `STAFFED` quand la capacité confirmée est atteinte.
- Centraliser davantage les règles métier frontend pour éviter leur duplication dans plusieurs ViewModels.
