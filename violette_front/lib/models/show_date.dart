import 'package:violette_front/models/enums/show_date_status.dart';

/// Date de spectacle côté app, calquée sur le [ShowDateDto] REST.
///
/// Les champs correspondent aux données persistées côté API ou saisies pour
/// la création (sans champ « cachet » ni autre donnée non exposée par le backend).
class ShowDate {
  /// Identifiant backend (champ JSON `id`). Chaîne vide si non encore persisté.
  final String id;

  /// `displayTitle` / `cabaretShowTitle` côté API.
  final String title;

  /// `eventDate` (jour local).
  final DateTime date;

  /// Représentation interne de `meetingTime` en minutes depuis minuit.
  /// Exemple : `08:30:00` côté API devient `510`.
  final int meetingTimeMinutes;

  /// `location`.
  final String address;

  /// `totalRequiredArtists`.
  final int totalRequiredArtists;

  /// `showDetails`.
  final String? description;

  /// Statut métier (`INQUIRY`, `OPTION`, etc.).
  final ShowDateStatus status;

  /// `selectedCount`.
  final int selectedCount;

  /// `clientContactName` — requis à la création REST.
  final String? clientContactName;

  /// `clientContactPhone` — requis à la création REST.
  final String? clientContactPhone;

  ShowDate({
    this.id = '',
    required this.title,
    required this.date,
    required this.meetingTimeMinutes,
    required this.address,
    required this.totalRequiredArtists,
    this.description,
    this.status = ShowDateStatus.inquiry,
    this.selectedCount = 0,
    this.clientContactName,
    this.clientContactPhone,
  });
}

extension ShowDateX on ShowDate {
  String get formattedDate => "${date.day}/${date.month}/${date.year}";

  String get formattedMeetingTime => _minutesToHHmm(meetingTimeMinutes);

  /// Affichage de l'heure de convocation (champ unique `meetingTime` côté API).
  String get formattedMeetingTimeForDisplay => formattedMeetingTime;
}

String _minutesToHHmm(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
}

int hourStringToMinutes(String value) {
  final parts = value.trim().split(':');
  final h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  return h * 60 + m;
}
