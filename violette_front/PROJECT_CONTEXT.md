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
> ⚠️ **Point Critique** : Problème récurrent de décalage horaire (UTC vs Local).

- **Enregistrement (Firestore)** : Toujours créer les dates à **Midi UTC** pour garantir qu'elles tombent le bon jour calendaire indépendamment du fuseau horaire de l'utilisateur.
  ```dart
  DateTime.utc(year, month, day, 12);
  ```
- **Lecture** : Convertir systématiquement en heure locale (`.toLocal()`) lors de la `factory fromFirestore` pour l'affichage correct dans l'UI.

## 4. Robustesse Firestore (Enums)
- **Parsing** : Ne jamais caster directement une String Firestore en Enum. Utiliser une méthode statique de parsing avec une valeur par défaut de secours (fallback).
- **Exemple** : Si le champ `status` vaut "unknown" ou est null, l'application ne doit pas planter (Spinner infini), mais retourner une valeur par défaut (ex: `ShowDateStatus.pending`).

## 5. UI & Design
- **Composants** : Privilégier la réutilisation des composants existants (ex: `VioletteCalendar`, `ManagerDateDetailCard`).
