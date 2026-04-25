import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/mappers/artist_booking_mapper.dart';

void main() {
  group('ArtistBookingMapper', () {
    group('findPendingBookingIdForShowDate', () {
      test('retourne l’id quand showDateId correspond (nombre JSON)', () {
        final items = <Map<String, dynamic>>[
          {'id': 10, 'showDateId': 5, 'status': 'PENDING_CONFIRMATION'},
          {'id': 42, 'showDateId': 7, 'status': 'PENDING_CONFIRMATION'},
        ];
        expect(
          ArtistBookingMapper.findPendingBookingIdForShowDate(items, '7'),
          42,
        );
      });

      test('retourne l’id quand showDateId est une chaîne côté API', () {
        final items = <Map<String, dynamic>>[
          {'id': 3, 'showDateId': '12', 'status': 'PENDING_CONFIRMATION'},
        ];
        expect(
          ArtistBookingMapper.findPendingBookingIdForShowDate(items, '12'),
          3,
        );
      });

      test('retourne null si aucune ligne ne correspond', () {
        final items = <Map<String, dynamic>>[
          {'id': 1, 'showDateId': 99, 'status': 'PENDING_CONFIRMATION'},
        ];
        expect(
          ArtistBookingMapper.findPendingBookingIdForShowDate(items, '7'),
          isNull,
        );
      });

      test(
        'ignore CONFIRMED et REFUSED pour la même date et retient '
        'PENDING_CONFIRMATION',
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
        'priorise la première ligne PENDING_CONFIRMATION quand plusieurs '
        'lignes existent pour le même showDateId',
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
        'retourne null si seules des lignes CONFIRMED ou REFUSED matchent la date',
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

      test('accepte le statut API en casse mixte (Pending_Confirmation)', () {
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

      test('retourne null pour showDateId vide', () {
        expect(
          ArtistBookingMapper.findPendingBookingIdForShowDate([], '  '),
          isNull,
        );
      });
    });

    group('findBookingIdForArtistId', () {
      test('retourne l’id du booking pour un artistId backend', () {
        final items = <Map<String, dynamic>>[
          {'id': 100, 'artistId': 2, 'status': 'SELECTED'},
          {'id': 55, 'artistId': 3, 'status': 'SELECTED'},
        ];
        expect(ArtistBookingMapper.findBookingIdForArtistId(items, 3), 55);
      });

      test('accepte artistId numérique ou chaîne dans le JSON', () {
        final items = <Map<String, dynamic>>[
          {'id': 1, 'artistId': '9'},
        ];
        expect(ArtistBookingMapper.findBookingIdForArtistId(items, 9), 1);
      });
    });

    group('parseBookingList', () {
      test('parse une liste directe', () {
        final data = [
          {'id': 1, 'showDateId': 2},
        ];
        expect(ArtistBookingMapper.parseBookingList(data).length, 1);
      });

      test('parse une chaîne JSON', () {
        const data = '[{"id":1,"showDateId":2}]';
        final list = ArtistBookingMapper.parseBookingList(data);
        expect(list.length, 1);
        expect(list.first['id'], 1);
      });
    });

    group('toArtistBooking', () {
      test('convertit un item SELECTED en ArtistBooking', () {
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

      test('convertit PENDING_CONFIRMATION correctement', () {
        final json = <String, dynamic>{
          'id': 1,
          'artistId': 3,
          'showDateId': 2,
          'status': 'PENDING_CONFIRMATION',
        };
        final booking = ArtistBookingMapper.toArtistBooking(json);
        expect(booking!.status, BookingStatus.pendingConfirmation);
      });

      test('convertit CONFIRMED correctement', () {
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

      test('convertit REFUSED correctement', () {
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

      test('retourne null si le statut est absent', () {
        final json = <String, dynamic>{
          'id': 1,
          'artistId': 3,
          'showDateId': 2,
        };
        expect(ArtistBookingMapper.toArtistBooking(json), isNull);
      });

      test('retourne null si le statut est inconnu', () {
        final json = <String, dynamic>{
          'id': 1,
          'artistId': 3,
          'showDateId': 2,
          'status': 'UNKNOWN_STATUS',
        };
        expect(ArtistBookingMapper.toArtistBooking(json), isNull);
      });

      test('accepte artistId en String JSON', () {
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

    group('toArtistBookingList', () {
      test('convertit une liste en ignorant les entrées sans statut valide', () {
        final items = <Map<String, dynamic>>[
          {'id': 1, 'artistId': 1, 'showDateId': 7, 'status': 'SELECTED'},
          {'id': 2, 'artistId': 2, 'showDateId': 7},
          {'id': 3, 'artistId': 3, 'showDateId': 7, 'status': 'CONFIRMED'},
        ];
        final list = ArtistBookingMapper.toArtistBookingList(items);
        expect(list.length, 2);
        expect(list.map((b) => b.artistId), containsAll(['1', '3']));
      });

      test('retourne une liste vide pour une entrée vide', () {
        expect(ArtistBookingMapper.toArtistBookingList([]), isEmpty);
      });
    });
  });
}
