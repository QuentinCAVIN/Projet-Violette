import 'package:cloud_firestore/cloud_firestore.dart';

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

//****************************************************************************//
//Fonctions Mapping Firestore                                                 //
//****************************************************************************//
  Map<String, dynamic> toFirestore() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "roles": roles.map((role) => role.name).toList(),
    };
  }
  // TODO REFACTO à faire
  factory VioletteUser.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return VioletteUser(
        uid: snapshot.id,
        firstName: data!['firstName'],
        lastName: data['lastName'],
        email: data['email'],
        roles: (data['roles'] as Iterable<dynamic>).map((e) => roleFromString(e.toString())).toList(), // François
    );

  }
}
// TODO Poser la question a ELies sur l'emplacement de l'enum ROle qui ne sert que pour User
// Felix -> Ne pas placer dans User pour faciliter la testabilité en appellant User.getRole == Role.mescouilles
// François ->



// Enum
