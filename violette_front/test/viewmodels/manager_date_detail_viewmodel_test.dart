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
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ManagerDateDetailViewModel - Détail de date côté manager', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    group('Initialisation du détail', () {
      test('initialize_whenShowDateHasId_loadsDetailFromRestRepository', () async {
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

      test('initialize_whenShowDateIdIsEmpty_skipsRemoteLoading', () async {
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
          'initialize_whenBackendReturnsNull_keepsInitialShowDate',
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

      test('initialize_whenBookingsExist_loadsRestBookings', () async {
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
          status: ShowDateStatus.confirmed,
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

    group('Rafraîchissement du détail', () {
      test('refreshShowDateDetail_whenCalled_reloadsDetailViaGetShowDateById', () async {
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

    group('Bascule de sélection d\'un artiste', () {
      test(
          'toggleSelection_whenDateIdIsNull_doesNotCallRepository',
          () async {
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;

        final showDateWithoutId = ShowDate(
          id: '',
          title: 'Date sans id',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse test',
          totalRequiredArtists: 2,
        );

        final viewModel = ManagerDateDetailViewModel(showDate: showDateWithoutId);

        await viewModel.toggleSelection('artist1', true);

        verifyNever(
            () => bookingRepository.toggleSelection(any(), any(), any()));
      });

      test(
          'toggleSelection_whenCallSucceeds_reloadsBookingsAndShowDate',
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
        final showDateAfterSelection = ShowDate(
          id: '7',
          title: 'Test',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
          selectedCount: 1,
        );

        final bookingAfterSelection = ArtistBooking(
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

        ShowDate? callbackShowDate;
        final viewModel = ManagerDateDetailViewModel(
          showDate: showDate,
          onShowDateUpdated: (updated) async {
            callbackShowDate = updated;
          },
        );
        await viewModel.initialize();

        when(() => bookingRepository.toggleSelection('7', '5', true))
            .thenAnswer((_) async {});
        when(() => bookingRepository.getBookingsForDate('7'))
            .thenAnswer((_) async => [bookingAfterSelection]);
        when(() => showDateRepository.getShowDateById('7'))
            .thenAnswer((_) async => showDateAfterSelection);

        await viewModel.toggleSelection('5', true);

        expect(viewModel.bookings.length, 1);
        expect(viewModel.bookings.first.status, BookingStatus.preselected);
        expect(callbackShowDate?.selectedCount, 1);
        verify(() => bookingRepository.toggleSelection('7', '5', true))
            .called(1);
        verify(() => showDateRepository.getShowDateById('7')).called(2);
      });
    });

    group('Envoi des demandes de confirmation', () {
      test(
        'sendConfirmation_whenShowDateIsNotConfirmed_doesNotCallRepository',
        () async {
          final bookingRepository =
              locator<BookingRepository>() as MockBookingRepository;
          final dialogService = locator<DialogService>() as MockDialogService;

          final showDate = ShowDate(
            id: '7',
            title: 'Test',
            date: DateTime(2026, 1, 1),
            meetingTimeMinutes: 540,
            address: 'Adresse',
            totalRequiredArtists: 2,
            status: ShowDateStatus.option,
          );

          final viewModel = ManagerDateDetailViewModel(showDate: showDate);
          when(() => dialogService.showDialog(
                title: any(named: 'title'),
                description: any(named: 'description'),
                buttonTitle: any(named: 'buttonTitle'),
                cancelTitle: any(named: 'cancelTitle'),
                dialogPlatform: any(named: 'dialogPlatform'),
                barrierDismissible: any(named: 'barrierDismissible'),
              )).thenAnswer((_) async => DialogResponse());
          await viewModel.sendConfirmation();

          verifyNever(() => bookingRepository.sendConfirmationRequests(any()));
        },
      );

      test(
          'sendConfirmation_whenDateIdIsNull_doesNotCallRepository',
          () async {
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;

        final showDateWithoutId = ShowDate(
          id: '',
          title: 'Date sans id',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse test',
          totalRequiredArtists: 2,
        );

        final viewModel = ManagerDateDetailViewModel(showDate: showDateWithoutId);

        await viewModel.sendConfirmation();

        verifyNever(() => bookingRepository.sendConfirmationRequests(any()));
      });

      test(
          'sendConfirmation_whenCallSucceeds_reloadsBookingsAndShowDate',
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
          status: ShowDateStatus.confirmed,
        );

        final bookingAfterConfirmationRequest = ArtistBooking(
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
            .thenAnswer((_) async => [bookingAfterConfirmationRequest]);

        await viewModel.sendConfirmation();

        expect(viewModel.bookings.length, 1);
        expect(
            viewModel.bookings.first.status, BookingStatus.pendingConfirmation);
        verify(() => bookingRepository.sendConfirmationRequests('7')).called(1);
        verify(() => showDateRepository.getShowDateById('7')).called(2);
      });
    });

    group('Changement de statut de la date', () {
      test('changeShowDateStatus_whenCallSucceeds_updatesStatusAndReloadsDetail', () async {
        final showDateRepository =
            locator<ShowDateRepository>() as MockShowDateRepository;
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;
        final availabilityRepository =
            locator<AvailabilityRepository>() as MockAvailabilityRepository;

        final initialShowDate = ShowDate(
          id: 'date-99',
          title: 'Date initiale',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
          status: ShowDateStatus.inquiry,
        );
        final updatedShowDate = ShowDate(
          id: 'date-99',
          title: 'Date option',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
          status: ShowDateStatus.option,
        );

        when(() => showDateRepository.getShowDateById('date-99'))
            .thenAnswer((_) async => initialShowDate);
        when(() => bookingRepository.getBookingsForDate('date-99'))
            .thenAnswer((_) async => []);
        when(() => availabilityRepository.getAvailabilitiesForDate('date-99'))
            .thenAnswer((_) async => []);

        ShowDate? callbackShowDate;
        final viewModel = ManagerDateDetailViewModel(
          showDate: initialShowDate,
          onShowDateUpdated: (updated) async {
            callbackShowDate = updated;
          },
        );
        await viewModel.initialize();

        when(() => showDateRepository.updateShowDateStatus(
              'date-99',
              ShowDateStatus.option,
            )).thenAnswer((_) async {});
        when(() => showDateRepository.getShowDateById('date-99'))
            .thenAnswer((_) async => updatedShowDate);

        await viewModel.changeShowDateStatus(ShowDateStatus.option);

        verify(() => showDateRepository.updateShowDateStatus(
              'date-99',
              ShowDateStatus.option,
            )).called(1);
        expect(viewModel.displayedShowDate.status, ShowDateStatus.option);
        expect(callbackShowDate?.status, ShowDateStatus.option);
      });

      test('changeShowDateStatus_whenCallFails_doesNotApplyFakeSuccess', () async {
        final showDateRepository =
            locator<ShowDateRepository>() as MockShowDateRepository;
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;
        final availabilityRepository =
            locator<AvailabilityRepository>() as MockAvailabilityRepository;
        final dialogService = locator<DialogService>() as MockDialogService;

        final initialShowDate = ShowDate(
          id: 'date-100',
          title: 'Date initiale',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
          status: ShowDateStatus.inquiry,
        );

        when(() => showDateRepository.getShowDateById('date-100'))
            .thenAnswer((_) async => initialShowDate);
        when(() => bookingRepository.getBookingsForDate('date-100'))
            .thenAnswer((_) async => []);
        when(() => availabilityRepository.getAvailabilitiesForDate('date-100'))
            .thenAnswer((_) async => []);
        when(() => showDateRepository.updateShowDateStatus(
              'date-100',
              ShowDateStatus.option,
            )).thenThrow(Exception('boom'));
        when(() => dialogService.showDialog(
              title: any(named: 'title'),
              description: any(named: 'description'),
              buttonTitle: any(named: 'buttonTitle'),
              cancelTitle: any(named: 'cancelTitle'),
              dialogPlatform: any(named: 'dialogPlatform'),
              barrierDismissible: any(named: 'barrierDismissible'),
            )).thenAnswer((_) async => DialogResponse());

        final viewModel = ManagerDateDetailViewModel(showDate: initialShowDate);
        await viewModel.initialize();
        await viewModel.changeShowDateStatus(ShowDateStatus.option);

        expect(viewModel.displayedShowDate.status, ShowDateStatus.inquiry);
        verify(() => dialogService.showDialog(
              title: 'Changement de statut impossible',
              description: any(named: 'description'),
              buttonTitle: any(named: 'buttonTitle'),
              cancelTitle: any(named: 'cancelTitle'),
              dialogPlatform: any(named: 'dialogPlatform'),
              barrierDismissible: any(named: 'barrierDismissible'),
            )).called(1);
      });
    });

    group('Annulation de la date', () {
      test('cancelShowDate_whenConfirmationIsAccepted_cancelsShowDate', () async {
        final showDateRepository =
            locator<ShowDateRepository>() as MockShowDateRepository;
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;
        final dialogService = locator<DialogService>() as MockDialogService;

        final initialShowDate = ShowDate(
          id: 'date-1',
          title: 'Date à annuler',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
          status: ShowDateStatus.inquiry,
        );
        final cancelledShowDate = ShowDate(
          id: 'date-1',
          title: 'Date à annuler',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
          status: ShowDateStatus.cancelled,
        );

        when(() => dialogService.showDialog(
              title: any(named: 'title'),
              description: any(named: 'description'),
              buttonTitle: any(named: 'buttonTitle'),
              cancelTitle: any(named: 'cancelTitle'),
              dialogPlatform: any(named: 'dialogPlatform'),
              barrierDismissible: any(named: 'barrierDismissible'),
            )).thenAnswer((_) async => DialogResponse(confirmed: true));
        when(() => showDateRepository.updateShowDateStatus(
              'date-1',
              ShowDateStatus.cancelled,
            )).thenAnswer((_) async {});
        when(() => showDateRepository.getShowDateById('date-1'))
            .thenAnswer((_) async => cancelledShowDate);
        when(() => bookingRepository.getBookingsForDate('date-1'))
            .thenAnswer((_) async => []);

        ShowDate? callbackShowDate;
        final viewModel = ManagerDateDetailViewModel(
          showDate: initialShowDate,
          onShowDateUpdated: (updated) async {
            callbackShowDate = updated;
          },
        );

        await viewModel.cancelShowDate();

        verify(() => showDateRepository.updateShowDateStatus(
              'date-1',
              ShowDateStatus.cancelled,
            )).called(1);
        expect(viewModel.displayedShowDate.status, ShowDateStatus.cancelled);
        expect(callbackShowDate?.status, ShowDateStatus.cancelled);
      });

      test('cancelShowDate_whenConfirmationIsDeclined_doesNotCancelShowDate', () async {
        final showDateRepository =
            locator<ShowDateRepository>() as MockShowDateRepository;
        final dialogService = locator<DialogService>() as MockDialogService;

        final showDate = ShowDate(
          id: 'date-1',
          title: 'Date active',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
          status: ShowDateStatus.inquiry,
        );

        when(() => dialogService.showDialog(
              title: any(named: 'title'),
              description: any(named: 'description'),
              buttonTitle: any(named: 'buttonTitle'),
              cancelTitle: any(named: 'cancelTitle'),
              dialogPlatform: any(named: 'dialogPlatform'),
              barrierDismissible: any(named: 'barrierDismissible'),
            )).thenAnswer((_) async => DialogResponse(confirmed: false));

        final viewModel = ManagerDateDetailViewModel(showDate: showDate);
        await viewModel.cancelShowDate();

        verifyNever(() => showDateRepository.updateShowDateStatus(
              'date-1',
              ShowDateStatus.cancelled,
            ));
      });

      test('cancelShowDate_whenDateIdIsEmpty_doesNotCancelShowDate', () async {
        final showDateRepository =
            locator<ShowDateRepository>() as MockShowDateRepository;

        final showDateWithoutId = ShowDate(
          id: '',
          title: 'Date sans id',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse test',
          totalRequiredArtists: 2,
        );

        final viewModel = ManagerDateDetailViewModel(showDate: showDateWithoutId);
        await viewModel.cancelShowDate();

        verifyNever(() => showDateRepository.updateShowDateStatus(
              '',
              ShowDateStatus.cancelled,
            ));
      });

      test('cancelShowDate_whenCallFails_doesNotApplyFakeSuccess', () async {
        final showDateRepository =
            locator<ShowDateRepository>() as MockShowDateRepository;
        final dialogService = locator<DialogService>() as MockDialogService;

        final initialShowDate = ShowDate(
          id: 'date-1',
          title: 'Date initiale',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
          status: ShowDateStatus.inquiry,
        );

        when(() => dialogService.showDialog(
              title: any(named: 'title'),
              description: any(named: 'description'),
              buttonTitle: any(named: 'buttonTitle'),
              cancelTitle: any(named: 'cancelTitle'),
              dialogPlatform: any(named: 'dialogPlatform'),
              barrierDismissible: any(named: 'barrierDismissible'),
            )).thenAnswer((invocation) async {
          final title = invocation.namedArguments[#title] as String?;
          if (title == 'Annuler la date') {
            return DialogResponse(confirmed: true);
          }
          return DialogResponse();
        });
        when(() => showDateRepository.updateShowDateStatus(
              'date-1',
              ShowDateStatus.cancelled,
            )).thenThrow(Exception('boom'));

        final viewModel = ManagerDateDetailViewModel(showDate: initialShowDate);
        await viewModel.cancelShowDate();

        expect(viewModel.displayedShowDate.status, ShowDateStatus.inquiry);
        verify(() => dialogService.showDialog(
              title: 'Annulation impossible',
              description: any(named: 'description'),
              buttonTitle: any(named: 'buttonTitle'),
              cancelTitle: any(named: 'cancelTitle'),
              dialogPlatform: any(named: 'dialogPlatform'),
              barrierDismissible: any(named: 'barrierDismissible'),
            )).called(1);
      });
    });

    group('Annulation d\'une réservation', () {
      test('cancelBooking_whenConfirmationIsAccepted_cancelsBooking', () async {
        final showDateRepository =
            locator<ShowDateRepository>() as MockShowDateRepository;
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;
        final dialogService = locator<DialogService>() as MockDialogService;

        final showDate = ShowDate(
          id: 'date-1',
          title: 'Date test',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
          status: ShowDateStatus.confirmed,
        );

        when(() => dialogService.showDialog(
              title: any(named: 'title'),
              description: any(named: 'description'),
              buttonTitle: any(named: 'buttonTitle'),
              cancelTitle: any(named: 'cancelTitle'),
              dialogPlatform: any(named: 'dialogPlatform'),
              barrierDismissible: any(named: 'barrierDismissible'),
            )).thenAnswer((_) async => DialogResponse(confirmed: true));
        when(() => bookingRepository.cancelBooking('date-1', '5'))
            .thenAnswer((_) async {});
        when(() => showDateRepository.getShowDateById('date-1'))
            .thenAnswer((_) async => showDate);
        when(() => bookingRepository.getBookingsForDate('date-1'))
            .thenAnswer((_) async => []);

        final viewModel = ManagerDateDetailViewModel(showDate: showDate);
        await viewModel.cancelBooking('5');

        verify(() => bookingRepository.cancelBooking('date-1', '5')).called(1);
      });

      test('cancelBooking_whenConfirmationIsDeclined_doesNotCancelBooking', () async {
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;
        final dialogService = locator<DialogService>() as MockDialogService;

        final showDate = ShowDate(
          id: 'date-1',
          title: 'Date active',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
          status: ShowDateStatus.confirmed,
        );

        when(() => dialogService.showDialog(
              title: any(named: 'title'),
              description: any(named: 'description'),
              buttonTitle: any(named: 'buttonTitle'),
              cancelTitle: any(named: 'cancelTitle'),
              dialogPlatform: any(named: 'dialogPlatform'),
              barrierDismissible: any(named: 'barrierDismissible'),
            )).thenAnswer((_) async => DialogResponse(confirmed: false));

        final viewModel = ManagerDateDetailViewModel(showDate: showDate);
        await viewModel.cancelBooking('5');

        verifyNever(() => bookingRepository.cancelBooking(any(), any()));
      });

      test('cancelBooking_whenDateIdIsEmpty_doesNotCancelBooking', () async {
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;

        final showDateWithoutId = ShowDate(
          id: '',
          title: 'Date sans id',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse test',
          totalRequiredArtists: 2,
        );

        final viewModel = ManagerDateDetailViewModel(showDate: showDateWithoutId);
        await viewModel.cancelBooking('5');

        verifyNever(() => bookingRepository.cancelBooking(any(), any()));
      });

      test('cancelBooking_whenCallFails_doesNotApplyFakeSuccess', () async {
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;
        final dialogService = locator<DialogService>() as MockDialogService;

        final showDate = ShowDate(
          id: 'date-1',
          title: 'Date initiale',
          date: DateTime(2026, 1, 1),
          meetingTimeMinutes: 540,
          address: 'Adresse',
          totalRequiredArtists: 2,
          status: ShowDateStatus.confirmed,
        );

        when(() => dialogService.showDialog(
              title: any(named: 'title'),
              description: any(named: 'description'),
              buttonTitle: any(named: 'buttonTitle'),
              cancelTitle: any(named: 'cancelTitle'),
              dialogPlatform: any(named: 'dialogPlatform'),
              barrierDismissible: any(named: 'barrierDismissible'),
            )).thenAnswer((invocation) async {
          final title = invocation.namedArguments[#title] as String?;
          if (title == 'Annuler la réservation') {
            return DialogResponse(confirmed: true);
          }
          return DialogResponse();
        });
        when(() => bookingRepository.cancelBooking('date-1', '5'))
            .thenThrow(Exception('boom'));

        final viewModel = ManagerDateDetailViewModel(showDate: showDate);
        await viewModel.cancelBooking('5');

        verify(() => dialogService.showDialog(
              title: 'Annulation impossible',
              description: any(named: 'description'),
              buttonTitle: any(named: 'buttonTitle'),
              cancelTitle: any(named: 'cancelTitle'),
              dialogPlatform: any(named: 'dialogPlatform'),
              barrierDismissible: any(named: 'barrierDismissible'),
            )).called(1);
      });
    });

    group('Autorisation de sélection', () {
      test(
          'isSelectionEnabled_whenBookingIsPreselected_allowsDeselection',
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
          'isSelectionEnabled_whenBookingHasNonPreselectedStatus_returnsFalse',
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
          'isSelectionEnabled_whenArtistIsNotAvailable_returnsFalse',
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
        'isSelectionEnabled_whenAvailabilityIsIfNeeded_returnsTrue',
        () {
          // IF_NEEDED : disponibilité possible mais non prioritaire pour la présélection.
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
              status: AvailabilityStatus.ifNeeded,
            ),
          ];
          viewModel.bookings = [];

          final canSelect = viewModel.isSelectionEnabled(currentShowDate, 'artist1');
          expect(canSelect, isTrue);
        },
      );

      test(
        'isSelectionEnabled_whenAvailabilityIsUnavailable_returnsFalse',
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

          final canSelect = viewModel.isSelectionEnabled(currentShowDate, 'artist1');
          expect(canSelect, isFalse);
        },
      );

      test(
        'isSelectionEnabled_whenAvailabilityIsPending_returnsFalse',
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
              status: AvailabilityStatus.pending,
            ),
          ];
          viewModel.bookings = [];

          final canSelect = viewModel.isSelectionEnabled(currentShowDate, 'artist1');
          expect(canSelect, isFalse);
        },
      );

      test(
          'isSelectionEnabled_whenRequiredArtistCountIsReached_returnsFalse',
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
        'isSelectionEnabled_whenTotalRequiredArtistsIsZero_returnsTrue',
        () {
          final currentShowDate = ShowDate(
            id: 'date-1',
            title: 'Test',
            date: DateTime(2026, 1, 1),
            meetingTimeMinutes: 540,
            address: 'Adresse test',
            totalRequiredArtists: 0,
            selectedCount: 0,
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

          final canSelect = viewModel.isSelectionEnabled(currentShowDate, 'artist1');
          expect(canSelect, isTrue);
        },
      );

      test(
        'isSelectionEnabled_whenShowDateStatusIsInquiry_returnsFalse',
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
        'isSelectionEnabled_whenStatusIsStaffedCancelledOrArchived_returnsFalse',
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
        'isSelectionEnabled_whenStatusIsOptionOrConfirmedWithCapacityAndAvailability_returnsTrue',
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

    group('État de la case à cocher de réservation', () {
      test('isBookingCheckboxChecked_whenBookingIsNullRefusedOrCancelled_returnsFalse', () {
        // CANCELLED : un booking annulé n'est pas considéré comme actif.
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
        expect(
          viewModel.isBookingCheckboxChecked(
            ArtistBooking(
              artistId: 'a',
              status: BookingStatus.cancelled,
            ),
          ),
          isFalse,
        );
      });

      test('isBookingCheckboxChecked_whenStatusIsActiveSelectionState_returnsTrue', () {
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
