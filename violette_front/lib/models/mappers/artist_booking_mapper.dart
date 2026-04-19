import 'dart:convert';

/// Utilitaires de mapping entre le JSON REST `ArtistBookingDto` et le domaine Flutter.
///
/// Incrément booking : uniquement ce qui est nécessaire pour résoudre un booking
/// en attente côté API (identifiant numérique) à partir du `showDateId` métier.
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
}
