import 'package:test/test.dart';
import 'package:violette_api_client/violette_api_client.dart';


/// tests for CompagniesApi
void main() {
  final instance = VioletteApiClient().getCompagniesApi();

  group(CompagniesApi, () {
    // Récupérer une compagnie par id
    //
    // Retourne le détail d'une compagnie. Requiert le rôle MANAGER.
    //
    //Future<CabaretCompanyDto> apiCompaniesIdGet(int id) async
    test('test apiCompaniesIdGet', () async {
      // TODO
    });

    // Lister les membres d'une compagnie
    //
    // Retourne les artistes membres d'une compagnie. Requiert le rôle MANAGER.
    //
    //Future<CompanyMemberDto> apiCompaniesIdMembersGet(int id) async
    test('test apiCompaniesIdMembersGet', () async {
      // TODO
    });

    // Lister les revues d'une compagnie
    //
    // Retourne les revues d'une compagnie. Requiert le rôle MANAGER.
    //
    //Future<CabaretShowDto> apiCompaniesIdShowsGet(int id) async
    test('test apiCompaniesIdShowsGet', () async {
      // TODO
    });

  });
}
