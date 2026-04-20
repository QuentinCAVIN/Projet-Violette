import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/show_date.dart';
// Généré par IA

void main() {
  group('ShowDate - Conversion minutes ↔ HH:mm', () {
    test('_minutesToHHmm: 0 minutes devrait retourner "00:00"', () {
      // Arrange
      final showDate = _createTestShowDate(startMinutes: 0);

      // Act & Assert
      expect(showDate.formattedStartTime, '00:00');
    });

    test('_minutesToHHmm: 125 minutes devrait retourner "02:05"', () {
      final showDate = _createTestShowDate(startMinutes: 125);
      expect(showDate.formattedStartTime, '02:05');
    });

    test('_minutesToHHmm: 1439 minutes devrait retourner "23:59"', () {
      final showDate = _createTestShowDate(startMinutes: 1439);
      expect(showDate.formattedStartTime, '23:59');
    });

    test('_minutesToHHmm: 540 minutes (9h) devrait retourner "09:00"', () {
      final showDate = _createTestShowDate(startMinutes: 540);
      expect(showDate.formattedStartTime, '09:00');
    });

    test('_minutesToHHmm: 720 minutes (12h) devrait retourner "12:00"', () {
      final showDate = _createTestShowDate(endMinutes: 720);
      expect(showDate.formattedEndTime, '12:00');
    });

    test('hourStringToMinutes: "00:00" devrait retourner 0', () {
      final result = hourStringToMinutes('00:00');
      expect(result, 0);
    });

    test('hourStringToMinutes: "02:05" devrait retourner 125', () {
      final result = hourStringToMinutes('02:05');
      expect(result, 125);
    });

    test('hourStringToMinutes: "23:59" devrait retourner 1439', () {
      final result = hourStringToMinutes('23:59');
      expect(result, 1439);
    });

    test('hourStringToMinutes: "09:00" devrait retourner 540', () {
      final result = hourStringToMinutes('09:00');
      expect(result, 540);
    });
  });

  group('ShowDate - Formatage de dates', () {
    test('formattedDate devrait retourner le format dd/mm/yyyy', () {
      final showDate = _createTestShowDate(
        date: DateTime(2025, 12, 25),
      );

      expect(showDate.formattedDate, '25/12/2025');
    });

    test('formattedDate devrait gérer les jours à un chiffre', () {
      final showDate = _createTestShowDate(
        date: DateTime(2025, 1, 5),
      );

      expect(showDate.formattedDate, '5/1/2025');
    });
  });

  group('ShowDate - Heure de rendez-vous (alignement backend meetingTime)', () {
    test(
      'formattedMeetingTimeForDisplay reprend uniquement meetingTime (startMinutes)',
      () {
        final showDate = _createTestShowDate(
          startMinutes: 540,
          endMinutes: 540,
        );
        expect(showDate.formattedMeetingTimeForDisplay, '09:00');
        expect(
          showDate.formattedMeetingTimeForDisplay,
          showDate.formattedStartTime,
        );
      },
    );

    test(
      'formattedMeetingTimeForDisplay ignore endMinutes (hors modèle API)',
      () {
        final showDate = _createTestShowDate(
          startMinutes: 540,
          endMinutes: 720,
        );
        expect(showDate.formattedMeetingTimeForDisplay, '09:00');
        expect(showDate.formattedEndTime, '12:00');
      },
    );
  });

  group('ShowDate - Règle métier : Durée max 12h (720 minutes)', () {
    test('Durée de 12h exactement (720 min) devrait être valide', () {
      final showDate = _createTestShowDate(
        startMinutes: 540, // 9:00
        endMinutes: 1260, // 21:00
      );

      final duration = showDate.endMinutes - showDate.startMinutes;
      expect(duration, 720);
      expect(duration, lessThanOrEqualTo(720));
    });

    test('Durée de moins de 12h devrait être valide', () {
      final showDate = _createTestShowDate(
        startMinutes: 540, // 9:00
        endMinutes: 720, // 12:00 (3h)
      );

      final duration = showDate.endMinutes - showDate.startMinutes;
      expect(duration, 180);
      expect(duration, lessThanOrEqualTo(720));
    });

    test('Durée de plus de 12h devrait être détectée', () {
      final showDate = _createTestShowDate(
        startMinutes: 540, // 9:00
        endMinutes: 1320, // 22:00 (13h)
      );

      final duration = showDate.endMinutes - showDate.startMinutes;
      expect(duration, 780);
      expect(duration, greaterThan(720));
    });

    test('Durée d\'une heure devrait être valide', () {
      final showDate = _createTestShowDate(
        startMinutes: 600, // 10:00
        endMinutes: 660, // 11:00
      );

      final duration = showDate.endMinutes - showDate.startMinutes;
      expect(duration, 60);
      expect(duration, lessThanOrEqualTo(720));
    });
  });
}

// Helper pour créer des ShowDate de test
ShowDate _createTestShowDate({
  String title = 'Test Show',
  DateTime? date,
  int startMinutes = 540,
  int endMinutes = 720,
  String address = 'Test Address',
  int artistsCount = 1,
  double fee = 100.0,
}) {
  return ShowDate(
    title: title,
    date: date ?? DateTime(2025, 1, 1),
    startMinutes: startMinutes,
    endMinutes: endMinutes,
    address: address,
    artistsCount: artistsCount,
    fee: fee,
  );
}
