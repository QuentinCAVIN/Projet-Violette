import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/mappers/artist_booking_mapper.dart';

void main() {
  group('ArtistBookingMapper - Conversion JSON ↔ domaine', () {
    group('Recherche du booking en attente pour une date', () {
      test('findPendingBookingIdForShowDate_whenShowDateIdMatchesAsJsonNumber_returnsBookingId', () {
        final items = <Map<String, dynamic>>[
          {'id': 10, 'showDateId': 5, 'status': 'PENDING_CONFIRMATION'},
          {'id': 42, 'showDateId': 7, 'status': 'PENDING_CONFIRMATION'},
        ];
        expect(
          ArtistBookingMapper.findPendingBookingIdForShowDate(items, '7'),
          42,
        );
      });

      test('findPendingBookingIdForShowDate_whenShowDateIdIsApiString_returnsBookingId', () {
        final items = <Map<String, dynamic>>[
          {'id': 3, 'showDateId': '12', 'status': 'PENDING_CONFIRMATION'},
        ];
        expect(
          ArtistBookingMapper.findPendingBookingIdForShowDate(items, '12'),
          3,
        );
      });

      test('findPendingBookingIdForShowDate_whenNoRowMatches_returnsNull', () {
        final items = <Map<String, dynamic>>[
          {'id': 1, 'showDateId': 99, 'status': 'PENDING_CONFIRMATION'},
        ];
        expect(
          ArtistBookingMapper.findPendingBookingIdForShowDate(items, '7'),
          isNull,
        );
      });

      test(
        'findPendingBookingIdForShowDate_whenConfirmedAndRefusedRowsExist_keepsOnlyPendingConfirmation',
        () {
          final items = <Map<String, dynamic>>[
            {
              'id': 1,
              'showDateId': 7,
              'status': 'CONFIRMED',
            },
            {
              'id': 2,
              'showDateId': 7,
              'status': 'REFUSED',
            },
            {
              'id': 42,
              'showDateId': 7,
              'status': 'PENDING_CONFIRMATION',
            },
          ];
          expect(
            ArtistBookingMapper.findPendingBookingIdForShowDate(items, '7'),
            42,
          );
        },
      );

      test(
        'findPendingBookingIdForShowDate_whenSeveralPendingRowsExist_returnsFirstOne',
        () {
          final items = <Map<String, dynamic>>[
            {
              'id': 100,
              'showDateId': 7,
              'status': 'PENDING_CONFIRMATION',
            },
            {
              'id': 200,
              'showDateId': 7,
              'status': 'PENDING_CONFIRMATION',
            },
          ];
          expect(
            ArtistBookingMapper.findPendingBookingIdForShowDate(items, '7'),
            100,
          );
        },
      );

      test(
        'findPendingBookingIdForShowDate_whenOnlyConfirmedOrRefusedRowsMatch_returnsNull',
        () {
          final items = <Map<String, dynamic>>[
            {'id': 1, 'showDateId': 7, 'status': 'CONFIRMED'},
            {'id': 2, 'showDateId': 7, 'status': 'REFUSED'},
          ];
          expect(
            ArtistBookingMapper.findPendingBookingIdForShowDate(items, '7'),
            isNull,
          );
        },
      );

      test('findPendingBookingIdForShowDate_whenStatusHasMixedCase_matchesCaseInsensitively', () {
        final items = <Map<String, dynamic>>[
          {
            'id': 5,
            'showDateId': 3,
            'status': 'Pending_Confirmation',
          },
        ];
        expect(
          ArtistBookingMapper.findPendingBookingIdForShowDate(items, '3'),
          5,
        );
      });

      test('findPendingBookingIdForShowDate_whenShowDateIdIsBlank_returnsNull', () {
        expect(
          ArtistBookingMapper.findPendingBookingIdForShowDate([], '  '),
          isNull,
        );
      });
    });

    group('Recherche du booking par identifiant artiste', () {
      test('findBookingIdForArtistId_whenArtistIdMatches_returnsBookingId', () {
        final items = <Map<String, dynamic>>[
          {'id': 100, 'artistId': 2, 'status': 'SELECTED'},
          {'id': 55, 'artistId': 3, 'status': 'SELECTED'},
        ];
        expect(ArtistBookingMapper.findBookingIdForArtistId(items, 3), 55);
      });

      test('findBookingIdForArtistId_whenArtistIdIsJsonString_matchesNumericId', () {
        final items = <Map<String, dynamic>>[
          {'id': 1, 'artistId': '9'},
        ];
        expect(ArtistBookingMapper.findBookingIdForArtistId(items, 9), 1);
      });
    });

    group('Parsing d\'une liste JSON de réservations', () {
      test('parseBookingList_whenDataIsDirectList_returnsParsedList', () {
        final data = [
          {'id': 1, 'showDateId': 2},
        ];
        expect(ArtistBookingMapper.parseBookingList(data).length, 1);
      });

      test('parseBookingList_whenDataIsJsonString_returnsParsedList', () {
        const data = '[{"id":1,"showDateId":2}]';
        final list = ArtistBookingMapper.parseBookingList(data);
        expect(list.length, 1);
        expect(list.first['id'], 1);
      });
    });

    group('Conversion JSON vers ArtistBooking', () {
      test('toArtistBooking_whenStatusIsSelected_returnsPreselectedBooking', () {
        final json = <String, dynamic>{
          'id': 42,
          'artistId': 5,
          'showDateId': 7,
          'status': 'SELECTED',
        };
        final booking = ArtistBookingMapper.toArtistBooking(json);
        expect(booking, isNotNull);
        expect(booking!.artistId, '5');
        expect(booking.dateId, '7');
        expect(booking.status, BookingStatus.preselected);
      });

      test('toArtistBooking_whenStatusIsPendingConfirmation_returnsPendingConfirmation', () {
        final json = <String, dynamic>{
          'id': 1,
          'artistId': 3,
          'showDateId': 2,
          'status': 'PENDING_CONFIRMATION',
        };
        final booking = ArtistBookingMapper.toArtistBooking(json);
        expect(booking!.status, BookingStatus.pendingConfirmation);
      });

      test('toArtistBooking_whenStatusIsConfirmed_returnsConfirmed', () {
        final json = <String, dynamic>{
          'id': 1,
          'artistId': 3,
          'showDateId': 2,
          'status': 'CONFIRMED',
        };
        expect(
          ArtistBookingMapper.toArtistBooking(json)!.status,
          BookingStatus.confirmed,
        );
      });

      test('toArtistBooking_whenStatusIsRefused_returnsRefused', () {
        final json = <String, dynamic>{
          'id': 1,
          'artistId': 3,
          'showDateId': 2,
          'status': 'REFUSED',
        };
        expect(
          ArtistBookingMapper.toArtistBooking(json)!.status,
          BookingStatus.refused,
        );
      });

      test('toArtistBooking_whenStatusIsCancelled_returnsCancelled', () {
        // CANCELLED : booking non actif pour les actions opérationnelles.
        final json = <String, dynamic>{
          'id': 1,
          'artistId': 3,
          'showDateId': 2,
          'status': 'CANCELLED',
        };
        expect(
          ArtistBookingMapper.toArtistBooking(json)!.status,
          BookingStatus.cancelled,
        );
      });

      test('toArtistBooking_whenStatusIsMissing_returnsNull', () {
        final json = <String, dynamic>{
          'id': 1,
          'artistId': 3,
          'showDateId': 2,
        };
        expect(ArtistBookingMapper.toArtistBooking(json), isNull);
      });

      test('toArtistBooking_whenStatusIsUnknown_returnsNull', () {
        final json = <String, dynamic>{
          'id': 1,
          'artistId': 3,
          'showDateId': 2,
          'status': 'UNKNOWN_STATUS',
        };
        expect(ArtistBookingMapper.toArtistBooking(json), isNull);
      });

      test('toArtistBooking_whenArtistIdIsJsonString_returnsStringArtistId', () {
        final json = <String, dynamic>{
          'id': 1,
          'artistId': '9',
          'showDateId': 4,
          'status': 'SELECTED',
        };
        final booking = ArtistBookingMapper.toArtistBooking(json);
        expect(booking!.artistId, '9');
      });
    });

    group('Conversion JSON vers liste de réservations', () {
      test('toArtistBookingList_whenSomeEntriesHaveNoValidStatus_skipsInvalidEntries', () {
        final items = <Map<String, dynamic>>[
          {'id': 1, 'artistId': 1, 'showDateId': 7, 'status': 'SELECTED'},
          {'id': 2, 'artistId': 2, 'showDateId': 7},
          {'id': 3, 'artistId': 3, 'showDateId': 7, 'status': 'CONFIRMED'},
        ];
        final list = ArtistBookingMapper.toArtistBookingList(items);
        expect(list.length, 2);
        expect(list.map((b) => b.artistId), containsAll(['1', '3']));
      });

      test('toArtistBookingList_whenInputIsEmpty_returnsEmptyList', () {
        expect(ArtistBookingMapper.toArtistBookingList([]), isEmpty);
      });
    });
  });
}
