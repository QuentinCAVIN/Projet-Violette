import 'package:violette_front/models/availability.dart';
import 'package:violette_front/models/enums/availability_status.dart';

/// Mapper entre les DTO REST de disponibilité et le modèle domaine [Availability].
///
/// Remarque : les types exacts du client OpenAPI (par exemple `ArtistAvailabilityDto`)
/// seront branchés ici dès qu'ils seront générés. En attendant, on utilise des
/// structures simples (Map) pour limiter l'impact.
class AvailabilityMapper {
  AvailabilityMapper._();

  /// Convertit une entrée JSON brute `{ "artistId": "...", "status": "AVAILABLE" }`
  /// vers le modèle domaine [Availability].
  static Availability fromJson(Map<String, dynamic> json) {
    final rawArtist = json['artistId'];
    final artistId = rawArtist == null
        ? ''
        : (rawArtist is String ? rawArtist : rawArtist.toString());
    final rawStatus = json['status'];
    final statusStr = rawStatus == null ? '' : rawStatus.toString();
    return Availability(
      artistId: artistId,
      status: fromApiStatus(statusStr),
    );
  }

  /// Convertit un statut REST (chaîne) vers [AvailabilityStatus] local.
  static AvailabilityStatus fromApiStatus(String raw) {
    switch (raw.toUpperCase()) {
      case 'AVAILABLE':
        return AvailabilityStatus.available;
      case 'IF_NEEDED':
        return AvailabilityStatus.ifNeeded;
      case 'UNAVAILABLE':
        return AvailabilityStatus.unavailable;
      case 'PENDING':
      default:
        return AvailabilityStatus.pending;
    }
  }

  /// Convertit un statut local vers le format attendu par l'API REST.
  static String toApiStatus(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return 'AVAILABLE';
      case AvailabilityStatus.ifNeeded:
        return 'IF_NEEDED';
      case AvailabilityStatus.unavailable:
        return 'UNAVAILABLE';
      case AvailabilityStatus.pending:
        return 'PENDING';
    }
  }
}

