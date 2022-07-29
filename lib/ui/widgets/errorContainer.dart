import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class ErrorContainer extends StatelessWidget {
  final String? errorMessage;
  final Function onTapRetry;
  final bool showErrorImage;
  final double topMargin;
  final Color? errorMessageColor;
  final Color? buttonTitleColor;
  final bool? showBackButton;
  final Color? buttonColor;
  const ErrorContainer(
      {Key? key,
      this.errorMessageColor,
      required this.errorMessage,
      this.buttonColor,
      this.buttonTitleColor,
      required this.onTapRetry,
      required this.showErrorImage,
      this.topMargin = 0.1,
      this.showBackButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.only(top: MediaQuery.of(context).size.height * topMargin),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          showErrorImage
              ? Image.asset(
                  UiUtils.getImagePath("error.png"),
                )
              : Container(),
          showErrorImage
              ? const SizedBox(
                  height: 25.0,
                )
              : Container(),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "$errorMessage :(",
              style: TextStyle(
                  fontSize: 18.0,
                  color: errorMessageColor ?? Constants.primaryColor),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 25.0,
          ),
          CustomRoundedButton(
            widthPercentage: 0.375,
            backgroundColor: buttonColor ?? Constants.white,
            buttonTitle:
                AppLocalization.of(context)!.getTranslatedValues(retryLbl)!,
            radius: 5,
            showBorder: false,
            height: 40,
            titleColor:
                buttonTitleColor ?? Theme.of(context).colorScheme.secondary,
            elevation: 5.0,
            onTap: onTapRetry,
          ),
        ],
      ),
    );
  }
}
