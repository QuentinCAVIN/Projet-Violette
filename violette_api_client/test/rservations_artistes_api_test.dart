import 'package:test/test.dart';
import 'package:violette_api_client/violette_api_client.dart';


/// tests for RservationsArtistesApi
void main() {
  final instance = VioletteApiClient().getRservationsArtistesApi();

  group(RservationsArtistesApi, () {
    // Désélectionner un artiste
    //
    // Supprime une réservation en statut SELECTED. Requiert le rôle MANAGER.
    //
    //Future apiArtistBookingsIdDelete(int id) async
    test('test apiArtistBookingsIdDelete', () async {
      // TODO
    });

    // Répondre à une demande de confirmation
    //
    // L'artiste accepte (CONFIRMED) ou refuse (REFUSED) une demande. Requiert le rôle ARTIST.
    //
    //Future<ArtistBookingDto> apiArtistBookingsIdRespondPatch(int id, RespondToBookingRequestDto respondToBookingRequestDto) async
    test('test apiArtistBookingsIdRespondPatch', () async {
      // TODO
    });

    // Mes demandes de confirmation en attente
    //
    // Retourne les réservations PENDING_CONFIRMATION de l'artiste authentifié. Requiert le rôle ARTIST.
    //
    //Future<ArtistBookingDto> apiArtistBookingsMePendingGet() async
    test('test apiArtistBookingsMePendingGet', () async {
      // TODO
    });

    // Sélectionner un artiste pour une date
    //
    // Crée une réservation en statut SELECTED pour un artiste sur une date. Requiert le rôle MANAGER.
    //
    //Future<ArtistBookingDto> apiArtistBookingsPost(CreateBookingRequestDto createBookingRequestDto) async
    test('test apiArtistBookingsPost', () async {
      // TODO
    });

    // Lister les réservations d'une date
    //
    // Retourne toutes les réservations d'une date de spectacle. Requiert le rôle MANAGER.
    //
    //Future<ArtistBookingDto> apiArtistBookingsShowDatesShowDateIdGet(int showDateId) async
    test('test apiArtistBookingsShowDatesShowDateIdGet', () async {
      // TODO
    });

    // Envoyer les demandes de confirmation
    //
    // Passe toutes les réservations SELECTED de la date en PENDING_CONFIRMATION. Requiert le rôle MANAGER.
    //
    //Future<ArtistBookingDto> apiArtistBookingsShowDatesShowDateIdSendConfirmationsPost(int showDateId) async
    test('test apiArtistBookingsShowDatesShowDateIdSendConfirmationsPost', () async {
      // TODO
    });

  });
}
