// using mocktail
import 'package:violette_front/app/app.locator.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/services/show_date_service.dart';
import 'package:violette_front/services/violette_user_service.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

// Import generated mocks (if using build_runner with mockito) or define manually with Mocktail
// Using Mocktail as it's in pubspec
import 'package:mocktail/mocktail.dart';

class MockNavigationService extends Mock implements NavigationService {}
class MockBottomSheetService extends Mock implements BottomSheetService {}
class MockDialogService extends Mock implements DialogService {}
class MockShowDateService extends Mock implements ShowDateService {}
class MockVioletteUserService extends Mock implements VioletteUserService {}
class MockFirebaseAuthenticationService extends Mock implements FirebaseAuthenticationService {}
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

  registerFallbackValue(const Color(0));
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
    customData: any(named: 'customData'),
    data: any(named: 'data'),
    enableDrag: any(named: 'enableDrag'),
  )).thenAnswer((realInvocation) =>
      Future.value(showCustomSheetResponse ?? SheetResponse(confirmed: true)));

  locator.registerSingleton<BottomSheetService>(service);
  return service;
}

MockDialogService getAndRegisterDialogService() {
  _removeRegistrationIfExists<DialogService>();
  final service = MockDialogService();
  locator.registerSingleton<DialogService>(service);
  return service;
}

MockShowDateService getAndRegisterShowDateService() {
  _removeRegistrationIfExists<ShowDateService>();
  final service = MockShowDateService();
  locator.registerSingleton<ShowDateService>(service);
  return service;
}

MockVioletteUserService getAndRegisterVioletteUserService() {
  _removeRegistrationIfExists<VioletteUserService>();
  final service = MockVioletteUserService();
  locator.registerSingleton<VioletteUserService>(service);
  return service;
}

MockFirebaseAuthenticationService getAndRegisterFirebaseAuthenticationService() {
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
  getAndRegisterShowDateService();
  getAndRegisterVioletteUserService();
  getAndRegisterFirebaseAuthenticationService();
  getAndRegisterSnackbarService();
}

void unregisterServices() {
  locator.unregister<NavigationService>();
  locator.unregister<BottomSheetService>();
  locator.unregister<DialogService>();
  locator.unregister<ShowDateService>();
  locator.unregister<VioletteUserService>();
  locator.unregister<FirebaseAuthenticationService>();
  locator.unregister<SnackbarService>();
}

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
