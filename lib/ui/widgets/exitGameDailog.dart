import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/utils/constants.dart';

class ExitGameDailog extends StatelessWidget {
  final Function? onTapYes;
  const ExitGameDailog({Key? key, this.onTapYes}) : super(key: key);

  void onPressed(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Constants.white,
      content: Text(
        AppLocalization.of(context)!.getTranslatedValues("quizExitLbl")!,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
      actions: [
        TextButton(
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues("yesBtn")!,
            style: TextStyle(
              color: Constants.primaryColor,
            ),
          ),
          onPressed: () {
            if (onTapYes != null) {
              onTapYes!();
            } else {
              Navigator.of(context).pop();

              Navigator.of(context).pop();
            }
          },
        ),
        TextButton(
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues("noBtn")!,
            style: TextStyle(
              color: Constants.primaryColor,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
