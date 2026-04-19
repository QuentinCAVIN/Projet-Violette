import 'package:violette_front/models/artist_booking.dart';

abstract class BookingRepository {
  /// Stream Firestore — utilisé uniquement là où le temps réel est indispensable.
  /// L'écran manager détail n'écoute plus ce stream depuis la migration REST.
  Stream<List<ArtistBooking>> watchBookingsForDate(String dateId);
  Stream<List<ArtistBooking>> watchPendingRequestsForArtist(String artistId);

  /// Demandes de confirmation en attente pour l’artiste connecté (one-shot REST).
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
