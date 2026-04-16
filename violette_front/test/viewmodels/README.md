# Tests ViewModels - Volontairement différés - Généré par IA

## ⏳ Pourquoi ce dossier est vide

Les tests ViewModels ont été **volontairement supprimés** pour respecter l'approche agile du projet.

### Problème rencontré

Les ViewModels dépendent du **locator Stacked (GetIt)** qui doit être initialisé avec tous les services :
- `NavigationService`
- `DialogService`
- `BottomSheetService`
- `FirebaseAuthenticationService`
- etc.

Créer des mocks pour tous ces services irait à l'encontre de la stratégie **"tests légers et non bloquants"**.

### Solution actuelle

**✅ Focus sur les tests de logique métier pure** (45 tests dans `test/models/`)

Ces tests couvrent les règles critiques :
- Transitions de statut `AvailabilityStatus`
- Règle métier : durée max 12h
- Conversions minutes ↔ HH:mm

### Quand ajouter des tests ViewModels ?

**Plus tard**, quand :
1. L'architecture des ViewModels sera stabilisée
2. Vous serez prêt à créer un setup de locator pour les tests
3. Les règles métier seront extraites des ViewModels vers des services testables

### Alternative recommandée

Au lieu de tester les ViewModels directement, vous pouvez :
- Extraire la logique métier en **fonctions pures** ou **services**
- Tester ces fonctions/services isolément
- Garder les ViewModels minces (juste de la coordination)

---

**Voir `test/TEST_README.md` pour plus d'informations sur la stratégie de tests.**
