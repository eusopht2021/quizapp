import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/utils/size_config.dart';

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
  PageController _pageController = PageController();
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
    return Scaffold(
      body: DefaultBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
              flex: 5,
              child: CustomCard(
                // height: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(),
                    FittedBox(
                      fit: BoxFit.cover,
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 16,
                          left: 14,
                          right: 14,
                          bottom: 0,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        height: SizeConfig.screenHeight * 0.125,
                        width: SizeConfig.screenWidth,
                        child: TitleText(
                          text: onBoarding[selectedIndex],
                          textColor: Colors.black,
                          weight: FontWeight.w500,
                          size: Constants.heading3,
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                    // const Spacer(),
                    CustomButton(
                      verticalMargin: 50,
                      text: selectedIndex == 3
                          ? AppLocalization.of(context)!
                              .getTranslatedValues('signUpLbl')!
                          : AppLocalization.of(context)!
                              .getTranslatedValues('NEXT')!,
                      onPressed: () {
                        if (selectedIndex == 3) {
                          Navigator.of(context).pushNamed(Routes.signupoptions);
                        } else {
                          setState(() {
                            selectedIndex++;

                            _pageController.animateToPage(selectedIndex,
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeInOut);
                          });
                        }

                        // Get.to(() => const SignUpOptions());
                      },
                    ),

                    selectedIndex == 3 ? const Spacer() : const SizedBox(),

                    // WidgetsUtil.verticalSpace16,

                    selectedIndex == 3
                        ? Container(
                            margin: const EdgeInsets.only(
                              top: 0,
                              bottom: 10,
                            ),
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
                          )
                        : const SizedBox()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
