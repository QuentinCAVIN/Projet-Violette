enum Role {
  artist, //TODO différencier plus tard le role artiste : chanteur, danseur , echassier , musicien, performeur , comédien
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
