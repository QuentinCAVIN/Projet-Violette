import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/views/calendar/calendar_view.dart';
import 'package:violette_front/ui/views/dashboard/dashboard_view.dart';
import 'package:violette_front/ui/views/messages/messages_view.dart';
import 'package:violette_front/ui/views/profile/profile_view.dart';
import 'package:violette_front/ui/views/videos/videos_view.dart';

class MainView extends StatelessWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MainViewModel>.reactive(
      viewModelBuilder: () => MainViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          // Utilise un IndexedStack pour préserver l'état des vues
          // lors du changement d'onglet.
          body: IndexedStack(
            index: viewModel.currentIndex,
            children: const [
              DashboardView(),
              CalendarView(),
              MessagesView(),
              VideosView(),
              ProfileView(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
            currentIndex: viewModel.currentIndex,
            onTap: viewModel.setIndex,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Calendrier',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined),
                activeIcon: Icon(Icons.message),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.video_library_outlined),
                activeIcon: Icon(Icons.video_library),
                label: 'Vidéos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}

class MainViewModel extends BaseViewModel {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    // Utilise notifyListeners() pour informer le ViewModelBuilder de reconstruire.
    notifyListeners();
  }
}
