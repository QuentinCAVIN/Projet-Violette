import 'package:built_collection/built_collection.dart';
import 'package:violette_api_client/violette_api_client.dart';

import '../../core/network/dio_client.dart';

/// Source de données distante pour le domaine utilisateur.
///
/// Encapsule complètement [UtilisateursApi] (code généré).
/// Aucun autre fichier du projet Flutter ne doit importer directement [UtilisateursApi].
class UserRemoteDataSource {
  late final UtilisateursApi _api;

  UserRemoteDataSource() {
    _api = UtilisateursApi(DioClient.create(), standardSerializers);
  }

  /// Récupère le profil complet de l'utilisateur authentifié courant.
  ///
  /// Appelle GET /api/users/me/profile.
  /// Retourne null si l'utilisateur n'a pas encore de profil backend (404).
  Future<VioletteUserDto?> getMyProfile() async {
    final response = await _api.apiUsersMeProfileGet();
    return response.data;
  }

  /// Crée le profil backend de l'utilisateur authentifié courant.
  ///
  /// Appelle POST /api/users.
  /// Le firebaseUid et l'email sont extraits automatiquement du JWT par le backend.
  Future<VioletteUserDto> createUser({
    required String firstName,
    required String lastName,
    required BuiltSet<UserRole> roles,
  }) async {
    final request = CreateUserRequestDto(
      (b) => b
        ..firstName = firstName
        ..lastName = lastName
        ..roles = roles.toBuilder(),
    );

    final response = await _api.apiUsersPost(createUserRequestDto: request);

    if (response.data == null) {
      throw Exception(
        'Réponse vide du backend lors de la création du profil utilisateur.',
      );
    }

    return response.data!;
  }
}
