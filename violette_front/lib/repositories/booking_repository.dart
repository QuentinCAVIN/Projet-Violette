import 'package:violette_front/models/artist_booking.dart';

/// Contrat du domaine réservations artistes.
///
/// ## État de la migration REST (incrément en cours)
///
/// | Méthode                       | Implémentation active | Statut         |
/// |-------------------------------|----------------------|----------------|
/// | `getBookingsForDate`          | REST                 | ✓ migré        |
/// | `getPendingRequestsForArtist` | REST                 | ✓ migré        |
/// | `toggleSelection`             | REST                 | ✓ migré        |
/// | `sendConfirmationRequests`    | REST                 | ✓ migré        |
/// | `respondToRequest`            | REST                 | ✓ migré        |
/// | `watchBookingsForDate`        | Firestore legacy     | ⚠ déprécié     |
/// | `watchPendingRequestsForArtist` | Firestore legacy   | ⚠ déprécié     |
abstract class BookingRepository {
  /// Écoute en temps réel les bookings d'une date via Firestore.
  ///
  /// @deprecated : plus utilisé par aucun écran actif.
  /// Remplacé par [getBookingsForDate] (one-shot REST).
  /// À supprimer après confirmation que [FirestoreBookingRepository] n'est plus
  /// référencé directement.
  @Deprecated(
    'Délègue à Firestore. Utiliser getBookingsForDate à la place. '
    'À supprimer après stabilisation complète du domaine booking.',
  )
  Stream<List<ArtistBooking>> watchBookingsForDate(String dateId);

  /// Écoute en temps réel les demandes de confirmation en attente pour un artiste.
  ///
  /// @deprecated : plus utilisé par aucun écran actif.
  /// Remplacé par [getPendingRequestsForArtist] (one-shot REST).
  /// À supprimer après confirmation que [FirestoreBookingRepository] n'est plus
  /// référencé directement.
  @Deprecated(
    'Délègue à Firestore. Utiliser getPendingRequestsForArtist à la place. '
    'À supprimer après stabilisation complète du domaine booking.',
  )
  Stream<List<ArtistBooking>> watchPendingRequestsForArtist(String artistId);

  /// Demandes de confirmation en attente pour l'artiste connecté (one-shot REST).
  ///
  /// Implémentation : `GET /api/artist-bookings/me/pending` (JWT). Le paramètre
  /// [artistId] sert au fallback Firestore ; il est ignoré côté REST.
  Future<List<ArtistBooking>> getPendingRequestsForArtist(String artistId);

  /// Charge la liste des bookings pour une date (one-shot REST).
  /// Implémentation : `GET /api/artist-bookings/show-dates/{dateId}`.
  Future<List<ArtistBooking>> getBookingsForDate(String dateId);

  /// Présélection / désélection d'un artiste (gérant).
  /// Implémentation : REST (`POST /api/artist-bookings`, `DELETE ...`).
  Future<void> toggleSelection(String dateId, String artistId, bool select);

  /// Passe les réservations sélectionnées en attente de confirmation (gérant).
  /// Implémentation : REST (`POST .../send-confirmations`).
  Future<void> sendConfirmationRequests(String dateId);

  /// Réponse de l'artiste à une demande de confirmation (accepter / refuser).
  /// Implémentation : REST (`PATCH /api/artist-bookings/{id}/respond`).
  Future<void> respondToRequest(String dateId, String artistId, bool accept);
}
