import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';
import 'package:violette_front/ui/views/startup/startup_viewmodel.dart';

import '../helpers/test_data_builders.dart';
import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StartupViewModel - Routage initial', () {
    late MockNavigationService navigationService;
    late MockFirebaseAuthenticationService authService;
    late MockUserRepository userRepository;

    setUp(() {
      navigationService = getAndRegisterNavigationService();
      authService = getAndRegisterFirebaseAuthenticationService();
      userRepository = getAndRegisterUserRepository();

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

      when(() => authService.logout()).thenAnswer((_) async {});
    });

    tearDown(() => locator.reset());

    test(
      'Sans utilisateur Firebase connecté, devrait naviguer vers Login',
      () async {
        when(() => authService.currentUser).thenReturn(null);

        final viewModel = StartupViewModel();
        await viewModel.runStartupLogic();

        expect(viewModel.startupError, isNull);
        verify(
          () => navigationService.replaceWith<dynamic>(
            Routes.loginView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            preventDuplicates: any(named: 'preventDuplicates'),
            parameters: any(named: 'parameters'),
            transition: any(named: 'transition'),
          ),
        ).called(1);
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
        verifyNever(() => userRepository.getUser(any()));
      },
    );

    test(
      'Utilisateur Firebase connecté et profil backend présent, devrait naviguer vers Home',
      () async {
        const uid = 'firebase-uid-xyz';
        when(() => authService.currentUser).thenReturn(MockFirebaseUser(uid: uid));
        when(() => userRepository.getUser(uid)).thenAnswer(
          (_) async => TestDataBuilders.createTestUser(uid: uid),
        );

        final viewModel = StartupViewModel();
        await viewModel.runStartupLogic();

        expect(viewModel.startupError, isNull);
        verify(() => userRepository.getUser(uid)).called(1);
        verify(
          () => navigationService.replaceWith<dynamic>(
            Routes.homeView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            preventDuplicates: any(named: 'preventDuplicates'),
            parameters: any(named: 'parameters'),
            transition: any(named: 'transition'),
          ),
        ).called(1);
        verifyNever(
          () => navigationService.replaceWith<dynamic>(
            Routes.loginView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            preventDuplicates: any(named: 'preventDuplicates'),
            parameters: any(named: 'parameters'),
            transition: any(named: 'transition'),
          ),
        );
        verifyNever(() => authService.logout());
      },
    );

    test(
      'Utilisateur Firebase connecté et profil backend absent, devrait déclencher le logout Firebase puis naviguer vers Login',
      () async {
        const uid = 'firebase-sans-profil';
        when(() => authService.currentUser).thenReturn(MockFirebaseUser(uid: uid));
        when(() => userRepository.getUser(uid)).thenAnswer((_) async => null);

        final viewModel = StartupViewModel();
        await viewModel.runStartupLogic();

        expect(viewModel.startupError, isNull);
        verify(() => userRepository.getUser(uid)).called(1);
        verifyInOrder([
          () => authService.logout(),
          () => navigationService.replaceWith<dynamic>(
                Routes.loginView,
                arguments: any(named: 'arguments'),
                id: any(named: 'id'),
                preventDuplicates: any(named: 'preventDuplicates'),
                parameters: any(named: 'parameters'),
                transition: any(named: 'transition'),
              ),
        ]);
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
      },
    );

    test(
      'Utilisateur Firebase connecté et erreur backend/réseau, ne devrait pas lever d’exception, devrait exposer un état d’erreur et ne pas naviguer vers Home ni vers Login',
      () async {
        const uid = 'firebase-uid-err';
        when(() => authService.currentUser).thenReturn(MockFirebaseUser(uid: uid));
        when(() => userRepository.getUser(uid)).thenThrow(Exception('erreur réseau simulée'));

        final viewModel = StartupViewModel();

        await expectLater(viewModel.runStartupLogic(), completes);

        expect(viewModel.startupError, isNotNull);
        expect(
          viewModel.startupError,
          stringContainsInOrder([
            'Impossible de joindre le serveur au démarrage.',
            'erreur réseau simulée',
          ]),
        );
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
        verifyNever(
          () => navigationService.replaceWith<dynamic>(
            Routes.loginView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            preventDuplicates: any(named: 'preventDuplicates'),
            parameters: any(named: 'parameters'),
            transition: any(named: 'transition'),
          ),
        );
        verifyNever(() => authService.logout());
      },
    );
  });
}

/// Utilisateur Firebase minimal : seul [uid] est utilisé par [StartupViewModel].
class MockFirebaseUser extends Mock implements User {
  @override
  final String uid;

  MockFirebaseUser({required this.uid});
}
