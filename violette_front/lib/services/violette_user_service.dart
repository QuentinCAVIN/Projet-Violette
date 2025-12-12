import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/violette_user.dart';

class VioletteUserService {
  final _db = FirebaseFirestore.instance;
  final String collectionName = "users";

  Future<void> addUser(VioletteUser user) async {
    _db.collection(collectionName).doc(user.uid).set(user.toFirestore());
    print(
        "${user.firstName} ${user.lastName} adresse mail:${user.email} avec l'uid: ${user.uid} et le role ${user.roles[0]} a bien été ajouté au Firestore");
  }

  Future<VioletteUser?> getUser(String uid) async {
    final doc = await _db.collection(collectionName).doc(uid).get();

    if (!doc.exists) return null;

    final userData = doc.data(); ///////TODO: Question Elies: au final dans une DB SQL pas de nul possible, el test
    if (userData == null) return null; //

    return VioletteUser.fromFirestore(doc,null);
  }
}

//Doc Firebase:
//https://firebase.google.com/docs/firestore/query-data/get-data?hl=fr#get_a_document
