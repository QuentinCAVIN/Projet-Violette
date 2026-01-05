# Architecture Stacked Manuelle - Violette

Ce document explique comment l'architecture Stacked est utilisée dans ce projet **sans `build_runner` ni génération de code**. Il sert de guide pour comprendre les implémentations manuelles des concepts clés de Stacked (injection de dépendances, navigation, etc.) et comment les développeurs pourront activer la génération de code par la suite.

---

### 1. Le Rôle de `@StackedApp` et son Équivalent Manuel

Dans un projet Stacked standard, le fichier `app.dart` contient une classe annotée avec `@StackedApp`, qui ressemble à ceci :

```dart
// @StackedApp(
//   routes: [ MaterialRoute(page: HomeView), ... ],
//   dependencies: [ LazySingleton(classType: NavigationService), ... ],
// )
// class App {}
```

**À quoi ça sert ?**
L'annotation `@StackedApp` est lue par `build_runner` et `stacked_generator`. Elle génère automatiquement deux fichiers cruciaux :
1.  `app.locator.dart` : Gère l'injection de dépendances (Service Locator). Il crée une instance `locator` et une fonction `setupLocator()` pour enregistrer tous les services.
2.  `app.router.dart` : Gère la navigation. Il crée une classe `AppRouter` avec des méthodes typées pour naviguer (ex: `router.navigateToHomeView()`) et des constantes pour les noms de routes.

**Notre approche manuelle :**
Puisque nous n'utilisons pas le générateur, nous recréons ces mécanismes "à la main".

-   **Pour l'injection de dépendances**, nous créons un fichier `app/app.dart` qui contient :
    -   Une instance globale `locator` (utilisant le package `get_it`).
    -   Une fonction `setupLocator()` où nous enregistrons manuellement chaque service.
    ```dart
    // Dans app/app.dart
    final locator = GetIt.instance;

    void setupLocator() {
      locator.registerLazySingleton(() => NavigationService());
      // ... autres services
    }
    ```
-   **Pour la navigation**, nous créons un fichier `app/router.dart` qui contient :
    -   Des constantes pour les noms de routes (ex: `const String homeViewRoute = '/';`).
    -   Une classe `AppRouter` avec une méthode `generateRoute` qui utilise un `switch` pour retourner la bonne `MaterialPageRoute` en fonction du nom de la route.

### 2. Gestion des Vues et ViewModels

Une vue dans Stacked est un `StatelessWidget` qui utilise un `ViewModelBuilder` pour se connecter à son ViewModel.

**Approche avec `build_runner` :**
Normalement, une vue simple ne nécessite pas de code "boilerplate". Pour des fonctionnalités plus avancées comme les formulaires, on utilise l'annotation `@FormView`.
-   `@FormView(fields: [FormTextField('email'), ...])` génère un `mixin` (ex: `_$$LoginView`) qui contient les `TextEditingController`, `FocusNode` et les méthodes de validation pour chaque champ du formulaire.

**Notre approche manuelle :**
-   **Vues Simples** : Rien ne change. Nous créons un `StatelessWidget` et utilisons `ViewModelBuilder.reactive` pour l'associer à un `BaseViewModel`.
-   **Vues avec Formulaires** : Au lieu du `mixin` généré, nous devons :
    1.  Utiliser un `StatefulWidget` pour que la vue puisse gérer les `TextEditingController`.
    2.  Déclarer manuellement les `TextEditingController` et les `FocusNode` dans la classe `State` de notre vue.
    3.  Passer ces contrôleurs au ViewModel via une méthode (ex: `viewModel.setController('email', emailController)`).
    4.  S'assurer de `dispose()` les contrôleurs dans la méthode `dispose` de la vue.

### 3. Conclusion et Prochaines Étapes pour le Développeur

Cette base de code est structurée pour être immédiatement fonctionnelle et lisible. Un développeur reprenant ce projet pourra :
1.  Copier le contenu du dossier `lib` dans un projet Flutter local.
2.  Exécuter `flutter pub get`. L'application devrait fonctionner telle quelle.
3.  Pour activer la génération de code, il lui suffira de :
    -   Décommenter (ou réécrire) l'annotation `@StackedApp` dans `app/app.dart` avec toutes les routes et dépendances.
    -   Supprimer nos fichiers manuels `app/router.dart` et le contenu de `app/app.dart` (le `setupLocator`).
    -   Lancer `flutter pub run build_runner build --delete-conflicting-outputs`.
    -   Mettre à jour `main.dart` pour utiliser le nouveau routeur généré.

Cette approche nous permet de fournir une architecture propre et évolutive sans dépendre de l'environnement d'exécution.
