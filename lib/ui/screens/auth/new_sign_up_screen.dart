import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/auth/cubits/signInCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

import '../../../app/routes.dart';
import '../../../utils/assets.dart';
import '../../../utils/constants.dart';
import '../../../utils/widgets_util.dart';
import '../../widgets/default_layout.dart';
import '../../widgets/social_button.dart';
import '../../widgets/terms.dart';
import '../../widgets/title_text.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

final _formKey = GlobalKey<FormState>();

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (_) => SignInCubit(
        AuthRepository(),
      ),
      child: Builder(
        builder: (context) => DefaultLayout(
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
              // WidgetsUtil.verticalSpace16,
              // SocialButton(
              //   textColor: Constants.black1,
              //   icon: Assets.google,
              //   onTap: () {},
              //   text: 'Sign Up with Google',
              //   showBorder: true,
              // ),

              SizedBox(height: 85, child: _showGoogleButton()),

              // WidgetsUtil.verticalSpace16,

              SizedBox(height: 75, child: _showFacebookButton()),
              // SocialButton(
              //   textColor: Constants.white,
              //   icon: Assets.facebook,
              //   onTap: () {},
              //   text: 'Sign Up with Facebook',
              //   showBorder: false,
              //   background: Constants.facebookColor,
              // ),
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
                      Navigator.of(context).pushNamed(Routes.loginScreen);
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
        ),
      ),
    );
  }
}

Widget _showGoogleButton() {
  return BlocConsumer<SignInCubit, SignInState>(
    listener: (context, state) {
      if (state is SignInSuccess && state.authProvider != AuthProvider.email) {
        context.read<AuthCubit>().updateAuthDetails(
            authProvider: state.authProvider,
            firebaseId: state.user.uid,
            authStatus: true,
            isNewUser: state.isNewUser);
        if (state.isNewUser) {
          context.read<UserDetailsCubit>().fetchUserDetails(state.user.uid);
          //navigate to select profile screen
          Navigator.of(context)
              .pushReplacementNamed(Routes.selectProfile, arguments: true);
        } else {
          //get user detials of signed in user
          context.read<UserDetailsCubit>().fetchUserDetails(state.user.uid);
          //updateFcm id
          log(state.user.uid);
          Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.loginScreen, (Route<dynamic> route) => false);
        }
      } else if (state is SignInFailure &&
          state.authProvider != AuthProvider.email) {
        UiUtils.setSnackbar(
          AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(state.errorMessage))!,
          context,
          false,
        );
      }
    },
    builder: (context, state) {
      if (state is SignInProgress && state.authProvider == AuthProvider.gmail) {
        return Center(
          child: CircularProgressIndicator(
            color: Constants.primaryColor,
          ),
        );
      }
      return SocialButton(
        textColor: Constants.black2,
        icon: Assets.google,
        background: Constants.white,
        onTap: () {
          context.read<SignInCubit>().signInUser(AuthProvider.gmail);
        },
        horizontalMargin: 16,
        verticalMargin: 24,
        text: AppLocalization.of(context)!
            .getTranslatedValues('loginWithGooleLbl')!,
        showBorder: true,
      );
    },
  );
}

Widget _showFacebookButton() {
  return BlocConsumer<SignInCubit, SignInState>(
    builder: (context, state) {
      if (state is SignInProgress && state.authProvider == AuthProvider.fb) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
              Constants.primaryColor,
            ),
          ),
        );
      }
      return SocialButton(
        textColor: Constants.white,
        icon: Assets.facebook,
        background: Constants.facebookColor,
        onTap: () {
          context.read<SignInCubit>().signInUser(AuthProvider.fb);
        },
        horizontalMargin: 16,
        verticalMargin: 16,
        text: AppLocalization.of(context)!
            .getTranslatedValues('loginWithFacebookLbl')!,
        showBorder: false,
      );
    },
    listener: (context, state) {
      //Exceuting only if authProvider is not email
      if (state is SignInSuccess && state.authProvider != AuthProvider.email) {
        context.read<AuthCubit>().updateAuthDetails(
              authProvider: state.authProvider,
              firebaseId: state.user.uid,
              authStatus: true,
              isNewUser: state.isNewUser,
            );
        if (state.isNewUser) {
          context.read<UserDetailsCubit>().fetchUserDetails(state.user.uid);
          //navigate to select profile screen
          Navigator.of(context)
              .pushReplacementNamed(Routes.selectProfile, arguments: true);
        } else {
          //get user detials of signed in user
          context.read<UserDetailsCubit>().fetchUserDetails(state.user.uid);
          //updateFcm id
          log(state.user.uid);

          Navigator.of(context)
              .pushReplacementNamed(Routes.home, arguments: false);
        }
      } else if (state is SignInFailure &&
          state.authProvider != AuthProvider.email) {
        UiUtils.setSnackbar(
          AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(state.errorMessage))!,
          context,
          false,
        );
      }
    },
  );
}
