import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/screens/quizSection/puzzleScreen.dart';
import 'package:flutterquiz/ui/widgets/custom_card.dart';
import 'package:flutterquiz/ui/widgets/pie_chart.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class PollScreen extends StatelessWidget {
  PollScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
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
                    flex: 8,
                    child: Container(
                      height: 4,
                      width: 148,
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
                    flex: 4,
                    child: Container(
                      height: 4,
                      width: 44,
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
                              text: "25",
                              textColor: Constants.white,
                            ),
                          ],
                        )),
                  )
                ],
              ),
            )),
        body: CustomCard(
            padding:
                const EdgeInsets.only(top: 110, bottom: 8, left: 8, right: 8),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  const Expanded(
                    flex: 2,
                    child: CustomPieChart(
                      value1: 60,
                      value2: 40,
                      radius: 35,
                    ),
                  ),
                  Expanded(
                      flex: 8,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TitleText(
                              text: "QUESTION 8 OF 10",
                              textColor: Constants.grey2,
                            ),
                            WidgetsUtil.verticalSpace8,
                            TitleText(
                              text: "What is the best club in England?",
                              size: Constants.bodyXLarge,
                              weight: FontWeight.w500,
                            ),
                            WidgetsUtil.verticalSpace24,
                            GestureDetector(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PuzzleScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Constants.grey5,
                                          style: BorderStyle.solid,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: newOptionContainer(
                                              color: Constants.primaryColor
                                                  .withOpacity(0.2),
                                              child: const TitleText(
                                                text: "Manchester United",
                                                weight: FontWeight.w500,
                                              )),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: TitleText(text: "92%"),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                            WidgetsUtil.verticalSpace16,
                            newOptionContainer(
                                child: const TitleText(text: "Leeds United")),
                            WidgetsUtil.verticalSpace16,
                            newOptionContainer(
                                child: const TitleText(text: "Fulham")),
                            WidgetsUtil.verticalSpace16,
                            newOptionContainer(
                                child: const TitleText(text: "Leicester City")),
                          ])),
                ]))));
  }

  Widget newOptionContainer({child, color, double? width}) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Constants.white,
        border: Border.all(
          color: Constants.grey5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      width: width ?? SizeConfig.screenWidth,
      height: SizeConfig.screenHeight * 0.09,
      child: Center(child: child),
    );
  }
}
