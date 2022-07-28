import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/pie_chart.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/ui/widgets/custom_card.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';

import 'package:flutterquiz/utils/widgets_util.dart';

class PuzzleScreen extends StatelessWidget {
  PuzzleScreen({Key? key}) : super(key: key);

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
                                text: "40",
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
            padding:
                const EdgeInsets.only(top: 110, bottom: 8, left: 8, right: 8),
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
                  flex: 10,
                  child: ListView(
                    padding: const EdgeInsets.all(0),
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: SizeConfig.screenWidth,
                          child: Image.asset(Assets.hellicopterIllustration)),
                      WidgetsUtil.verticalSpace32,
                      TitleText(
                        text: "QUESTION 9 OF 10",
                        textColor: Constants.grey2,
                        size: 14,
                        weight: FontWeight.w500,
                      ),
                      WidgetsUtil.verticalSpace8,
                      const TitleText(
                        text: "What does UAV stand for drone?",
                        weight: FontWeight.w500,
                        size: 20,
                      ),
                      WidgetsUtil.verticalSpace24,
                      _customConatainer(
                          child: const TitleText(
                        text: "Unmanned Aerial Vehicle",
                        weight: FontWeight.w500,
                        size: 16,
                      )),
                      WidgetsUtil.verticalSpace24,
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _customConatainer(
                            width: 100,
                            child: const TitleText(
                              text: "Under",
                            ),
                          ),
                          Badge(
                            position: const BadgePosition(
                              top: 4,
                              end: 5,
                            ),
                            elevation: 0,
                            badgeColor: Colors.transparent,
                            badgeContent: const Text('1'),
                            child: _customConatainer(
                                color: Constants.primaryColor.withOpacity(0.2),
                                width: 140,
                                child: const TitleText(
                                  text: "Unmanned",
                                  weight: FontWeight.w500,
                                  size: 16,
                                )),
                          ),
                          _customConatainer(
                              width: 70, child: const TitleText(text: "Air")),
                          Badge(
                            position: const BadgePosition(
                              top: 4,
                              end: 5,
                            ),
                            elevation: 0,
                            badgeColor: Colors.transparent,
                            badgeContent: const Text('2'),
                            child: _customConatainer(
                                width: 110,
                                color: Constants.primaryColor.withOpacity(0.2),
                                child: const TitleText(
                                  text: "Aerial",
                                  weight: FontWeight.w500,
                                  size: 16,
                                )),
                          ),
                          Badge(
                            position: const BadgePosition(
                              top: 4,
                              end: 5,
                            ),
                            elevation: 0,
                            badgeColor: Colors.transparent,
                            badgeContent: const Text('3'),
                            child: _customConatainer(
                                color: Constants.primaryColor.withOpacity(0.2),
                                width: 120,
                                child: const TitleText(
                                  text: "Vehicle",
                                  weight: FontWeight.w500,
                                  size: 16,
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ]),
            )));
  }

  _customConatainer({color, double? width, child}) {
    return Container(
      height: 56,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: Constants.grey5),
        borderRadius: BorderRadius.circular(16),
        color: color,
      ),
      child: Center(child: child),
    );
  }
}
