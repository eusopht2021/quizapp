import 'dart:developer';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/ui/screens/home/new_home_screen.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';

class Navigation extends StatefulWidget {
  Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int selectedIndex = 0;

  List bodyWidgets = [
    NewHomeScreen(),
    // Discover(),

    // Container(
    //   color: Colors.pink,
    // ),
    Container(
      color: Colors.green,
    ),
    Container(
      color: Colors.black,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
        ),
        backgroundColor: Constants.primaryColor,
        onPressed: () {
          //  Navigator.of(context).pushNamed(Routes.create);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
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
            color: selectedIndex == index ? Constants.black1 : Constants.grey3,
          ),
        ),
        activeIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
          log('Item at #$index');
        },
      ),
      body: bodyWidgets[selectedIndex],
    );
  }
}
