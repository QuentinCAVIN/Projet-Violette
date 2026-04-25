import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';
import 'package:violette_front/ui/views/create_show_date/create_show_date_view.form.dart';
import 'package:violette_front/ui/views/create_show_date/create_show_date_viewmodel.dart';

import '../helpers/test_data_builders.dart';
import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(TestDataBuilders.createTestShowDate());
  });

  group('CreateShowDateViewModel - création de date', () {
    late MockNavigationService navigationService;
    late MockDialogService dialogService;
    late MockShowDateRepository showDateRepository;

    setUp(() {
      navigationService = getAndRegisterNavigationService();
      dialogService = getAndRegisterDialogService();
      showDateRepository = getAndRegisterShowDateRepository();

      when(
        () => navigationService.replaceWith<dynamic>(
          any(),
          arguments: any(named: 'arguments'),
          id: any(named: 'id'),
          preventDuplicates: any(named: 'preventDuplicates'),
          parameters: any(named: 'parameters'),
          transition: any(named: 'transition'),
        ),
      ).thenAnswer((_) async => null);

      when(
        () => dialogService.showDialog(
          title: any(named: 'title'),
          description: any(named: 'description'),
          buttonTitle: any(named: 'buttonTitle'),
          cancelTitle: any(named: 'cancelTitle'),
          dialogPlatform: any(named: 'dialogPlatform'),
          barrierDismissible: any(named: 'barrierDismissible'),
        ),
      ).thenAnswer((_) async => DialogResponse());
    });

    tearDown(() => locator.reset());

    test(
      'si addShowDate échoue, ne pas naviguer vers Home et afficher un message explicite',
      () async {
        final viewModel = CreateShowDateViewModel();
        viewModel.titleValue = 'Date test';
        viewModel.dateValue = '2026-04-25';
        viewModel.startTimeValue = '21:00';
        viewModel.addressValue = 'Paris';
        viewModel.artistsCountValue = '3';
        viewModel.clientContactNameController.text = 'Contact';
        viewModel.clientContactPhoneController.text = '0102030405';
        viewModel.onDateChanged(DateTime(2026, 4, 25));
        viewModel.onStartTimeChanged(const TimeOfDay(hour: 21, minute: 0));

        when(() => showDateRepository.addShowDate(any())).thenThrow(
          StateError(
            'Impossible de créer une date : aucune compagnie associée au profil manager.',
          ),
        );

        await viewModel.submitShowDateForm();

        verifyNever(
          () => navigationService.replaceWith<dynamic>(
            Routes.homeView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            preventDuplicates: any(named: 'preventDuplicates'),
            parameters: any(named: 'parameters'),
            transition: any(named: 'transition'),
          ),
        );

        verify(
          () => dialogService.showDialog(
            title: 'Création de date impossible',
            description:
                'Impossible de créer la date. Votre compte manager n’est associé à aucune compagnie.',
            buttonTitle: any(named: 'buttonTitle'),
            cancelTitle: any(named: 'cancelTitle'),
            dialogPlatform: any(named: 'dialogPlatform'),
            barrierDismissible: any(named: 'barrierDismissible'),
          ),
        ).called(1);
      },
    );
  });
}
