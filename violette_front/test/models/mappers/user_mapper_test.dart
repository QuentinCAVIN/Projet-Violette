import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:violette_api_client/violette_api_client.dart' as api;
import 'package:violette_front/models/enums/role.dart';
import 'package:violette_front/models/mappers/user_mapper.dart';
import 'package:violette_front/models/violette_user.dart';

void main() {
  group('UserMapper - Mapping DTO → profil utilisateur (fromDto)', () {
    test(
      'fromDto_whenDtoIsComplete_mapsFirebaseUidToUidAndCopiesIdentityFields',
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
      'fromDto_whenTextFieldsAreMissing_returnsEmptyStrings',
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
      'fromDto_whenRolesAreNull_returnsEmptyRoleList',
      () {
        final dto = api.VioletteUserDto(
          (b) => b..firebaseUid = 'u',
        );

        final user = UserMapper.fromDto(dto);

        expect(user.roles, isEmpty);
      },
    );

    test(
      'fromDto_whenRoleSetIsEmpty_returnsEmptyRoleList',
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
      'fromDto_whenRoleIsApiArtist_mapsToArtistRole',
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
      'fromDto_whenRoleIsApiManager_mapsToManagerRole',
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
      'fromDto_whenAnyDeclaredApiRole_neverThrowsAndIgnoresUnhandledRoles',
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
      'rolesToApi_whenRoleListIsEmpty_returnsEmptyApiSet',
      () {
        expect(UserMapper.rolesToApi(<Role>[]), isEmpty);
      },
    );

    test(
      'rolesToApi_whenArtistAndManagerRoles_mapsToApiArtistAndManager',
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
