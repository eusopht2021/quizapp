import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadiusGeometry? borderRadius;

  const CustomCard({
    Key? key,
    this.height,
    required this.child,
    this.borderRadius,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Constants.white,
          borderRadius: borderRadius ?? BorderRadius.circular(20),
        ),
        child: child,
      ),
    );
  }
}
