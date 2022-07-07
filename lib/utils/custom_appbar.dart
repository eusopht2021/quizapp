import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final Function()? onBackTapped;
  final String? backIcon;
  final bool? showBackButton;
  const CustomAppBar({
    Key? key,
    required this.title,
    this.onBackTapped,
    this.backIcon,
    this.showBackButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TitleText(
        text: title,
        weight: FontWeight.w500,
        size: Constants.heading3,
        textColor: Constants.white,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      leading: showBackButton!
          ? InkWell(
              onTap: onBackTapped,
              child: Container(
                padding: const EdgeInsets.all(
                  15,
                ),
                child: Image.asset(
                  backIcon ?? Assets.backIcon,
                  color: Constants.white,
                ),
              ),
            )
          : SizedBox(),
    );
  }
}
