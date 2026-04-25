import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/enums/show_date_status.dart';
import 'package:violette_front/models/mappers/show_date_mapper.dart';

void main() {
  group('ShowDateMapper', () {
    test(
      'fromJson_mapsNumericIdDisplayTitleMeetingTimeLocationAndCounters',
      () {
        final showDate = ShowDateMapper.fromJson(<String, dynamic>{
          'id': 7,
          'displayTitle': 'Gala Violette',
          'cabaretShowTitle': 'Fallback Title',
          'eventDate': '2026-05-15',
          'meetingTime': '19:30:00',
          'location': 'Paris 11',
          'selectedCount': 3,
          'totalRequiredArtists': 8,
          'status': 'CONFIRMED',
        });

        expect(showDate.id, '7');
        expect(showDate.title, 'Gala Violette');
        expect(showDate.meetingTimeMinutes, 19 * 60 + 30);
        expect(showDate.address, 'Paris 11');
        expect(showDate.selectedCount, 3);
        expect(showDate.totalRequiredArtists, 8);
        expect(showDate.status, ShowDateStatus.confirmed);
      },
    );

    test('fromJson_usesCabaretShowTitleWhenDisplayTitleIsBlank', () {
      final showDate = ShowDateMapper.fromJson(<String, dynamic>{
        'id': 8,
        'displayTitle': '   ',
        'cabaretShowTitle': 'Titre Cabaret',
        'eventDate': '2026-05-16',
        'meetingTime': '20:00',
        'location': 'Lille',
        'status': 'OPTION',
      });

      expect(showDate.title, 'Titre Cabaret');
    });

    test('fromApiStatus_mapsCancelledToCancelled', () {
      expect(
        ShowDateMapper.fromApiStatus('CANCELLED'),
        ShowDateStatus.cancelled,
      );
    });

    test('fromApiStatus_mapsArchivedToArchived', () {
      expect(
        ShowDateMapper.fromApiStatus('ARCHIVED'),
        ShowDateStatus.archived,
      );
    });

    test('fromJson_whenEndTimeIsMissing_keepsShowDateValid', () {
      final showDate = ShowDateMapper.fromJson(<String, dynamic>{
        'id': 9,
        'displayTitle': 'Date sans fin',
        'eventDate': '2026-06-01',
        'meetingTime': '18:15',
        'location': 'Bordeaux',
        'status': 'OPTION',
      });

      expect(showDate.id, '9');
      expect(showDate.meetingTimeMinutes, 18 * 60 + 15);
      expect(showDate.date.year, 2026);
      expect(showDate.date.month, 6);
      expect(showDate.date.day, 1);
    });

    test('fromJson_whenEndTimeIsProvided_usesOnlyMeetingTimeAsRendezvousTime', () {
      // meetingTime représente une heure de rendez-vous, pas une plage horaire.
      final showDate = ShowDateMapper.fromJson(<String, dynamic>{
        'id': 10,
        'displayTitle': 'Date rendez-vous',
        'eventDate': '2026-06-02',
        'meetingTime': '21:00:00',
        'endTime': '23:00:00',
        'location': 'Nantes',
        'status': 'CONFIRMED',
      });

      expect(showDate.meetingTimeMinutes, 21 * 60);
    });
  });
}
