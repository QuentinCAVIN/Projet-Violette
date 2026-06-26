import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import '../../../../models/show_date.dart';

class ShowDateDetail extends StatelessWidget {
  final ShowDate showDate;
  final AvailabilityStatus status;

  const ShowDateDetail({
    super.key,
    required this.showDate,
    required this.status,
  });

  String get _statusAccessibilityLabel {
    final formattedDate =
        DateFormat('d MMMM y', 'fr_FR').format(showDate.date);
    return '$formattedDate, ${status.label}';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        Semantics(
          header: true,
          child: Text(
            showDate.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Semantics(
          liveRegion: true,
          label: _statusAccessibilityLabel,
          child: ExcludeSemantics(
            child: Card(
              child: ListTile(
                title: Text("Disponibilité : ${status.label}"),
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Date : ${showDate.formattedDate}"),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(
              'Heure de rendez-vous : ${showDate.formattedMeetingTimeForDisplay}',
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(
              "Adresse : ${showDate.address}",
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(
              "Nombre d'artiste nécessaire : ${showDate.totalRequiredArtists}",
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Description : ${showDate.description}"),
          ),
        ),
      ],
    );
  }
}
