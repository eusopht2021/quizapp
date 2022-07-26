import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/ui/screens/createQuizScreens/new_review_Quiz.dart';
import 'package:flutterquiz/ui/widgets/custom_button.dart';
import 'package:flutterquiz/ui/widgets/custom_card.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/question_types/checkbox_answer.dart';
import 'package:flutterquiz/ui/widgets/question_types/multiple_answer.dart';
import 'package:flutterquiz/ui/widgets/question_types/poll.dart';
import 'package:flutterquiz/ui/widgets/question_types/puzzle.dart';
import 'package:flutterquiz/ui/widgets/question_types/true_false.dart';
import 'package:flutterquiz/ui/widgets/question_types/type_answer.dart';
import 'package:flutterquiz/ui/widgets/question_types/voice_note.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/widgets_util.dart';
import 'package:screenshot/screenshot.dart';

class CreateMultiQuizScreen extends StatefulWidget {
  CreateMultiQuizScreen({Key? key}) : super(key: key);

  @override
  State<CreateMultiQuizScreen> createState() => _CreateMultiQuizScreenState();
}

class _CreateMultiQuizScreenState extends State<CreateMultiQuizScreen> {
  TextEditingController question = TextEditingController();

  List<int> tabindex = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
  ];

  int selectedIndex = 3;
  // String currentValue = "Multiple Answer";

  bool checkBoxValue = false;

  String questionCategoriesInitialValue = "Multiple Answer";
  List<String> questionCategories = [
    "Multiple Answer",
    "True or False",
    "Type Answer",
    "Voice Note",
    "Checkbox",
    "Poll",
    "Puzzle",
  ];

  List<Widget> questionCategoriesItems = [
    Column(),
    Column(),
    Column(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      extendBody: false,
      bottomSheet: Container(
        color: Constants.white,
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 15,
            left: 24,
            right: 24,
          ),
          child: CustomButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateComplete(),
                ),
              );
            },
            text: "Add Question",
            horizontalMargin: 0,
          ),
        ),
      ),
      backgroundColor: Constants.primaryColor,
      title: "Create Quiz",
      titleColor: Constants.white,
      expandBodyBehindAppBar: false,
      action: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_horiz,
          color: Constants.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            Constants.cardsRadius,
          ),
        ),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              onTap: () {
                log('Duplicate');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.copy,
                    color: Constants.grey2,
                  ),
                  TitleText(
                    text: 'Duplicate',
                    size: Constants.bodyNormal,
                    textColor: Constants.grey2,
                    weight: FontWeight.w400,
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () {
                log('Delete');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(
                    Icons.delete_outline_outlined,
                    color: Colors.red,
                  ),
                  TitleText(
                    text: 'Delete',
                    size: Constants.bodyNormal,
                    textColor: Colors.red,
                    weight: FontWeight.w400,
                  ),
                ],
              ),
            ),
          ];
        },
      ),
      child: SingleChildScrollView(
        child: CustomCard(
          height: SizeConfig.screenHeight,
          padding: EdgeInsets.only(top: 24, bottom: 8, right: 8, left: 8),
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tabs(selectedIndex),
                WidgetsUtil.verticalSpace16,
                body(),
                WidgetsUtil.verticalSpace16,
                _tabItems(questionCategoriesInitialValue),
                // tab4(),
                // WidgetsUtil.verticalSpace16,
                // Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _tabItems(currentValue) {
    switch (currentValue) {
      case "Multiple Answer":
        return MultipleAnswer();

      case "True or False":
        return TrueFalse();
      case "Type Answer":
        return TypeAnswer();
      case "Voice Note":
        return VoiceNote();
      case "Checkbox":
        return CheckboxAnswer(
            checkValue: checkBoxValue,
            onChanged: (value) {
              checkBoxValue = value!;
            });
      case "Poll":
        return Poll();
      case "Puzzle":
        return Puzzle();
    }
  }

  tabs(newIndex) {
    return Row(
      children: List.generate(
        tabindex.length,
        (index) {
          if (newIndex == tabindex.length) {
            selectedIndex = 3;
          } else {
            selectedIndex = newIndex;
          }

          return Expanded(
            flex: SizeConfig.screenWidth.toInt(),
            child: AnimatedContainer(
              width: 32,
              height: 32,
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selectedIndex == index
                    ? Constants.black1
                    : Colors.transparent,
              ),
              child: Center(
                child: TitleText(
                  text: "${tabindex[index]}",
                  textColor: selectedIndex == index
                      ? Constants.white
                      : Constants.black2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Constants.grey5,
          ),
          width: SizeConfig.screenWidth,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                Assets.addImage,
                width: 60,
                height: 60,
              ),
              TitleText(
                text: "Add Cover Image",
                weight: FontWeight.w500,
                size: Constants.bodyNormal,
                textColor: Constants.primaryColor,
              ),
            ],
          ),
        ),
        WidgetsUtil.verticalSpace16,
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              height: 35,
              width: 85,
              decoration: BoxDecoration(
                border: Border.all(color: Constants.grey5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 2,
                    child: Icon(
                      Icons.schedule,
                      color: Constants.primaryColor,
                      size: 15,
                    ),
                  ),
                  WidgetsUtil.horizontalSpace8,
                  Expanded(
                    flex: 8,
                    child: TitleText(
                      text: "10 Sec",
                      weight: FontWeight.w500,
                      size: Constants.bodyXSmall,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Container(
              height: 35,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Constants.grey5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    alignment: Alignment.center,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: Constants.white,
                    items: questionCategories.map(
                      (String? title) {
                        return DropdownMenuItem<String>(
                          value: title!,
                          child: TitleText(text: title),
                        );
                      },
                    ).toList(),
                    value: questionCategoriesInitialValue,
                    onChanged: (value) {
                      setState(() {
                        questionCategoriesInitialValue = value.toString();
                        // log(value.toString());
                        _tabItems(value.toString());
                        tabs(selectedIndex + 1);
                      });
                    },
                    icon: SizedBox(),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Constants.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        WidgetsUtil.verticalSpace24,
      ],
    );
  }
}
