import 'package:dio/dio.dart';
import 'package:violette_front/data/remote/show_date_remote_data_source.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/services/show_date_service.dart';

import 'show_date_repository.dart';

/// Implémentation REST de [ShowDateRepository].
///
/// Incrément transitoire :
/// - [getAllShowDates] bascule sur REST
/// - [addShowDate], [deleteShowDate] et [updateShowDate] sont branchées REST
/// - [updateAllShowDates] conserve temporairement le comportement Firestore
///   pour ne pas impacter les écrans hors périmètre de cet incrément.
class RestShowDateRepository implements ShowDateRepository {
  final ShowDateRemoteDataSource _remoteDataSource;
  final FirestoreShowDateRepository _legacyRepository;

  RestShowDateRepository({
    ShowDateRemoteDataSource? remoteDataSource,
    FirestoreShowDateRepository? legacyRepository,
  })  : _remoteDataSource = remoteDataSource ?? ShowDateRemoteDataSource(),
        _legacyRepository = legacyRepository ?? FirestoreShowDateRepository();

  @override
  Future<List<ShowDate>> getAllShowDates() async {
    try {
      return await _remoteDataSource.getAllShowDates();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ShowDate?> getShowDateById(String dateId) async {
    if (dateId.isEmpty) return null;

    try {
      final remoteShowDate = await _remoteDataSource.getShowDateById(dateId);
      if (remoteShowDate != null) {
        return remoteShowDate;
      }
      // Compatibilité transitoire : fallback legacy si la date n'existe pas côté REST.
      return _legacyRepository.getShowDateById(dateId);
    } on DioException catch (e) {
      // 401/403/5xx : fallback défensif pour conserver l'écran fonctionnel durant la migration.
      if (e.response?.statusCode != 404) {
        return _legacyRepository.getShowDateById(dateId);
      }
      return null;
    }
  }

  /// Crée une date de spectacle via REST, avec fallback Firestore.
  ///
  /// ## Stratégie transitoire
  ///
  /// Le backend expose désormais `GET /api/companies/mine` pour résoudre
  /// la compagnie métier du manager courant.
  ///
  /// Fallbacks Firestore déclenchés :
  /// - si `/api/companies/mine` répond `404` (manager sans compagnie)
  /// - si le `companyId` est non résolvable dans la réponse
  /// - si la requête REST échoue (erreur réseau, 4xx, 5xx)
  @override
  Future<void> addShowDate(ShowDate showDate) async {
    String? companyId;
    try {
      companyId = await _remoteDataSource.getMyCompanyId();
    } on DioException {
      companyId = null;
    }

    if (companyId == null) {
      // Fallback défensif : compagnie manager introuvable/non résolvable.
      return _legacyRepository.addShowDate(showDate);
    }

    try {
      await _remoteDataSource.createShowDate(
        companyId: companyId,
        eventDate: showDate.date,
        meetingTimeMinutes: showDate.startMinutes,
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
    } on DioException {
      // Fallback défensif : toute erreur HTTP bascule sur Firestore.
      return _legacyRepository.addShowDate(showDate);
    }
  }

  /// Supprime une date via REST si l'uid est un id backend numérique.
  ///
  /// Fallback legacy conservé uniquement pour la transition :
  /// - uid non numérique (anciennes données Firestore)
  /// - backend répond 404 (date absente côté SQL mais potentiellement présente côté Firestore)
  @override
  Future<void> deleteShowDate(String uid) async {
    final normalizedUid = uid.trim();
    if (normalizedUid.isEmpty) {
      throw ArgumentError('Identifiant de date vide.');
    }

    final backendId = int.tryParse(normalizedUid);
    if (backendId == null) {
      return _legacyRepository.deleteShowDate(uid);
    }

    try {
      await _remoteDataSource.deleteShowDate(normalizedUid);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _legacyRepository.deleteShowDate(uid);
      }
      rethrow;
    }
  }

  /// @deprecated : aucun endpoint backend de mise à jour batch.
  /// Délègue au repository Firestore legacy.
  @override
  Future<void> updateAllShowDates(List<ShowDate> updatedList) {
    return _legacyRepository.updateAllShowDates(updatedList);
  }

  /// Mise à jour unitaire : désormais branchée sur REST (`PATCH /api/show-dates/{id}`).
  ///
  /// Fallback legacy conservé uniquement pour les uid non numériques
  /// (documents Firestore historiques).
  @override
  Future<void> updateShowDate(ShowDate updated) async {
    final normalizedUid = (updated.uid ?? '').trim();
    if (normalizedUid.isEmpty) {
      throw ArgumentError('Identifiant de date vide.');
    }

    final backendId = int.tryParse(normalizedUid);
    if (backendId == null) {
      return _legacyRepository.updateShowDate(updated);
    }

    await _remoteDataSource.updateShowDate(
      showDateId: normalizedUid,
      eventDate: updated.date,
      meetingTimeMinutes: updated.startMinutes,
      location: updated.address,
      clientContactName: updated.clientContactName,
      clientContactPhone: updated.clientContactPhone,
      showDetails: updated.description,
    );
  }

  /// @deprecated : délègue au repository Firestore legacy.
  /// Ne pas introduire de nouveaux usages de cette méthode.
  /// Utiliser [getShowDateById] à la place dans tout nouveau code (migration booking incluse).
  @override
  // ignore: deprecated_member_use_from_same_package
  Stream<ShowDate> watchShowDate(String dateId) {
    return _legacyRepository.watchShowDate(dateId);
  }
}
