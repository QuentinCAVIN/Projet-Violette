# Stratégie de tests — Violette

## Objectif

Garantir la stabilité du contrat API REST ↔ domaine à chaque évolution frontend/backend, et détecter les régressions avant merge.

---

## Répartition des tests

### Backend (Quarkus)

| Type | Outil | Périmètre |
|------|-------|-----------|
| Unitaire H2 | `@QuarkusTest` + H2 in-memory | Service, Repository, Mapper, Controller (logique) |
| Intégration MySQL | `@QuarkusTest` + Dev Services / Testcontainers | Repository + flux complets sur MySQL réel |
| Sécurité HTTP | `@TestSecurity` + `@InjectMock` | Contrôleur avec principal JWT simulé |

Flyway est **désactivé** en profil test ; Hibernate régénère le schéma via `drop-and-create`.

### Frontend (Flutter/Dart)

| Type | Outil | Périmètre |
|------|-------|-----------|
| Unitaire Mapper | `flutter_test` (pur Dart) | Contrat DTO API → modèle métier |
| Unitaire ViewModel | `flutter_test` + `mocktail` | Flux de routage, appels service |
| Golden tests | `flutter_test` / `golden_toolkit` | Stabilité visuelle des composants ciblés |

---

## Profils de test Quarkus

Le projet utilise plusieurs profils pour isoler les environnements :

- **`test`**
  - base H2 en mémoire
  - utilisé pour les tests unitaires rapides

- **`integration`**
  - base MySQL via Testcontainers (Dev Services)
  - utilisé pour les tests d'intégration backend (classes suffixées `IT`)

- **`prod`**
  - base MySQL réelle
  - configuration fournie par variables d'environnement

Principe :

- ne jamais définir `quarkus.datasource.jdbc.url` dans le profil `integration`
- laisser Quarkus démarrer automatiquement un conteneur MySQL pour les tests d'intégration

Cela garantit :

- des tests proches de la production
- une configuration stable en CI

---

## Règle de migration REST

Chaque domaine migré vers le backend REST doit embarquer :

1. **Test mapper** (Flutter) — vérifie champ par champ le mapping DTO ↔ domaine, cas null, rôles/enums inconnus.
2. **Test ViewModel** (Flutter) — couvre les chemins nominaux et les cas d'erreur (réseau, état incohérent).
3. **Test contrôleur backend** — au minimum : happy path (200), not found (404), non authentifié (401).

Domaines concernés pour `v0.4.0` :

| Domaine | État attendu |
|---|---|
| `user` | REST via client OpenAPI généré |
| `availability` | REST via Dio + mapper manuel |
| `showDate` | REST via Dio + mapper manuel |
| `booking` | REST via Dio + mapper manuel |

---

## Couverture JaCoCo (backend)

- Rapport XML généré par `quarkus-jacoco` à chaque `mvn verify`.
- Seuil de couverture : **70 %** (lignes, voir ci-dessous).
- `quarkus.jacoco.reuse-data-file=true` → cumul Surefire (H2) + Failsafe (ITs MySQL) dans un seul rapport.
- ITs activés en CI avec `-DskipITs=false`.

### Couverture réelle mesurée

Rapport JaCoCo généré par la CI (JDK 21 Temurin, `mvn verify -DskipITs=false`) :

| Métrique | Couverture |
|----------|------------|
| Instructions | 83,6 % |
| Lignes | 81,1 % |
| Branches | 60,7 % |
| Méthodes | 81,5 % |
| Classes | 84,9 % |

### Profil de couverture assumé

Le choix de couverture cible les **règles métier** plutôt qu'une couverture uniforme artificielle. Les domaines critiques sont couverts à ~95 % :

| Package | Couverture lignes |
|---------|-------------------|
| `artistbooking.service` | 95,1 % |
| `showdate.service` | 95,3 % |

En revanche, la plomberie sans logique (records DTO, `exception.mapper`, classes d'exception à simple constructeur) est volontairement peu couverte : ces artefacts n'apportent pas de valeur métier en test unitaire.

**`CabaretCompanyService`** : sa logique critique (bootstrap de la compagnie par défaut, rattachement manager/artiste) est couverte par `DefaultCompanyBootstrapServiceTest` — nommé d'après le scénario métier, non d'après la classe, d'où une couverture réelle supérieure à ce que le nommage suggère.

**`CabaretShowService`** : classe de lecture avec contrôle d'ownership, désormais couverte par `CabaretShowServiceTest`.

### Seuil CI

Le seuil JaCoCo est passé de **30 %** (plafond hérité du module d'architecture initial, volontairement bas) à **70 %**. Ce plancher professionnel est dépassé par la couverture réelle (81 % lignes) avec une marge confortable : le garde-fou n'est pas bloquant et laisse de l'air pour les évolutions du code.

**Note sur les branches** : le seuil porte uniquement sur les **lignes** (`LINE` / `COVEREDRATIO`). La couverture de branches (60,7 %) n'est pas soumise à seuil ; les branches non couvertes se concentrent dans les cas d'erreur rares et la plomberie.

Commandes utiles :

```bash
cd violette-back
./mvnw test
./mvnw verify
./mvnw verify -DskipITs=false
```

```bash
cd violette_front
flutter analyze
flutter test
flutter test --update-goldens
```

---

## Tests de recette manuelle — domaines REST

| ID | Scénario |
|----|----------|
| USER-REC-01 | Connexion avec profil backend déjà créé → navigation vers Home |
| USER-REC-02 | Inscription nouvel utilisateur → profil créé, navigation vers Home au prochain lancement |
| USER-REC-03 | Perte réseau au démarrage → écran d'erreur, aucune navigation silencieuse |
| USER-REC-04 | Session Firebase sans profil backend → logout + redirection Login |

À compléter avant release avec des recettes courtes pour :

- disponibilité artiste sur téléphone ;
- planning gérant et détail de date ;
- présélection en `OPTION` ;
- demande de confirmation après passage en `CONFIRMED` ;
- réponse artiste et affichage booking.
