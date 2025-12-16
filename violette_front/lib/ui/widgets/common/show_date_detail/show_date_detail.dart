import 'package:flutter/material.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import '../../../../models/show_date.dart';

class ShowDateDetail extends StatelessWidget {
  final ShowDate showDate;

  const ShowDateDetail({super.key, required this.showDate});

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        Text(
          showDate.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Card(
          child: ListTile(
            title: Text("Disponibilité : ${showDate.availabilityStatus.label}"),
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
                "Periode : ${showDate.formattedStartTime} à ${showDate.formattedEndTime}"),
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Adresse : ${showDate.description}",),
          ),
        ),
        Card(
          child: ListTile(
            title:
            Text("Nombre d'artiste nécessaire : ${showDate.artistsCount}"),
          ),
        ),

        Card(
          child: ListTile(
            title: Text("Montant du cachet : ${showDate.fee} €"),
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
