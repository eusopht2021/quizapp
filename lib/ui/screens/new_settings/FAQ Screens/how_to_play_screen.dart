import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/notched_card.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/custom_appbar.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class HowToPlay extends StatelessWidget {
  const HowToPlay({Key? key}) : super(key: key);

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
              top: 40,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Constants.white),
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                headingText("Instructions"),
                WidgetsUtil.verticalSpace4,
                descriptionText(
                    " Online Quiz game has 4 or 5 options.\nFor each right answer 5 points will be given.\nMinus 2 points for each question."),
                WidgetsUtil.verticalSpace16,
                headingText("Use of Lifeline"),
                WidgetsUtil.verticalSpace4,
                descriptionText("You can use only once per level"),
                WidgetsUtil.verticalSpace16,
                headingText("50 - 50 "),
                WidgetsUtil.verticalSpace4,
                descriptionText(
                    "For remove two option out of four (deduct 4 coins)."),
                WidgetsUtil.verticalSpace16,
                headingText("Skip question"),
                WidgetsUtil.verticalSpace4,
                descriptionText(
                    "You can pass question without minus points(deduct 4 coins)."),
                WidgetsUtil.verticalSpace16,
                headingText("Audience poll"),
                WidgetsUtil.verticalSpace4,
                descriptionText(
                    "Use audience poll to check other users choose option(deduct 4 coins)"),
                WidgetsUtil.verticalSpace16,
                headingText("Reset timer"),
                WidgetsUtil.verticalSpace4,
                descriptionText(
                    "Reset timer again if you needed more time score (deduct 4 coins)."),
                WidgetsUtil.verticalSpace16,
                headingText("Leaderboard"),
                WidgetsUtil.verticalSpace4,
                descriptionText(
                    "You can compare your score with other users of app."),
                WidgetsUtil.verticalSpace16,
                headingText("Contest Rules"),
                WidgetsUtil.verticalSpace4,
                descriptionText(
                    "To provide fair and equal chance of winning to all Online Quiz readers, the following are the official rules for all contests on Online Quiz."),
                WidgetsUtil.verticalSpace16,
                headingText("ELIGIBILITY"),
                WidgetsUtil.verticalSpace4,
                descriptionText("All player/users can play contest."),
                WidgetsUtil.verticalSpace16,
                headingText("HOW TO ENTER"),
                WidgetsUtil.verticalSpace4,
                descriptionText(
                    "User can Play Contest by spending number of coins specified as an entry fees in contest details."),
                WidgetsUtil.verticalSpace16,
                headingText("CHOICE OF LAW"),
                WidgetsUtil.verticalSpace4,
                descriptionText(
                    "All the Contest and Operations are belongs to WRTeam. and Apple is not involved in any way with the contest."),
                WidgetsUtil.verticalSpace16,
                headingText("SPONSOR"),
                WidgetsUtil.verticalSpace4,
                descriptionText(
                    "Sponsers data will be shown there in contest as there are many sponsers for contest.")
              ],
            ),
          ),
        ),
      ),
    );
  }

  headingText(
    String? title,
  ) {
    return TitleText(
      text: title!,
      size: Constants.bodyXLarge,
      weight: FontWeight.w500,
    );
  }

  descriptionText(String? title) {
    return TitleText(
      text: title!,
      weight: FontWeight.w400,
      textColor: Constants.grey1,
      align: TextAlign.justify,
    );
  }
}
