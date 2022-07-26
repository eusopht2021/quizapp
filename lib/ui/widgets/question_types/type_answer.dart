import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/custom_text_field.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class TypeAnswer extends StatelessWidget {
  const TypeAnswer({Key? key}) : super(key: key);

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
          hint: 'Add answer',
          showBorder: true,
          borderColor: Constants.grey5,
          horizontalMargin: 16,
          maxLines: 3,
        ),
        WidgetsUtil.verticalSpace8,
      ],
    );
  }
}
