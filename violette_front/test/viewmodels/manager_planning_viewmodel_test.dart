import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/ui/views/manager_planning/manager_planning_viewmodel.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_data_builders.dart';

void main() {
  group('ManagerPlanningViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    group('onDaySelected -', () {
      test('devrait effacer la sélection quand aucune date n\'existe',
          () async {
        final showDateRepo = getAndRegisterShowDateRepository();
        when(() => showDateRepo.getAllShowDates())
            .thenAnswer((_) => Future.value([]));

        final viewModel = ManagerPlanningViewModel();
        await viewModel.loadShowDates();

        final testDate = DateTime(2026, 2, 15);
        await viewModel.onDaySelected(testDate, testDate);

        expect(viewModel.selectedDay, null);
        expect(viewModel.showDatePicked, null);
        expect(viewModel.artists, isEmpty);
      });

      test(
          'devrait charger les artistes avec statut != pending pour une date sélectionnée',
          () async {
        final showDateRepo = getAndRegisterShowDateRepository();
        final userRepo = getAndRegisterUserRepository();

        final testDate = DateTime(2026, 2, 15);
        final artist1 = TestDataBuilders.createTestUser(
          uid: 'artist1',
          firstName: 'Marie',
          lastName: 'Martin',
        );
        final artist2 = TestDataBuilders.createTestUser(
          uid: 'artist2',
          firstName: 'Paul',
          lastName: 'Dubois',
        );

        final showDate = TestDataBuilders.createTestShowDate(
          date: testDate,
          artistsAvailability: {
            'artist1': AvailabilityStatus.available,
            'artist2': AvailabilityStatus.unavailable,
            'artist3': AvailabilityStatus.pending, // Ne devrait PAS être chargé
          },
        );

        when(() => showDateRepo.getAllShowDates())
            .thenAnswer((_) => Future.value([showDate]));
        when(() => userRepo.getUser('artist1'))
            .thenAnswer((_) => Future.value(artist1));
        when(() => userRepo.getUser('artist2'))
            .thenAnswer((_) => Future.value(artist2));
        when(() => userRepo.getUser('artist3'))
            .thenAnswer((_) => Future.value(null));

        final viewModel = ManagerPlanningViewModel();
        await viewModel.loadShowDates();

        await viewModel.onDaySelected(testDate, testDate);

        expect(viewModel.showDatePicked, showDate);
        expect(viewModel.artists.length, 2);
        expect(viewModel.artists, contains(artist1));
        expect(viewModel.artists, contains(artist2));

        // Vérifier que le service utilisateur a bien été appelé pour les bons artistes
        verify(() => userRepo.getUser('artist1')).called(1);
        verify(() => userRepo.getUser('artist2')).called(1);
        verifyNever(() => userRepo
            .getUser('artist3')); // le status pending ne doit pas être chargé
      });

      test('devrait gérer le cas où getUser retourne null', () async {
        final showDateRepo = getAndRegisterShowDateRepository();
        final userRepo = getAndRegisterUserRepository();

        final testDate = DateTime(2026, 2, 15);
        final showDate = TestDataBuilders.createTestShowDate(
          date: testDate,
          artistsAvailability: {
            'artist1': AvailabilityStatus.available,
          },
        );

        when(() => showDateRepo.getAllShowDates())
            .thenAnswer((_) => Future.value([showDate]));
        when(() => userRepo.getUser('artist1'))
            .thenAnswer((_) => Future.value(null));

        final viewModel = ManagerPlanningViewModel();
        await viewModel.loadShowDates();

        await viewModel.onDaySelected(testDate, testDate);

        expect(viewModel.artists, isEmpty);
      });
    });

    group('expanded state -', () {
      test('isExpanded devrait être false par défaut', () async {
        final viewModel = ManagerPlanningViewModel();
        final showDate = TestDataBuilders.createTestShowDate(
          uid: 'date-1',
        );

        expect(viewModel.isExpanded(showDate), isFalse);
        expect(viewModel.expandedShowDateId, isNull);
      });

      test('toggleExpanded devrait ouvrir puis refermer la même date',
          () async {
        final viewModel = ManagerPlanningViewModel();
        final showDate = TestDataBuilders.createTestShowDate(
          uid: 'date-1',
        );

        viewModel.toggleExpanded(showDate);
        expect(viewModel.isExpanded(showDate), isTrue);
        expect(viewModel.expandedShowDateId, equals('date-1'));

        viewModel.toggleExpanded(showDate);
        expect(viewModel.isExpanded(showDate), isFalse);
        expect(viewModel.expandedShowDateId, isNull);
      });

      test(
          'toggleExpanded devrait fermer la date précédente lorsqu’une nouvelle est ouverte',
          () async {
        final viewModel = ManagerPlanningViewModel();
        final firstDate = TestDataBuilders.createTestShowDate(
          uid: 'date-1',
        );
        final secondDate = TestDataBuilders.createTestShowDate(
          uid: 'date-2',
        );

        viewModel.toggleExpanded(firstDate);
        expect(viewModel.isExpanded(firstDate), isTrue);

        viewModel.toggleExpanded(secondDate);
        expect(viewModel.isExpanded(firstDate), isFalse);
        expect(viewModel.isExpanded(secondDate), isTrue);
        expect(viewModel.expandedShowDateId, equals('date-2'));
      });

      test(
          'onDaySelected devrait réinitialiser expandedShowDateId lors d’un changement de jour',
          () async {
        final showDateRepo = getAndRegisterShowDateRepository();
        final userRepo = getAndRegisterUserRepository();

        final testDate = DateTime(2026, 2, 15);
        final showDate = TestDataBuilders.createTestShowDate(
          uid: 'date-1',
          date: testDate,
          artistsAvailability: {
            'artist1': AvailabilityStatus.available,
          },
        );

        when(() => showDateRepo.getAllShowDates())
            .thenAnswer((_) => Future.value([showDate]));
        when(() => userRepo.getUser('artist1')).thenAnswer(
          (_) => Future.value(
            TestDataBuilders.createTestUser(uid: 'artist1'),
          ),
        );

        final viewModel = ManagerPlanningViewModel();
        await viewModel.loadShowDates();

        // Ouvre le détail pour la date sélectionnée
        viewModel.toggleExpanded(showDate);
        expect(viewModel.isExpanded(showDate), isTrue);

        // Sélection d’un jour (même date ou autre) doit fermer le détail inline
        await viewModel.onDaySelected(testDate, testDate);

        expect(viewModel.expandedShowDateId, isNull);
        expect(viewModel.isExpanded(showDate), isFalse);
      });
    });
  });
}
