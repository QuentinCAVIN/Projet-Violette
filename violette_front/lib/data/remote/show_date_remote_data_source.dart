import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:violette_front/core/network/dio_client.dart';
import 'package:violette_front/models/mappers/show_date_mapper.dart';
import 'package:violette_front/models/show_date.dart';

/// Source de données distante pour le domaine des dates de spectacle.
///
/// Encapsule les appels HTTP REST vers :
/// - GET `/api/show-dates`
/// - GET `/api/show-dates/{id}`
class ShowDateRemoteDataSource {
  late final Dio _dio;

  ShowDateRemoteDataSource({Dio? dio}) {
    _dio = dio ?? DioClient.create();
  }

  /// Récupère toutes les dates de spectacle.
  Future<List<ShowDate>> getAllShowDates() async {
    final response = await _dio.get('/api/show-dates');
    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ShowDateMapper.fromJson)
          .toList();
    }

    // Gestion défensive si le backend renvoie du JSON encodé en chaîne.
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(ShowDateMapper.fromJson)
            .toList();
      }
    }

    return [];
  }

  /// Récupère une date de spectacle par son identifiant backend.
  Future<ShowDate?> getShowDateById(String showDateId) async {
    final response = await _dio.get('/api/show-dates/$showDateId');
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return ShowDateMapper.fromJson(data);
    }

    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return ShowDateMapper.fromJson(decoded);
      }
    }

    return null;
  }
}
