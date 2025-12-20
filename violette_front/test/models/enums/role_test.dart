import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/enums/role.dart';
// Généré par IA

void main() {
  group('Role - Mapping string → Role', () {
    test('"artist" devrait mapper vers Role.artist', () {
      final result = roleFromString('artist');
      expect(result, Role.artist);
    });

    test('"manager" devrait mapper vers Role.manager', () {
      final result = roleFromString('manager');
      expect(result, Role.manager);
    });

    test('valeur invalide devrait lancer une exception', () {
      expect(
        () => roleFromString('invalid'),
        throwsA(isA<Exception>()),
      );
    });

    test('chaîne vide devrait lancer une exception', () {
      expect(
        () => roleFromString(''),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Role - Labels', () {
    test('Role.artist devrait avoir le label "Artiste"', () {
      expect(Role.artist.label, 'Artiste');
    });

    test('Role.manager devrait avoir le label "Gérant"', () {
      expect(Role.manager.label, 'Gérant');
    });
  });

  group('Role - Serialization (enum → string)', () {
    test('Role.artist.name devrait retourner "artist"', () {
      expect(Role.artist.name, 'artist');
    });

    test('Role.manager.name devrait retourner "manager"', () {
      expect(Role.manager.name, 'manager');
    });
  });
}
