import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/screens/new_settings/FAQ%20Screens/faq_description_one.dart';
import 'package:flutterquiz/ui/screens/new_settings/FAQ%20Screens/how_to_play_screen.dart';
import 'package:flutterquiz/ui/screens/new_settings/FAQ%20Screens/invite_friendsScreen.dart';

import 'package:flutterquiz/ui/widgets/notched_card.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/custom_appbar.dart';
import 'package:flutterquiz/utils/custom_text_field.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.grey5,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomAppBar(
            title: "Help and Support",
            showBackButton: true,
            textColor: Constants.black1,
            iconColor: Constants.black1,
            onBackTapped: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            top: 24,
          ),
          child: NotchedCard(
            dotColor: Constants.grey5,
            circleColor: Constants.white,
            child: Container(
              padding: const EdgeInsets.only(
                right: 16,
                left: 16,
                top: 16,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Constants.white),
              // width: SizeConfig.screenWidth,
              // height: SizeConfig.screenHeight,
              child: Column(
                children: [
                  CustomTextField(
                    horizontalMargin: 0.0,
                    textcolor: Constants.black1,
                    hint: 'Search topics or questions',
                    fillColor: Constants.grey5,
                    prefixIcon: Assets.search,
                    typedTextColor: Constants.black1,
                    showBorder: false,
                  ),
                  Expanded(
                    flex: 10,
                    child: ListView(
                      padding: const EdgeInsets.only(
                        bottom: 25,
                      ),
                      children: [
                        WidgetsUtil.verticalSpace24,
                        TitleText(
                          text: "INTRO",
                          textColor: Constants.black1.withOpacity(0.5),
                          weight: FontWeight.w500,
                          size: Constants.bodySmall,
                        ),
                        WidgetsUtil.verticalSpace16,
                        _customDivider(),
                        WidgetsUtil.verticalSpace16,
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const IntroToQuiz()));
                          },
                          child: TitleText(
                            text: "Intro to Queezy apps",
                            weight: FontWeight.w500,
                            textColor: Constants.black1,
                            size: Constants.bodyNormal,
                          ),
                        ),
                        WidgetsUtil.verticalSpace16,
                        _customDivider(),
                        WidgetsUtil.verticalSpace16,
                        GestureDetector(
                          onTap: () {},
                          child: TitleText(
                            text: "How to login or sign up",
                            weight: FontWeight.w500,
                            textColor: Constants.black1,
                            size: Constants.bodyNormal,
                          ),
                        ),
                        WidgetsUtil.verticalSpace32,
                        GestureDetector(
                          onTap: () {},
                          child: TitleText(
                            text: "CREATE AND TAKE QUIZ",
                            textColor: Constants.black1.withOpacity(0.5),
                            weight: FontWeight.w500,
                            size: Constants.bodySmall,
                          ),
                        ),
                        WidgetsUtil.verticalSpace16,
                        _customDivider(),
                        WidgetsUtil.verticalSpace16,
                        GestureDetector(
                          onTap: () {},
                          child: TitleText(
                            text: "How to create quiz in the app",
                            weight: FontWeight.w500,
                            textColor: Constants.black1,
                            size: Constants.bodyNormal,
                          ),
                        ),
                        WidgetsUtil.verticalSpace16,
                        _customDivider(),
                        WidgetsUtil.verticalSpace16,
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => HowToPlay()),
                            );
                          },
                          child: TitleText(
                            text: "How to Play?",
                            weight: FontWeight.w500,
                            textColor: Constants.black1,
                            size: Constants.bodyNormal,
                          ),
                        ),
                        WidgetsUtil.verticalSpace16,
                        _customDivider(),
                        WidgetsUtil.verticalSpace16,
                        GestureDetector(
                          onTap: () {},
                          child: TitleText(
                            text: "How do I play quiz with other players?",
                            weight: FontWeight.w500,
                            textColor: Constants.black1,
                            size: Constants.bodyNormal,
                          ),
                        ),
                        WidgetsUtil.verticalSpace16,
                        _customDivider(),
                        WidgetsUtil.verticalSpace16,
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const InviteFriendsScreen(),
                              ),
                            );
                          },
                          child: TitleText(
                            text:
                                "Can I invite my friends to play quiz together?",
                            weight: FontWeight.w500,
                            textColor: Constants.black1,
                            size: Constants.bodyNormal,
                          ),
                        ),
                        WidgetsUtil.verticalSpace16,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _customDivider() {
    return Divider(
      thickness: 1,
      color: Constants.grey5,
    );
  }
}