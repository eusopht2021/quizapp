import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/custom_text_field.dart';
import 'package:flutterquiz/ui/widgets/new_Custom-Card.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class MultipleAnswer extends StatelessWidget {
  const MultipleAnswer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          hint: 'Enter your question',
          label: 'Add Question',
          horizontalMargin: 16,
          titleWeight: FontWeight.w500,
          iconTextColor: Constants.black1,
          textSize: Constants.bodyNormal,
          showBorder: true,
          borderColor: Constants.grey5,
        ),
        WidgetsUtil.verticalSpace16,
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
          ),
          children: List.generate(
            4,
            (index) {
              return gridItem(index, context);
            },
          ),
        ),
      ],
    );
  }

  Widget gridItem(int index, context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: Constants.grey5,
        borderRadius: BorderRadius.circular(
          Constants.cardsRadius,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            NewCustomDialog.showMultipleQuestionDialog(context);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Constants.primaryColor,
                size: 30,
              ),
              WidgetsUtil.verticalSpace16,
              TitleText(
                text: 'Add answer',
                size: Constants.bodySmall,
                weight: FontWeight.w500,
                textColor: Constants.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
