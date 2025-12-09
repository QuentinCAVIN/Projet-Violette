import 'package:violette_front/models/availability_status.dart';

class ShowDate {
  final String uid;
  final DateTime date;
  AvailabilityStatus availabilityStatus;
  //TODO A rajouter plus tard:
  //La feuille de route de la date, le type d'artiste a qui elle est déstiné (chanteur, danseur)

  ShowDate({
    required this.uid,
    required this.date,
    required this.availabilityStatus,
  });
}
