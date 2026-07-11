import 'package:flutter/material.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/ui/widgets/common/calendar/calendar_day_cell.dart';

class BookingStatusPill extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusPill({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // DETTE-15 : clarifier la sémantique visuelle de preselected vs confirmed selon le contexte
    Color color = status.color;
    String label = status.displayName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: contrastTextForStatusPill(color),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
