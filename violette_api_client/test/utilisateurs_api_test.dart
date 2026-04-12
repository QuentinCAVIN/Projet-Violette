import 'package:test/test.dart';
import 'package:violette_api_client/violette_api_client.dart';


/// tests for UtilisateursApi
void main() {
  final instance = VioletteApiClient().getUtilisateursApi();

  group(UtilisateursApi, () {
    // Récupérer un utilisateur par Firebase UID
    //
    // Retourne le profil utilisateur par Firebase UID. Requiert le rôle MANAGER.
    //
    //Future<VioletteUserDto> apiUsersByFirebaseFirebaseUidGet(String firebaseUid) async
    test('test apiUsersByFirebaseFirebaseUidGet', () async {
      // TODO
    });

    // Lister les utilisateurs (pagination)
    //
    // Retourne la liste paginée des utilisateurs, triée par createdAt DESC. Requiert le rôle MANAGER.
    //
    //Future<VioletteUserDto> apiUsersGet({ int page, int size }) async
    test('test apiUsersGet', () async {
      // TODO
    });

    // Récupérer un utilisateur par identifiant
    //
    // Retourne le profil utilisateur par identifiant. Requiert le rôle MANAGER.
    //
    //Future<VioletteUserDto> apiUsersIdGet(int id) async
    test('test apiUsersIdGet', () async {
      // TODO
    });

    // Contexte de l'utilisateur courant
    //
    // Retourne les informations de l'utilisateur authentifié depuis le JWT (firebaseUid, email, nom).
    //
    //Future<AuthenticatedUserDto> apiUsersMeGet() async
    test('test apiUsersMeGet', () async {
      // TODO
    });

    // Profil complet de l'utilisateur courant
    //
    // Retourne le profil backend complet (firstName, lastName, rôles, compétences) de l'utilisateur authentifié. Accessible à tout utilisateur ayant un profil backend créé.
    //
    //Future<VioletteUserDto> apiUsersMeProfileGet() async
    test('test apiUsersMeProfileGet', () async {
      // TODO
    });

    // Créer un profil utilisateur
    //
    // Crée un profil utilisateur backend à partir du JWT (firebaseUid, email) et du corps de requête (firstName, lastName, roles).
    //
    //Future<VioletteUserDto> apiUsersPost(CreateUserRequestDto createUserRequestDto) async
    test('test apiUsersPost', () async {
      // TODO
    });

  });
}
