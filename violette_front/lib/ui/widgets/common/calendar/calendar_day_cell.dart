import 'package:flutter/material.dart';

class CalendarDayCell extends StatelessWidget {
  final DateTime day;
  final Color? color;
  final bool isSelected;
  final bool isToday;

  const CalendarDayCell({
    super.key,
    required this.day,
    this.color,
    this.isSelected = false,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    if (color == null && !isSelected && !isToday) {
      return Center(
        child: Text(
          '${day.day}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    BoxDecoration decoration;
    TextStyle textStyle;

    if (color != null) {
      // Cellule avec statut (couleur de fond)
      decoration = BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(width: 2, color: Colors.black.withValues(alpha: 0.4))
            : null,
      );
      textStyle = const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      );
    } else {
      // Cellule normale mais peut être Today ou Selected sans couleur définie (ex: Manager view si pas de statut)
      // Dans le cas spécifié par availability_choice, on a une couleur ou rien.
      // Mais pour être générique, gérons le 'Today' ou 'Selected' sans couleur de statut.

      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Theme.of(context).primaryColor : null,
        border: isToday && !isSelected
            ? Border.all(width: 1, color: Theme.of(context).primaryColor)
            : null,
      );
      textStyle = TextStyle(
        color: isSelected
            ? Colors.white
            : Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: 14,
        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
      );
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: decoration,
      child: Center(
        child: Text(
          '${day.day}',
          style: textStyle,
        ),
      ),
    );
  }
}
