import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/enums/availability_status.dart';
// Généré par IA

void main() {
  group('AvailabilityStatus - Transitions de statut', () {
    test('next_whenStatusIsPending_returnsAvailable', () {
      // Arrange
      const status = AvailabilityStatus.pending;

      // Act
      final result = status.next;

      // Assert
      expect(result, AvailabilityStatus.available);
    });

    test('next_whenStatusIsAvailable_returnsIfNeeded', () {
      const status = AvailabilityStatus.available;
      final result = status.next;
      expect(result, AvailabilityStatus.ifNeeded);
    });

    test('next_whenStatusIsIfNeeded_returnsUnavailable', () {
      const status = AvailabilityStatus.ifNeeded;
      final result = status.next;
      expect(result, AvailabilityStatus.unavailable);
    });

    test('next_whenStatusIsUnavailable_returnsAvailableAndCyclesBack', () {
      const status = AvailabilityStatus.unavailable;
      final result = status.next;
      expect(result, AvailabilityStatus.available);
    });
  });

  group('AvailabilityStatus - Libellés d\'affichage', () {
    test('label_whenStatusIsAvailable_returnsDisponibleLabel', () {
      expect(AvailabilityStatus.available.label, 'Disponible');
    });

    test('label_whenStatusIsIfNeeded_returnsSiBesoinLabel', () {
      expect(AvailabilityStatus.ifNeeded.label, 'Si besoin');
    });

    test('label_whenStatusIsUnavailable_returnsIndisponibleLabel', () {
      expect(AvailabilityStatus.unavailable.label, 'Indisponible');
    });

    test('label_whenStatusIsPending_returnsEnAttenteLabel', () {
      expect(AvailabilityStatus.pending.label, 'En attente');
    });
  });

  group('AvailabilityStatus - Sérialisation enum vers string', () {
    test('name_whenStatusIsAvailable_returnsAvailableString', () {
      expect(AvailabilityStatus.available.name, 'available');
    });

    test('name_whenStatusIsIfNeeded_returnsIfNeededString', () {
      expect(AvailabilityStatus.ifNeeded.name, 'ifNeeded');
    });

    test('name_whenStatusIsUnavailable_returnsUnavailableString', () {
      expect(AvailabilityStatus.unavailable.name, 'unavailable');
    });

    test('name_whenStatusIsPending_returnsPendingString', () {
      expect(AvailabilityStatus.pending.name, 'pending');
    });
  });
}
