import 'package:flutter/material.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/show_date.dart';

class BookingRequestCard extends StatelessWidget {
  final ArtistBooking booking;
  /// Null si les détails de la date n’ont pas pu être chargés (aucune donnée factice).
  final ShowDate? showDate;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;
  final bool isBusy;

  const BookingRequestCard({
    super.key,
    required this.booking,
    this.showDate,
    required this.onAccept,
    required this.onRefuse,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nouvelle proposition !",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (showDate != null) ...[
              Text(
                showDate!.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(showDate!.formattedDate),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(showDate!.formattedMeetingTimeForDisplay),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      showDate!.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Demande de confirmation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Détails de la date indisponibles pour le moment',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            if (booking.status == BookingStatus.pendingConfirmation)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isBusy ? null : onRefuse,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text("Refuser"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isBusy ? null : onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Confirmer"),
                    ),
                  ),
                ],
              )
            else
              Text(
                booking.status.displayName,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}
