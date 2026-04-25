# Contexte et Règles du Projet Violette

Ce fichier résume les règles importantes, conventions et leçons apprises à respecter pour tout développement futur sur ce projet.

## 1. Architecture & Commandes
- **Framework** : Utilisation stricte de l'architecture **Stacked (MVVM)**.
- **Création de Vues** : Ne jamais créer les fichiers manuellement. Utiliser impérativement la commande CLI :
  ```bash
  stacked create view nom_de_la_vue
  ```
- **Structure** : Respecter la séparation Model (Données) - View (UI) - ViewModel (Logique).

## 2. Tests Unitaires & Widgets
- **Langue** : Tous les commentaires, noms de groupes (`group`) et descriptions de tests (`test`, `testWidgets`) doivent être rédigés en **Français**.
- **Référence** : Suivre les directives du fichier `test/TEST_README.md`.
- **Données de Test** : Utiliser systématiquement `test/helpers/test_data_builders.dart` pour instancier des objets complexes (ShowDate, User...). Ex: `TestDataBuilders.createTestShowDate(...)`.

## 3. Gestion des Dates et Timezones
> **Point critique** : éviter les décalages de jour calendaire entre l'API, l'appareil et l'affichage local.

- **Enregistrement / mapping API REST** : normaliser les dates de spectacle en conservant l'intention calendaire. Pour les dates sans heure métier, utiliser une heure neutre comme **midi UTC** si un `DateTime` complet est nécessaire.
  ```dart
  DateTime.utc(year, month, day, 12);
  ```
- **Lecture** : convertir seulement au niveau adapté à l'affichage. Ne pas introduire de conversion locale dans un mapper si elle change le jour métier attendu.

## 4. Robustesse API REST (Enums)
- **Parsing** : ne jamais caster directement une chaîne API en enum domaine. Utiliser les mappers dédiés (`ShowDateMapper`, `AvailabilityMapper`, `ArtistBookingMapper`) et conserver une valeur de secours explicite.
- **ShowDateStatus** : les valeurs métier actuelles sont `inquiry`, `option`, `confirmed`, `staffed`, `cancelled`, `archived`.
- **AvailabilityStatus** : `pending`, `available`, `ifNeeded`, `unavailable`.
- **BookingStatus** : le backend expose `SELECTED`, `PENDING_CONFIRMATION`, `CONFIRMED`, `REFUSED`, `CANCELLED`; le domaine Flutter affiche `preselected`, `pendingConfirmation`, `confirmed`, `refused`, `cancelled`.

## 5. UI & Design
- **Composants** : Privilégier la réutilisation des composants existants (ex: `VioletteCalendar`, `ManagerDateDetailCard`).
