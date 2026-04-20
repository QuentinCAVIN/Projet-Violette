import 'package:dio/dio.dart';
import 'package:violette_front/data/remote/show_date_remote_data_source.dart';
import 'package:violette_front/models/show_date.dart';

import 'show_date_repository.dart';

/// Implémentation [ShowDateRepository] exclusivement via le backend REST.
class RestShowDateRepository implements ShowDateRepository {
  final ShowDateRemoteDataSource _remoteDataSource;

  RestShowDateRepository({
    ShowDateRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? ShowDateRemoteDataSource();

  @override
  Future<List<ShowDate>> getAllShowDates() async {
    return _remoteDataSource.getAllShowDates();
  }

  @override
  Future<ShowDate?> getShowDateById(String dateId) async {
    if (dateId.isEmpty) return null;
    return _remoteDataSource.getShowDateById(dateId);
  }

  @override
  Future<void> addShowDate(ShowDate showDate) async {
    final companyId = await _remoteDataSource.getMyCompanyId();
    if (companyId == null) {
      throw StateError(
        'Impossible de créer une date : aucune compagnie associée au profil '
        'manager (réponse vide ou 404 sur GET /api/companies/mine).',
      );
    }

    await _remoteDataSource.createShowDate(
      companyId: companyId,
      eventDate: showDate.date,
      meetingTimeMinutes: showDate.meetingTimeMinutes,
      location: showDate.address,
      clientContactName: showDate.clientContactName?.trim().isNotEmpty == true
          ? showDate.clientContactName!
          : 'À compléter',
      clientContactPhone:
          showDate.clientContactPhone?.trim().isNotEmpty == true
              ? showDate.clientContactPhone!
              : '0000000000',
      showDetails: showDate.description,
    );
  }

  /// Suppression via REST. Une réponse 404 est ignorée (ressource déjà absente).
  @override
  Future<void> deleteShowDate(String uid) async {
    final normalizedUid = uid.trim();
    if (normalizedUid.isEmpty) {
      throw ArgumentError('Identifiant de date vide.');
    }

    try {
      await _remoteDataSource.deleteShowDate(normalizedUid);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> updateShowDate(ShowDate updated) async {
    final normalizedUid = updated.id.trim();
    if (normalizedUid.isEmpty) {
      throw ArgumentError('Identifiant de date vide.');
    }

    await _remoteDataSource.updateShowDate(
      showDateId: normalizedUid,
      eventDate: updated.date,
      meetingTimeMinutes: updated.meetingTimeMinutes,
      location: updated.address,
      clientContactName: updated.clientContactName,
      clientContactPhone: updated.clientContactPhone,
      showDetails: updated.description,
    );
  }
}
