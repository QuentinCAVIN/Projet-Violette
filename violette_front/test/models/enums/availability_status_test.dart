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

    test('available.next devrait retourner conditional', () {
      const status = AvailabilityStatus.available;
      final result = status.next;
      expect(result, AvailabilityStatus.conditional);
    });

    test('conditional.next devrait retourner unavailable', () {
      const status = AvailabilityStatus.conditional;
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

    test('conditional devrait avoir le label "Conditionnel"', () {
      expect(AvailabilityStatus.conditional.label, 'Incertain');
    });

    test('unavailable devrait avoir le label "Indisponible"', () {
      expect(AvailabilityStatus.unavailable.label, 'Indisponible');
    });

    test('pending devrait avoir le label "En attente"', () {
      expect(AvailabilityStatus.pending.label, 'En attente');
    });
  });

  group('AvailabilityStatus - Mapping Firestore (string → enum)', () {
    test('"available" devrait mapper vers AvailabilityStatus.available', () {
      final result = availabilityStatusFromString('available');
      expect(result, AvailabilityStatus.available);
    });

    test('"conditional" devrait mapper vers AvailabilityStatus.conditional',
        () {
      final result = availabilityStatusFromString('conditional');
      expect(result, AvailabilityStatus.conditional);
    });

    test('"unavailable" devrait mapper vers AvailabilityStatus.unavailable',
        () {
      final result = availabilityStatusFromString('unavailable');
      expect(result, AvailabilityStatus.unavailable);
    });

    test('"pending" devrait mapper vers AvailabilityStatus.pending', () {
      final result = availabilityStatusFromString('pending');
      expect(result, AvailabilityStatus.pending);
    });

    test(
        'valeur invalide devrait retourner AvailabilityStatus.pending (default)',
        () {
      final result = availabilityStatusFromString('invalid');
      expect(result, AvailabilityStatus.pending);
    });

    test('chaîne vide devrait retourner AvailabilityStatus.pending (default)',
        () {
      final result = availabilityStatusFromString('');
      expect(result, AvailabilityStatus.pending);
    });
  });

  group('AvailabilityStatus - Serialization (enum → string)', () {
    test('AvailabilityStatus.available.name devrait retourner "available"', () {
      expect(AvailabilityStatus.available.name, 'available');
    });

    test('AvailabilityStatus.conditional.name devrait retourner "conditional"',
        () {
      expect(AvailabilityStatus.conditional.name, 'conditional');
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
