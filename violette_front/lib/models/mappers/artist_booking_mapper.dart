import 'dart:convert';

import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/enums/booking_status.dart';

/// Utilitaires de mapping entre le JSON REST `ArtistBookingDto` et le domaine Flutter.
///
/// Incrément booking : résolution des identifiants backend (toggleSelection,
/// respondToRequest) et conversion one-shot (getBookingsForDate).
class ArtistBookingMapper {
  ArtistBookingMapper._();

  /// Extrait les objets carte d'une réponse JSON liste (liste directe ou chaîne JSON).
  static List<Map<String, dynamic>> parseBookingList(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
    }
    return [];
  }

  /// Retourne l'identifiant backend du booking pour lequel l'artiste peut encore
  /// répondre à une demande de confirmation.
  ///
  /// Compare [showDateId] (identifiant `ShowDate.uid`, ex. `"7"`) au champ
  /// `showDateId` du DTO (nombre JSON).
  ///
  /// Ne retient que les lignes dont le champ `status` est
  /// `PENDING_CONFIRMATION` (insensible à la casse). Les statuts
  /// `CONFIRMED`, `REFUSED`, `SELECTED`, etc. sont ignorés.
  ///
  /// Si plusieurs lignes valides existent pour la même date (anomalie), la
  /// première dans l'ordre de la liste est retournée.
  ///
  /// Retourne `null` si aucune entrée ne correspond.
  static int? findPendingBookingIdForShowDate(
    List<Map<String, dynamic>> items,
    String showDateId,
  ) {
    final normalized = showDateId.trim();
    if (normalized.isEmpty) return null;

    for (final item in items) {
      if (!_showDateIdsMatch(item['showDateId'], normalized)) continue;
      if (!_isPendingConfirmationStatus(item['status'])) continue;
      return _toBookingId(item['id']);
    }
    return null;
  }

  static bool _isPendingConfirmationStatus(dynamic status) {
    if (status == null) return false;
    final normalized = status.toString().trim().toUpperCase();
    return normalized == 'PENDING_CONFIRMATION';
  }

  static bool _showDateIdsMatch(dynamic apiShowDateId, String dateId) {
    if (apiShowDateId == null) return false;
    final a = apiShowDateId is num
        ? apiShowDateId.toInt().toString()
        : apiShowDateId.toString().trim();
    return a == dateId;
  }

  static int? _toBookingId(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '');
  }

  /// Trouve l’id du booking pour un [artistId] backend (GET liste des bookings d’une date).
  static int? findBookingIdForArtistId(
    List<Map<String, dynamic>> items,
    int artistId,
  ) {
    for (final item in items) {
      if (_sameNumericId(item['artistId'], artistId)) {
        return _toBookingId(item['id']);
      }
    }
    return null;
  }

  static bool _sameNumericId(dynamic raw, int expected) {
    if (raw == null) return false;
    final n = raw is num ? raw.toInt() : int.tryParse(raw.toString());
    return n == expected;
  }

  // ── Conversion complète REST → domaine Flutter ──────────────────────────

  /// Convertit un item JSON de `GET /api/artist-bookings/show-dates/{id}` en
  /// [ArtistBooking]. Retourne `null` si le statut est absent ou inconnu.
  ///
  /// Le champ `artistId` (int backend) est converti en String pour rester
  /// compatible avec le domaine Flutter.
  static ArtistBooking? toArtistBooking(Map<String, dynamic> json) {
    final status = _bookingStatusFromApi(json['status']);
    if (status == null) return null;

    final rawArtistId = json['artistId'];
    final artistId = rawArtistId is num
        ? rawArtistId.toInt().toString()
        : rawArtistId?.toString() ?? '';

    final rawDateId = json['showDateId'];
    final dateId = rawDateId is num
        ? rawDateId.toInt().toString()
        : rawDateId?.toString();

    return ArtistBooking(
      artistId: artistId,
      dateId: dateId,
      status: status,
    );
  }

  /// Convertit une liste brute JSON (issue de [parseBookingList]) en liste de
  /// [ArtistBooking], en ignorant silencieusement les entrées non parsables.
  static List<ArtistBooking> toArtistBookingList(
    List<Map<String, dynamic>> items,
  ) {
    final result = <ArtistBooking>[];
    for (final item in items) {
      final booking = toArtistBooking(item);
      if (booking != null) result.add(booking);
    }
    return result;
  }

  /// Convertit un statut REST (ex. `"PENDING_CONFIRMATION"`) en [BookingStatus].
  ///
  /// Retourne `null` si la valeur est absente ou non reconnue.
  static BookingStatus? _bookingStatusFromApi(dynamic raw) {
    if (raw == null) return null;
    switch (raw.toString().trim().toUpperCase()) {
      case 'SELECTED':
        return BookingStatus.preselected;
      case 'PENDING_CONFIRMATION':
        return BookingStatus.pendingConfirmation;
      case 'CONFIRMED':
        return BookingStatus.confirmed;
      case 'REFUSED':
        return BookingStatus.refused;
      default:
        return null;
    }
  }
}
