import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/size_config.dart';

import '../../utils/constants.dart';
import 'title_text.dart';

class DefaultLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? backgroundColor;
  final Color? titleColor;
  final Widget? action;
  final bool? expandBodyBehindAppBar;
  final bool? showBackButton;
  final double? size;
  Function()? onTap;
  final Widget? bottomSheet;
  final bool? extendBody;
  final bool? resizeToAvoidBottomInset;

  DefaultLayout({
    Key? key,
    required this.title,
    required this.child,
    this.backgroundColor,
    this.titleColor,
    this.action,
    this.size,
    this.resizeToAvoidBottomInset,
    this.showBackButton,
    this.onTap,
    this.bottomSheet,
    this.expandBodyBehindAppBar,
    this.extendBody,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: bottomSheet ?? SizedBox(),
      // bottomNavigationBar: bottomNavigationbar ?? SizedBox(),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      backgroundColor: backgroundColor ?? Constants.backgroundColor,
      extendBodyBehindAppBar: expandBodyBehindAppBar ?? false,
      extendBody: extendBody ?? false,
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TitleText(
                text: title,
                size: size ?? Constants.heading3,
                weight: FontWeight.w500,
                textColor: titleColor ?? Constants.black2,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          action ?? SizedBox(),
        ],
        leading: (showBackButton ?? true)
            ? InkWell(
                onTap: onTap ?? () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(
                    15,
                  ),
                  child: Image.asset(
                    Assets.backIcon,
                    color: titleColor,
                  ),
                ),
              )
            : SizedBox(),
      ),
      body: child,
    );
  }
}
