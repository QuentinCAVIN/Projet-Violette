// ignore_for_file: deprecated_member_use_from_same_package

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/enums/show_date_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/repositories/booking_repository.dart';

/// Implémentation Firestore du [BookingRepository].
///
/// ## État de la migration
///
/// Cette classe est le **fallback Firestore** utilisé par [RestBookingRepository]
/// pour les méthodes dépréciées. Elle n'est PAS le repository actif en production.
///
/// En production, le locator injecte [RestBookingRepository] qui délègue
/// uniquement aux méthodes REST de [BookingRemoteDataSource].
///
/// | Méthode                        | Statut dans cette classe           |
/// |--------------------------------|------------------------------------|
/// | `watchBookingsForDate`         | ⚠ déprécié — Firestore stream       |
/// | `watchPendingRequestsForArtist`| ⚠ déprécié — Firestore stream       |
/// | `getPendingRequestsForArtist`  | ⚠ fallback Firestore one-shot       |
/// | `getBookingsForDate`           | ⚠ fallback Firestore one-shot       |
/// | `toggleSelection`              | ⚠ legacy Firestore transaction      |
/// | `sendConfirmationRequests`     | ⚠ legacy Firestore batch            |
/// | `respondToRequest`             | ⚠ legacy Firestore transaction      |
///
/// Conservé uniquement pour :
/// 1. les tests Firestore directs (`booking_service_test`)
/// 2. satisfaire le contrat d'interface dans [RestBookingRepository]
class FirestoreBookingRepository implements BookingRepository {
  final FirebaseFirestore _firestore;

  FirestoreBookingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// @deprecated — stream Firestore, non utilisé en production.
  /// Remplacé par [getBookingsForDate] via REST.
  @override
  @Deprecated(
    'Stream Firestore. Utiliser getBookingsForDate (REST) à la place.',
  )
  Stream<List<ArtistBooking>> watchBookingsForDate(String dateId) {
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

  /// @deprecated — stream Firestore, non utilisé en production.
  /// Remplacé par [getPendingRequestsForArtist] via REST.
  @override
  @Deprecated(
    'Stream Firestore. Utiliser getPendingRequestsForArtist (REST) à la place.',
  )
  Stream<List<ArtistBooking>> watchPendingRequestsForArtist(String artistId) {
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

  /// Fallback Firestore one-shot pour [getPendingRequestsForArtist].
  ///
  /// En production, [RestBookingRepository] surcharge cette méthode avec
  /// `GET /api/artist-bookings/me/pending`.
  @override
  Future<List<ArtistBooking>> getPendingRequestsForArtist(String artistId) async {
    final snapshot = await _firestore
        .collectionGroup('artistBookings')
        .where('artistId', isEqualTo: artistId)
        .where('status', isEqualTo: BookingStatus.pendingConfirmation.name)
        .get();
    return snapshot.docs
        .map((doc) => ArtistBooking.fromFirestore(doc, null))
        .toList();
  }

  /// Fallback Firestore one-shot pour [getBookingsForDate].
  ///
  /// En production, [RestBookingRepository] surcharge cette méthode avec
  /// `GET /api/artist-bookings/show-dates/{dateId}`.
  @override
  Future<List<ArtistBooking>> getBookingsForDate(String dateId) async {
    final snapshot = await _firestore
        .collection('showDates')
        .doc(dateId)
        .collection('artistBookings')
        .get();
    return snapshot.docs
        .map((doc) => ArtistBooking.fromFirestore(doc, null))
        .toList();
  }

  /// @deprecated — legacy Firestore. En production : REST via [RestBookingRepository].
  @override
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

      final showDate = _showDateFromFirestoreSnapshot(dateSnapshot);
      final bookingSnapshot = await transaction.get(bookingRef);

      if (select) {
        if (showDate.selectedCount >= showDate.totalRequiredArtists) {
          throw Exception("Limite d'artistes atteinte");
        }

        if (bookingSnapshot.exists) return;

        transaction.update(dateRef, {
          'selectedCount': FieldValue.increment(1),
        });

        transaction.set(
          bookingRef,
          ArtistBooking(
            artistId: artistId,
            status: BookingStatus.preselected,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ).toFirestore(),
        );
      } else {
        if (!bookingSnapshot.exists) return;

        transaction.update(dateRef, {
          'selectedCount': FieldValue.increment(-1),
        });

        transaction.delete(bookingRef);
      }
    });
  }

  /// @deprecated — legacy Firestore. En production : REST via [RestBookingRepository].
  @override
  Future<void> sendConfirmationRequests(String dateId) async {
    final bookingsRef = _firestore
        .collection('showDates')
        .doc(dateId)
        .collection('artistBookings');

    final selectedBookingsSnapshot = await bookingsRef
        .where('status', isEqualTo: BookingStatus.preselected.name)
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

  /// @deprecated — legacy Firestore. En production : REST via [RestBookingRepository].
  @override
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

      final booking = ArtistBooking.fromFirestore(bookingSnapshot, null);

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

        transaction.update(dateRef, {
          'selectedCount': FieldValue.increment(-1),
        });
      }
    });
  }
}

/// Lecture d’un document `showDates/{id}` pour le legacy Firestore booking uniquement.
/// Le modèle domaine [ShowDate] n’embarque plus de sérialisation Firestore.
ShowDate _showDateFromFirestoreSnapshot(
  DocumentSnapshot<Map<String, dynamic>> snapshot,
) {
  final data = snapshot.data()!;

  return ShowDate(
    id: snapshot.id,
    title: data['title'],
    date: data['date'].toDate().toLocal(),
    meetingTimeMinutes: data['startTime'] as int,
    address: data['address'],
    totalRequiredArtists: data['artistsCount'] as int,
    description: data['description'],
    status: showDateStatusFromString(data['status'] ?? ''),
    selectedCount: data['selectedCount'] ?? 0,
  );
}
