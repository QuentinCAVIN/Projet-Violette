import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/show_date.dart';

void main() {
  group('ShowDate - Conversion minutes ↔ HH:mm', () {
    test('formattedMeetingTime: 0 minutes devrait retourner "00:00"', () {
      final showDate = _createTestShowDate(meetingTimeMinutes: 0);
      expect(showDate.formattedMeetingTime, '00:00');
    });

    test('formattedMeetingTime: 125 minutes devrait retourner "02:05"', () {
      final showDate = _createTestShowDate(meetingTimeMinutes: 125);
      expect(showDate.formattedMeetingTime, '02:05');
    });

    test('formattedMeetingTime: 1439 minutes devrait retourner "23:59"', () {
      final showDate = _createTestShowDate(meetingTimeMinutes: 1439);
      expect(showDate.formattedMeetingTime, '23:59');
    });

    test('formattedMeetingTime: 540 minutes (9h) devrait retourner "09:00"', () {
      final showDate = _createTestShowDate(meetingTimeMinutes: 540);
      expect(showDate.formattedMeetingTime, '09:00');
    });

    test('hourStringToMinutes: "00:00" devrait retourner 0', () {
      expect(hourStringToMinutes('00:00'), 0);
    });

    test('hourStringToMinutes: "02:05" devrait retourner 125', () {
      expect(hourStringToMinutes('02:05'), 125);
    });

    test('hourStringToMinutes: "23:59" devrait retourner 1439', () {
      expect(hourStringToMinutes('23:59'), 1439);
    });

    test('hourStringToMinutes: "09:00" devrait retourner 540', () {
      expect(hourStringToMinutes('09:00'), 540);
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

  group('ShowDate - Heure de rendez-vous (meetingTime API)', () {
    test('formattedMeetingTimeForDisplay reprend meetingTimeMinutes', () {
      final showDate = _createTestShowDate(meetingTimeMinutes: 540);
      expect(showDate.formattedMeetingTimeForDisplay, '09:00');
      expect(
        showDate.formattedMeetingTimeForDisplay,
        showDate.formattedMeetingTime,
      );
    });
  });
}

ShowDate _createTestShowDate({
  String title = 'Test Show',
  DateTime? date,
  int meetingTimeMinutes = 540,
  String address = 'Test Address',
  int totalRequiredArtists = 1,
}) {
  return ShowDate(
    title: title,
    date: date ?? DateTime(2025, 1, 1),
    meetingTimeMinutes: meetingTimeMinutes,
    address: address,
    totalRequiredArtists: totalRequiredArtists,
  );
}
