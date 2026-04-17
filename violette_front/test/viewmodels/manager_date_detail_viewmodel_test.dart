import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/availability.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/repositories/availability_repository.dart';
import 'package:violette_front/repositories/booking_repository.dart';
import 'package:violette_front/repositories/show_date_repository.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_viewmodel.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ManagerDateDetailViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    group('initialize -', () {
      test('devrait charger le détail showDate via le repository REST', () async {
        final showDateRepository = locator<ShowDateRepository>() as MockShowDateRepository;
        final bookingRepository = locator<BookingRepository>() as MockBookingRepository;
        final availabilityRepository =
            locator<AvailabilityRepository>() as MockAvailabilityRepository;

        final initialShowDate = ShowDate(
          uid: 'date-1',
          title: 'Date initiale',
          date: DateTime(2026, 1, 1),
          startMinutes: 540,
          endMinutes: 600,
          address: 'Adresse initiale',
          artistsCount: 2,
          fee: 100,
        );

        final restShowDate = ShowDate(
          uid: 'date-1',
          title: 'Date REST',
          date: DateTime(2026, 1, 2),
          startMinutes: 600,
          endMinutes: 600,
          address: 'Adresse REST',
          artistsCount: 3,
          fee: 0,
          selectedCount: 1,
        );

        when(() => bookingRepository.watchBookingsForDate('date-1'))
            .thenAnswer((_) => Stream.value([]));
        when(() => showDateRepository.getShowDateById('date-1'))
            .thenAnswer((_) async => restShowDate);
        when(() => availabilityRepository.getAvailabilitiesForDate('date-1'))
            .thenAnswer((_) async => []);

        final viewModel = ManagerDateDetailViewModel(showDate: initialShowDate);

        await viewModel.initialize();

        expect(viewModel.currentShowDate?.title, 'Date REST');
        expect(viewModel.currentShowDate?.selectedCount, 1);
        verify(() => showDateRepository.getShowDateById('date-1')).called(1);
      });

      test('devrait ignorer le chargement distant si uid est null', () async {
        final showDateRepository = locator<ShowDateRepository>() as MockShowDateRepository;
        final bookingRepository = locator<BookingRepository>() as MockBookingRepository;

        final showDateWithoutId = ShowDate(
          uid: null,
          title: 'Date sans id',
          date: DateTime(2026, 1, 1),
          startMinutes: 540,
          endMinutes: 600,
          address: 'Adresse test',
          artistsCount: 2,
          fee: 100,
        );

        final viewModel = ManagerDateDetailViewModel(showDate: showDateWithoutId);

        await viewModel.initialize();

        expect(viewModel.currentShowDate?.title, 'Date sans id');
        verifyNever(() => showDateRepository.getShowDateById(any()));
        verifyNever(() => bookingRepository.watchBookingsForDate(any()));
      });

      test(
          'devrait conserver la showDate initiale quand le backend retourne null',
          () async {
        final showDateRepository =
            locator<ShowDateRepository>() as MockShowDateRepository;
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;
        final availabilityRepository =
            locator<AvailabilityRepository>() as MockAvailabilityRepository;

        final initialShowDate = ShowDate(
          uid: 'date-1',
          title: 'Date initiale',
          date: DateTime(2026, 1, 1),
          startMinutes: 540,
          endMinutes: 600,
          address: 'Adresse initiale',
          artistsCount: 2,
          fee: 100,
        );

        when(() => bookingRepository.watchBookingsForDate('date-1'))
            .thenAnswer((_) => Stream.value([]));
        when(() => showDateRepository.getShowDateById('date-1'))
            .thenAnswer((_) async => null);
        when(() => availabilityRepository.getAvailabilitiesForDate('date-1'))
            .thenAnswer((_) async => []);

        final viewModel = ManagerDateDetailViewModel(showDate: initialShowDate);

        await viewModel.initialize();

        expect(viewModel.displayedShowDate.title, 'Date initiale');
        verify(() => showDateRepository.getShowDateById('date-1')).called(1);
      });
    });

    group('refreshShowDateDetail -', () {
      test('devrait recharger le détail via getShowDateById', () async {
        final showDateRepository =
            locator<ShowDateRepository>() as MockShowDateRepository;
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;
        final availabilityRepository =
            locator<AvailabilityRepository>() as MockAvailabilityRepository;

        final initialShowDate = ShowDate(
          uid: 'date-1',
          title: 'Date initiale',
          date: DateTime(2026, 1, 1),
          startMinutes: 540,
          endMinutes: 600,
          address: 'Adresse initiale',
          artistsCount: 2,
          fee: 100,
        );

        final refreshedShowDate = ShowDate(
          uid: 'date-1',
          title: 'Date rechargée',
          date: DateTime(2026, 1, 2),
          startMinutes: 600,
          endMinutes: 600,
          address: 'Adresse rechargée',
          artistsCount: 3,
          fee: 0,
          selectedCount: 1,
        );

        when(() => bookingRepository.watchBookingsForDate('date-1'))
            .thenAnswer((_) => Stream.value([]));
        when(() => availabilityRepository.getAvailabilitiesForDate('date-1'))
            .thenAnswer((_) async => []);
        when(() => showDateRepository.getShowDateById('date-1'))
            .thenAnswer((_) async => initialShowDate);

        final viewModel = ManagerDateDetailViewModel(showDate: initialShowDate);
        await viewModel.initialize();

        when(() => showDateRepository.getShowDateById('date-1'))
            .thenAnswer((_) async => refreshedShowDate);

        await viewModel.refreshShowDateDetail();

        expect(viewModel.displayedShowDate.title, 'Date rechargée');
        verify(() => showDateRepository.getShowDateById('date-1')).called(2);
      });
    });

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
