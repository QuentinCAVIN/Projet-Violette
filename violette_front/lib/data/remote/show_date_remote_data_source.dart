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
/// - POST `/api/show-dates`
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
    try {
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
    } on DioException catch (e) {
      // 404 = date absente : retourne null pour laisser le ViewModel gérer le fallback UI.
      if (e.response?.statusCode == 404) {
        return null;
      }
      // 401/403 et autres erreurs réseau/backend : remontées au repository.
      rethrow;
    }
  }

  /// Résout l'identifiant de la première compagnie disponible côté REST.
  ///
  /// Mécanisme transitoire : le backend ne dispose pas d'un endpoint
  /// "ma compagnie" (ex. `GET /api/users/me/company`). On extrait le
  /// `companyId` du premier résultat de `GET /api/show-dates`.
  ///
  /// Limitation : retourne `null` si aucune date n'existe encore pour cette
  /// compagnie (première utilisation), ce qui déclenche le fallback Firestore.
  ///
  /// TODO : remplacer par un endpoint dédié dès que le backend l'exposera.
  Future<String?> resolveFirstCompanyId() async {
    try {
      final response = await _dio.get('/api/show-dates');
      final data = response.data;

      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is List) items = decoded;
      }

      if (items.isEmpty) return null;

      final first = items.first;
      if (first is! Map<String, dynamic>) return null;

      final companyId = first['companyId'];
      if (companyId == null) return null;
      return companyId is num
          ? companyId.toInt().toString()
          : companyId.toString();
    } catch (_) {
      return null;
    }
  }

  /// Crée une date de spectacle via REST.
  ///
  /// POST `/api/show-dates`
  ///
  /// [companyId] — identifiant backend SQL de la compagnie.
  /// [meetingTimeMinutes] — converti en `HH:MM:SS` pour le champ `meetingTime`.
  /// [clientContactName] / [clientContactPhone] — champs requis par le backend,
  ///   collectés dans le formulaire de création.
  Future<void> createShowDate({
    required String companyId,
    required DateTime eventDate,
    required int meetingTimeMinutes,
    required String location,
    required String clientContactName,
    required String clientContactPhone,
    String? showDetails,
  }) async {
    final companyIdNum = int.tryParse(companyId.trim());
    if (companyIdNum == null) {
      throw Exception('Identifiant de compagnie invalide : $companyId');
    }

    final eventDateStr =
        '${eventDate.year.toString().padLeft(4, '0')}-'
        '${eventDate.month.toString().padLeft(2, '0')}-'
        '${eventDate.day.toString().padLeft(2, '0')}';

    final hours = (meetingTimeMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (meetingTimeMinutes % 60).toString().padLeft(2, '0');
    final meetingTimeStr = '$hours:$minutes:00';

    await _dio.post<void>(
      '/api/show-dates',
      data: <String, dynamic>{
        'companyId': companyIdNum,
        'eventDate': eventDateStr,
        'meetingTime': meetingTimeStr,
        'location': location,
        'clientContactName': clientContactName,
        'clientContactPhone': clientContactPhone,
        if (showDetails != null && showDetails.trim().isNotEmpty)
          'showDetails': showDetails.trim(),
      },
    );
  }
}
