// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_firebase_auth/src/firebase_authentication_service.dart';
import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_services/src/snackbar/snackbar_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../repositories/availability_repository.dart';
import '../repositories/booking_repository.dart';
import '../repositories/rest_availability_repository.dart';
import '../repositories/rest_booking_repository.dart';
import '../repositories/rest_show_date_repository.dart';
import '../repositories/rest_user_repository.dart';
import '../repositories/show_date_repository.dart';
import '../repositories/user_repository.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => FirebaseAuthenticationService());
  locator.registerLazySingleton<UserRepository>(() => RestUserRepository());
  locator.registerLazySingleton<ShowDateRepository>(
      () => RestShowDateRepository());
  locator.registerLazySingleton(() => SnackbarService());
  locator
      .registerLazySingleton<BookingRepository>(() => RestBookingRepository());
  locator.registerLazySingleton<AvailabilityRepository>(
      () => RestAvailabilityRepository());
}
