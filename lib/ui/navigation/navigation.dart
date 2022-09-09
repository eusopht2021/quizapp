import 'dart:developer';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/navigation/navbarcubit.dart';
import 'package:flutterquiz/ui/navigation/navbaritems.dart';
import 'package:flutterquiz/ui/navigation/navigation_bar_state.dart';
import 'package:flutterquiz/ui/screens/Discover%20Screen/discover.dart';
import 'package:flutterquiz/ui/screens/home/new_home_screen.dart';
import 'package:flutterquiz/ui/screens/new_leaderBoard.dart';
import 'package:flutterquiz/ui/screens/profile/profile.dart';
import 'package:flutterquiz/ui/screens/quiz/new_room_dialog.dart';
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
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      floatingActionButton: Visibility(
        visible: !isKeyboardOpen,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            context.read<BattleRoomCubit>().updateState(BattleRoomInitial());
            context
                .read<QuizCategoryCubit>()
                .updateState(QuizCategoryInitial());
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const BattleQuizScreen(quizType: QuizTypes.groupPlay)));

            // showDialog(
            //   context: context,
            //   builder: (context) => MultiBlocProvider(providers: [
            //     BlocProvider<QuizCategoryCubit>(
            //         create: (_) => QuizCategoryCubit(QuizRepository())),
            //     BlocProvider<UpdateScoreAndCoinsCubit>(
            //         create: (_) => UpdateScoreAndCoinsCubit(
            //             ProfileManagementRepository())),
            //   ], child: RoomDialog(quizType: QuizTypes.battle)),
            // );
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
                Navigator.pushNamed(context, Routes.leaderBoard);
                // BlocProvider.of<NavigationCubit>(context)
                //     .getNavBarItem(NavbarItems.leaderboard);
              } else if (index == 3) {
                // BlocProvider.of<NavigationCubit>(context)
                //     .getNavBarItem(NavbarItems.profile);
                Navigator.pushNamed(context, Routes.profile,
                    arguments: {"routefromHomeScreen": true});
              }
            },
          );
        },
      ),
      body: BlocBuilder<NavigationCubit, NavigationbarState>(
        builder: (context, state) {
          log(" navbar items: ${state.navbarItems}");

          if (state.navbarItems == NavbarItems.newhome) {
            return const NewHomeScreen();
          } else if (state.navbarItems == NavbarItems.discover) {
            return const Discover();
          } else if (state.navbarItems == NavbarItems.leaderboard) {
            return const NewLeaderBoardScreen();
          } else if (state.navbarItems == NavbarItems.profile) {
            return const Profile(routefromHomeScreen: false);
          }

          return Container();
        },
      ),
    );
  }
}
