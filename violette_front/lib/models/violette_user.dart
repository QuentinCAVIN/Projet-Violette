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
