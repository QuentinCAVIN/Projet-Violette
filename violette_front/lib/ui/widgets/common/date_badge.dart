import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Carré date partagé (jour + mois abrégé) pour les cartes gérant et artiste.
class DateBadge extends StatelessWidget {
  final DateTime date;

  const DateBadge({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final dayStr = DateFormat('d', 'fr_FR').format(date);
    final monthStr = DateFormat('MMM', 'fr_FR').format(date);

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF673AB7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            monthStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
