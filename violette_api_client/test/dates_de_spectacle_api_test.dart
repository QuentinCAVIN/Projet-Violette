import 'package:test/test.dart';
import 'package:violette_api_client/violette_api_client.dart';


/// tests for DatesDeSpectacleApi
void main() {
  final instance = VioletteApiClient().getDatesDeSpectacleApi();

  group(DatesDeSpectacleApi, () {
    // Lister les dates d'une compagnie
    //
    // Retourne toutes les dates de spectacle d'une compagnie. Requiert le rôle MANAGER.
    //
    //Future<ShowDateDto> apiShowDatesCompanyCompanyIdGet(int companyId) async
    test('test apiShowDatesCompanyCompanyIdGet', () async {
      // TODO
    });

    // Lister toutes les dates de spectacle
    //
    // Retourne toutes les dates de spectacle, triées par date croissante. Requiert le rôle MANAGER.
    //
    //Future<ShowDateDto> apiShowDatesGet() async
    test('test apiShowDatesGet', () async {
      // TODO
    });

    // Récupérer une date par id
    //
    // Retourne le détail d'une date de spectacle. Requiert le rôle MANAGER.
    //
    //Future<ShowDateDto> apiShowDatesIdGet(int id) async
    test('test apiShowDatesIdGet', () async {
      // TODO
    });

    // Lister les besoins artistiques d'une date
    //
    // Retourne les besoins artistiques par compétence pour une date de spectacle. Requiert le rôle MANAGER.
    //
    //Future<ShowDateSkillRequirementDto> apiShowDatesIdSkillRequirementsGet(int id) async
    test('test apiShowDatesIdSkillRequirementsGet', () async {
      // TODO
    });

    // Ajouter un besoin artistique
    //
    // Ajoute un besoin artistique par compétence à une date de spectacle. Requiert le rôle MANAGER.
    //
    //Future<ShowDateSkillRequirementDto> apiShowDatesIdSkillRequirementsPost(int id, CreateSkillRequirementRequestDto createSkillRequirementRequestDto) async
    test('test apiShowDatesIdSkillRequirementsPost', () async {
      // TODO
    });

    // Créer une date de spectacle
    //
    // Crée une nouvelle date de spectacle pour une compagnie. Requiert le rôle MANAGER.
    //
    //Future<ShowDateDto> apiShowDatesPost(CreateShowDateRequestDto createShowDateRequestDto) async
    test('test apiShowDatesPost', () async {
      // TODO
    });

  });
}
