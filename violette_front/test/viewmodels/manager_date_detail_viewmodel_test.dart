import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/availability.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_viewmodel.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ManagerDateDetailViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    group('isSelectionEnabled -', () {
      test(
          'devrait autoriser la désélection quand un booking existe avec status selected',
          () {
        final showDate = ShowDate(
          uid: 'date-1',
          title: 'Test',
          date: DateTime(2026, 1, 1),
          startMinutes: 540,
          endMinutes: 600,
          address: 'Adresse test',
          artistsCount: 2,
          fee: 100,
        );

        final viewModel = ManagerDateDetailViewModel(showDate: showDate);
        viewModel.availabilities = [
          Availability(
            artistId: 'artist1',
            status: AvailabilityStatus.available,
          ),
        ];
        viewModel.bookings = [
          ArtistBooking(
            artistId: 'artist1',
            dateId: 'date-1',
            status: BookingStatus.selected,
          ),
        ];

        final canSelect =
            viewModel.isSelectionEnabled(showDate, 'artist1');

        expect(canSelect, isTrue);
      });

      test(
          'devrait refuser la sélection quand un booking existe avec status non selected',
          () {
        final showDate = ShowDate(
          uid: 'date-1',
          title: 'Test',
          date: DateTime(2026, 1, 1),
          startMinutes: 540,
          endMinutes: 600,
          address: 'Adresse test',
          artistsCount: 2,
          fee: 100,
        );

        final viewModel = ManagerDateDetailViewModel(showDate: showDate);
        viewModel.availabilities = [
          Availability(
            artistId: 'artist1',
            status: AvailabilityStatus.available,
          ),
        ];
        viewModel.bookings = [
          ArtistBooking(
            artistId: 'artist1',
            dateId: 'date-1',
            status: BookingStatus.pendingConfirmation,
          ),
        ];

        final canSelect =
            viewModel.isSelectionEnabled(showDate, 'artist1');

        expect(canSelect, isFalse);
      });

      test(
          'devrait refuser la sélection si l’artiste n’est pas available',
          () {
        final currentShowDate = ShowDate(
          uid: 'date-1',
          title: 'Test',
          date: DateTime(2026, 1, 1),
          startMinutes: 540,
          endMinutes: 600,
          address: 'Adresse test',
          artistsCount: 2,
          fee: 100,
        );

        final viewModel = ManagerDateDetailViewModel(showDate: currentShowDate);
        viewModel.availabilities = [
          Availability(
            artistId: 'artist1',
            status: AvailabilityStatus.unavailable,
          ),
        ];
        viewModel.bookings = [];

        final canSelect =
            viewModel.isSelectionEnabled(currentShowDate, 'artist1');

        expect(canSelect, isFalse);
      });

      test(
          'devrait refuser la sélection si le plafond artistsCount est atteint',
          () {
        final currentShowDate = ShowDate(
          uid: 'date-1',
          title: 'Test',
          date: DateTime(2026, 1, 1),
          startMinutes: 540,
          endMinutes: 600,
          address: 'Adresse test',
          artistsCount: 2,
          fee: 100,
          selectedCount: 2,
        );

        final viewModel = ManagerDateDetailViewModel(showDate: currentShowDate);
        viewModel.availabilities = [
          Availability(
            artistId: 'artist1',
            status: AvailabilityStatus.available,
          ),
        ];
        viewModel.bookings = [];

        final canSelect =
            viewModel.isSelectionEnabled(currentShowDate, 'artist1');

        expect(canSelect, isFalse);
      });
    });
  });
}
