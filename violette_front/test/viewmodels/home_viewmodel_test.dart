import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/enums/role.dart';
import 'package:violette_front/models/violette_user.dart';
import 'package:violette_front/repositories/booking_repository.dart';
import 'package:violette_front/ui/views/home/home_viewmodel.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('HomeViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    group('respondToRequest -', () {
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
          'respondToRequest_quandArtisteConnecte_rechargeLaListeViaGetPending',
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
  });
}

class _MockFirebaseUser extends Mock implements User {
  @override
  final String uid;

  _MockFirebaseUser({required this.uid});
}
