import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:violette_front/models/availability_status.dart';

class ShowDate {
  final String? uid;
  final DateTime date;
  AvailabilityStatus availabilityStatus;

  //TODO A rajouter plus tard:
  //La feuille de route de la date, le type d'artiste a qui elle est déstiné (chanteur, danseur)

  ShowDate({
    this.uid,
    required this.date,
    required this.availabilityStatus,
  });

  // TODO Question ELies, cela m'oblige a changer ma methode le jour ou je change de DB
  factory ShowDate.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ShowDate(
        uid: snapshot.id,
        date: data!['date'].toDate(),
        availabilityStatus: availabilityStatusFromString(
            data['availability_status'].toString()));
  }
  //récupéré tel quel de la doc : à adapter
//https://firebase.google.com/docs/firestore/query-data/get-data?hl=fr

  /* Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (state != null) "state": state,
      if (country != null) "country": country,
      if (capital != null) "capital": capital,
      if (population != null) "population": population,
      if (regions != null) "regions": regions,
    };
  }
}*/
}
