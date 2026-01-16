import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/views/availability_choice/availability_choice_viewmodel.dart';

import '../../../../models/enums/availability_status.dart';

class DayCell extends ViewModelWidget<AvailabilityChoiceViewModel> {
  final DateTime day;
  final AvailabilityStatus? status;
  final bool isSelected;

  const DayCell({
    super.key,
    required this.day,
    required this.status,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, AvailabilityChoiceViewModel viewModel) {
    if (status == null) {
      return Center(
        child: Text(
          '${day.day}',
          style: Theme.of(context)
              .textTheme
              .bodyMedium, // TODO Faire un theme personalisé (je garde la ligne pour l'exemple)
        ),
      );
    }

    // Cas avec status → on utilise la couleur de Availability_status
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: status!.color,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(width: 2, color: Colors.black.withValues(alpha: 0.4))
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: const TextStyle(
            //TODO  passer par un thème
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
