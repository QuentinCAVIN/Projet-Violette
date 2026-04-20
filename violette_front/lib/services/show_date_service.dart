import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/repositories/show_date_repository.dart';

class FirestoreShowDateRepository implements ShowDateRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionName = "showDates";

  // Stockage en mémoir pour optimisation
  final List<ShowDate> showDates = [];

  CollectionReference<Map<String, dynamic>> get collection {
    // getter, quand je fais collection dans le code je récupére ma collection firestore issue de _db.collection(collectionName)
    return _db.collection(collectionName);
  }

  @override
  Future<List<ShowDate>> getAllShowDates() async {
    final snapshot = await collection.get();

    showDates.clear();
    for (var doc in snapshot.docs) {
      showDates.add(ShowDate.fromFirestore(doc,
          null)); // TODO question ELies -> c'est quoi le null (firebaseOption)
    }
    /*showDates
      ..clear()
      ..addAll(snapshot.docs.map(_fromDoc));*/ // autre écriture possible de la ligne du dessus
    return List<ShowDate>.unmodifiable(
        showDates); // On ne peut pas add ou remove mais on peux modifier le contenu
  }

  @override
  Future<ShowDate?> getShowDateById(String dateId) async {
    if (dateId.isEmpty) return null;

    final allShowDates = await getAllShowDates();
    for (final showDate in allShowDates) {
      if (showDate.uid == dateId) {
        return showDate;
      }
    }
    return null;
  }

  @override
  Future<void> addShowDate(ShowDate showDate) async {
    _db.collection(collectionName).add(showDate.toFirestore());
  }

  Future<void> addShowDateObscure(ShowDate showDate) async {
    // On utilise l’uid comme id de document
    await collection.doc(showDate.uid).set(showDate.toFirestore());
    showDates.add(showDate);
  }

  //Met à jour une ShowDate existante (même uid)
  @override
  Future<void> updateShowDate(ShowDate updated) async {
    await collection.doc(updated.uid).update(updated.toFirestore());

    final index = showDates.indexWhere((d) => d.uid == updated.uid);
    if (index != -1) {
      showDates[index] = updated;
    }
  }

  @override
  Future<void> deleteShowDate(String uid) async {
    await collection.doc(uid).delete();
    showDates.removeWhere((d) => d.uid == uid);
  }
}
