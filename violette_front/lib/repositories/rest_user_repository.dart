import 'package:dio/dio.dart';

import '../data/remote/user_remote_data_source.dart';
import '../models/mappers/user_mapper.dart';
import '../models/violette_user.dart';
import 'user_repository.dart';

/// Implémentation REST de [UserRepository].
///
/// Remplace [FirestoreUserRepository] sans modifier les ViewModels ni l'interface.
/// La bascule se fait dans app.dart en changeant une seule ligne de DI.
///
/// Limitation actuelle (POC) :
/// [getUser] ignore le paramètre [uid] et retourne toujours le profil de
/// l'utilisateur authentifié courant via GET /api/users/me/profile.
/// Pour les cas MANAGER (consulter un autre utilisateur), un endpoint dédié
/// sera nécessaire dans une prochaine itération.
class RestUserRepository implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  /// [remoteDataSource] permet les tests avec mock ; sinon une instance par défaut.
  /// Stacked génère `RestUserRepository()` sans arguments.
  RestUserRepository({UserRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? UserRemoteDataSource();

  @override
  Future<VioletteUser?> getUser(String uid) async {
    try {
      final dto = await _remoteDataSource.getMyProfile();
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
