import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:violette_front/app/app.bottomsheets.dart';
import 'package:violette_front/app/app.dialogs.dart';
import 'package:violette_front/app/app.locator.dart';
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

  VioletteUser? currentUser; // Voir question ci dessous pour le ?

  void logOut() {
    _authenticationService.logout();
  }

  Future<void> loadUser() async {
    setBusy(true);
    final uid = _authenticationService.currentUser!.uid; // TODO Question Elies -> je peux mettre un ! sur currentUser? si il a acces a la home view il est forcément connécté. Ou laors je prevois dans le code le cas ou il est nul
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
      title: 'Stacked Rocks!',
      description: 'Give stacked $_counter stars on Github',
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
