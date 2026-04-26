import 'package:flutter/material.dart';
import 'package:violette_front/models/enums/booking_status.dart';

class BookingStatusPill extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusPill({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // TODO(v0.5.0): clarifier la sémantique visuelle de preselected vs confirmed
    // selon le contexte (manager/artist) pour éviter l'ambiguïté métier.
    Color color = status.color;
    String label = status.displayName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
