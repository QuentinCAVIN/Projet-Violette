import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/enums/role.dart';
// Généré par IA

void main() {
  group('Role - Mapping string → Role', () {
    test('roleFromString_whenValueIsArtist_returnsArtistRole', () {
      final result = roleFromString('artist');
      expect(result, Role.artist);
    });

    test('roleFromString_whenValueIsManager_returnsManagerRole', () {
      final result = roleFromString('manager');
      expect(result, Role.manager);
    });

    test('roleFromString_whenValueIsInvalid_throwsException', () {
      expect(
        () => roleFromString('invalid'),
        throwsA(isA<Exception>()),
      );
    });

    test('roleFromString_whenValueIsEmpty_throwsException', () {
      expect(
        () => roleFromString(''),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Role - Libellés d\'affichage', () {
    test('label_whenRoleIsArtist_returnsArtisteLabel', () {
      expect(Role.artist.label, 'Artiste');
    });

    test('label_whenRoleIsManager_returnsGerantLabel', () {
      expect(Role.manager.label, 'Gérant');
    });
  });

  group('Role - Sérialisation enum vers string', () {
    test('name_whenRoleIsArtist_returnsArtistString', () {
      expect(Role.artist.name, 'artist');
    });

    test('name_whenRoleIsManager_returnsManagerString', () {
      expect(Role.manager.name, 'manager');
    });
  });
}
