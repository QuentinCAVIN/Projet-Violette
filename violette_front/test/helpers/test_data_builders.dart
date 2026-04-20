import 'package:violette_front/models/enums/role.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/violette_user.dart';

/// Builders pour créer des données de test facilement et de manière réutilisable
class TestDataBuilders {
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

  static ShowDate createTestShowDate({
    String id = '',
    String title = 'Spectacle Test',
    DateTime? date,
    int meetingTimeMinutes = 540,
    String address = '123 Rue de Test, Paris',
    int totalRequiredArtists = 3,
    String? description,
  }) {
    return ShowDate(
      id: id,
      title: title,
      date: date ?? DateTime(2025, 6, 15),
      meetingTimeMinutes: meetingTimeMinutes,
      address: address,
      totalRequiredArtists: totalRequiredArtists,
      description: description,
    );
  }

  static List<ShowDate> createTestShowDatesForMonth({
    required int year,
    required int month,
    int count = 5,
  }) {
    return List.generate(count, (index) {
      return createTestShowDate(
        id: 'show-$index',
        title: 'Spectacle ${index + 1}',
        date: DateTime(year, month, (index + 1) * 5),
      );
    });
  }
}
