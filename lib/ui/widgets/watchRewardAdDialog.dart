import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/utils/constants.dart';

class WatchRewardAdDialog extends StatelessWidget {
  final Function onTapYesButton;
  final Function? onTapNoButton;
  const WatchRewardAdDialog(
      {Key? key, required this.onTapYesButton, this.onTapNoButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Text(
          AppLocalization.of(context)!.getTranslatedValues("showAdsLbl")!,
        ),
        actions: [
          CupertinoButton(
            onPressed: () {
              onTapYesButton();
              Navigator.pop(context);
            },
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues("yesBtn")!,
              style: TextStyle(color: Constants.primaryColor),
            ),
          ),
          CupertinoButton(
            onPressed: () {
              if (onTapNoButton != null) {
                onTapNoButton!();
                return;
              }
              Navigator.pop(context);
            },
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues("noBtn")!,
              style: TextStyle(color: Constants.primaryColor),
            ),
          ),
        ]);
  }
}
