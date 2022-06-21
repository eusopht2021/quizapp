import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class FriendCard extends StatelessWidget {
  final String name, icon;
  final int points;
  const FriendCard({
    Key? key,
    required this.name,
    required this.points,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        WidgetsUtil.horizontalSpace24,
        SvgPicture.asset(icon),
        WidgetsUtil.horizontalSpace16,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TitleText(
              text: name,
              size: Constants.bodyNormal,
              weight: FontWeight.w500,
              textColor: Constants.black1,
            ),
            const SizedBox(
              height: 4,
            ),
            TitleText(
              text: '$points Points',
              size: Constants.bodySmall,
              weight: FontWeight.w400,
              textColor: Constants.grey2,
            ),
          ],
        ),
      ],
    );
  }
}
