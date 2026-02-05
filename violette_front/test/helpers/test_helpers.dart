import 'package:violette_front/app/app.locator.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/repositories/booking_repository.dart';
import 'package:violette_front/repositories/show_date_repository.dart';
import 'package:violette_front/repositories/user_repository.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

// Import des mocks générés (si utilisation de build_runner avec mockito) ou définition manuelle avec Mocktail

import 'package:mocktail/mocktail.dart';

class MockNavigationService extends Mock implements NavigationService {}

class MockBottomSheetService extends Mock implements BottomSheetService {}

class MockDialogService extends Mock implements DialogService {}

class MockShowDateRepository extends Mock implements ShowDateRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockBookingRepository extends Mock implements BookingRepository {}

class MockFirebaseAuthenticationService extends Mock
    implements FirebaseAuthenticationService {}

class MockSnackbarService extends Mock implements SnackbarService {}

MockNavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

MockBottomSheetService getAndRegisterBottomSheetService({
  SheetResponse? showCustomSheetResponse,
}) {
  _removeRegistrationIfExists<BottomSheetService>();
  final service = MockBottomSheetService();

  registerFallbackValue(const Color(0xFF000000));
  registerFallbackValue(SheetResponse());

  when(() => service.showCustomSheet(
            variant: any(named: 'variant'),
            title: any(named: 'title'),
            description: any(named: 'description'),
            hasImage: any(named: 'hasImage'),
            imageUrl: any(named: 'imageUrl'),
            showIconInMainButton: any(named: 'showIconInMainButton'),
            mainButtonTitle: any(named: 'mainButtonTitle'),
            showIconInSecondaryButton: any(named: 'showIconInSecondaryButton'),
            secondaryButtonTitle: any(named: 'secondaryButtonTitle'),
            additionalButtonTitle: any(named: 'additionalButtonTitle'),
            takesInput: any(named: 'takesInput'),
            barrierColor: any(named: 'barrierColor'),
            barrierDismissible: any(named: 'barrierDismissible'),
            isScrollControlled: any(named: 'isScrollControlled'),
            barrierLabel: any(named: 'barrierLabel'),
            data: any(named: 'data'),
            enableDrag: any(named: 'enableDrag'),
          ))
      .thenAnswer((realInvocation) => Future.value(
          showCustomSheetResponse ?? SheetResponse(confirmed: true)));

  locator.registerSingleton<BottomSheetService>(service);
  return service;
}

MockDialogService getAndRegisterDialogService() {
  _removeRegistrationIfExists<DialogService>();
  final service = MockDialogService();
  locator.registerSingleton<DialogService>(service);
  return service;
}

MockShowDateRepository getAndRegisterShowDateRepository() {
  _removeRegistrationIfExists<ShowDateRepository>();
  final service = MockShowDateRepository();
  locator.registerSingleton<ShowDateRepository>(service);
  return service;
}

MockUserRepository getAndRegisterUserRepository() {
  _removeRegistrationIfExists<UserRepository>();
  final service = MockUserRepository();
  locator.registerSingleton<UserRepository>(service);
  return service;
}

MockBookingRepository getAndRegisterBookingRepository() {
  _removeRegistrationIfExists<BookingRepository>();
  final service = MockBookingRepository();
  locator.registerSingleton<BookingRepository>(service);
  return service;
}

MockFirebaseAuthenticationService
    getAndRegisterFirebaseAuthenticationService() {
  _removeRegistrationIfExists<FirebaseAuthenticationService>();
  final service = MockFirebaseAuthenticationService();
  locator.registerSingleton<FirebaseAuthenticationService>(service);
  return service;
}

MockSnackbarService getAndRegisterSnackbarService() {
  _removeRegistrationIfExists<SnackbarService>();
  final service = MockSnackbarService();
  locator.registerSingleton<SnackbarService>(service);
  return service;
}

void registerServices() {
  getAndRegisterNavigationService();
  getAndRegisterBottomSheetService();
  getAndRegisterDialogService();
  getAndRegisterShowDateRepository();
  getAndRegisterUserRepository();
  getAndRegisterBookingRepository();
  getAndRegisterFirebaseAuthenticationService();
  getAndRegisterSnackbarService();
}

void unregisterServices() {
  locator.unregister<NavigationService>();
  locator.unregister<BottomSheetService>();
  locator.unregister<DialogService>();
  locator.unregister<ShowDateRepository>();
  locator.unregister<UserRepository>();
  locator.unregister<BookingRepository>();
  locator.unregister<FirebaseAuthenticationService>();
  locator.unregister<SnackbarService>();
}

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
