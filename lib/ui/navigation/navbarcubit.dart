import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutterquiz/ui/navigation/navbaritems.dart';
import 'package:flutterquiz/ui/navigation/navigation.dart';
import 'package:flutterquiz/ui/navigation/navigation_bar_state.dart';

class NavigationCubit extends Cubit<NavigationbarState> {
  NavigationCubit(Navigation navigation)
      : super(NavigationbarState(NavbarItems.newhome, 0));

  void getNavBarItem(NavbarItems navbarItem) {
    switch (navbarItem) {
      case NavbarItems.newhome:
        emit(NavigationbarState(NavbarItems.newhome, 0));
        break;
      case NavbarItems.discover:
        emit(NavigationbarState(NavbarItems.discover, 1));
        break;
      case NavbarItems.leaderboard:
        emit(NavigationbarState(NavbarItems.leaderboard, 2));
        break;
      case NavbarItems.profile:
     
        emit(NavigationbarState(NavbarItems.profile, 3));

        break;
    }
  }
}
