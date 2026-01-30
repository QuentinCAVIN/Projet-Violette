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
import 'package:violette_front/services/show_date_service.dart';
import 'package:violette_front/ui/views/create_show_date/create_show_date_view.dart';
import 'package:violette_front/ui/views/manager_planning/manager_planning_view.dart';
import 'package:violette_front/services/booking_service.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: RegisterView),
    MaterialRoute(page: AvailabilityChoiceView),
    MaterialRoute(page: CreateShowDateView),
    MaterialRoute(page: ManagerPlanningView),
    MaterialRoute(page: ManagerDateDetailView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: FirebaseAuthenticationService),
    LazySingleton(classType: VioletteUserService),
    LazySingleton(classType: ShowDateService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: BookingService),
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
