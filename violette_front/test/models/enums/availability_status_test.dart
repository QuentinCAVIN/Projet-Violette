import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/enums/availability_status.dart';
// Généré par IA

void main() {
  group('AvailabilityStatus - Transitions de statut', () {
    test('pending.next devrait retourner available', () {
      // Arrange
      const status = AvailabilityStatus.pending;

      // Act
      final result = status.next;

      // Assert
      expect(result, AvailabilityStatus.available);
    });

    test('available.next devrait retourner ifNeeded', () {
      const status = AvailabilityStatus.available;
      final result = status.next;
      expect(result, AvailabilityStatus.ifNeeded);
    });

    test('ifNeeded.next devrait retourner unavailable', () {
      const status = AvailabilityStatus.ifNeeded;
      final result = status.next;
      expect(result, AvailabilityStatus.unavailable);
    });

    test('unavailable.next devrait retourner available (cycle)', () {
      const status = AvailabilityStatus.unavailable;
      final result = status.next;
      expect(result, AvailabilityStatus.available);
    });
  });

  group('AvailabilityStatus - Labels', () {
    test('available devrait avoir le label "Disponible"', () {
      expect(AvailabilityStatus.available.label, 'Disponible');
    });

    test('ifNeeded devrait avoir le label "Si besoin"', () {
      expect(AvailabilityStatus.ifNeeded.label, 'Si besoin');
    });

    test('unavailable devrait avoir le label "Indisponible"', () {
      expect(AvailabilityStatus.unavailable.label, 'Indisponible');
    });

    test('pending devrait avoir le label "En attente"', () {
      expect(AvailabilityStatus.pending.label, 'En attente');
    });
  });

  group('AvailabilityStatus - Serialization (enum → string)', () {
    test('AvailabilityStatus.available.name devrait retourner "available"', () {
      expect(AvailabilityStatus.available.name, 'available');
    });

    test('AvailabilityStatus.ifNeeded.name devrait retourner "ifNeeded"',
        () {
      expect(AvailabilityStatus.ifNeeded.name, 'ifNeeded');
    });

    test('AvailabilityStatus.unavailable.name devrait retourner "unavailable"',
        () {
      expect(AvailabilityStatus.unavailable.name, 'unavailable');
    });

    test('AvailabilityStatus.pending.name devrait retourner "pending"', () {
      expect(AvailabilityStatus.pending.name, 'pending');
    });
  });
}
