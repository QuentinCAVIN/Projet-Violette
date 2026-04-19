import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:violette_front/core/network/dio_client.dart';
import 'package:violette_front/models/mappers/artist_booking_mapper.dart';

/// Source de données distante pour le domaine réservations artistes (REST).
///
/// Incréments : réponse artiste (`respondToRequest`), envoi des demandes de
/// confirmation gérant (`sendConfirmationRequests`).
class BookingRemoteDataSource {
  late final Dio _dio;

  BookingRemoteDataSource({Dio? dio}) {
    _dio = dio ?? DioClient.create();
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
