import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/custom_text_field.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class NewCustomDialog {
  static bool value = false;

  static void showMultipleQuestionDialog(context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.only(
            left: 8,
            right: 8,
          ),
          contentPadding: const EdgeInsets.only(
            top: 24,
            bottom: 24,
          ),
          backgroundColor: Constants.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          scrollable: true,
          content: SizedBox(
            width: SizeConfig.screenWidth,
            child: Column(
              children: [
                CustomTextField(
                  mainAxisAlignment: MainAxisAlignment.center,
                  hint: 'Add answer',
                  label: 'Add answer',
                  textSize: Constants.bodyNormal,
                  titleWeight: FontWeight.w500,
                  iconTextColor: Constants.black1,
                  showBorder: true,
                  borderColor: Constants.grey5,
                  maxLines: 3,
                ),
                WidgetsUtil.verticalSpace16,
                Row(
                  children: [
                    WidgetsUtil.horizontalSpace24,
                    TitleText(
                      text: 'Correct answer',
                      textColor: Constants.black2,
                      weight: FontWeight.w500,
                      size: Constants.bodyNormal,
                    ),
                    const Spacer(),
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Switch(
                          value: value,
                          activeColor: Constants.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              NewCustomDialog.value = value;
                            });
                          },
                        );
                      },
                    ),
                    WidgetsUtil.horizontalSpace24,
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showCheckBoxDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.only(
            left: 8,
            right: 8,
          ),
          contentPadding: const EdgeInsets.all(24),
          backgroundColor: Constants.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          scrollable: true,
          content: SizedBox(
            width: SizeConfig.screenWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Add answer',
                  textSize: Constants.bodyNormal,
                  titleWeight: FontWeight.w500,
                  hint: 'Add answer',
                  fillColor: Constants.white,
                  horizontalMargin: 0,
                  showBorder: true,
                  borderColor: Constants.grey5,
                  prefixIcon: StatefulBuilder(
                    builder: (BuildContext context, setState) => Checkbox(
                      value: NewCustomDialog.value,
                      onChanged: (value) {
                        setState(
                          () => NewCustomDialog.value = value!,
                        );
                      },
                      fillColor: MaterialStateProperty.all(
                        Constants.primaryColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                WidgetsUtil.verticalSpace8,
                Row(
                  children: [
                    TitleText(
                      text: 'Correct answer',
                      textColor: Constants.black2,
                      weight: FontWeight.w500,
                      size: Constants.bodyNormal,
                    ),
                    const Spacer(),
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Switch(
                          value: value,
                          activeColor: Constants.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              NewCustomDialog.value = value;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
