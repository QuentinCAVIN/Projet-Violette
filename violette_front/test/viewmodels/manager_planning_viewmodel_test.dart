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

    group('toggleShowArtists -', () {
      test('devrait basculer showArtists de false à true', () {
        final viewModel = ManagerPlanningViewModel();

        expect(viewModel.showArtists, false);

        viewModel.toggleShowArtists();

        expect(viewModel.showArtists, true);
      });

      test('devrait basculer showArtists de true à false', () {
        final viewModel = ManagerPlanningViewModel();
        viewModel.showArtists = true;

        viewModel.toggleShowArtists();

        expect(viewModel.showArtists, false);
      });
    });

    group('onDaySelected -', () {
      test('devrait effacer la sélection quand aucune date n\'existe',
          () async {
        final showDateService = getAndRegisterShowDateService();
        when(() => showDateService.getAllShowDates())
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
          'devrait réinitialiser showArtists à false lors d\'une nouvelle sélection',
          () async {
        final showDateService = getAndRegisterShowDateService();
        final userService = getAndRegisterVioletteUserService();

        final testDate = DateTime(2026, 2, 15);
        final showDate = TestDataBuilders.createTestShowDate(
          date: testDate,
          artistsAvailability: {'artist1': AvailabilityStatus.available},
        );

        when(() => showDateService.getAllShowDates())
            .thenAnswer((_) => Future.value([showDate]));
        when(() => userService.getUser(any()))
            .thenAnswer((_) => Future.value(TestDataBuilders.createTestUser()));

        final viewModel = ManagerPlanningViewModel();
        await viewModel.loadShowDates();

        viewModel.showArtists = true; // Simuler qu'elle était ouverte

        await viewModel.onDaySelected(testDate, testDate);

        expect(viewModel.showArtists, false);
      });

      test(
          'devrait charger les artistes avec statut != pending pour une date sélectionnée',
          () async {
        final showDateService = getAndRegisterShowDateService();
        final userService = getAndRegisterVioletteUserService();

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

        when(() => showDateService.getAllShowDates())
            .thenAnswer((_) => Future.value([showDate]));
        when(() => userService.getUser('artist1'))
            .thenAnswer((_) => Future.value(artist1));
        when(() => userService.getUser('artist2'))
            .thenAnswer((_) => Future.value(artist2));
        when(() => userService.getUser('artist3'))
            .thenAnswer((_) => Future.value(null));

        final viewModel = ManagerPlanningViewModel();
        await viewModel.loadShowDates();

        await viewModel.onDaySelected(testDate, testDate);

        expect(viewModel.showDatePicked, showDate);
        expect(viewModel.artists.length, 2);
        expect(viewModel.artists, contains(artist1));
        expect(viewModel.artists, contains(artist2));

        // Vérifier que le service utilisateur a bien été appelé pour les bons artistes
        verify(() => userService.getUser('artist1')).called(1);
        verify(() => userService.getUser('artist2')).called(1);
        verifyNever(() => userService
            .getUser('artist3')); // le status pending ne doit pas être chargé
      });

      test('devrait gérer le cas où getUser retourne null', () async {
        final showDateService = getAndRegisterShowDateService();
        final userService = getAndRegisterVioletteUserService();

        final testDate = DateTime(2026, 2, 15);
        final showDate = TestDataBuilders.createTestShowDate(
          date: testDate,
          artistsAvailability: {
            'artist1': AvailabilityStatus.available,
          },
        );

        when(() => showDateService.getAllShowDates())
            .thenAnswer((_) => Future.value([showDate]));
        when(() => userService.getUser('artist1'))
            .thenAnswer((_) => Future.value(null));

        final viewModel = ManagerPlanningViewModel();
        await viewModel.loadShowDates();

        await viewModel.onDaySelected(testDate, testDate);

        expect(viewModel.artists, isEmpty);
      });
    });
  });
}
