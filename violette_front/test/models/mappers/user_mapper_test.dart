import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:violette_api_client/violette_api_client.dart' as api;
import 'package:violette_front/models/enums/role.dart';
import 'package:violette_front/models/mappers/user_mapper.dart';
import 'package:violette_front/models/violette_user.dart';

void main() {
  group('UserMapper - Mapping DTO → profil utilisateur (fromDto)', () {
    test(
      'DTO complet devrait mapper firebaseUid vers uid et recopier prénom, nom, email et rôles',
      () {
        final dto = api.VioletteUserDto(
          (b) => b
            ..id = 42
            ..firebaseUid = 'firebase-uid-abc'
            ..firstName = 'Ada'
            ..lastName = 'Lovelace'
            ..email = 'ada@example.com'
            ..roles.replace(
              BuiltSet<api.UserRole>(<api.UserRole>[
                api.UserRole.ARTIST,
                api.UserRole.MANAGER,
              ]),
            ),
        );

        final user = UserMapper.fromDto(dto);

        expect(user.uid, 'firebase-uid-abc');
        expect(user.firstName, 'Ada');
        expect(user.lastName, 'Lovelace');
        expect(user.email, 'ada@example.com');
        expect(user.roles.toSet(), {Role.artist, Role.manager});
      },
    );

    test(
      'Champs texte absents du DTO devraient utiliser des chaînes vides (uid, prénom, nom, email)',
      () {
        final dto = api.VioletteUserDto((b) => b);

        final user = UserMapper.fromDto(dto);

        expect(user.uid, '');
        expect(user.firstName, '');
        expect(user.lastName, '');
        expect(user.email, '');
      },
    );

    test(
      'Rôles null sur le DTO devraient retourner une liste de rôles métier vide',
      () {
        final dto = api.VioletteUserDto(
          (b) => b..firebaseUid = 'u',
        );

        final user = UserMapper.fromDto(dto);

        expect(user.roles, isEmpty);
      },
    );

    test(
      'Ensemble de rôles vide sur le DTO devrait retourner une liste de rôles métier vide',
      () {
        final dto = api.VioletteUserDto(
          (b) => b
            ..firebaseUid = 'u'
            ..roles.replace(BuiltSet<api.UserRole>()),
        );

        final user = UserMapper.fromDto(dto);

        expect(user.roles, isEmpty);
      },
    );

    test(
      'UserRole ARTIST du DTO devrait mapper vers Role.artist',
      () {
        final dto = api.VioletteUserDto(
          (b) => b
            ..firebaseUid = 'u'
            ..roles.replace(BuiltSet<api.UserRole>(<api.UserRole>[api.UserRole.ARTIST])),
        );

        expect(UserMapper.fromDto(dto).roles, [Role.artist]);
      },
    );

    test(
      'UserRole MANAGER du DTO devrait mapper vers Role.manager',
      () {
        final dto = api.VioletteUserDto(
          (b) => b
            ..firebaseUid = 'u'
            ..roles.replace(BuiltSet<api.UserRole>(<api.UserRole>[api.UserRole.MANAGER])),
        );

        expect(UserMapper.fromDto(dto).roles, [Role.manager]);
      },
    );

    test(
      'Chaque valeur UserRole déclarée par le client API ne devrait pas lever d’exception ; '
      'ARTIST et MANAGER devraient mapper ; un rôle futur non géré devrait être ignoré',
      () {
        for (final apiRole in api.UserRole.values) {
          final dto = api.VioletteUserDto(
            (b) => b
              ..firebaseUid = 'uid'
              ..roles.replace(BuiltSet<api.UserRole>(<api.UserRole>[apiRole])),
          );

          late final VioletteUser user;
          expect(() => user = UserMapper.fromDto(dto), returnsNormally);

          if (apiRole == api.UserRole.ARTIST) {
            expect(user.roles, [Role.artist]);
          } else if (apiRole == api.UserRole.MANAGER) {
            expect(user.roles, [Role.manager]);
          } else {
            expect(
              user.roles,
              isEmpty,
              reason:
                  'Une valeur UserRole ajoutée au client OpenAPI sans branche '
                  'correspondante dans UserMapper doit être ignorée sans lever '
                  'd\'exception.',
            );
          }
        }
      },
    );
  });

  group('UserMapper - Mapping rôles métier → DTO API (rolesToApi)', () {
    test(
      'Liste de rôles métier vide devrait retourner un BuiltSet API vide',
      () {
        expect(UserMapper.rolesToApi(<Role>[]), isEmpty);
      },
    );

    test(
      'Role.artist et Role.manager devraient mapper vers UserRole.ARTIST et UserRole.MANAGER',
      () {
        expect(
          UserMapper.rolesToApi(<Role>[Role.artist, Role.manager]),
          equals(
            BuiltSet<api.UserRole>(
              <api.UserRole>[api.UserRole.ARTIST, api.UserRole.MANAGER],
            ),
          ),
        );
      },
    );
  });
}
