import 'dart:developer';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/ui/navigation/navbarcubit.dart';
import 'package:flutterquiz/ui/navigation/navbaritems.dart';
import 'package:flutterquiz/ui/navigation/navigation_bar_state.dart';
import 'package:flutterquiz/ui/screens/Discover%20Screen/discover.dart';
import 'package:flutterquiz/ui/screens/home/homeScreen.dart';
import 'package:flutterquiz/ui/screens/home/new_home_screen.dart';
import 'package:flutterquiz/ui/screens/new_leaderBoard.dart';
import 'package:flutterquiz/ui/screens/profile/profile.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  @override
  void initState() {
    selectedIndex = 0;
    // TODO: implement initState
    super.initState();
  }

  int selectedIndex = 0;

  List<BottomNavigationBarItem> bodyWidgets = [
    BottomNavigationBarItem(
        icon: SvgPicture.asset(Assets.homeFilled), label: "home"),

    BottomNavigationBarItem(
        icon: SvgPicture.asset(Assets.search), label: "discover"),

    BottomNavigationBarItem(
        icon: SvgPicture.asset(Assets.leaderboardFilled), label: "leaderbard"),

    BottomNavigationBarItem(
        icon: SvgPicture.asset(Assets.personFilled), label: "profile"),

    // Discover(),
    // NewLeaderBoardScreen(),
    // Container(
    //   color: Colors.pink,
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.primaryColor,
        onPressed: () {
          //  Navigator.of(context).pushNamed(Routes.create);
        },
        child: const Icon(
          Icons.add,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      bottomNavigationBar: BlocBuilder<NavigationCubit, NavigationbarState>(
          builder: (context, state) {
        return AnimatedBottomNavigationBar.builder(
          itemCount: 4,
          backgroundColor: Constants.white,
          height: kBottomNavigationBarHeight,
          gapLocation: GapLocation.center,
          leftCornerRadius: 20.0,
          rightCornerRadius: 20.0,
          notchSmoothness: NotchSmoothness.softEdge,
          tabBuilder: (index, value) => Container(
            padding: const EdgeInsets.all(15),
            child: SvgPicture.asset(
              Assets.navigationBarIcons[index],
              color:
                  selectedIndex == index ? Constants.black1 : Constants.grey3,
            ),
          ),
          activeIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
            if (index == 0) {
              BlocProvider.of<NavigationCubit>(context)
                  .getNavBarItem(NavbarItems.newhome);
            } else if (index == 1) {
              BlocProvider.of<NavigationCubit>(context)
                  .getNavBarItem(NavbarItems.discover);
            } else if (index == 2) {
              BlocProvider.of<NavigationCubit>(context)
                  .getNavBarItem(NavbarItems.leaderboard);
            } else if (index == 3) {
              BlocProvider.of<NavigationCubit>(context)
                  .getNavBarItem(NavbarItems.profile);
            }
          },
        );
      }),
      body: BlocBuilder<NavigationCubit, NavigationbarState>(
          builder: (context, state) {
        if (state.navbarItems == NavbarItems.newhome) {
          return NewHomeScreen();
        } else if (state.navbarItems == NavbarItems.discover) {
          return Discover();
        } else if (state.navbarItems == NavbarItems.leaderboard) {
          return NewLeaderBoardScreen();
        } else if (state.navbarItems == NavbarItems.profile) {
          return Profile(routefromHomeScreen: false);
        }
        return Container();
      }),
    );
  }
}
// bottomNavigationBar: AnimatedBottomNavigationBar.builder(
//   itemCount: 4,
//   backgroundColor: Constants.white,
//   height: kBottomNavigationBarHeight,
//   gapLocation: GapLocation.center,
//   leftCornerRadius: 20.0,
//   rightCornerRadius: 20.0,
//   notchSmoothness: NotchSmoothness.softEdge,
//   tabBuilder: (index, value) => Expanded(
//     child: Container(
//       padding: const EdgeInsets.all(15),
//       child: SvgPicture.asset(
//         Assets.navigationBarIcons[index],
//         color:
//             selectedIndex == index ? Constants.black1 : Constants.grey3,
//       ),
//     ),
//   ),
//   activeIndex: selectedIndex,
//   onTap: (index) {
//     setState(() {
//       selectedIndex = index;
//     });
//     log('Item at #$index');
//   },
// ),       //   BottomNavigationBar(
//     currentIndex: state.index,
//     showUnselectedLabels: false,
//     items: bodyWidgets,
//     onTap: (index) {
//       if (index == 0) {
//         BlocProvider.of<NavigationCubit>(context)
//             .getNavBarItem(NavbarItems.newhome);
//       } else if (index == 1) {
//         BlocProvider.of<NavigationCubit>(context)
//             .getNavBarItem(NavbarItems.discover);
//       } else if (index == 2) {
//         BlocProvider.of<NavigationCubit>(context)
//             .getNavBarItem(NavbarItems.leaderboard);
//       }
//     },
//   );
