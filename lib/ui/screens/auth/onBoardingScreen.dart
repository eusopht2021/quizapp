import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

import '../../../../app/routes.dart';
import '../../../../utils/assets.dart';
import '../../../../utils/constants.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/default_background.dart';
import '../../widgets/title_text.dart';

class OnBoarding extends StatefulWidget {
  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  int selectedIndex = 0;
  List<String> onBoarding = [];
  final PageController _pageController = PageController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    onBoarding = [
      AppLocalization.of(context)!.getTranslatedValues('onBoardingIndex0')!,
      AppLocalization.of(context)!.getTranslatedValues('onBoardingIndex1')!,
      AppLocalization.of(context)!.getTranslatedValues('onBoardingIndex2')!,
      AppLocalization.of(context)!.getTranslatedValues('onBoardingIndex3')!,
    ];
    return DefaultBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
          ),

          Expanded(
            flex: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, Routes.loginScreen);
                      },
                      child: Container(
                        width: SizeConfig.screenWidth * 0.17,
                        height: SizeConfig.screenHeight * 0.03,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Constants.white.withOpacity(0.2),
                        ),
                        child: Center(
                          child: TitleText(
                            text: "SKIP",
                            size: Constants.bodyNormal,
                            textColor: Constants.white.withOpacity(0.9),
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )),
                ),
                Expanded(
                  flex: 9,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(
                          top: 60,
                          right: index == 0 ? 40 : 10,
                        ),
                        child: Image.asset(
                          Assets.onBoarding[index],
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          height: 15,
                          width: 15,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: selectedIndex == index
                                ? Border.all(
                                    width: 2,
                                    color: Colors.white,
                                  )
                                : const Border.fromBorderSide(
                                    BorderSide.none,
                                  ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // const Spacer(),
          Expanded(
            flex: 4,
            child: CustomCard(
              // height: double.infinity,
              child: Column(
                children: [
                  // WidgetsUtil.verticalSpace16,
                  FittedBox(
                    fit: BoxFit.fitHeight,
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      height: SizeConfig.screenHeight * 0.13,
                      width: SizeConfig.screenWidth * 0.80,
                      child: Center(
                        child: TitleText(
                          text: onBoarding[selectedIndex],
                          textColor: Colors.black,
                          weight: FontWeight.w500,
                          size: Constants.bodyXLarge,
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  // const Spacer(),
                  CustomButton(
                    verticalMargin: 0,
                    text: selectedIndex == 3
                        ? AppLocalization.of(context)!
                            .getTranslatedValues('signUpLbl')!
                        : AppLocalization.of(context)!
                            .getTranslatedValues('NEXT')!,
                    onPressed: () async {
                      if (selectedIndex == 3) {
                        Navigator.of(context).pushNamed(Routes.signupoptions);
                      } else {
                        selectedIndex++;

                        await _pageController.animateToPage(selectedIndex,
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeInOut);
                      }

                      // Get.to(() => const SignUpOptions());
                    },
                  ),

                  // WidgetsUtil.verticalSpace4, // WidgetsUtil.verticalSpace16,

                  selectedIndex == 3 ? const Spacer() : const SizedBox(),
                  selectedIndex == 3
                      ? Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(
                            top: 0,
                            bottom: 10,
                            right: 50,
                            left: 50,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TitleText(
                                  text: AppLocalization.of(context)!
                                      .getTranslatedValues(
                                          'alreadyAccountLbl')!,
                                  size: Constants.bodyNormal,
                                  textColor: Colors.grey,
                                  weight: FontWeight.w400,
                                ),
                                InkWell(
                                  onTap: () {
                                    log('Login');
                                    Navigator.of(context)
                                        .pushNamed(Routes.loginScreen);
                                  },
                                  child: TitleText(
                                    text:
                                        " ${AppLocalization.of(context)!.getTranslatedValues('loginLbl')!}",
                                    size: Constants.bodyNormal,
                                    textColor: Constants.primaryColor,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(
                          height: 10,
                          width: double.infinity,
                        )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
