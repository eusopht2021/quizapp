import 'package:flutter/cupertino.dart';

class SizeConfig {
  static double screenWidth = 0;

  static double screenHeight = 0;

  static void init(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
  }
}
