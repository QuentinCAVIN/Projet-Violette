import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';
import 'package:violette_front/models/availability.dart';
import 'package:violette_front/ui/views/availability_choice/availability_choice_viewmodel.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/test_helpers.dart';

void main() {
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
