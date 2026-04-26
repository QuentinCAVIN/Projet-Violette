import 'package:violette_front/models/artist_booking.dart';

/// Contrat du domaine réservations artistes.
///
/// ## État de la migration REST (incrément en cours)
///
/// | Méthode                       | Implémentation active | Statut         |
/// |-------------------------------|----------------------|----------------|
/// | `getBookingsForDate`          | REST                 | ✓ migré        |
/// | `getMyBookings`               | REST                 | ✓ migré        |
/// | `getPendingRequestsForArtist` | REST                 | ✓ migré        |
/// | `toggleSelection`             | REST                 | ✓ migré        |
/// | `sendConfirmationRequests`    | REST                 | ✓ migré        |
/// | `respondToRequest`            | REST                 | ✓ migré        |
abstract class BookingRepository {
  /// Toutes les réservations de l'artiste connecté (one-shot REST).
  ///
  /// Implémentation : `GET /api/artist-bookings/me` (JWT).
  Future<List<ArtistBooking>> getMyBookings();

  /// Demandes de confirmation en attente pour l'artiste connecté (one-shot REST).
  ///
  /// Implémentation : `GET /api/artist-bookings/me/pending` (JWT).
  /// Le paramètre [artistId] est conservé pour compatibilité avec les appels UI ;
  /// il est ignoré côté REST.
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
