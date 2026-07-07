enum Role {
  // DETTE-16 : différencier les sous-types artiste (chanteur, danseur, échassier, etc.)
  artist,
  manager,
}

extension RoleX on Role {
  String get label {
    switch (this) {
      case Role.artist:
        return 'Artiste';
      case Role.manager:
        return 'Gérant';
    }
  }
}

Role roleFromString(String value) {
  switch (value) {
    case 'artist':
      return Role.artist;
    case 'manager':
      return Role.manager;
    default:
      throw Exception('Unknown role: $value');
  }
}
