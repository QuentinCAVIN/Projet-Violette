import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';
import 'package:violette_front/repositories/user_repository.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/enums/role.dart';
import 'package:violette_front/models/violette_user.dart';
import 'package:violette_front/repositories/booking_repository.dart';
import 'package:violette_front/repositories/show_date_repository.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/views/home/home_viewmodel.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('HomeViewModel - Écran d\'accueil artiste', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    group('Réponse à une demande de confirmation', () {
      test(
          'respondToRequest_whenDateIdIsNull_doesNotCallRepository',
          () async {
        // dateId absent : la garde doit bloquer toute interaction avec le repository booking.
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;

        final booking = ArtistBooking(
          artistId: 'artist1',
          dateId: null,
          status: BookingStatus.pendingConfirmation,
        );

        final viewModel = HomeViewModel();
        viewModel.pendingRequests = [booking];

        await viewModel.respondToRequest(booking, true);

        verifyNever(
            () => bookingRepository.respondToRequest(any(), any(), any()));
        // La demande doit rester dans la liste (pas de retrait optimiste).
        expect(viewModel.pendingRequests, hasLength(1));
      });

      test(
          'respondToRequest_whenAccepted_removesBookingFromPendingList',
          () async {
        // Réponse acceptée : le repository est appelé et la demande est retirée de la liste.
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;

        when(() => bookingRepository.respondToRequest('date-1', 'artist1', true))
            .thenAnswer((_) async {});

        final booking = ArtistBooking(
          artistId: 'artist1',
          dateId: 'date-1',
          status: BookingStatus.pendingConfirmation,
        );

        final viewModel = HomeViewModel();
        viewModel.pendingRequests = [booking];

        await viewModel.respondToRequest(booking, true);

        verify(() =>
                bookingRepository.respondToRequest('date-1', 'artist1', true))
            .called(1);
        expect(viewModel.pendingRequests, isEmpty);
      });

      test(
          'respondToRequest_whenRefused_removesBookingFromPendingList',
          () async {
        // Réponse refusée : le repository est appelé et la demande est retirée de la liste.
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;

        when(() => bookingRepository.respondToRequest('date-1', 'artist1', false))
            .thenAnswer((_) async {});

        final booking = ArtistBooking(
          artistId: 'artist1',
          dateId: 'date-1',
          status: BookingStatus.pendingConfirmation,
        );

        final viewModel = HomeViewModel();
        viewModel.pendingRequests = [booking];

        await viewModel.respondToRequest(booking, false);

        verify(() =>
                bookingRepository.respondToRequest('date-1', 'artist1', false))
            .called(1);
        expect(viewModel.pendingRequests, isEmpty);
      });

      test(
          'respondToRequest_whenArtistIsLoggedIn_reloadsPendingListViaGetPendingRequests',
          () async {
        final bookingRepository =
            locator<BookingRepository>() as MockBookingRepository;
        final authService =
            locator<FirebaseAuthenticationService>() as MockFirebaseAuthenticationService;
        final snackbar = locator<SnackbarService>() as MockSnackbarService;

        when(() => authService.currentUser)
            .thenReturn(_MockFirebaseUser(uid: 'firebase-uid-1'));
        when(() => bookingRepository.respondToRequest('7', '5', true))
            .thenAnswer((_) async {});
        when(() => bookingRepository.getPendingRequestsForArtist('firebase-uid-1'))
            .thenAnswer((_) async => []);
        when(() => snackbar.showSnackbar(
              message: any(named: 'message'),
              duration: any(named: 'duration'),
            )).thenReturn(null);

        final booking = ArtistBooking(
          artistId: '5',
          dateId: '7',
          status: BookingStatus.pendingConfirmation,
        );

        final viewModel = HomeViewModel();
        viewModel.currentUser = VioletteUser(
          uid: 'firebase-uid-1',
          firstName: 'A',
          lastName: 'B',
          email: 'a@b.c',
          roles: const [Role.artist],
        );
        viewModel.pendingRequests = [booking];

        await viewModel.respondToRequest(booking, true);

        verify(() => bookingRepository.getPendingRequestsForArtist('firebase-uid-1'))
            .called(1);
        expect(viewModel.pendingRequests, isEmpty);
      });
    });

    group('Chargement des dates pour demandes en attente', () {
      test(
        'loadShowDatesForPendingRequests_whenShowDateInMyAvailableList_doesNotCallGetShowDateById',
        () async {
          final showDateRepository =
              locator<ShowDateRepository>() as MockShowDateRepository;

          final sd = ShowDate(
            id: 'date-artist-list',
            title: 'Revue',
            date: DateTime(2026, 4, 10),
            meetingTimeMinutes: 600,
            address: 'Nantes',
            totalRequiredArtists: 4,
          );

          when(() => showDateRepository.getMyAvailableShowDates())
              .thenAnswer((_) async => [sd]);

          final viewModel = HomeViewModel();
          viewModel.pendingRequests = [
            ArtistBooking(
              artistId: 'a1',
              dateId: 'date-artist-list',
              status: BookingStatus.pendingConfirmation,
            ),
          ];

          await viewModel.loadShowDatesForPendingRequests();

          expect(viewModel.requestsShowDates['date-artist-list'], sd);
          verifyNever(() => showDateRepository.getShowDateById(any()));
        },
      );

      test(
        'loadShowDatesForPendingRequests_whenIdNotInArtistList_usesGetShowDateById',
        () async {
          final showDateRepository =
              locator<ShowDateRepository>() as MockShowDateRepository;

          final sd = ShowDate(
            id: 'date-by-id',
            title: 'Fallback',
            date: DateTime(2026, 5, 1),
            meetingTimeMinutes: 0,
            address: 'Brest',
            totalRequiredArtists: 1,
          );

          when(() => showDateRepository.getMyAvailableShowDates())
              .thenAnswer((_) async => []);
          when(() => showDateRepository.getShowDateById('date-by-id'))
              .thenAnswer((_) async => sd);

          final viewModel = HomeViewModel();
          viewModel.pendingRequests = [
            ArtistBooking(
              artistId: 'a1',
              dateId: 'date-by-id',
              status: BookingStatus.pendingConfirmation,
            ),
          ];

          await viewModel.loadShowDatesForPendingRequests();

          verify(() => showDateRepository.getShowDateById('date-by-id'))
              .called(1);
          expect(viewModel.requestsShowDates['date-by-id'], sd);
        },
      );

      test(
        'loadShowDatesForPendingRequests_whenDetailUnavailable_mapsNullWithoutFakeShowDate',
        () async {
          final showDateRepository =
              locator<ShowDateRepository>() as MockShowDateRepository;

          when(() => showDateRepository.getMyAvailableShowDates())
              .thenAnswer((_) async => []);
          when(() => showDateRepository.getShowDateById('missing'))
              .thenAnswer((_) async => null);

          final viewModel = HomeViewModel();
          viewModel.pendingRequests = [
            ArtistBooking(
              artistId: 'a1',
              dateId: 'missing',
              status: BookingStatus.pendingConfirmation,
            ),
          ];

          await viewModel.loadShowDatesForPendingRequests();

          expect(viewModel.requestsShowDates['missing'], isNull);
        },
      );
    });

    group('Resolution du profil au chargement (BOGUE-01 / AUTH-REC-04)', () {
      test(
        'loadUser_whenBackendProfileIsMissing_logsOutThenNavigatesToLogin',
        () async {
          final authService = locator<FirebaseAuthenticationService>()
              as MockFirebaseAuthenticationService;
          final userRepository =
              locator<UserRepository>() as MockUserRepository;
          final navigationService =
              locator<NavigationService>() as MockNavigationService;

          const uid = 'firebase-sans-profil';
          when(() => authService.currentUser)
              .thenReturn(_MockFirebaseUser(uid: uid));
          // 404 absorbe en amont par RestUserRepository.getUser : profil absent = null.
          when(() => userRepository.getUser(uid)).thenAnswer((_) async => null);
          when(() => authService.logout()).thenAnswer((_) async {});
          when(
            () => navigationService.replaceWith<dynamic>(
              any(),
              arguments: any(named: 'arguments'),
              id: any(named: 'id'),
              preventDuplicates: any(named: 'preventDuplicates'),
              parameters: any(named: 'parameters'),
              transition: any(named: 'transition'),
            ),
          ).thenAnswer((_) async => null);

          final viewModel = HomeViewModel();
          await viewModel.loadUser();

          expect(viewModel.currentUser, isNull);
          verifyInOrder([
            () => authService.logout(),
            () => navigationService.replaceWith<dynamic>(
                  Routes.loginView,
                  arguments: any(named: 'arguments'),
                  id: any(named: 'id'),
                  preventDuplicates: any(named: 'preventDuplicates'),
                  parameters: any(named: 'parameters'),
                  transition: any(named: 'transition'),
                ),
          ]);
          verifyNever(
            () => navigationService.replaceWith<dynamic>(
              Routes.homeView,
              arguments: any(named: 'arguments'),
              id: any(named: 'id'),
              preventDuplicates: any(named: 'preventDuplicates'),
              parameters: any(named: 'parameters'),
              transition: any(named: 'transition'),
            ),
          );
        },
      );

      test(
        'loadUser_whenBackendThrows_logsOutThenNavigatesToLogin',
        () async {
          final authService = locator<FirebaseAuthenticationService>()
              as MockFirebaseAuthenticationService;
          final userRepository =
              locator<UserRepository>() as MockUserRepository;
          final navigationService =
              locator<NavigationService>() as MockNavigationService;
          final dialogService =
              locator<DialogService>() as MockDialogService;

          const uid = 'firebase-uid-err';
          when(() => authService.currentUser)
              .thenReturn(_MockFirebaseUser(uid: uid));
          when(() => userRepository.getUser(uid))
              .thenThrow(Exception('erreur backend simulee'));
          when(() => authService.logout()).thenAnswer((_) async {});
          when(
            () => dialogService.showDialog(
              title: any(named: 'title'),
              description: any(named: 'description'),
              buttonTitle: any(named: 'buttonTitle'),
              cancelTitle: any(named: 'cancelTitle'),
              dialogPlatform: any(named: 'dialogPlatform'),
              barrierDismissible: any(named: 'barrierDismissible'),
            ),
          ).thenAnswer((_) async => DialogResponse());
          when(
            () => navigationService.replaceWith<dynamic>(
              any(),
              arguments: any(named: 'arguments'),
              id: any(named: 'id'),
              preventDuplicates: any(named: 'preventDuplicates'),
              parameters: any(named: 'parameters'),
              transition: any(named: 'transition'),
            ),
          ).thenAnswer((_) async => null);

          final viewModel = HomeViewModel();
          await viewModel.loadUser();

          expect(viewModel.currentUser, isNull);
          verify(
            () => dialogService.showDialog(
              title: any(named: 'title'),
              description: any(named: 'description'),
              buttonTitle: any(named: 'buttonTitle'),
              cancelTitle: any(named: 'cancelTitle'),
              dialogPlatform: any(named: 'dialogPlatform'),
              barrierDismissible: any(named: 'barrierDismissible'),
            ),
          ).called(1);
          verifyInOrder([
            () => authService.logout(),
            () => navigationService.replaceWith<dynamic>(
                  Routes.loginView,
                  arguments: any(named: 'arguments'),
                  id: any(named: 'id'),
                  preventDuplicates: any(named: 'preventDuplicates'),
                  parameters: any(named: 'parameters'),
                  transition: any(named: 'transition'),
                ),
          ]);
          verifyNever(
            () => navigationService.replaceWith<dynamic>(
              Routes.homeView,
              arguments: any(named: 'arguments'),
              id: any(named: 'id'),
              preventDuplicates: any(named: 'preventDuplicates'),
              parameters: any(named: 'parameters'),
              transition: any(named: 'transition'),
            ),
          );
        },
      );
    });
  });
}

class _MockFirebaseUser extends Mock implements User {
  @override
  final String uid;

  _MockFirebaseUser({required this.uid});
}
