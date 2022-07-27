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
import 'package:flutterquiz/ui/screens/createQuizScreens/createQuizScreen.dart';
import 'package:flutterquiz/ui/screens/home/homeScreen.dart';
import 'package:flutterquiz/ui/screens/home/new_home_screen.dart';
import 'package:flutterquiz/ui/screens/new_leaderBoard.dart';
import 'package:flutterquiz/ui/screens/profile/profile.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';

class Navigation extends StatefulWidget {
  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  @override
  void initState() {
    super.initState();
  }

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
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      floatingActionButton: Visibility(
        visible: !isKeyboardOpen,
        child: FloatingActionButton(
          backgroundColor: Constants.primaryColor,
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => CreateQuizScreen()));
          },
          child: const Icon(
            Icons.add,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      bottomNavigationBar: BlocBuilder<NavigationCubit, NavigationbarState>(
        builder: (context, state) {
          return AnimatedBottomNavigationBar.builder(
            itemCount: bodyWidgets.length,
            backgroundColor: Constants.white,
            height: kBottomNavigationBarHeight,
            gapLocation: GapLocation.center,
            leftCornerRadius: 20.0,
            rightCornerRadius: 20.0,
            notchSmoothness: NotchSmoothness.softEdge,
            tabBuilder: (index, value) => Container(
              padding: const EdgeInsets.all(15),
              child: SvgPicture.asset(
                state.index == index
                    ? Assets.navigationBarIcons[index]
                    : Assets.outlinedNavigationBarIcons[index],
                color:
                    state.index == index ? Constants.black1 : Constants.grey3,
              ),
            ),
            activeIndex: state.index,
            onTap: (index) {
              // setState(() {
              //   selectedIndex = index;
              // });
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
        },
      ),
      body: BlocBuilder<NavigationCubit, NavigationbarState>(
        builder: (context, state) {
          log(" navbar items: ${state.navbarItems}");

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
        },
      ),
    );
  }
}
