import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../utils/assets.dart';
import '../../../utils/constants.dart';
import '../../../utils/widgets_util.dart';
import '../../widgets/default_layout.dart';
import '../../widgets/social_button.dart';
import '../../widgets/terms.dart';
import '../../widgets/title_text.dart';

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: 'Sign Up',
      child: Column(
        children: [
          WidgetsUtil.verticalSpace24,
          SocialButton(
            textColor: Constants.white,
            icon: Assets.mail,
            iconColor: Constants.white,
            onTap: () {
              log('Go to SignUpProcess');

              Navigator.of(context).pushNamed(Routes.signupprocess);
              // Get.to(
              //   () => SignUpProcess(),
              // );
            },
            text: 'Sign Up with Email',
            showBorder: false,
            background: Constants.primaryColor,
          ),
          WidgetsUtil.verticalSpace16,
          SocialButton(
            textColor: Constants.black1,
            icon: Assets.google,
            onTap: () {},
            text: 'Sign Up with Google',
            showBorder: true,
          ),
          WidgetsUtil.verticalSpace16,
          SocialButton(
            textColor: Constants.white,
            icon: Assets.facebook,
            onTap: () {},
            text: 'Sign Up with Facebook',
            showBorder: false,
            background: Constants.facebookColor,
          ),
          WidgetsUtil.verticalSpace24,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TitleText(
                text: 'Already have an account? ',
                textColor: Constants.grey2,
                size: Constants.bodyNormal,
                weight: FontWeight.w400,
              ),
              InkWell(
                onTap: () {
                  // Get.to(
                  //   () => const Login(),
                  // );
                },
                child: TitleText(
                  text: 'Login',
                  textColor: Constants.primaryColor,
                  size: Constants.bodyNormal,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
          WidgetsUtil.verticalSpace24,
          const Terms(),
          WidgetsUtil.verticalSpace24,
        ],
      ),
    );
  }
}
