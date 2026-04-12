import 'package:test/test.dart';
import 'package:violette_api_client/violette_api_client.dart';


/// tests for SantApi
void main() {
  final instance = VioletteApiClient().getSantApi();

  group(SantApi, () {
    // Vérifie que l'application est démarrée
    //
    // Retourne le statut et la version du backend Violette.
    //
    //Future<JsonObject> apiPingGet() async
    test('test apiPingGet', () async {
      // TODO
    });

  });
}
