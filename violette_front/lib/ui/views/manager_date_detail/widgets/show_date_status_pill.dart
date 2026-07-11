import 'package:flutter/material.dart';
import 'package:violette_front/models/enums/show_date_status.dart';
import 'package:violette_front/ui/widgets/common/calendar/calendar_day_cell.dart';

class ShowDateStatusPill extends StatelessWidget {
  final ShowDateStatus status;

  const ShowDateStatusPill({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;

    return Semantics(
      label: 'Statut : ${status.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status.label,
          style: TextStyle(
            color: contrastTextForStatusPill(color),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
