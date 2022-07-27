import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/custom_checkbox.dart';
import 'package:flutterquiz/ui/widgets/custom_text_field.dart';
import 'package:flutterquiz/ui/widgets/new_Custom-Card.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class CheckboxAnswer extends StatelessWidget {
  final bool checkValue;
  final Function(bool?) onChanged;
  const CheckboxAnswer({
    Key? key,
    required this.checkValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'Add Question',
          textSize: Constants.bodyNormal,
          horizontalMargin: 16,
          iconTextColor: Constants.black1,
          titleWeight: FontWeight.w500,
          showBorder: true,
          borderColor: Constants.grey5,
          hint: 'Enter your question',
        ),
        WidgetsUtil.verticalSpace16,
        check(context),
        WidgetsUtil.verticalSpace16,
        check(context),
      ],
    );
  }

  Widget check(context) {
    return InkWell(
      onTap: () {
        NewCustomDialog.showCheckBoxDialog(context);
      },
      child: IgnorePointer(
        child: CustomCheckbox(
          horizontalMargin: 16,
          value: NewCustomDialog.value,
          onChanged: (value) {
            NewCustomDialog.value = value!;
          },
        ),
      ),
    );
  }
}
