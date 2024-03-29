import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/custom_card.dart';
import 'package:flutterquiz/ui/widgets/custom_text_field.dart';
import 'package:flutterquiz/ui/widgets/pie_chart.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class TypeAnswerScreen extends StatelessWidget {
  const TypeAnswerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        // extendBodyBehindAppBar: true,
        backgroundColor: Constants.primaryColor,
        appBar: PreferredSize(
            preferredSize: Size(
              SizeConfig.screenWidth,
              kBottomNavigationBarHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 52,
                left: 24,
                right: 24,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: Constants.secondaryColor,
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(
                            Assets.person,
                            color: Constants.white,
                            width: 16,
                            height: 16,
                          ),
                          TitleText(
                            text: '1',
                            size: Constants.bodyXSmall,
                            textColor: Constants.white,
                            weight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 4,
                      width: 74,
                      margin: const EdgeInsets.only(
                        left: 30,
                      ),
                      decoration: BoxDecoration(
                        color: Constants.white,
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 4,
                      width: 148,
                      margin: const EdgeInsets.only(
                        left: 0,
                        right: 50,
                      ),
                      decoration: BoxDecoration(
                        color: Constants.secondaryColor,
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                          height: 34,
                          decoration: BoxDecoration(
                            color: Constants.orange,
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset(
                                Assets.puzzleIcon1,
                                color: Constants.white,
                                width: 16,
                                height: 16,
                              ),
                              TitleText(
                                text: "20",
                                textColor: Constants.white,
                              ),
                            ],
                          )),
                    ),
                  )
                ],
              ),
            )),
        body: CustomCard(
          height: SizeConfig.screenHeight - kBottomNavigationBarHeight,
          padding: const EdgeInsets.only(top: 24, bottom: 8, left: 8, right: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              const Expanded(
                flex: 2,
                child: CustomPieChart(
                  value1: 30,
                  value2: 70,
                  radius: 35,
                ),
              ),
              Expanded(
                flex: 8,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleText(
                        text: "QUESTION 5 OF 10",
                        textColor: Constants.grey2,
                      ),
                      WidgetsUtil.verticalSpace8,
                      TitleText(
                        text:
                            "Who are three players share the record for most Premier League red cards (8)?",
                        size: Constants.bodyXLarge,
                        weight: FontWeight.w500,
                      ),
                      Expanded(
                        child: CustomTextField(
                          hint: "Write your answer",
                          showBorder: true,
                          maxLines: 5,
                          borderColor: Constants.grey5,
                          horizontalMargin: 0,
                        ),
                      )
                    ]),
              ),
            ]),
          ),
        ));
  }
}
