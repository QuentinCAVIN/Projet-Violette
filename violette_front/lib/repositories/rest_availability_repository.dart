import 'package:dio/dio.dart';

import 'package:violette_front/data/remote/availability_remote_data_source.dart';
import 'package:violette_front/models/availability.dart';
import 'package:violette_front/models/enums/availability_status.dart';

import 'availability_repository.dart';

/// Implémentation REST de [AvailabilityRepository].
///
/// Suit le même pattern que [RestUserRepository] : les ViewModels ne voient
/// que l'interface, jamais les détails HTTP ou les DTO backend.
class RestAvailabilityRepository implements AvailabilityRepository {
  final AvailabilityRemoteDataSource _remoteDataSource;

  RestAvailabilityRepository({AvailabilityRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? AvailabilityRemoteDataSource();

  @override
  Future<List<Availability>> getAvailabilitiesForDate(
    String showDateId,
  ) async {
    try {
      return await _remoteDataSource.getAvailabilitiesForDate(showDateId);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> upsertMyAvailability({
    required String showDateId,
    required AvailabilityStatus status,
  }) async {
    final availability = Availability(
      artistId: '', // résolu côté backend via le JWT Firebase
      status: status,
    );

    try {
      await _remoteDataSource.upsertMyAvailability(showDateId, availability);
    } on DioException {
      rethrow;
    }
  }
}

