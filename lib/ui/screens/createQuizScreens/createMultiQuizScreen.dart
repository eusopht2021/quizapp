import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/ui/screens/createQuizScreens/chooseCategoryScreen.dart';
import 'package:flutterquiz/ui/widgets/custom_button.dart';
import 'package:flutterquiz/ui/widgets/custom_card.dart';
import 'package:flutterquiz/ui/widgets/custom_text_field.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

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

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: Constants.primaryColor,
      title: "Create Quiz",
      titleColor: Constants.white,
      expandBodyBehindAppBar: false,
      action: Padding(
          padding: EdgeInsets.only(right: 16), child: Icon(Icons.more_horiz)),
      child: SingleChildScrollView(
        child: CustomCard(
          height: SizeConfig.screenHeight,
          padding: EdgeInsets.only(top: 24, bottom: 8, right: 8, left: 8),
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tabs(),
                WidgetsUtil.verticalSpace16,
                tab4(),
                WidgetsUtil.verticalSpace16,
                Spacer(),
                CustomButton(
                  onPressed: () {},
                  text: "Add Question",
                  horizontalMargin: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  tabs() {
    return Row(
      children: List.generate(
        tabindex.length,
        (index) {
          return Expanded(
            flex: SizeConfig.screenWidth.toInt(),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
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
            ),
          );
        },
      ),
    );
  }

  tab4() {
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
        TitleText(
          text: "Add Question",
          weight: FontWeight.w500,
          size: Constants.bodyNormal,
        ),
        WidgetsUtil.verticalSpace8,
        CustomTextField(
          hint: "Enter Your Question",
          showBorder: true,
          horizontalMargin: 0,
          borderColor: Constants.grey5,
          iconTextColor: Constants.grey2,
        ),
      ],
    );
  }
}
