import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:violette_front/core/network/dio_client.dart';
import 'package:violette_front/models/availability.dart';
import 'package:violette_front/models/mappers/availability_mapper.dart';

/// Source de données distante pour le domaine des disponibilités artistes.
///
/// Encapsule totalement les appels HTTP vers les endpoints REST :
/// - GET `/api/show-dates/{id}/availabilities`
/// - PUT `/api/show-dates/{id}/availabilities/me`
class AvailabilityRemoteDataSource {
  late final Dio _dio;

  AvailabilityRemoteDataSource({Dio? dio}) {
    _dio = dio ?? DioClient.create();
  }

  /// Récupère toutes les disponibilités d'une date donnée (côté MANAGER).
  ///
  /// GET /api/show-dates/{id}/availabilities
  Future<List<Availability>> getAvailabilitiesForDate(String showDateId) async {
    final response = await _dio.get(
      '/api/show-dates/$showDateId/availabilities',
    );

    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(AvailabilityMapper.fromJson)
          .toList();
    }

    // Gestion défensive si le backend renvoie du JSON encodé en chaîne.
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(AvailabilityMapper.fromJson)
            .toList();
      }
    }

    return [];
  }

  /// Met à jour la disponibilité de l'artiste courant pour une date donnée.
  ///
  /// PUT /api/show-dates/{id}/availabilities/me
  Future<void> upsertMyAvailability(
    String showDateId,
    Availability availability,
  ) async {
    await _dio.put(
      '/api/show-dates/$showDateId/availabilities/me',
      data: <String, dynamic>{
        'status': AvailabilityMapper.toApiStatus(availability.status),
      },
    );
  }
}

