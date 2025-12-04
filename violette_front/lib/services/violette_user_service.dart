import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/violette_user.dart';


class VioletteUserService {
 final _db = FirebaseFirestore.instance;
 final String collection = "users";


  Future<void> addUser(VioletteUser user) async {

    _db.collection(collection).doc(user.uid).set(
        {
          "firstName": user.firstName,
          "lastName": user.lastName,
          "email":user.email
        }
    );
    print ("${user.firstName} ${user.lastName} adresse mail:${user.email} avec l'uid: ${user.uid} a bien été ajouté au Firestore");
  }

 Future<VioletteUser?> getUser(String uid) async {
   final doc = await _db.collection(collection).doc(uid).get();

   if (!doc.exists) return null;

   final userData = doc.data(); ///////TODO: Question Elies: au final dans une DB SQL pas de nul possible
   if (userData == null) return null;//

   return VioletteUser(
       uid: doc.id,
       firstName: userData["firstName"],
       lastName: userData["lastName"],
       email: userData ["email"]
   );
 }
}


//Doc Firebase:
//https://firebase.google.com/docs/firestore/query-data/get-data?hl=fr#get_a_document