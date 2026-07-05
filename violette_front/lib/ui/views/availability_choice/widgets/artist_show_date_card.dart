import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/common/app_theme.dart';
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
        color: VioletteTheme.cardSurface,
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
                  style: const TextStyle(
                    color: VioletteTheme.textOnCard,
                    fontSize: 14,
                  ),
                ),
              ],
              if (showDate.description != null &&
                  showDate.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  showDate.description!,
                  style: const TextStyle(
                    color: VioletteTheme.textOnCard,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (isAvailabilityLocked)
                Text(
                  availabilityLockMessage,
                  style: const TextStyle(
                    color: VioletteTheme.textOnCardSecondary,
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
                  color: VioletteTheme.cardTitle,
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
        style: const TextStyle(
          color: VioletteTheme.textOnCard,
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
              const Text(
                'Ma disponibilité : ',
                style: TextStyle(
                  color: VioletteTheme.textOnCard,
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
          style: TextButton.styleFrom(
            foregroundColor: VioletteTheme.cardTitle,
          ),
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

  /// Fond saturé opaque compatible WCAG AA (texte blanc ≥ 4,5:1).
  /// Aligné sur la palette des pills de disponibilité.
  Color get _pillBackgroundColor {
    switch (status) {
      case BookingStatus.preselected:
        return const Color(0xFF1565C0);
      case BookingStatus.pendingConfirmation:
        return const Color(0xFFE65100);
      case BookingStatus.confirmed:
        return const Color(0xFF2E7D32);
      case BookingStatus.refused:
        return const Color(0xFFC62828);
      case BookingStatus.cancelled:
        return const Color(0xFF616161);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Engagement : $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _pillBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
