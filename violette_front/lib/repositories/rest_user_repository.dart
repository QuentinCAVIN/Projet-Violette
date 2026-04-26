import 'package:dio/dio.dart';

import '../data/remote/user_remote_data_source.dart';
import '../models/mappers/user_mapper.dart';
import '../models/violette_user.dart';
import 'user_repository.dart';

/// Implémentation REST de [UserRepository].
///
/// Remplace [FirestoreUserRepository] sans modifier les ViewModels ni l'interface.
/// La bascule se fait dans app.dart en changeant une seule ligne de DI.
class RestUserRepository implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  /// [remoteDataSource] permet les tests avec mock ; sinon une instance par défaut.
  /// Stacked génère `RestUserRepository()` sans arguments.
  RestUserRepository({UserRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? UserRemoteDataSource();

  @override
  Future<VioletteUser?> getUser(String uid) async {
    final normalizedUid = uid.trim();
    if (normalizedUid.isEmpty) return null;

    try {
      final isBackendId = RegExp(r'^\d+$').hasMatch(normalizedUid);
      final dto = isBackendId
          ? await _remoteDataSource.getUserById(normalizedUid)
          : await _remoteDataSource.getMyProfile();
      if (dto == null) return null;
      return UserMapper.fromDto(dto);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> addUser(VioletteUser user) async {
    await _remoteDataSource.createUser(
      firstName: user.firstName,
      lastName: user.lastName,
      roles: UserMapper.rolesToApi(user.roles),
    );
  }
}
