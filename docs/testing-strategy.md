# Stratégie de tests — Violette

## Objectif

Garantir la stabilité du contrat DTO ↔ domaine à chaque migration Firestore → REST backend, et détecter les régressions avant merge.

---

## Répartition des tests

### Backend (Quarkus)

| Type | Outil | Périmètre |
|------|-------|-----------|
| Unitaire H2 | `@QuarkusTest` + H2 in-memory | Service, Repository, Mapper, Controller (logique) |
| Intégration MySQL | `@QuarkusTest` + Testcontainers | Repository + flux complets sur MySQL réel |
| Sécurité HTTP | `@TestSecurity` + `@InjectMock` | Contrôleur avec principal JWT simulé |

Flyway est **désactivé** en profil test ; Hibernate régénère le schéma via `drop-and-create`.

### Frontend (Flutter/Dart)

| Type | Outil | Périmètre |
|------|-------|-----------|
| Unitaire Mapper | `flutter_test` (pur Dart) | Contrat DTO API → modèle métier |
| Unitaire ViewModel | `flutter_test` + `mocktail` | Flux de routage, appels service |

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

## Règle de migration

Chaque domaine migré de Firestore vers le backend REST doit embarquer :

1. **Test mapper** (Flutter) — vérifie champ par champ le mapping DTO ↔ domaine, cas null, rôles/enums inconnus.
2. **Test ViewModel** (Flutter) — couvre les chemins nominaux et les cas d'erreur (réseau, état incohérent).
3. **Test contrôleur backend** — au minimum : happy path (200), not found (404), non authentifié (401).

---

## Couverture JaCoCo (backend)

- Rapport XML généré par `quarkus-jacoco` à chaque `mvn verify`.
- Seuil de couverture : **30 %** (branche minimale, relevé à la maturité du projet).
- `quarkus.jacoco.reuse-data-file=true` → cumul Surefire (H2) + Failsafe (ITs MySQL) dans un seul rapport.
- ITs activés en CI avec `-DskipITs=false`.

---

## Tests de recette manuelle — domaine `user`

| ID | Scénario |
|----|----------|
| USER-REC-01 | Connexion avec profil backend déjà créé → navigation vers Home |
| USER-REC-02 | Inscription nouvel utilisateur → profil créé, navigation vers Home au prochain lancement |
| USER-REC-03 | Perte réseau au démarrage → écran d'erreur, aucune navigation silencieuse |
| USER-REC-04 | Session Firebase sans profil backend → logout + redirection Login |
