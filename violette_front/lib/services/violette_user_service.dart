import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/violette_user.dart';

class VioletteUserService {
  final _db = FirebaseFirestore.instance;
  final String collectionName = "users";

  Future<void> addUser(VioletteUser user) async {
    _db.collection(collectionName).doc(user.uid).set(user.toFirestore());
  }

  Future<VioletteUser?> getUser(String uid) async {
    final doc = await _db.collection(collectionName).doc(uid).get();

    if (!doc.exists) return null;

    final userData = doc
        .data(); ///////TODO: Question Elies: au final dans une DB SQL pas de nul possible, le test
    if (userData == null) return null; //

    return VioletteUser.fromFirestore(doc, null);
  }
}

//Doc Firebase:
//https://firebase.google.com/docs/firestore/query-data/get-data?hl=fr#get_a_document
