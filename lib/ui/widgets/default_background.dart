import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/size_config.dart';

import '../../utils/assets.dart';
import '../../utils/constants.dart';

class DefaultBackground extends StatelessWidget {
  final Widget child;
  final String? background;
  const DefaultBackground({
    Key? key,
    required this.child,
    this.background,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            color: Constants.primaryColor,
            child: Image.asset(
              background ?? Assets.background,
              fit: BoxFit.fill,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
