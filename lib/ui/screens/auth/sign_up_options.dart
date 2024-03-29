import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/social_button.dart';

import '../../../app/appLocalization.dart';
import '../../../app/routes.dart';
import '../../../utils/assets.dart';
import '../../../utils/constants.dart';
import '../../../utils/widgets_util.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/default_background.dart';
import '../../widgets/title_text.dart';

class SignUpOptions extends StatelessWidget {
  const SignUpOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultBackground(
      background: Assets.background1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WidgetsUtil.verticalSpace24,
          // WidgetsUtil.verticalSpace24,
          WidgetsUtil.verticalSpace16,
          Expanded(
            flex: 3,
            child: Column(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.asset(
                    'assets/icons/light_icon.png',
                  ),
                ),
                WidgetsUtil.verticalSpace10,
                TitleText(
                  text: 'Queezy',
                  textColor: Constants.white,
                  size: Constants.heading3 - 2,
                  fontFamily: 'Nunito',
                  weight: FontWeight.w800,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.only(
                left: 24,
                right: 24,
              ),
              alignment: Alignment.center,
              child: Image.asset(
                Assets.personsMeeting,
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: CustomCard(
              // height: double.infinity,
              child: Column(
                children: [
                  WidgetsUtil.verticalSpace16,
                  Expanded(
                    flex: 1,
                    child: TitleText(
                      text: AppLocalization.of(context)!
                          .getTranslatedValues('loginOrSignUpLbl')!,
                      size: Constants.heading3,
                      weight: FontWeight.w500,
                    ),
                  ),
                  // WidgetsUtil.verticalSpace8,
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                      ),
                      child: TitleText(
                        text: AppLocalization.of(context)!
                            .getTranslatedValues('optionScreenTextLbl')!,
                        align: TextAlign.center,
                        size: Constants.bodyNormal,
                        textColor: Constants.grey2,
                        weight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      height: 56,
                      text: AppLocalization.of(context)!
                          .getTranslatedValues('loginLbl')!,
                      onPressed: () {
                        Navigator.of(context).pushNamed(Routes.loginScreen);
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                        height: 56,
                        backgroundColor: Constants.grey4,
                        text: AppLocalization.of(context)!
                            .getTranslatedValues('createAccountLbl')!,
                        textColor: Constants.primaryColor,
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.signupScreen);
                        }),
                  ),
                  // const Spacer(),
                  Expanded(
                    flex: 2,
                    child: SocialButton(
                      textColor: Constants.grey2,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      text: AppLocalization.of(context)!
                          .getTranslatedValues('laterLbl')!,
                      showBorder: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
