import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/models/mappers/availability_mapper.dart';

void main() {
  group('AvailabilityMapper - Mapping API -> domaine', () {
    test('fromApiStatus_whenValueIsAvailable_returnsAvailable', () {
      expect(
        AvailabilityMapper.fromApiStatus('AVAILABLE'),
        AvailabilityStatus.available,
      );
    });

    test('fromApiStatus_whenValueIsIfNeeded_returnsIfNeeded', () {
      // IF_NEEDED : disponibilité possible mais non prioritaire côté métier.
      expect(
        AvailabilityMapper.fromApiStatus('IF_NEEDED'),
        AvailabilityStatus.ifNeeded,
      );
    });

    test('fromApiStatus_whenValueIsUnavailable_returnsUnavailable', () {
      expect(
        AvailabilityMapper.fromApiStatus('UNAVAILABLE'),
        AvailabilityStatus.unavailable,
      );
    });

    test('fromApiStatus_whenValueIsPending_returnsPending', () {
      expect(
        AvailabilityMapper.fromApiStatus('PENDING'),
        AvailabilityStatus.pending,
      );
    });

    test('fromApiStatus_whenValueIsUnknown_returnsPending', () {
      expect(
        AvailabilityMapper.fromApiStatus('SOMETHING_NEW'),
        AvailabilityStatus.pending,
      );
    });

    test('fromJson_whenArtistIdIsNumeric_returnsStringArtistId', () {
      final availability = AvailabilityMapper.fromJson(<String, dynamic>{
        'artistId': 42,
        'artistFirebaseUid': 'firebase-uid-42',
        'status': 'AVAILABLE',
      });

      expect(availability.artistId, '42');
      expect(availability.artistFirebaseUid, 'firebase-uid-42');
      expect(availability.status, AvailabilityStatus.available);
    });

    test('fromJson_whenArtistFirebaseUidIsMissing_returnsNullFirebaseUid', () {
      final availability = AvailabilityMapper.fromJson(<String, dynamic>{
        'artistId': 42,
        'status': 'AVAILABLE',
      });

      expect(availability.artistId, '42');
      expect(availability.artistFirebaseUid, isNull);
      expect(availability.status, AvailabilityStatus.available);
    });
  });

  group('AvailabilityMapper - Mapping domaine -> API', () {
    test('toApiStatus_whenStatusIsAvailable_returnsAvailableLiteral', () {
      expect(
        AvailabilityMapper.toApiStatus(AvailabilityStatus.available),
        'AVAILABLE',
      );
    });

    test('toApiStatus_whenStatusIsIfNeeded_returnsIfNeededLiteral', () {
      expect(
        AvailabilityMapper.toApiStatus(AvailabilityStatus.ifNeeded),
        'IF_NEEDED',
      );
    });

    test('toApiStatus_whenStatusIsUnavailable_returnsUnavailableLiteral', () {
      expect(
        AvailabilityMapper.toApiStatus(AvailabilityStatus.unavailable),
        'UNAVAILABLE',
      );
    });

    test('toApiStatus_whenStatusIsPending_returnsPendingLiteral', () {
      expect(
        AvailabilityMapper.toApiStatus(AvailabilityStatus.pending),
        'PENDING',
      );
    });
  });
}
