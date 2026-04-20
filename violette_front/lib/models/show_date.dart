import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:violette_front/models/enums/show_date_status.dart';

//TODO Définir avec Agathe les champs qui doivent être obligatoire
class ShowDate {
  final String? uid;
  final String title;
  final DateTime date;
  final int startMinutes;
  final int endMinutes;
  final String address;
  final int artistsCount;
  final double fee;
  final String? description;
  final ShowDateStatus status;
  final int selectedCount;

  /// Nom du contact client — requis par le backend REST pour la création.
  /// Absent du modèle Firestore legacy (null si chargé via Firestore).
  final String? clientContactName;

  /// Téléphone du contact client — requis par le backend REST pour la création.
  /// Absent du modèle Firestore legacy (null si chargé via Firestore).
  final String? clientContactPhone;

  ShowDate({
    this.uid,
    required this.title,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    required this.address,
    required this.artistsCount,
    required this.fee,
    this.description,
    this.status = ShowDateStatus.inquiry, // Par défaut une date nouvellement créée
    this.selectedCount = 0,
    this.clientContactName,
    this.clientContactPhone,
  });

  factory ShowDate.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions?
        options, // Option trouvé dans la doc que je ne comprends pas, voir pour la supprimer
  ) {
    final data = snapshot.data()!;

    return ShowDate(
      uid: snapshot.id,
      title: data['title'],
      date: data['date'].toDate().toLocal(),
      startMinutes: data['startTime'],
      endMinutes: data['endTime'],
      address: data['address'],
      artistsCount: data['artistsCount'],
      fee: (data['fee']).toDouble(),
      description: data['description'],
      status: showDateStatusFromString(data['status'] ?? ''),
      selectedCount: data['selectedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "date": date,
      "startTime": startMinutes,
      "endTime": endMinutes,
      "address": address,
      "artistsCount": artistsCount,
      "fee": fee,
      "status": status.name,
      "selectedCount": selectedCount,
      if (description != null) "description": description,
    };
  }
}

extension ShowDateX on ShowDate {
  String get formattedDate => "${date.day}/${date.month}/${date.year}";

  String get formattedStartTime => _minutesToHHmm(startMinutes);
  String get formattedEndTime => _minutesToHHmm(endMinutes);

  /// Heure de rendez-vous / convocation à afficher, alignée sur le backend réel :
  /// l’API expose `eventDate` (jour du spectacle) et `meetingTime` (une seule
  /// heure, type `LocalTime`), sans heure de fin — ce n’est pas une plage
  /// horaire de représentation.
  ///
  /// Côté Flutter, `startMinutes` est dérivé de `meetingTime` ; `endMinutes`
  /// reste transitoire (ancien formulaire ou Firestore) et n’existe pas sur
  /// l’entité `ShowDateEntity`. On n’utilise donc pas `endMinutes` ici, pour
  /// éviter tout libellé suggérant une plage début/fin ou un doublon trompeur
  /// (ex. 09:00 – 09:00).
  String get formattedMeetingTimeForDisplay => formattedStartTime;
}

//TODO Reflechir si on laisse ici ou si on met dans un Helper a coté
String _minutesToHHmm(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
}

//TODO Le parser n'est pas utilisé, corriger ça au moment de la récupération et de l'affichage d'une date
int hourStringToMinutes(String value) {
  final parts = value.trim().split(':');
  final h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  return h * 60 + m;
}
