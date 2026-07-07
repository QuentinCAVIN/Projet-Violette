import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/show_date.dart';

void main() {
  group('ShowDate - Conversion minutes ↔ HH:mm', () {
    test('formattedMeetingTime_whenZeroMinutes_returnsMidnight', () {
      final showDate = _createTestShowDate(meetingTimeMinutes: 0);
      expect(showDate.formattedMeetingTime, '00:00');
    });

    test('formattedMeetingTime_when125Minutes_returnsTwoOhFive', () {
      final showDate = _createTestShowDate(meetingTimeMinutes: 125);
      expect(showDate.formattedMeetingTime, '02:05');
    });

    test('formattedMeetingTime_when1439Minutes_returnsLastMinuteOfDay', () {
      final showDate = _createTestShowDate(meetingTimeMinutes: 1439);
      expect(showDate.formattedMeetingTime, '23:59');
    });

    test('formattedMeetingTime_when540Minutes_returnsNineAm', () {
      final showDate = _createTestShowDate(meetingTimeMinutes: 540);
      expect(showDate.formattedMeetingTime, '09:00');
    });

    test('hourStringToMinutes_whenMidnight_returnsZero', () {
      expect(hourStringToMinutes('00:00'), 0);
    });

    test('hourStringToMinutes_whenTwoOhFive_returns125', () {
      expect(hourStringToMinutes('02:05'), 125);
    });

    test('hourStringToMinutes_whenLastMinuteOfDay_returns1439', () {
      expect(hourStringToMinutes('23:59'), 1439);
    });

    test('hourStringToMinutes_whenNineAm_returns540', () {
      expect(hourStringToMinutes('09:00'), 540);
    });
  });

  group('ShowDate - Formatage de dates', () {
    test('formattedDate_whenCalled_returnsDayMonthYearFormat', () {
      final showDate = _createTestShowDate(
        date: DateTime(2025, 12, 25),
      );
      expect(showDate.formattedDate, '25/12/2025');
    });

    test('formattedDate_whenSingleDigitDay_returnsUnpaddedDay', () {
      final showDate = _createTestShowDate(
        date: DateTime(2025, 1, 5),
      );
      expect(showDate.formattedDate, '5/1/2025');
    });
  });

  group('ShowDate - Heure de rendez-vous (meetingTime API)', () {
    test('formattedMeetingTimeForDisplay_whenCalled_matchesFormattedMeetingTime', () {
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
