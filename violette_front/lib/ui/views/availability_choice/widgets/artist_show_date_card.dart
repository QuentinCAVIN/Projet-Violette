import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/widgets/common/availability_status_pill.dart';
import 'package:violette_front/ui/widgets/common/date_badge.dart';

/// Carte structurée d'une date de spectacle pour la vue artiste (planning).
class ArtistShowDateCard extends StatelessWidget {
  final ShowDate showDate;
  final AvailabilityStatus availabilityStatus;
  final BookingStatus? bookingStatus;
  final bool isAvailabilityLocked;
  final VoidCallback onEditAvailability;

  /// Message affiché lorsque la disponibilité est verrouillée (booking confirmé).
  final String availabilityLockMessage;

  const ArtistShowDateCard({
    super.key,
    required this.showDate,
    required this.availabilityStatus,
    required this.isAvailabilityLocked,
    required this.onEditAvailability,
    this.bookingStatus,
    this.availabilityLockMessage =
        'Confirmé — contactez le gérant pour modifier',
  });

  String get _bookingStatusLabel {
    if (bookingStatus == BookingStatus.cancelled) {
      return 'Annulée par le gérant';
    }
    return bookingStatus!.displayName;
  }

  String get _accessibilityLabel {
    final formattedDate =
        DateFormat('d MMMM y', 'fr_FR').format(showDate.date);
    final bookingPart = bookingStatus != null
        ? ', engagement : $_bookingStatusLabel'
        : '';
    if (isAvailabilityLocked) {
      return '$formattedDate, ${showDate.title}$bookingPart, '
          'engagement confirmé, $availabilityLockMessage';
    }
    return '$formattedDate, ${showDate.title}$bookingPart, '
        'disponibilité : ${availabilityStatus.label}';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _accessibilityLabel,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildInfoRow('Date', showDate.formattedDate),
              _buildInfoRow('Heure', showDate.formattedMeetingTimeForDisplay),
              _buildInfoRow('Adresse', showDate.address),
              if (showDate.totalRequiredArtists > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Artistes conviés : ${showDate.totalRequiredArtists}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
              if (showDate.description != null &&
                  showDate.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  showDate.description!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (isAvailabilityLocked)
                Text(
                  availabilityLockMessage,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                _buildAvailabilitySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DateBadge(date: showDate.date),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showDate.title,
                style: const TextStyle(
                  color: Color(0xFF673AB7),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (bookingStatus != null) ...[
                const SizedBox(height: 4),
                _ArtistBookingStatusPill(
                  status: bookingStatus!,
                  label: _bookingStatusLabel,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label : $value',
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          liveRegion: true,
          label: 'Ma disponibilité : ${availabilityStatus.label}',
          child: Row(
            children: [
              Text(
                'Ma disponibilité : ',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AvailabilityStatusPill(status: availabilityStatus),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onEditAvailability,
          child: const Text('Modifier ma disponibilité'),
        ),
      ],
    );
  }
}

/// Pill de statut de booking avec libellé personnalisable (ex. annulation gérant).
class _ArtistBookingStatusPill extends StatelessWidget {
  final BookingStatus status;
  final String label;

  const _ArtistBookingStatusPill({
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;

    return Semantics(
      label: 'Engagement : $label',
      child: Container(
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
      ),
    );
  }
}
