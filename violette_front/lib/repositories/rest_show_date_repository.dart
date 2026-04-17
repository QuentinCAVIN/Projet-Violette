import 'package:dio/dio.dart';
import 'package:violette_front/data/remote/show_date_remote_data_source.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/services/show_date_service.dart';

import 'show_date_repository.dart';

/// Implémentation REST de [ShowDateRepository].
///
/// Incrément transitoire :
/// - [getAllShowDates] bascule sur REST
/// - les autres méthodes conservent temporairement le comportement Firestore
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
  Future<void> addShowDate(ShowDate showDate) {
    return _legacyRepository.addShowDate(showDate);
  }

  @override
  Future<void> deleteShowDate(String uid) {
    return _legacyRepository.deleteShowDate(uid);
  }

  @override
  Future<void> updateAllShowDates(List<ShowDate> updatedList) {
    return _legacyRepository.updateAllShowDates(updatedList);
  }

  @override
  Future<void> updateShowDate(ShowDate updated) {
    return _legacyRepository.updateShowDate(updated);
  }

  @override
  Stream<ShowDate> watchShowDate(String dateId) {
    return _legacyRepository.watchShowDate(dateId);
  }
}
