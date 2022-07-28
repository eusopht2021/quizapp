import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/utils/constants.dart';

class FontSizeDialog extends StatefulWidget {
  final SettingsCubit bloc;
  FontSizeDialog({required this.bloc});
  @override
  _FontSizeDialog createState() => _FontSizeDialog();
}

class _FontSizeDialog extends State<FontSizeDialog> {
  double textSize = 14;
  @override
  Widget build(BuildContext context) {
    return FittedBox(
        child: AlertDialog(
      backgroundColor: Constants.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 70, vertical: 300),
      title: Center(
        child: Text(
          AppLocalization.of(context)!.getTranslatedValues("fontSizeLbl")!,
          style: TextStyle(
            color: Constants.primaryColor,
          ),
        ),
      ),
      content: StatefulBuilder(
          builder: (context, state) => FittedBox(
                child: Slider(
                  label: (textSize).toStringAsFixed(0),
                  value: textSize,
                  activeColor: Constants.primaryColor,
                  inactiveColor: Constants.secondaryColor,
                  min: 14,
                  max: 25,
                  divisions: 10,
                  onChanged: (value) {
                    state(() {
                      textSize = value;
                      widget.bloc.changeFontSize(textSize);
                      print(textSize);
                    });
                  },
                ),
              )),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Constants.primaryColor,
            elevation: 20,
            primary: Constants.primaryColor,
            shadowColor: backgroundColor.withOpacity(0.8),
            side: BorderSide(width: 1.0, color: Constants.primaryColor),
            minimumSize: const Size(100, 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          onPressed: () {
            widget.bloc.changeFontSize(textSize);
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues("okayLbl")!,
            style: TextStyle(
              color: Constants.white,
            ),
          ),
        )
      ],
    ));
  }
}
