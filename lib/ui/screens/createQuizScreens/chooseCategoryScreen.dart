import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/ui/screens/createQuizScreens/createMultiQuizScreen.dart';
import 'package:flutterquiz/ui/widgets/custom_button.dart';
import 'package:flutterquiz/ui/widgets/custom_card.dart';
import 'package:flutterquiz/ui/widgets/custom_text_field.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/category_card.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class ChooseCategoryScreen extends StatefulWidget {
  ChooseCategoryScreen({Key? key}) : super(key: key);

  @override
  State<ChooseCategoryScreen> createState() => _ChooseCategoryScreenState();
}

class _ChooseCategoryScreenState extends State<ChooseCategoryScreen> {
  TextEditingController title = TextEditingController();

  TextEditingController description = TextEditingController();

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      resizeToAvoidBottomInset: false,
      backgroundColor: Constants.primaryColor,
      title: "Choose Category",
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
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          padding: const EdgeInsets.only(top: 24, bottom: 8, right: 8, left: 8),
          child: Container(
            // height: double.infinity,
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: List.generate(
                    Assets.quizCategories.length,
                    (index) {
                      bool checked = index == selectedIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: CategoryCard(
                          showAsSubCategories: false,
                          backgroundColor:
                              checked ? Constants.pink : Constants.grey5,
                          icon: Assets.quizCategories[index].asset,
                          iconColor: checked
                              ? Constants.white
                              : Constants.primaryColor,
                          iconShadowOpacity: checked ? 0.2 : 1,
                          categoryName: Assets.quizCategories[index].name,
                          textColor: checked
                              ? Constants.white
                              : Constants.primaryColor,
                          quizzes: 21,
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
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
}
