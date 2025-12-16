import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:violette_front/app/app.bottomsheets.dart';
import 'package:violette_front/app/app.dialogs.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';
import 'package:violette_front/ui/common/app_strings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../models/violette_user.dart';
import '../../../services/violette_user_service.dart';

class HomeViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _authenticationService = locator<FirebaseAuthenticationService>();
  final _userServices = locator<VioletteUserService>();
  final _navigationService = locator<NavigationService>();

  VioletteUser? currentUser; // Pareil com ci dessous

  void logOut() {
    _authenticationService.logout();
  }

  void navigateToAvailabilityChoiceView() {
    _navigationService.navigateToAvailabilityChoiceView();
  }

  void navigateToShowDateFormView() {
    _navigationService.navigateToCreateShowDateView();
  }

  Future<void> loadUser() async {
    setBusy(true);

    final firebaseUser = _authenticationService.currentUser;
    if (firebaseUser == null) {
      setBusy(false);

      _navigationService.replaceWithLoginView();
      return;
    }

    final uid = firebaseUser.uid;
    currentUser = await _userServices.getUser(uid);
    setBusy(false);
    rebuildUi();
  }

  ////////// CI DESSOUS FONCTIONS CREE PAR STACKED //////////

  String get counterLabel => 'Counter is: $_counter';

  int _counter = 0;

  void incrementCounter() {
    _counter++;
    rebuildUi();
  }

  void showDialog() {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Violllleeeeeettttttteeee',
      description: 'Salut ${currentUser!.firstName} tu es notre ${currentUser!.roles[0]} préféré!',
    );
  }

  void showBottomSheet() {
    _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: ksHomeBottomSheetTitle,
      description: ksHomeBottomSheetDescription,
    );
  }
}
