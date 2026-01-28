import 'package:flutter/material.dart';
import 'package:violette_front/models/enums/availability_status.dart';

class AvailabilityStatusPill extends StatelessWidget {
  final AvailabilityStatus status;

  const AvailabilityStatusPill({
    super.key,
    required this.status,
  });

  //TODO -> Travaille d'harmonisation:  voir si les couleurs peuvent être récupéré dans AvailabilyStatus
  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case AvailabilityStatus.available:
        color = Colors.green;
        label = "Dispo";
        break;
      case AvailabilityStatus.unavailable:
        color = Colors.red;
        label = "Indispo";
        break;
      case AvailabilityStatus.conditional:
        color = Colors.orange;
        label = "Incertain";
        break;
      default:
        color = Colors.grey;
        label = "N/A";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
