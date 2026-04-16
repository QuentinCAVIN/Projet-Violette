import 'package:violette_front/models/availability.dart';
import 'package:violette_front/models/enums/availability_status.dart';

/// Contrat de repository pour le domaine des disponibilités.
abstract class AvailabilityRepository {
  /// Liste les disponibilités pour une date donnée (vue MANAGER).
  Future<List<Availability>> getAvailabilitiesForDate(String showDateId);

  /// Met à jour la disponibilité de l'artiste courant pour une date donnée.
  Future<void> upsertMyAvailability({
    required String showDateId,
    required AvailabilityStatus status,
  });
}

