import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/ui/screens/createQuizScreens/chooseCategoryScreen.dart';
import 'package:flutterquiz/ui/screens/createQuizScreens/createMultiQuizScreen.dart';
import 'package:flutterquiz/ui/widgets/custom_button.dart';
import 'package:flutterquiz/ui/widgets/custom_card.dart';
import 'package:flutterquiz/ui/widgets/custom_text_field.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class CreateQuizScreen extends StatelessWidget {
  CreateQuizScreen({Key? key}) : super(key: key);

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

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
                  text: "Title",
                  weight: FontWeight.w500,
                  size: Constants.bodyNormal,
                ),
                WidgetsUtil.verticalSpace8,
                CustomTextField(
                  hint: "Enter Quiz Title",
                  showBorder: true,
                  horizontalMargin: 0,
                  borderColor: Constants.grey5,
                  iconTextColor: Constants.grey2,
                ),
                WidgetsUtil.verticalSpace16,
                TitleText(
                  text: "Quiz Category",
                  weight: FontWeight.w500,
                  size: Constants.bodyNormal,
                ),
                WidgetsUtil.verticalSpace8,
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChooseCategoryScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Constants.grey5,
                      ),
                    ),
                    child: Row(
                      children: [
                        TitleText(
                          text: "Choose Quiz Category",
                          weight: FontWeight.w500,
                          size: Constants.bodyNormal,
                          textColor: Constants.grey2,
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
                WidgetsUtil.verticalSpace16,
                TitleText(
                  text: "Description",
                  weight: FontWeight.w500,
                  size: Constants.bodyNormal,
                ),
                WidgetsUtil.verticalSpace8,
                CustomTextField(
                  hint: "Enter Quiz Title",
                  showBorder: true,
                  horizontalMargin: 0,
                  maxLines: 3,
                  borderColor: Constants.grey5,
                  iconTextColor: Constants.grey2,
                ),
                Spacer(),
                CustomButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CreateMultiQuizScreen()));
                  },
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
}
