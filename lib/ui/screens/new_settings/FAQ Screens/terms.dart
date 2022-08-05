import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/notched_card.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/custom_appbar.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/title_text.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class TermsOfServicesScreen extends StatelessWidget {
  const TermsOfServicesScreen({Key? key}) : super(key: key);

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
                headingText("Terms and Conditions"),
                WidgetsUtil.verticalSpace4,
                descriptionText(
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum"),
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
