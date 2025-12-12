import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/enums/availability_status.dart';

class ShowDateService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionName = "show_date";

  // Stockage en mémoir pour optimisation
  final List<ShowDate> showDates = [];

  CollectionReference<Map<String, dynamic>> get collection {
    return _db.collection(collectionName);
  }

  Future<List<ShowDate>> getAllShowDates() async {
    final snapshot = await collection.get();

    showDates.clear();
    snapshot.docs.forEach((doc) {
      showDates.add(ShowDate.fromFirestore(doc,
          null)); // TODO question ELies -> c'est quoi le null (firebaseOption)
    });
    /*showDates
      ..clear()
      ..addAll(snapshot.docs.map(_fromDoc));*/ // autre écriture possible de la ligne du dessus
    return List<ShowDate>.unmodifiable(
        showDates); // On ne peut pas add ou remove mais on peux modifier le contenu
  }

  Future<void> updateAllShowDates(List<ShowDate> updatedList) async {
    final batch = _db.batch(); // Write Batch = panier d'opération Firestore

    for (final showDates in updatedList) {
      final docRef = collection.doc(showDates.uid);
      batch.update(docRef, _toMap(showDates));
    }
    await batch.commit();
    //Mise a jour du cache local
    showDates
      ..clear()
      ..addAll(updatedList);
  }

  //TODO implémenter une methode toFirebase sur SHowDate
  Future<void> addShowDate(ShowDate showDate) async {
    _db.collection(collectionName).add({
      "date": showDate.date,
      "availability_status": showDate.availabilityStatus.name,
    });
  }

//****************************************************************************//
// CI DESSOUS -> code mort gardé pour exemple en temps voulu
//****************************************************************************//
  Stream<List<ShowDate>> watchShowDates() {
    return collection.snapshots().map(
          (snapshot) => snapshot.docs.map(_fromDoc).toList(),
        );
  }

  Future<void> addShowDateObscure(ShowDate showDate) async {
    // On utilise l’uid comme id de document
    await collection.doc(showDate.uid).set(_toMap(showDate));
    showDates.add(showDate);
  }

  /// Met à jour une ShowDate existante (même uid)
  Future<void> updateShowDate(ShowDate updated) async {
    await collection.doc(updated.uid).update(_toMap(updated));

    final index = showDates.indexWhere((d) => d.uid == updated.uid);
    if (index != -1) {
      showDates[index] = updated;
    }
  }

  Future<void> deleteShowDate(String uid) async {
    await collection.doc(uid).delete();
    showDates.removeWhere((d) => d.uid == uid);
  }

//****************************************************************************//
// HELPERS
//****************************************************************************//
  ShowDate _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return ShowDate(
      uid: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      availabilityStatus: AvailabilityStatus.values.firstWhere(
        (e) => e.name == data['availabilityStatus'],
      ),
    );
  }

  Map<String, dynamic> _toMap(ShowDate showDate) {
    return {
      'date': Timestamp.fromDate(showDate.date),
      'availability_status': showDate.availabilityStatus.name,
    };
  }
}
