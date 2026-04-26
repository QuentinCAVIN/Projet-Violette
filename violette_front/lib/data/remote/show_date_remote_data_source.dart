import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:violette_front/core/network/dio_client.dart';
import 'package:violette_front/models/enums/show_date_status.dart';
import 'package:violette_front/models/mappers/show_date_mapper.dart';
import 'package:violette_front/models/show_date.dart';

/// Source de données distante pour le domaine des dates de spectacle.
///
/// Encapsule les appels HTTP REST vers :
/// - GET `/api/show-dates`
/// - GET `/api/show-dates/{id}`
/// - GET `/api/companies/mine`
/// - POST `/api/show-dates`
/// - DELETE `/api/show-dates/{id}`
/// - PATCH `/api/show-dates/{id}`
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

  /// Récupère les dates visibles pour l'artiste courant.
  ///
  /// GET `/api/show-dates/me/available`
  Future<List<ShowDate>> getMyAvailableShowDates() async {
    final response = await _dio.get('/api/show-dates/me/available');
    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ShowDateMapper.fromJson)
          .toList();
    }

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
      // 404 = date absente : retourne null (affichage / chargement à la charge du ViewModel).
      if (e.response?.statusCode == 404) {
        return null;
      }
      // 401/403 et autres erreurs réseau/backend : remontées au repository.
      rethrow;
    }
  }

  /// Retourne l'identifiant backend de la compagnie du manager courant.
  ///
  /// Contrat backend : `GET /api/companies/mine` retourne un objet compagnie
  /// unique pour le manager authentifié.
  ///
  /// En cas de `404` (profil manager sans compagnie), retourne `null`.
  /// Le repository décide alors (ex. [RestShowDateRepository.addShowDate] lève une erreur explicite).
  Future<String?> getMyCompanyId() async {
    try {
      final response = await _dio.get('/api/companies/mine');
      final data = response.data;

      Map<String, dynamic>? payload;
      if (data is Map<String, dynamic>) {
        payload = data;
      } else if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          payload = decoded;
        }
      }

      if (payload == null) return null;
      final companyId = payload['id'];
      if (companyId == null) return null;
      return companyId is num
          ? companyId.toInt().toString()
          : companyId.toString();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
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

  /// Supprime une date de spectacle via REST.
  ///
  /// DELETE `/api/show-dates/{id}`
  ///
  /// [showDateId] doit être un identifiant backend numérique.
  Future<void> deleteShowDate(String showDateId) async {
    final normalizedId = showDateId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('Identifiant de date vide.');
    }

    final idNum = int.tryParse(normalizedId);
    if (idNum == null) {
      throw FormatException(
        'Identifiant de date invalide pour REST: $showDateId',
      );
    }

    await _dio.delete<void>('/api/show-dates/$idNum');
  }

  /// Met à jour partiellement une date de spectacle via REST.
  ///
  /// PATCH `/api/show-dates/{id}`
  ///
  /// Convention backend :
  /// - champ envoyé non nul => mis à jour
  /// - champ absent => inchangé
  Future<void> updateShowDate({
    required String showDateId,
    DateTime? eventDate,
    int? meetingTimeMinutes,
    String? location,
    String? clientContactName,
    String? clientContactPhone,
    String? showDetails,
    ShowDateStatus? status,
  }) async {
    final normalizedId = showDateId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('Identifiant de date vide.');
    }

    final idNum = int.tryParse(normalizedId);
    if (idNum == null) {
      throw FormatException(
        'Identifiant de date invalide pour REST: $showDateId',
      );
    }

    final payload = <String, dynamic>{};
    if (eventDate != null) {
      payload['eventDate'] =
          '${eventDate.year.toString().padLeft(4, '0')}-'
          '${eventDate.month.toString().padLeft(2, '0')}-'
          '${eventDate.day.toString().padLeft(2, '0')}';
    }
    if (meetingTimeMinutes != null) {
      final hours = (meetingTimeMinutes ~/ 60).toString().padLeft(2, '0');
      final minutes = (meetingTimeMinutes % 60).toString().padLeft(2, '0');
      payload['meetingTime'] = '$hours:$minutes:00';
    }
    if (location != null) {
      payload['location'] = location.trim();
    }
    if (clientContactName != null) {
      payload['clientContactName'] = clientContactName.trim();
    }
    if (clientContactPhone != null) {
      payload['clientContactPhone'] = clientContactPhone.trim();
    }
    if (showDetails != null) {
      payload['showDetails'] = showDetails.trim();
    }
    if (status != null) {
      payload['status'] = _toApiShowDateStatus(status);
    }

    if (payload.isEmpty) {
      return;
    }

    await _dio.patch<void>(
      '/api/show-dates/$idNum',
      data: payload,
    );
  }

  static String _toApiShowDateStatus(ShowDateStatus status) {
    switch (status) {
      case ShowDateStatus.inquiry:
        return 'INQUIRY';
      case ShowDateStatus.option:
        return 'OPTION';
      case ShowDateStatus.confirmed:
        return 'CONFIRMED';
      case ShowDateStatus.staffed:
        return 'STAFFED';
      case ShowDateStatus.cancelled:
        return 'CANCELLED';
      case ShowDateStatus.archived:
        return 'ARCHIVED';
    }
  }
}
