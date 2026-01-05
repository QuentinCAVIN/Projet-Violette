import 'package:stacked/stacked.dart';

// Énumération pour définir clairement les rôles des utilisateurs.
enum UserRole { artist, manager }

class DashboardViewModel extends BaseViewModel {
  // Rôle actuel de l'utilisateur, initialisé en tant qu'artiste par défaut.
  UserRole _currentUserRole = UserRole.artist;
  UserRole get currentUserRole => _currentUserRole;

  String get viewTitle =>
      _currentUserRole == UserRole.artist ? 'Tableau de Bord Artiste' : 'Tableau de Bord Gérant';

  // Méthode pour simuler un changement de rôle.
  // Dans une vraie application, ce rôle viendrait d'un service d'authentification.
  void switchUserRole() {
    _currentUserRole =
        _currentUserRole == UserRole.artist ? UserRole.manager : UserRole.artist;
    // Informe les auditeurs (la vue) que l'état a changé et qu'il faut reconstruire l'UI.
    notifyListeners();
  }

  // TODO: Remplacer par des modèles de données et des services réels.
  // Données fictives pour l'artiste.
  final List<String> artistUpcomingDates = [
    'Spectacle "Étoiles de Paris" - 20h00',
    'Répétition "Cabaret Rouge" - 14h00',
  ];
  final List<String> artistPendingOffers = [
    'Nouvelle proposition pour "Revue Céleste"',
  ];

  // Données fictives pour le gérant.
  final List<String> managerDatesToFinalize = [
    'Équipe pour "Nuit des Merveilles" à compléter (4/5)',
  ];
  final List<String> managerUpcomingDates = [
    'Spectacle "Étoiles de Paris" - Confirmé',
    'Gala Privé "Lumières d\'Or" - Confirmé',
  ];
}
