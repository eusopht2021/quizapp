import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/custom_text_field.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class Poll extends StatelessWidget {
  const Poll({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'Add Question',
          hint: 'Enter your question',
          horizontalMargin: 16,
          textSize: Constants.bodyNormal,
          iconTextColor: Constants.black2,
          titleWeight: FontWeight.w500,
          showBorder: true,
          borderColor: Constants.grey5,
        ),
        WidgetsUtil.verticalSpace8,
        CustomTextField(
          hint: 'Add choice Answer 1',
          showBorder: true,
          borderColor: Constants.grey5,
          horizontalMargin: 16,
        ),
        WidgetsUtil.verticalSpace8,
        CustomTextField(
          hint: 'Add choice Answer 2',
          showBorder: true,
          borderColor: Constants.grey5,
          horizontalMargin: 16,
        ),
        WidgetsUtil.verticalSpace8,
      ],
    );
  }
}
