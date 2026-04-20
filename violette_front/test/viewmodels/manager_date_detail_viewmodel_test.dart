import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/availability.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/enums/show_date_status.dart';
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
          id: 'date-1',
          title: 'Date initiale',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse initiale',
          totalRequiredArtists: 2,
        );

        final restShowDate = ShowDate(
          id: 'date-1',
          title: 'Date REST',
          date: DateTime(2026, 1, 2),
          meetingTimeMinutes: 600,
          address: 'Adresse REST',
          totalRequiredArtists: 3,
          selectedCount: 1,
        );

        when(() => bookingRepository.getBookingsForDate('date-1'))
            .thenAnswer((_) async => []);
        when(() => showDateRepository.getShowDateById('date-1'))
            .thenAnswer((_) async => restShowDate);
        when(() => availabilityRepository.getAvailabilitiesForDate('date-1'))
            .thenAnswer((_) async => []);

        final viewModel = ManagerDateDetailViewModel(showDate: initialShowDate);

        await viewModel.initialize();

        expect(viewModel.currentShowDate?.title, 'Date REST');
        expect(viewModel.currentShowDate?.selectedCount, 1);
        verify(() => showDateRepository.getShowDateById('date-1')).called(1);
        verify(() => bookingRepository.getBookingsForDate('date-1')).called(1);
      });

      test('devrait ignorer le chargement distant si uid est null', () async {
        final showDateRepository = locator<ShowDateRepository>() as MockShowDateRepository;
        final bookingRepository = locator<BookingRepository>() as MockBookingRepository;

        final showDateWithoutId = ShowDate(
          id: '',
          title: 'Date sans id',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse test',
          totalRequiredArtists: 2,
        );

        final viewModel = ManagerDateDetailViewModel(showDate: showDateWithoutId);

        await viewModel.initialize();

        expect(viewModel.currentShowDate?.title, 'Date sans id');
        verifyNever(() => showDateRepository.getShowDateById(any()));
        verifyNever(() => bookingRepository.getBookingsForDate(any()));
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
          id: 'date-1',
          title: 'Date initiale',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse initiale',
          totalRequiredArtists: 2,
        );

        when(() => bookingRepository.getBookingsForDate('date-1'))
            .thenAnswer((_) async => []);
        when(() => showDateRepository.getShowDateById('date-1'))
            .thenAnswer((_) async => null);
        when(() => availabilityRepository.getAvailabilitiesForDate('date-1'))
            .thenAnswer((_) async => []);

        final viewModel = ManagerDateDetailViewModel(showDate: initialShowDate);

        await viewModel.initialize();

        expect(viewModel.displayedShowDate.title, 'Date initiale');
        verify(() => showDateRepository.getShowDateById('date-1')).called(1);
      });

      test("devrait charger les bookings REST à l'initialisation", () async {
        final showDateRepository =
            locator<ShowDateRepository>() as MockShowDateRepository;
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;
        final availabilityRepository =
            locator<AvailabilityRepository>() as MockAvailabilityRepository;

        final showDate = ShowDate(
          id: 'date-1',
          title: 'Test',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
        );

        final existingBooking = ArtistBooking(
          artistId: '5',
          dateId: 'date-1',
          status: BookingStatus.preselected,
        );

        when(() => bookingRepository.getBookingsForDate('date-1'))
            .thenAnswer((_) async => [existingBooking]);
        when(() => showDateRepository.getShowDateById('date-1'))
            .thenAnswer((_) async => showDate);
        when(() => availabilityRepository.getAvailabilitiesForDate('date-1'))
            .thenAnswer((_) async => []);

        final viewModel = ManagerDateDetailViewModel(showDate: showDate);
        await viewModel.initialize();

        expect(viewModel.bookings.length, 1);
        expect(viewModel.bookings.first.artistId, '5');
        expect(viewModel.canSendConfirmation, isTrue);
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
          id: 'date-1',
          title: 'Date initiale',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse initiale',
          totalRequiredArtists: 2,
        );

        final refreshedShowDate = ShowDate(
          id: 'date-1',
          title: 'Date rechargée',
          date: DateTime(2026, 1, 2),
          meetingTimeMinutes: 600,
          address: 'Adresse rechargée',
          totalRequiredArtists: 3,
          selectedCount: 1,
        );

        when(() => bookingRepository.getBookingsForDate('date-1'))
            .thenAnswer((_) async => []);
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

    group('toggleSelection -', () {
      test(
          'toggleSelection_whenDateIdIsNull_doesNotCallRepository',
          () async {
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;

        final showDateSansId = ShowDate(
          id: '',
          title: 'Date sans id',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse test',
          totalRequiredArtists: 2,
        );

        final viewModel = ManagerDateDetailViewModel(showDate: showDateSansId);

        await viewModel.toggleSelection('artist1', true);

        verifyNever(
            () => bookingRepository.toggleSelection(any(), any(), any()));
      });

      test(
          'toggleSelection_afterSuccess_rechargeBookingsEtShowDate',
          () async {
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;
        final showDateRepository =
            locator<ShowDateRepository>() as MockShowDateRepository;
        final availabilityRepository =
            locator<AvailabilityRepository>() as MockAvailabilityRepository;

        final showDate = ShowDate(
          id: '7',
          title: 'Test',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
        );

        final bookingApresSelection = ArtistBooking(
          artistId: '5',
          dateId: '7',
          status: BookingStatus.preselected,
        );

        when(() => bookingRepository.getBookingsForDate('7'))
            .thenAnswer((_) async => []);
        when(() => showDateRepository.getShowDateById('7'))
            .thenAnswer((_) async => showDate);
        when(() => availabilityRepository.getAvailabilitiesForDate('7'))
            .thenAnswer((_) async => []);

        final viewModel = ManagerDateDetailViewModel(showDate: showDate);
        await viewModel.initialize();

        when(() => bookingRepository.toggleSelection('7', '5', true))
            .thenAnswer((_) async {});
        when(() => bookingRepository.getBookingsForDate('7'))
            .thenAnswer((_) async => [bookingApresSelection]);

        await viewModel.toggleSelection('5', true);

        expect(viewModel.bookings.length, 1);
        expect(viewModel.bookings.first.status, BookingStatus.preselected);
        verify(() => bookingRepository.toggleSelection('7', '5', true))
            .called(1);
        verify(() => showDateRepository.getShowDateById('7')).called(2);
      });
    });

    group('sendConfirmation -', () {
      test(
          'sendConfirmation_whenDateIdIsNull_doesNotCallRepository',
          () async {
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;

        final showDateSansId = ShowDate(
          id: '',
          title: 'Date sans id',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse test',
          totalRequiredArtists: 2,
        );

        final viewModel = ManagerDateDetailViewModel(showDate: showDateSansId);

        await viewModel.sendConfirmation();

        verifyNever(() => bookingRepository.sendConfirmationRequests(any()));
      });

      test(
          'sendConfirmation_afterSuccess_rechargeBookingsEtShowDate',
          () async {
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;
        final showDateRepository =
            locator<ShowDateRepository>() as MockShowDateRepository;
        final availabilityRepository =
            locator<AvailabilityRepository>() as MockAvailabilityRepository;

        final showDate = ShowDate(
          id: '7',
          title: 'Test',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
        );

        final bookingApresEnvoi = ArtistBooking(
          artistId: '5',
          dateId: '7',
          status: BookingStatus.pendingConfirmation,
        );

        when(() => bookingRepository.getBookingsForDate('7'))
            .thenAnswer((_) async => [
                  ArtistBooking(
                    artistId: '5',
                    dateId: '7',
                    status: BookingStatus.preselected,
                  ),
                ]);
        when(() => showDateRepository.getShowDateById('7'))
            .thenAnswer((_) async => showDate);
        when(() => availabilityRepository.getAvailabilitiesForDate('7'))
            .thenAnswer((_) async => []);

        final viewModel = ManagerDateDetailViewModel(showDate: showDate);
        await viewModel.initialize();

        when(() => bookingRepository.sendConfirmationRequests('7'))
            .thenAnswer((_) async {});
        when(() => bookingRepository.getBookingsForDate('7'))
            .thenAnswer((_) async => [bookingApresEnvoi]);

        await viewModel.sendConfirmation();

        expect(viewModel.bookings.length, 1);
        expect(
            viewModel.bookings.first.status, BookingStatus.pendingConfirmation);
        verify(() => bookingRepository.sendConfirmationRequests('7')).called(1);
        verify(() => showDateRepository.getShowDateById('7')).called(2);
      });
    });

    group('isSelectionEnabled -', () {
      test(
          'devrait autoriser la désélection quand un booking existe avec status selected',
          () {
        final showDate = ShowDate(
          id: 'date-1',
          title: 'Test',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse test',
          totalRequiredArtists: 2,
          status: ShowDateStatus.inquiry,
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
            status: BookingStatus.preselected,
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
          id: 'date-1',
          title: 'Test',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse test',
          totalRequiredArtists: 2,
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
          "devrait refuser la sélection si l'artiste n'est pas available",
          () {
        final currentShowDate = ShowDate(
          id: 'date-1',
          title: 'Test',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse test',
          totalRequiredArtists: 2,
          status: ShowDateStatus.option,
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
          id: 'date-1',
          title: 'Test',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse test',
          totalRequiredArtists: 2,
          selectedCount: 2,
          status: ShowDateStatus.option,
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

      test(
        'devrait refuser une nouvelle sélection si le statut de date est inquiry',
        () {
          final currentShowDate = ShowDate(
            id: 'date-1',
            title: 'Test',
            date: DateTime(2026, 1, 1),
            meetingTimeMinutes: 540,
            address: 'Adresse test',
            totalRequiredArtists: 2,
            selectedCount: 0,
            status: ShowDateStatus.inquiry,
          );

          final viewModel =
              ManagerDateDetailViewModel(showDate: currentShowDate);
          viewModel.availabilities = [
            Availability(
              artistId: 'artist1',
              status: AvailabilityStatus.available,
            ),
          ];
          viewModel.bookings = [];

          expect(
            viewModel.isSelectionEnabled(currentShowDate, 'artist1'),
            isFalse,
          );
        },
      );

      test(
        'devrait refuser une nouvelle sélection pour staffed, cancelled ou archived',
        () {
          for (final status in [
            ShowDateStatus.staffed,
            ShowDateStatus.cancelled,
            ShowDateStatus.archived,
          ]) {
            final currentShowDate = ShowDate(
              id: 'date-1',
              title: 'Test',
              date: DateTime(2026, 1, 1),
              meetingTimeMinutes: 540,
              address: 'Adresse test',
              totalRequiredArtists: 2,
              selectedCount: 0,
              status: status,
            );

            final viewModel =
                ManagerDateDetailViewModel(showDate: currentShowDate);
            viewModel.availabilities = [
              Availability(
                artistId: 'artist1',
                status: AvailabilityStatus.available,
              ),
            ];
            viewModel.bookings = [];

            expect(
              viewModel.isSelectionEnabled(currentShowDate, 'artist1'),
              isFalse,
              reason: 'statut ${status.name}',
            );
          }
        },
      );

      test(
        'devrait autoriser une nouvelle sélection en option ou confirmée si dispo et plafond OK',
        () {
          for (final status in [
            ShowDateStatus.option,
            ShowDateStatus.confirmed,
          ]) {
            final currentShowDate = ShowDate(
              id: 'date-1',
              title: 'Test',
              date: DateTime(2026, 1, 1),
              meetingTimeMinutes: 540,
              address: 'Adresse test',
              totalRequiredArtists: 2,
              selectedCount: 0,
              status: status,
            );

            final viewModel =
                ManagerDateDetailViewModel(showDate: currentShowDate);
            viewModel.availabilities = [
              Availability(
                artistId: 'artist1',
                status: AvailabilityStatus.available,
              ),
            ];
            viewModel.bookings = [];

            expect(
              viewModel.isSelectionEnabled(currentShowDate, 'artist1'),
              isTrue,
              reason: 'statut ${status.name}',
            );
          }
        },
      );
    });

    group('isBookingCheckboxChecked -', () {
      test('retourne false sans booking ou si refused', () {
        final viewModel = ManagerDateDetailViewModel(
          showDate: ShowDate(
            id: 'date-1',
            title: 'Test',
            date: DateTime(2026, 1, 1),
            meetingTimeMinutes: 540,
            address: 'Adresse test',
            totalRequiredArtists: 2,
          ),
        );

        expect(viewModel.isBookingCheckboxChecked(null), isFalse);
        expect(
          viewModel.isBookingCheckboxChecked(
            ArtistBooking(
              artistId: 'a',
              status: BookingStatus.refused,
            ),
          ),
          isFalse,
        );
      });

      test('retourne true pour selected, pendingConfirmation ou confirmed', () {
        final viewModel = ManagerDateDetailViewModel(
          showDate: ShowDate(
            id: 'date-1',
            title: 'Test',
            date: DateTime(2026, 1, 1),
            meetingTimeMinutes: 540,
            address: 'Adresse test',
            totalRequiredArtists: 2,
          ),
        );

        for (final status in [
          BookingStatus.preselected,
          BookingStatus.pendingConfirmation,
          BookingStatus.confirmed,
        ]) {
          expect(
            viewModel.isBookingCheckboxChecked(
              ArtistBooking(artistId: 'a', status: status),
            ),
            isTrue,
            reason: status.name,
          );
        }
      });
    });
  });
}
