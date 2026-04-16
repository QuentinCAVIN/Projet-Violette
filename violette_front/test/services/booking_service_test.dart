import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/enums/show_date_status.dart';

import 'package:violette_front/services/booking_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreBookingRepository bookingRepo;
  late String dateId;
  late String artist1Id;
  late String artist2Id;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    bookingRepo = FirestoreBookingRepository(firestore: firestore);
    dateId = 'date_123';
    artist1Id = 'artist_1';
    artist2Id = 'artist_2';

    // Configuration de la date initiale
    await firestore.collection('showDates').doc(dateId).set(ShowDate(
          uid: dateId,
          title: 'Concert Test',
          date: DateTime.now(),
          startMinutes: 600,
          endMinutes: 720,
          address: 'Test Address',
          artistsCount: 2, // La limite est de 2
          fee: 100,
          status: ShowDateStatus.confirmed,
          selectedCount: 0,
        ).toFirestore());
  });

  group('BookingService', () {
    group('toggleSelection', () {
      test('devrait sélectionner l\'artiste et incrémenter selectedCount',
          () async {
        await bookingRepo.toggleSelection(dateId, artist1Id, true);

        final bookingSnap = await firestore
            .collection('showDates')
            .doc(dateId)
            .collection('artistBookings')
            .doc(artist1Id)
            .get();
        expect(bookingSnap.exists, true);
        expect(bookingSnap.data()?['status'], BookingStatus.selected.name);

        final dateSnap =
            await firestore.collection('showDates').doc(dateId).get();
        expect(dateSnap.data()?['selectedCount'], 1);
      });

      test('devrait lever une exception si la limite est atteinte', () async {
        // Sélection de 2 artistes (la limite est de 2)
        await bookingRepo.toggleSelection(dateId, artist1Id, true);
        await bookingRepo.toggleSelection(dateId, artist2Id, true);

        expect(
          () => bookingRepo.toggleSelection(dateId, 'artist_3', true),
          throwsException,
        );
      });

      test('devrait désélectionner l\'artiste et décrémenter selectedCount',
          () async {
        // Première sélection
        await bookingRepo.toggleSelection(dateId, artist1Id, true);

        // Puis désélection
        await bookingRepo.toggleSelection(dateId, artist1Id, false);

        final bookingSnap = await firestore
            .collection('showDates')
            .doc(dateId)
            .collection('artistBookings')
            .doc(artist1Id)
            .get();
        expect(bookingSnap.exists, false);

        final dateSnap =
            await firestore.collection('showDates').doc(dateId).get();
        expect(dateSnap.data()?['selectedCount'], 0);
      });
    });

    group('sendConfirmationRequests', () {
      test(
          'devrait mettre à jour le statut en pendingConfirmation UNIQUEMENT pour les réservations sélectionnées',
          () async {
        // Configuration : artiste 1 sélectionné, artiste 2 déjà confirmé (devrait être ignoré)
        await firestore
            .collection('showDates')
            .doc(dateId)
            .collection('artistBookings')
            .doc(artist1Id)
            .set({
          'artistId': artist1Id,
          'status': BookingStatus.selected.name,
        });

        await firestore
            .collection('showDates')
            .doc(dateId)
            .collection('artistBookings')
            .doc(artist2Id)
            .set({
          'artistId': artist2Id,
          'status': BookingStatus.confirmed.name,
        });

        await bookingRepo.sendConfirmationRequests(dateId);

        final booking1 = await firestore
            .collection('showDates')
            .doc(dateId)
            .collection('artistBookings')
            .doc(artist1Id)
            .get();
        expect(
            booking1.data()?['status'], BookingStatus.pendingConfirmation.name);
        expect(booking1.data()?['requestedAt'], isNotNull);

        final booking2 = await firestore
            .collection('showDates')
            .doc(dateId)
            .collection('artistBookings')
            .doc(artist2Id)
            .get();
        expect(booking2.data()?['status'], BookingStatus.confirmed.name);
      });
    });

    group('respondToRequest', () {
      test('devrait confirmer la réservation si acceptée', () async {
        // Configuration : confirmation en attente
        await firestore
            .collection('showDates')
            .doc(dateId)
            .collection('artistBookings')
            .doc(artist1Id)
            .set({
          'artistId': artist1Id,
          'status': BookingStatus.pendingConfirmation.name,
        });

        await bookingRepo.respondToRequest(dateId, artist1Id, true);

        final booking = await firestore
            .collection('showDates')
            .doc(dateId)
            .collection('artistBookings')
            .doc(artist1Id)
            .get();
        expect(booking.data()?['status'], BookingStatus.confirmed.name);
        expect(booking.data()?['respondedAt'], isNotNull);
      });

      test(
          'devrait refuser la réservation et décrémenter selectedCount si refusée',
          () async {
        // Configuration : la date a un compteur de sélection à 1, artiste en attente
        await firestore.collection('showDates').doc(dateId).update({
          'selectedCount': 1,
        });

        await firestore
            .collection('showDates')
            .doc(dateId)
            .collection('artistBookings')
            .doc(artist1Id)
            .set({
          'artistId': artist1Id,
          'status': BookingStatus.pendingConfirmation.name,
        });

        await bookingRepo.respondToRequest(dateId, artist1Id, false);

        final booking = await firestore
            .collection('showDates')
            .doc(dateId)
            .collection('artistBookings')
            .doc(artist1Id)
            .get();
        expect(booking.data()?['status'], BookingStatus.refused.name);

        final dateSnap =
            await firestore.collection('showDates').doc(dateId).get();
        expect(dateSnap.data()?['selectedCount'], 0);
      });

      test(
          'ne devrait rien faire si le statut n\'est pas pendingConfirmation (Idempotence)',
          () async {
        // Configuration : déjà confirmé
        await firestore
            .collection('showDates')
            .doc(dateId)
            .collection('artistBookings')
            .doc(artist1Id)
            .set({
          'artistId': artist1Id,
          'status': BookingStatus.confirmed.name,
        });

        await bookingRepo.respondToRequest(dateId, artist1Id, false);

        final booking = await firestore
            .collection('showDates')
            .doc(dateId)
            .collection('artistBookings')
            .doc(artist1Id)
            .get();
        // Devrait TOUJOURS être confirmé, PAS refusé
        expect(booking.data()?['status'], BookingStatus.confirmed.name);
      });
    });
  });
}
