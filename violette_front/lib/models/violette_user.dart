import 'enums/role.dart';

class VioletteUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final List<Role> roles;

  VioletteUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.roles,
  });
}
// TODO Poser la question a ELies sur l'emplacement de l'enum ROle qui ne sert que pour User
// Felix -> Ne pas placer dans User pour faciliter la testabilité en appellant User.getRole == Role.mescouilles
// François ->

// Enum
