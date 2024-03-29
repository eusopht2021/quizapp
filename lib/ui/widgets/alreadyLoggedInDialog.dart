import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class AlreadyLoggedInDialog extends StatelessWidget {
  final Function? onAlreadyLoggedInCallBack;
  const AlreadyLoggedInDialog({Key? key, this.onAlreadyLoggedInCallBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * (0.5),
            height: MediaQuery.of(context).size.width * (0.5),
            child: SvgPicture.asset(
              UiUtils.getImagePath("already_login.svg"),
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
          TitleText(
              text: "Already logged in other device",
              textColor: Constants.black1),
          const SizedBox(
            height: 15.0,
          ),
          GestureDetector(
            onTap: () {
              onAlreadyLoggedInCallBack?.call();
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushReplacementNamed(Routes.loginScreen);
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: Constants.primaryColor)),
              height: 40.0,
              child: Text(
                AppLocalization.of(context)!.getTranslatedValues(okayLbl)!,
                style: TextStyle(color: Constants.primaryColor),
              ),
            ),
          )
        ],
      ),
    );
  }
}
