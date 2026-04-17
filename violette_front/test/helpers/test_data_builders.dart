import 'package:violette_front/models/enums/role.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/violette_user.dart';
// Généré par IA

/// Builders pour créer des données de test facilement et de manière réutilisable
class TestDataBuilders {
  /// Crée un VioletteUser de test avec des valeurs par défaut
  static VioletteUser createTestUser({
    String uid = 'test-uid-123',
    String firstName = 'Jean',
    String lastName = 'Dupont',
    String email = 'jean.dupont@test.com',
    List<Role> roles = const [Role.artist],
  }) {
    return VioletteUser(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      roles: roles,
    );
  }

  /// Crée une ShowDate de test avec des valeurs par défaut
  static ShowDate createTestShowDate({
    String? uid,
    String title = 'Spectacle Test',
    DateTime? date,
    int startMinutes = 540, // 9:00
    int endMinutes = 720, // 12:00
    String address = '123 Rue de Test, Paris',
    int artistsCount = 3,
    double fee = 250.0,
    String? description,
  }) {
    return ShowDate(
      uid: uid,
      title: title,
      date: date ?? DateTime(2025, 6, 15),
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      address: address,
      artistsCount: artistsCount,
      fee: fee,
      description: description,
    );
  }

  /// Crée plusieurs ShowDates pour un mois donné (pratique pour tester le calendrier)
  static List<ShowDate> createTestShowDatesForMonth({
    required int year,
    required int month,
    int count = 5,
  }) {
    return List.generate(count, (index) {
      return createTestShowDate(
        uid: 'show-$index',
        title: 'Spectacle ${index + 1}',
        date: DateTime(year, month, (index + 1) * 5), // Tous les 5 jours
      );
    });
  }
}
