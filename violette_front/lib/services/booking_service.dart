import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/show_date.dart';


/// Gestion des sélections et confirmations d’artistes pour une date donnée.
class BookingService {
  final FirebaseFirestore _firestore;

  BookingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  //TODO:ralentissement?
  Stream<List<ArtistBooking>> getBookingsForDate(String dateId) {
    return _firestore
        .collection('showDates')
        .doc(dateId)
        .collection('artistBookings')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ArtistBooking.fromFirestore(doc, null))
              .toList();
        });
  }


  Stream<List<ArtistBooking>> getPendingRequestsForArtist(String artistId) {
    return _firestore
        .collectionGroup('artistBookings')
        .where('artistId', isEqualTo: artistId)
        .where('status', isEqualTo: BookingStatus.pendingConfirmation.name)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ArtistBooking.fromFirestore(doc, null))
              .toList();
        });
  }

  /// Sélectionne ou désélectionne un artiste pour une date.
  Future<void> toggleSelection(
    String dateId,
    String artistId,
    bool select,
  ) async {
    final dateRef = _firestore.collection('showDates').doc(dateId);
    final bookingRef = dateRef.collection('artistBookings').doc(artistId);

    await _firestore.runTransaction((transaction) async {
      final dateSnapshot = await transaction.get(dateRef);

      if (!dateSnapshot.exists) {
        throw Exception("Date introuvable");
      }

      final showDate = ShowDate.fromFirestore(dateSnapshot, null);
      final bookingSnapshot = await transaction.get(bookingRef);

      if (select) {
        // Tentative de sélection
        if (showDate.selectedCount >= showDate.artistsCount) {
          throw Exception("Limite d’artistes atteinte");
        }

        // Idempotence : déjà sélectionné → aucune action
        if (bookingSnapshot.exists) return;

        transaction.update(dateRef, {
          'selectedCount': FieldValue.increment(1),
        });

        transaction.set(
          bookingRef,
          ArtistBooking(
            artistId: artistId,
            status: BookingStatus.selected,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ).toFirestore(),
        );
      } else {
        // Tentative de désélection
        if (!bookingSnapshot.exists) return;

        transaction.update(dateRef, {
          'selectedCount': FieldValue.increment(-1),
        });

        transaction.delete(bookingRef);
      }
    });
  }

  /// Envoie les demandes de confirmation aux artistes sélectionnés.
  Future<void> sendConfirmationRequests(String dateId) async {
    final bookingsRef = _firestore
        .collection('showDates')
        .doc(dateId)
        .collection('artistBookings');

    final selectedBookingsSnapshot = await bookingsRef
        .where('status', isEqualTo: BookingStatus.selected.name)
        .get();

    if (selectedBookingsSnapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    final now = DateTime.now();

    for (final doc in selectedBookingsSnapshot.docs) {
      batch.update(doc.reference, {
        'status': BookingStatus.pendingConfirmation.name,
        'requestedAt': now,
        'updatedAt': now,
      });
    }

    await batch.commit();
  }

  /// Traite la réponse d’un artiste à une demande de confirmation.
  Future<void> respondToRequest(
    String dateId,
    String artistId,
    bool accept,
  ) async {
    final dateRef = _firestore.collection('showDates').doc(dateId);
    final bookingRef = dateRef.collection('artistBookings').doc(artistId);

    await _firestore.runTransaction((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);

      if (!bookingSnapshot.exists) {
        throw Exception("Demande de booking introuvable");
      }

      final booking =
          ArtistBooking.fromFirestore(bookingSnapshot, null);

      // on ne traite que les demandes réellement en attente
      if (booking.status != BookingStatus.pendingConfirmation) {
        return;
      }

      final now = DateTime.now();

      if (accept) {
        transaction.update(bookingRef, {
          'status': BookingStatus.confirmed.name,
          'respondedAt': now,
          'updatedAt': now,
        });
      } else {
        transaction.update(bookingRef, {
          'status': BookingStatus.refused.name,
          'respondedAt': now,
          'updatedAt': now,
        });

        // Libération d’une place dans l’équipe
        transaction.update(dateRef, {
          'selectedCount': FieldValue.increment(-1),
        });
      }
    });
  }
}