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
