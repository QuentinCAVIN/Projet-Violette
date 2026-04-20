import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:violette_front/core/network/dio_client.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/mappers/artist_booking_mapper.dart';

/// Source de données distante pour le domaine réservations artistes (REST).
///
/// Incréments : réponse artiste (`respondToRequest`), liste des demandes en
/// attente (`getPendingRequestsForArtist`), envoi des demandes de confirmation
/// gérant (`sendConfirmationRequests`), sélection / désélection gérant
/// (`toggleSelection`).
class BookingRemoteDataSource {
  late final Dio _dio;

  BookingRemoteDataSource({Dio? dio}) {
    _dio = dio ?? DioClient.create();
  }

  /// Liste des demandes de confirmation en attente pour l’artiste authentifié.
  ///
  /// `GET /api/artist-bookings/me/pending`
  ///
  /// Le filtrage par artiste est assuré par le JWT ; aucun paramètre d’URL.
  Future<List<ArtistBooking>> getPendingRequestsForArtist() async {
    try {
      final response = await _dio.get('/api/artist-bookings/me/pending');
      final items = ArtistBookingMapper.parseBookingList(response.data);
      return ArtistBookingMapper.toArtistBookingList(items);
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e));
    }
  }

  /// Répond à une demande de confirmation pour la date [showDateId].
  ///
  /// Résout d'abord l'identifiant backend du booking via
  /// `GET /api/artist-bookings/me/pending`, puis appelle
  /// `PATCH /api/artist-bookings/{id}/respond` avec `{ "accept": ... }`.
  ///
  /// Le paramètre [artistId] est conservé pour la compatibilité avec
  /// [BookingRepository.respondToRequest] ; la liste `/me/pending` est déjà
  /// filtrée par l'artiste authentifié (JWT).
  Future<void> respondToRequest(
    String showDateId,
    String artistId, // ignore: unused_parameter — JWT côté API
    bool accept,
  ) async {
    late final List<Map<String, dynamic>> items;
    try {
      final pendingResponse = await _dio.get('/api/artist-bookings/me/pending');
      items = ArtistBookingMapper.parseBookingList(pendingResponse.data);
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e));
    }
    final bookingId = ArtistBookingMapper.findPendingBookingIdForShowDate(
      items,
      showDateId,
    );

    if (bookingId == null) {
      throw Exception(
        'Aucune demande de confirmation correspondante sur le serveur pour '
        'cette date. Elle a peut-être déjà été traitée ou les données ne sont '
        'pas encore synchronisées.',
      );
    }

    try {
      await _dio.patch(
        '/api/artist-bookings/$bookingId/respond',
        data: <String, dynamic>{'accept': accept},
      );
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e));
    }
  }

  /// Envoie les demandes de confirmation pour la date [showDateId] (rôle MANAGER).
  ///
  /// POST `/api/artist-bookings/show-dates/{showDateId}/send-confirmations`
  /// Sélectionne ou désélectionne un artiste (rôle MANAGER).
  ///
  /// Sélection : `POST /api/artist-bookings` avec `showDateId` et `artistId`
  /// (identifiants backend numériques).
  ///
  /// Désélection : `GET /api/artist-bookings/show-dates/{showDateId}` puis
  /// `DELETE /api/artist-bookings/{id}` pour le booking en statut SELECTED.
  Future<void> toggleSelection(
    String showDateId,
    String artistId,
    bool select,
  ) async {
    final showDateIdNum = int.tryParse(showDateId.trim());
    final artistIdNum = int.tryParse(artistId.trim());
    if (showDateIdNum == null || artistIdNum == null) {
      throw Exception(
        'Identifiant de date ou d’artiste invalide pour l’API (attendu : entiers).',
      );
    }

    if (select) {
      try {
        await _dio.post<void>(
          '/api/artist-bookings',
          data: <String, dynamic>{
            'showDateId': showDateIdNum,
            'artistId': artistIdNum,
          },
        );
      } on DioException catch (e) {
        throw Exception(_messageFromDio(e));
      }
      return;
    }

    late final List<Map<String, dynamic>> items;
    try {
      final listResponse =
          await _dio.get('/api/artist-bookings/show-dates/$showDateId');
      items = ArtistBookingMapper.parseBookingList(listResponse.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Date de spectacle introuvable côté serveur.');
      }
      throw Exception(_messageFromDio(e));
    }

    final bookingId =
        ArtistBookingMapper.findBookingIdForArtistId(items, artistIdNum);
    if (bookingId == null) {
      throw Exception(
        'Aucune présélection à retirer pour cet artiste sur le serveur.',
      );
    }

    try {
      await _dio.delete<void>('/api/artist-bookings/$bookingId');
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e));
    }
  }

  /// Retourne la liste des bookings actifs pour la date [showDateId] (rôle MANAGER).
  ///
  /// `GET /api/artist-bookings/show-dates/{showDateId}`
  ///
  /// Retourne une liste vide si la date n'a aucun booking ou si le serveur
  /// répond 404 (date inconnue côté backend).
  Future<List<ArtistBooking>> getBookingsForDate(String showDateId) async {
    try {
      final response =
          await _dio.get('/api/artist-bookings/show-dates/$showDateId');
      final items = ArtistBookingMapper.parseBookingList(response.data);
      return ArtistBookingMapper.toArtistBookingList(items);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception(_messageFromDio(e));
    }
  }

  Future<void> sendConfirmationRequests(String showDateId) async {
    try {
      await _dio.post<void>(
        '/api/artist-bookings/show-dates/$showDateId/send-confirmations',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Date de spectacle introuvable côté serveur.');
      }
      throw Exception(_messageFromDio(e));
    }
  }

  static String _messageFromDio(DioException e) {
    final status = e.response?.statusCode;
    final raw = e.response?.data;

    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }

    if (raw is Map) {
      final msg = raw['message'] ?? raw['detail'] ?? raw['error'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString().trim();
      }
      try {
        return jsonEncode(raw);
      } catch (_) {}
    }

    switch (status) {
      case 401:
        return 'Session expirée ou non authentifié. Reconnecte-toi.';
      case 403:
        return 'Accès refusé (rôle insuffisant).';
      case 404:
        return 'Réservation introuvable côté serveur.';
      case 409:
        return 'Action impossible : la réservation n’est pas dans le bon état '
            '(ex. déjà traitée ou transition interdite).';
      default:
        break;
    }

    return e.message ??
        'Erreur réseau ou serveur${status != null ? ' (HTTP $status)' : ''}.';
  }
}
