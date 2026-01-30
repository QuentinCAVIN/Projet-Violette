import 'package:flutter/material.dart';
import 'package:violette_front/models/enums/availability_status.dart';

class AvailabilityStatusPill extends StatelessWidget {
  final AvailabilityStatus status;

  const AvailabilityStatusPill({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {

    Color color = status.color;
    String label = status.label;

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