import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:violette_front/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:violette_front/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:violette_front/ui/views/home/home_view.dart';
import 'package:violette_front/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/ui/views/login/login_view.dart';
import 'package:violette_front/ui/views/register/register_view.dart';
import 'package:violette_front/services/violette_user_service.dart';
import 'package:violette_front/ui/views/availability_choice/availability_choice_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: RegisterView),
    MaterialRoute(page: AvailabilityChoiceView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: FirebaseAuthenticationService),
    LazySingleton(classType: VioletteUserService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}