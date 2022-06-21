import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';

import '../../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final double? horizontalMargin;
  final double? verticalMargin;
  final Function() onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final bool? isLoading;

  const CustomButton({
    Key? key,
    this.text,
    this.isLoading = false,
    this.horizontalMargin,
    this.verticalMargin,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: horizontalMargin ?? 16,
        right: horizontalMargin ?? 16,
        top: verticalMargin ?? 24,
      ),
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all(
            const Size(
              311,
              56,
            ),
          ),
          minimumSize: MaterialStateProperty.all(
            const Size(
              311,
              56,
            ),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
            backgroundColor ?? Constants.primaryColor,
          ),
        ),
        child: isLoading!
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    Constants.white,
                  ),
                ),
              )
            : TitleText(
                text: text!,
                align: TextAlign.center,
                textColor: textColor ?? Constants.white,
                size: Constants.bodyNormal,
                weight: FontWeight.w500,
              ),
      ),
    );
  }
}
