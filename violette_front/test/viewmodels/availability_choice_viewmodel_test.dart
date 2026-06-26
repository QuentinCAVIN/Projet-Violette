import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';
import 'package:violette_front/models/availability.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/ui/views/availability_choice/availability_choice_viewmodel.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AvailabilityChoiceViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    group('getStatusForDay -', () {
      test(
          'getStatusForDay_whenNoShowDateExists_returnsNull',
          () {
        // Le service mocké renvoie une liste vide
        final showDateRepo = getAndRegisterShowDateRepository();
        when(() => showDateRepo.getMyAvailableShowDates())
            .thenAnswer((_) => Future.value([]));

        final viewModel = AvailabilityChoiceViewModel();

        // Charge des dates vides
        viewModel.loadShowDates();

        final status = viewModel.getStatusForDay(DateTime(2025, 12, 12));
        expect(status, null,
            reason:
                "Un jour libre ne doit PAS avoir de statut (donc pas de couleur par défaut)");
      });

      test('getStatusForDay_whenShowDateExists_returnsAvailabilityStatus',
          () async {
        final showDateRepo = getAndRegisterShowDateRepository();
        final availabilityRepo = getAndRegisterAvailabilityRepository();
        final authService = getAndRegisterFirebaseAuthenticationService();

        final cleanDate = DateTime(2025, 10, 10);
        final dummyShowDate = ShowDate(
          id: 'show-date-1',
          title: 'Test',
          date: cleanDate,
          meetingTimeMinutes: 0,
          address: 'Paris',
          totalRequiredArtists: 1,
        );

        when(() => showDateRepo.getMyAvailableShowDates())
            .thenAnswer((_) => Future.value([dummyShowDate]));
        when(
          () => availabilityRepo.getMyAvailabilityForDate('show-date-1'),
        ).thenAnswer(
          (_) => Future.value(
            Availability(
              artistId: '42',
              artistFirebaseUid: 'uid-123',
              status: AvailabilityStatus.available,
            ),
          ),
        );
        when(() => authService.currentUser).thenReturn(MockUser(
            uid: 'uid-123')); // besoin d'un utilisateur fictif ou similaire

        final viewModel = AvailabilityChoiceViewModel();

        await viewModel.loadShowDates();

        final status = viewModel.getStatusForDay(cleanDate);
        expect(status, AvailabilityStatus.available);
      });

      test(
        'getStatusForDay_whenArtistFirebaseUidMatchesCurrentUser_returnsAvailabilityStatus',
        () async {
          final showDateRepo = getAndRegisterShowDateRepository();
          final availabilityRepo = getAndRegisterAvailabilityRepository();
          final authService = getAndRegisterFirebaseAuthenticationService();

          final cleanDate = DateTime(2025, 10, 11);
          final dummyShowDate = ShowDate(
            id: 'show-date-2',
            title: 'Test mismatch id',
            date: cleanDate,
            meetingTimeMinutes: 0,
            address: 'Lyon',
            totalRequiredArtists: 1,
          );

          when(() => showDateRepo.getMyAvailableShowDates())
              .thenAnswer((_) => Future.value([dummyShowDate]));
          when(() => availabilityRepo.getMyAvailabilityForDate('show-date-2'))
              .thenAnswer(
            (_) => Future.value(
              Availability(
                artistId: '42',
                artistFirebaseUid: 'firebase-uid-artist',
                status: AvailabilityStatus.available,
              ),
            ),
          );
          when(() => authService.currentUser).thenReturn(
            MockUser(uid: 'firebase-uid-artist'),
          );

          final viewModel = AvailabilityChoiceViewModel();

          await viewModel.loadShowDates();

          final status = viewModel.getStatusForDay(cleanDate);
          expect(status, AvailabilityStatus.available);
        },
      );

      test(
        'getStatusForDay_whenMyAvailabilityIsReturnedWithoutFirebaseUid_stillUsesStatus',
        () async {
          // Le endpoint /availabilities/me renvoie la disponibilité de l'utilisateur courant.
          // Le Firebase UID n'est donc plus nécessaire pour faire un matching côté frontend.
          final showDateRepo = getAndRegisterShowDateRepository();
          final availabilityRepo = getAndRegisterAvailabilityRepository();
          final authService = getAndRegisterFirebaseAuthenticationService();

          final cleanDate = DateTime(2025, 10, 13);
          final dummyShowDate = ShowDate(
            id: 'show-date-4',
            title: 'Test missing firebase uid',
            date: cleanDate,
            meetingTimeMinutes: 0,
            address: 'Lyon',
            totalRequiredArtists: 1,
          );

          when(() => showDateRepo.getMyAvailableShowDates())
              .thenAnswer((_) => Future.value([dummyShowDate]));
          when(() => availabilityRepo.getMyAvailabilityForDate('show-date-4'))
              .thenAnswer(
            (_) => Future.value(
              Availability(
                artistId: '42',
                status: AvailabilityStatus.available,
              ),
            ),
          );
          when(() => authService.currentUser).thenReturn(
            MockUser(uid: 'firebase-uid-artist'),
          );

          final viewModel = AvailabilityChoiceViewModel();
          await viewModel.loadShowDates();

          expect(viewModel.getStatusForDay(cleanDate), AvailabilityStatus.available);
        },
      );

      test(
        'getStatusForDay_whenMatchedAvailabilityIsIfNeeded_returnsIfNeeded',
        () async {
          final showDateRepo = getAndRegisterShowDateRepository();
          final availabilityRepo = getAndRegisterAvailabilityRepository();
          final authService = getAndRegisterFirebaseAuthenticationService();

          final cleanDate = DateTime(2025, 10, 12);
          final dummyShowDate = ShowDate(
            id: 'show-date-3',
            title: 'Test if needed',
            date: cleanDate,
            meetingTimeMinutes: 0,
            address: 'Marseille',
            totalRequiredArtists: 1,
          );

          when(() => showDateRepo.getMyAvailableShowDates())
              .thenAnswer((_) => Future.value([dummyShowDate]));
          when(() => availabilityRepo.getMyAvailabilityForDate('show-date-3'))
              .thenAnswer(
            (_) => Future.value(
              Availability(
                artistId: '77',
                artistFirebaseUid: 'uid-artist-if-needed',
                status: AvailabilityStatus.ifNeeded,
              ),
            ),
          );
          when(() => authService.currentUser)
              .thenReturn(MockUser(uid: 'uid-artist-if-needed'));

          final viewModel = AvailabilityChoiceViewModel();
          await viewModel.loadShowDates();

          expect(viewModel.getStatusForDay(cleanDate), AvailabilityStatus.ifNeeded);
        },
      );

      test(
        'loadShowDates_whenMyAvailabilityEndpointReturns403_showsAccessDeniedSnackbar',
        () async {
          final showDateRepo = getAndRegisterShowDateRepository();
          final availabilityRepo = getAndRegisterAvailabilityRepository();
          final authService = getAndRegisterFirebaseAuthenticationService();
          final snackbarService = getAndRegisterSnackbarService();

          final dummyShowDate = ShowDate(
            id: 'show-date-403',
            title: 'Test 403',
            date: DateTime(2025, 10, 14),
            meetingTimeMinutes: 0,
            address: 'Paris',
            totalRequiredArtists: 1,
          );

          when(() => showDateRepo.getMyAvailableShowDates())
              .thenAnswer((_) async => [dummyShowDate]);
          when(() => authService.currentUser).thenReturn(MockUser(uid: 'uid-403'));
          when(() => availabilityRepo.getMyAvailabilityForDate('show-date-403'))
              .thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/api/show-dates/show-date-403/availabilities/me'),
              response: Response(
                requestOptions: RequestOptions(path: '/api/show-dates/show-date-403/availabilities/me'),
                statusCode: 403,
              ),
            ),
          );
          when(() => snackbarService.showSnackbar(
                message: any(named: 'message'),
                title: any(named: 'title'),
                duration: any(named: 'duration'),
                mainButtonTitle: any(named: 'mainButtonTitle'),
                onTap: any(named: 'onTap'),
              )).thenReturn(null);

          final viewModel = AvailabilityChoiceViewModel();
          await viewModel.loadShowDates();

          verify(() => snackbarService.showSnackbar(
                message: 'Accès refusé pour charger votre disponibilité.',
                title: any(named: 'title'),
                duration: any(named: 'duration'),
                mainButtonTitle: any(named: 'mainButtonTitle'),
                onTap: any(named: 'onTap'),
              )).called(1);
        },
      );
    });

    group('plusieurs ShowDate le même jour -', () {
      test(
        'onDaySelected_whenTwoShowDatesOnSameDay_setsSelectedShowDatesWithBoth',
        () async {
          final showDateRepo = getAndRegisterShowDateRepository();
          final availabilityRepo = getAndRegisterAvailabilityRepository();
          final authService = getAndRegisterFirebaseAuthenticationService();

          final day = DateTime(2025, 6, 15);
          final sd1 = ShowDate(
            id: 'same-day-1',
            title: 'Matin',
            date: day,
            meetingTimeMinutes: 480,
            address: 'Paris',
            totalRequiredArtists: 2,
          );
          final sd2 = ShowDate(
            id: 'same-day-2',
            title: 'Soir',
            date: day,
            meetingTimeMinutes: 1200,
            address: 'Paris',
            totalRequiredArtists: 3,
          );

          when(() => showDateRepo.getMyAvailableShowDates())
              .thenAnswer((_) async => [sd1, sd2]);
          when(() => availabilityRepo.getMyAvailabilityForDate(any()))
              .thenAnswer(
            (_) async => Availability(
              artistId: '1',
              status: AvailabilityStatus.pending,
            ),
          );
          when(() => authService.currentUser).thenReturn(MockUser(uid: 'uid-1'));

          final viewModel = AvailabilityChoiceViewModel();
          await viewModel.loadShowDates();

          await viewModel.onDaySelected(day, day);

          expect(viewModel.selectedShowDates, hasLength(2));
          expect(
            viewModel.selectedShowDates.map((e) => e.id).toSet(),
            {'same-day-1', 'same-day-2'},
          );
        },
      );

      test(
        'getStatusForDay_whenTwoShowDatesWithMixedStatus_returnsMostFavorableForCalendar',
        () async {
          final showDateRepo = getAndRegisterShowDateRepository();
          final availabilityRepo = getAndRegisterAvailabilityRepository();
          final authService = getAndRegisterFirebaseAuthenticationService();

          final day = DateTime(2025, 7, 20);
          final sd1 = ShowDate(
            id: 'mix-1',
            title: 'A',
            date: day,
            meetingTimeMinutes: 0,
            address: 'Lyon',
            totalRequiredArtists: 1,
          );
          final sd2 = ShowDate(
            id: 'mix-2',
            title: 'B',
            date: day,
            meetingTimeMinutes: 0,
            address: 'Lyon',
            totalRequiredArtists: 1,
          );

          when(() => showDateRepo.getMyAvailableShowDates())
              .thenAnswer((_) async => [sd1, sd2]);
          when(() => availabilityRepo.getMyAvailabilityForDate('mix-1'))
              .thenAnswer(
            (_) async => Availability(
              artistId: '1',
              status: AvailabilityStatus.pending,
            ),
          );
          when(() => availabilityRepo.getMyAvailabilityForDate('mix-2'))
              .thenAnswer(
            (_) async => Availability(
              artistId: '1',
              status: AvailabilityStatus.available,
            ),
          );
          when(() => authService.currentUser).thenReturn(MockUser(uid: 'uid-1'));

          final viewModel = AvailabilityChoiceViewModel();
          await viewModel.loadShowDates();

          expect(viewModel.getStatusForDay(day), AvailabilityStatus.available);
        },
      );

      test(
        'cycleAvailabilityForShowDate_whenTwoDatesSameDay_updatesOnlyTargetShowDate',
        () async {
          final showDateRepo = getAndRegisterShowDateRepository();
          final availabilityRepo = getAndRegisterAvailabilityRepository();
          final authService = getAndRegisterFirebaseAuthenticationService();

          final day = DateTime(2025, 8, 1);
          final sd1 = ShowDate(
            id: 'cyc-1',
            title: 'Un',
            date: day,
            meetingTimeMinutes: 0,
            address: 'Marseille',
            totalRequiredArtists: 1,
          );
          final sd2 = ShowDate(
            id: 'cyc-2',
            title: 'Deux',
            date: day,
            meetingTimeMinutes: 0,
            address: 'Marseille',
            totalRequiredArtists: 1,
          );

          when(() => showDateRepo.getMyAvailableShowDates())
              .thenAnswer((_) async => [sd1, sd2]);
          when(() => availabilityRepo.getMyAvailabilityForDate('cyc-1'))
              .thenAnswer(
            (_) async => Availability(
              artistId: '1',
              status: AvailabilityStatus.pending,
            ),
          );
          when(() => availabilityRepo.getMyAvailabilityForDate('cyc-2'))
              .thenAnswer(
            (_) async => Availability(
              artistId: '1',
              status: AvailabilityStatus.pending,
            ),
          );
          when(
            () => availabilityRepo.upsertMyAvailability(
              showDateId: 'cyc-1',
              status: AvailabilityStatus.available,
            ),
          ).thenAnswer((_) async {});

          when(() => authService.currentUser).thenReturn(MockUser(uid: 'uid-1'));

          final viewModel = AvailabilityChoiceViewModel();
          await viewModel.loadShowDates();

          await viewModel.cycleAvailabilityForShowDate(sd1);

          expect(
            viewModel.getStatusForShowDateId('cyc-1'),
            AvailabilityStatus.available,
          );
          expect(
            viewModel.getStatusForShowDateId('cyc-2'),
            AvailabilityStatus.pending,
          );
        },
      );
    });

    group('booking confirmé -', () {
      test(
        'cycleAvailabilityForShowDate_whenBookingIsConfirmed_blocksAvailabilityUpdate',
        () async {
          final showDateRepo = getAndRegisterShowDateRepository();
          final availabilityRepo = getAndRegisterAvailabilityRepository();
          final bookingRepo = getAndRegisterBookingRepository();
          final authService = getAndRegisterFirebaseAuthenticationService();
          final snackbarService = getAndRegisterSnackbarService();

          final showDate = ShowDate(
            id: 'confirmed-date',
            title: 'Date confirmée',
            date: DateTime(2026, 2, 3),
            meetingTimeMinutes: 900,
            address: 'Paris',
            totalRequiredArtists: 1,
          );

          when(() => showDateRepo.getMyAvailableShowDates())
              .thenAnswer((_) async => [showDate]);
          when(() => availabilityRepo.getMyAvailabilityForDate('confirmed-date'))
              .thenAnswer(
            (_) async => Availability(
              artistId: '1',
              status: AvailabilityStatus.available,
            ),
          );
          when(() => bookingRepo.getMyBookings()).thenAnswer(
            (_) async => [
              ArtistBooking(
                artistId: '1',
                dateId: 'confirmed-date',
                status: BookingStatus.confirmed,
              ),
            ],
          );
          when(() => authService.currentUser).thenReturn(MockUser(uid: 'uid-1'));
          when(() => snackbarService.showSnackbar(
                message: any(named: 'message'),
                title: any(named: 'title'),
                duration: any(named: 'duration'),
                mainButtonTitle: any(named: 'mainButtonTitle'),
                onTap: any(named: 'onTap'),
              )).thenReturn(null);

          final viewModel = AvailabilityChoiceViewModel();
          await viewModel.loadShowDates();

          expect(viewModel.isShowDateConfirmedByBooking('confirmed-date'), true);
          expect(
            viewModel.confirmedBookingLockMessage,
            'Confirmé — contactez le gérant pour modifier',
          );

          await viewModel.cycleAvailabilityForShowDate(showDate);

          verifyNever(
            () => availabilityRepo.upsertMyAvailability(
              showDateId: 'confirmed-date',
              status: AvailabilityStatus.ifNeeded,
            ),
          );
          verify(() => snackbarService.showSnackbar(
                message: 'Confirmé — contactez le gérant pour modifier',
                title: any(named: 'title'),
                duration: any(named: 'duration'),
                mainButtonTitle: any(named: 'mainButtonTitle'),
                onTap: any(named: 'onTap'),
              )).called(1);
          expect(
            viewModel.getStatusForShowDateId('confirmed-date'),
            AvailabilityStatus.available,
          );
        },
      );

      test(
        'cycleAvailabilityForShowDate_whenBookingIsNotConfirmed_updatesAvailability',
        () async {
          final showDateRepo = getAndRegisterShowDateRepository();
          final availabilityRepo = getAndRegisterAvailabilityRepository();
          final bookingRepo = getAndRegisterBookingRepository();
          final authService = getAndRegisterFirebaseAuthenticationService();

          final showDate = ShowDate(
            id: 'free-date',
            title: 'Date libre',
            date: DateTime(2026, 2, 4),
            meetingTimeMinutes: 900,
            address: 'Lyon',
            totalRequiredArtists: 1,
          );

          when(() => showDateRepo.getMyAvailableShowDates())
              .thenAnswer((_) async => [showDate]);
          when(() => availabilityRepo.getMyAvailabilityForDate('free-date'))
              .thenAnswer(
            (_) async => Availability(
              artistId: '1',
              status: AvailabilityStatus.pending,
            ),
          );
          when(() => bookingRepo.getMyBookings()).thenAnswer(
            (_) async => [
              ArtistBooking(
                artistId: '1',
                dateId: 'free-date',
                status: BookingStatus.pendingConfirmation,
              ),
            ],
          );
          when(
            () => availabilityRepo.upsertMyAvailability(
              showDateId: 'free-date',
              status: AvailabilityStatus.available,
            ),
          ).thenAnswer((_) async {});
          when(() => authService.currentUser).thenReturn(MockUser(uid: 'uid-1'));

          final viewModel = AvailabilityChoiceViewModel();
          await viewModel.loadShowDates();

          expect(viewModel.isShowDateConfirmedByBooking('free-date'), false);

          await viewModel.cycleAvailabilityForShowDate(showDate);

          verify(
            () => availabilityRepo.upsertMyAvailability(
              showDateId: 'free-date',
              status: AvailabilityStatus.available,
            ),
          ).called(1);
          expect(
            viewModel.getStatusForShowDateId('free-date'),
            AvailabilityStatus.available,
          );
        },
      );
    });

    group('navigation -', () {
      test('onBackPressed_clearStackAndShowHome', () async {
        final navigationService = getAndRegisterNavigationService();
        when(() => navigationService.clearStackAndShow(
              any(),
              arguments: any(named: 'arguments'),
              id: any(named: 'id'),
              parameters: any(named: 'parameters'),
            )).thenAnswer((_) async => true);

        final viewModel = AvailabilityChoiceViewModel();
        await viewModel.onBackPressed();

        verify(() => navigationService.clearStackAndShow(
              Routes.homeView,
              arguments: any(named: 'arguments'),
              id: any(named: 'id'),
              parameters: any(named: 'parameters'),
            )).called(1);
      });
    });
  });
}

// Mock minimal pour les besoins du test
class MockUser extends Mock implements User {
  @override
  final String uid;
  MockUser({required this.uid});
}
