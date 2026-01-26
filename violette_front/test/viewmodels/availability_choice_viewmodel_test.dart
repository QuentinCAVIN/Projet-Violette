import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/ui/views/availability_choice/availability_choice_viewmodel.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AvailabilityChoiceViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    group('getStatusForDay -', () {
      test(
          'When no show date exists for the given day, should return null (no color)',
          () {
        // Le service mocké renvoie une liste vide
        final showDateService = getAndRegisterShowDateService();
        when(() => showDateService.getAllShowDates())
            .thenAnswer((_) => Future.value([]));

        final viewModel = AvailabilityChoiceViewModel();

        // Charge des dates vides
        viewModel.loadShowDates();

        final status = viewModel.getStatusForDay(DateTime(2025, 12, 12));
        expect(status, null,
            reason:
                "Un jour libre ne doit PAS avoir de statut (donc pas de couleur par défaut)");
      });

      test('When show date exists, should return correct status from ShowDate',
          () async {
        final showDateService = getAndRegisterShowDateService();
        final authService = getAndRegisterFirebaseAuthenticationService();

        final cleanDate = DateTime(2025, 10, 10);
        final dummyShowDate = ShowDate(
          title: 'Test',
          date: cleanDate,
          artistsAvailability: {'uid-123': AvailabilityStatus.available},
          startMinutes: 0,
          endMinutes: 0,
          address: 'Paris',
          artistsCount: 1,
          fee: 100,
        );

        when(() => showDateService.getAllShowDates())
            .thenAnswer((_) => Future.value([dummyShowDate]));
        when(() => authService.currentUser).thenReturn(MockUser(
            uid: 'uid-123')); // besoin d'un utilisateur fictif ou similaire

        final viewModel = AvailabilityChoiceViewModel();

        await viewModel.loadShowDates();

        final status = viewModel.getStatusForDay(cleanDate);
        expect(status, AvailabilityStatus.available);
      });
    });
  });
}

// Mock minimal pour les besoins du test
class MockUser extends Mock implements User {
  @override
  final String uid;
  MockUser({required this.uid});
}
