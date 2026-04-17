# Guide des tests unitaires - Projet Violette (Généré par IA)

## 🎯 Philosophie

Ce projet adopte une approche **agile et légère** pour les tests unitaires :

- ✅ **Tests à forte valeur** - Focus sur la logique métier stable
- ✅ **Faible couplage** - Tests résistants aux refactorings
- ✅ **Rapidité** - Exécution en quelques secondes
- ❌ **Pas de mocking complexe** - Éviter Firebase, services externes

## 🚀 Exécution des tests

```bash
# Tous les tests
flutter test

# Tests par catégorie
flutter test test/models/
flutter test test/viewmodels/

# Test spécifique
flutter test test/models/enums/availability_status_test.dart

# Avec plus de détails
flutter test --reporter=expanded
```

## 📁 Structure des tests

```
test/
├── models/                          # Tests de logique métier pure (priorité 1)
│   ├── enums/
│   │   ├── availability_status_test.dart   # Transitions et labels
│   │   └── role_test.dart                  # Mapping string ↔ enum
│   └── show_date_test.dart                 # Conversions, règle 12h
│
├── viewmodels/                      # Tests ViewModels légers (priorité 2)
│   ├── availability_choice_viewmodel_test.dart
│   ├── create_show_date_viewmodel_test.dart
│   └── login_viewmodel_test.dart
│
└── helpers/
    └── test_data_builders.dart      # Utilitaires pour créer des données de test
```

## ✅ Tests de logique métier pure

### AvailabilityStatus (`test/models/enums/availability_status_test.dart`)

**Ce qui est testé :**
- ✅ Transitions de statut : `pending → available → ifNeeded → unavailable → available`
- ✅ Labels français pour l'UI
- ✅ Serialization : `.name` retourne la bonne string

**Pourquoi c'est important :**
- Règle métier critique pour le calendrier
- Utilisé partout dans l'app

### ShowDate (`test/models/show_date_test.dart`)

**Ce qui est testé :**
- ✅ Conversion minutes ↔ HH:mm (ex: 125 → "02:05")
- ✅ Formatage de dates
- ✅ **Règle métier : Durée max 12h pour un cachet**
- ✅ Formatage et helpers de `ShowDate` (date, heures, règles de durée)

**Pourquoi c'est important :**
- Contrainte légale : un cachet d'intermittent ≤ 12h
- Conversions utilisées dans toute l'UI
- Logique pure, testable sans mocks

### Role (`test/models/enums/role_test.dart`)

**Ce qui est testé :**
- ✅ Mapping string ↔ Role
- ✅ Gestion des erreurs (valeur invalide)
- ✅ Labels

## 🎨 Tests ViewModels légers

Les tests de ViewModels se concentrent sur les **états observables finaux**, pas sur l'implémentation.

### Principes

❌ **On NE teste PAS :**
- L'ordre des appels (`setBusy()`, `rebuildUi()`)
- Les détails d'implémentation
- Les appels de navigation précis
- Les services Firebase

✅ **On teste :**
- Les états finaux observables
- La logique métier dans le ViewModel
- Les helpers publics
- Les comportements utilisateur

### Exemple : AvailabilityChoiceViewModel

```dart
test('2e tap sur le même jour devrait modifier le statut local', () {
  final viewModel = AvailabilityChoiceViewModel();
  final testDate = DateTime(2025, 6, 15);
  
  final showDate = TestDataBuilders.createTestShowDate(
    date: testDate,
    status: AvailabilityStatus.pending,
  );
  viewModel.showDates.add(showDate);

  // 1er tap
  viewModel.onDaySelected(testDate, testDate);
  
  // 2e tap
  viewModel.onDaySelected(testDate, testDate);

  // Vérifier le résultat final
  expect(viewModel.getStatusForDay(testDate), AvailabilityStatus.available);
});
```

## 🛠️ Créer un nouveau test

### 1. Test de logique pure (recommandé)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/...'  ;

void main() {
  group('NomDeLaClasse', () {
    test('devrait faire X quand Y', () {
      // Arrange - Préparer les données
      final input = ...;
      
      // Act - Exécuter la fonction
      final result = maFonction(input);
      
      // Assert - Vérifier le résultat
      expect(result, expectedValue);
    });
  });
}
```

### 2. Test ViewModel léger

```dart
test('devrait mettre à jour l\'état observable', () {
  // Créer le ViewModel
  final viewModel = MonViewModel();
  
  // Injecter des données manuellement (pas de mock)
  viewModel.items.add(TestDataBuilders.createTestItem());
  
  // Appeler la méthode
  viewModel.onAction();
  
  // Vérifier l'état final
  expect(viewModel.stateObservable, expectedValue);
});
```

## 📦 Utilitaires : TestDataBuilders

Le fichier `test/helpers/test_data_builders.dart` contient des fonctions pour créer facilement des données de test :

```dart
// Créer un utilisateur de test
final user = TestDataBuilders.createTestUser(
  firstName: 'Marie',
  roles: [Role.manager],
);

// Créer une ShowDate de test
final showDate = TestDataBuilders.createTestShowDate(
  date: DateTime(2025, 6, 15),
  status: AvailabilityStatus.available,
  startMinutes: 540, // 9:00
  endMinutes: 1020,  // 17:00
);

// Créer plusieurs ShowDates pour un mois
final showDates = TestDataBuilders.createTestShowDatesForMonth(
  year: 2025,
  month: 6,
  count: 10,
);
```

## ⚡ Bonnes pratiques

### ✅ À FAIRE

- **Noms descriptifs** : `test('devrait retourner null quand utilisateur inexistant')`
- **AAA pattern** : Arrange / Act / Assert
- **Un seul concept par test**
- **Tests indépendants** : chaque test peut tourner seul
- **Pas de logique dans les tests** : if/else/loops sont suspects

### ❌ À ÉVITER

- Tester des détails d'implémentation
- Mocker des classes qu'on ne possède pas (Firebase, etc.)
- Tests trop longs (> 10 lignes dans le test)
- Dépendances entre tests

## 🔮 Prochaines étapes (à implémenter plus tard)

Ces éléments sont volontairement **reportés** pour rester agile :

- **Smoke tests** (2-3 tests end-to-end)
- **Tests services** avec mocks Firestore
- **Widget tests** pour l'UI
- **Injection de dépendances** dans les services
- **Coverage** > 80%

---

**Dernière mise à jour :** 2025-12-20
