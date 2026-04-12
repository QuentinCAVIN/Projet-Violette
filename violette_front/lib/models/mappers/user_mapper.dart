import 'package:built_collection/built_collection.dart';
import 'package:violette_api_client/violette_api_client.dart' as api;

import 'package:violette_front/models/enums/role.dart';
import 'package:violette_front/models/violette_user.dart';

/// Convertit les types générés par OpenAPI (built_value) vers les modèles métier Flutter,
/// et inversement pour les requêtes sortantes.
///
/// Isolation : seul ce fichier a connaissance des types générés du package violette_api_client.
class UserMapper {
  UserMapper._();

  /// Convertit un [VioletteUserDto] généré vers le modèle métier [VioletteUser].
  static VioletteUser fromDto(api.VioletteUserDto dto) {
    return VioletteUser(
      uid: dto.firebaseUid ?? '',
      firstName: dto.firstName ?? '',
      lastName: dto.lastName ?? '',
      email: dto.email ?? '',
      roles: _mapRolesToDomain(dto.roles),
    );
  }

  /// Convertit la liste de rôles métier Flutter en [BuiltSet<api.UserRole>] pour les requêtes REST.
  static BuiltSet<api.UserRole> rolesToApi(List<Role> roles) {
    return BuiltSet(roles.map(_roleToApi).whereType<api.UserRole>());
  }

  static List<Role> _mapRolesToDomain(BuiltSet<api.UserRole>? apiRoles) {
    if (apiRoles == null) return [];
    return apiRoles.map(_roleToDomain).whereType<Role>().toList();
  }

  static Role? _roleToDomain(api.UserRole apiRole) {
    if (apiRole == api.UserRole.ARTIST) return Role.artist;
    if (apiRole == api.UserRole.MANAGER) return Role.manager;
    // Rôle inconnu : ignoré silencieusement (compatibilité ascendante)
    return null;
  }

  static api.UserRole? _roleToApi(Role role) {
    switch (role) {
      case Role.artist:
        return api.UserRole.ARTIST;
      case Role.manager:
        return api.UserRole.MANAGER;
    }
  }
}
