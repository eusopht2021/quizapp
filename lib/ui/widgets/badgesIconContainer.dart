import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/ui/styles/colors.dart';

import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';

class BadgesIconContainer extends StatelessWidget {
  final Badge badge;
  final BoxConstraints constraints;
  final bool addTopPadding;

  BadgesIconContainer(
      {Key? key,
      required this.badge,
      required this.constraints,
      required this.addTopPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: addTopPadding ? Alignment.topCenter : Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(
              top: constraints.maxHeight * (addTopPadding ? 0.085 : 0),
            ),
            child: CustomPaint(
              painter: HexagonCustomPainter(
                  color: badge.status == "0"
                      ? Constants.primaryColor.withOpacity(0.5)
                      : Constants.primaryColor,
                  paintingStyle: PaintingStyle.fill),
              child: SizedBox(
                width: constraints.maxWidth * (0.875),
                height: constraints.maxHeight * (0.6), //65
              ),
            ),
          ),
        ),
        Align(
          alignment: addTopPadding ? Alignment.topCenter : Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(
              top: constraints.maxHeight *
                  (addTopPadding
                      ? 0.135
                      : 0), //outer hexagon top padding + differnce of inner and outer height
            ),
            child: CustomPaint(
              painter: HexagonCustomPainter(
                  color: Constants.white,
                  paintingStyle: PaintingStyle.stroke), //
              child: SizedBox(
                width: constraints.maxWidth * (0.725),
                height: constraints.maxHeight * (0.5),
                child: Padding(
                  padding: const EdgeInsets.all(12.5),
                  child: badge.status == "0"
                      ? badges.Badge(
                          toAnimate: false,
                          elevation: 0,
                          badgeColor: Colors.transparent,
                          position: badges.BadgePosition.center(),
                          badgeContent: Image.asset(
                            Assets.lock,
                            color: Constants.black1,
                          ),
                          child: CachedNetworkImage(imageUrl: badge.badgeIcon))
                      : CachedNetworkImage(imageUrl: badge.badgeIcon),
                ), //55
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HexagonCustomPainter extends CustomPainter {
  final Color color;
  final PaintingStyle paintingStyle;
  HexagonCustomPainter({required this.color, required this.paintingStyle});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = paintingStyle;

    if (paintingStyle == PaintingStyle.stroke) {
      paint.strokeWidth = 2.5;
    }
    Path path = Path();
    path.moveTo(size.width * (0.5), 0);
    path.lineTo(size.width, size.height * (0.25));
    path.lineTo(size.width, size.height * (0.75));
    path.lineTo(size.width * (0.5), size.height);
    path.lineTo(0, size.height * (0.75));
    path.lineTo(0, size.height * (0.25));
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
