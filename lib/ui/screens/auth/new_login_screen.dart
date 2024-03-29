import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/ui/widgets/social_button.dart';

import '../../../app/appLocalization.dart';
import '../../../app/routes.dart';
import '../../../features/auth/cubits/authCubit.dart';
import '../../../features/auth/cubits/signInCubit.dart';
import '../../../features/profileManagement/cubits/userDetailsCubit.dart';
import '../../../utils/assets.dart';
import '../../../utils/constants.dart';
import '../../../utils/errorMessageKeys.dart';
import '../../../utils/uiUtils.dart';
import '../../../utils/validators.dart';
import '../../../utils/widgets_util.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_divider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/default_layout.dart';
import '../../widgets/terms.dart';
import '../../widgets/title_text.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController edtEmailReset = TextEditingController();
  TextEditingController edtEmail = TextEditingController();
  TextEditingController edtPwd = TextEditingController();
  bool _obscureText = true, isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: BlocProvider<SignInCubit>(
        create: (_) => SignInCubit(
          AuthRepository(),
        ),
        child: Builder(
          builder: (context) => DefaultLayout(
            title: AppLocalization.of(context)!
                .getTranslatedValues('userLoginLbl')!,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 85,
                      child: _showGoogleButton(),
                    ),
                    SizedBox(
                      height: 75,
                      child: _showFacebookButton(),
                    ),
                    CustomDivider(
                      text: AppLocalization.of(context)!
                          .getTranslatedValues('or')!,
                      verticalMargin: 24,
                    ),
                    WidgetsUtil.verticalSpace24,
                    CustomTextField(
                      controller: edtEmail,
                      keyboardtype: TextInputType.emailAddress,
                      label: AppLocalization.of(context)!
                          .getTranslatedValues('emailFldLbl')!,
                      textInputType: TextInputType.emailAddress,
                      hint:
                          "${AppLocalization.of(context)!.getTranslatedValues('emailLbl')!}*",
                      validator: (val) => Validators.validateEmail(
                        val!,
                        AppLocalization.of(context)!
                            .getTranslatedValues('emailRequiredMsg')!,
                        AppLocalization.of(context)!
                            .getTranslatedValues('VALID_EMAIL'),
                      ),
                      prefixIcon: Assets.mail,
                    ),
                    WidgetsUtil.verticalSpace16,
                    CustomTextField(
                      controller: edtPwd,
                      hidetext: _obscureText,
                      obscuringCharacter: "●",
                      validator: (val) => val!.isEmpty
                          ? '${AppLocalization.of(context)!.getTranslatedValues('pwdLengthMsg')}'
                          : null,
                      label: AppLocalization.of(context)!
                          .getTranslatedValues('pwdLbl')!,
                      hint:
                          "${AppLocalization.of(context)!.getTranslatedValues('pwdLbl')!}*",
                      prefixIcon: Assets.password,
                      suffixIcon: _obscureText ? Assets.eye : Assets.closeEye,
                      onSuffixTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });

                        log('Suffix');
                      },
                    ),
                    showSignIn(context),
                    WidgetsUtil.verticalSpace24,
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.resetpswdScreen);
                      },
                      child: TitleText(
                        text: AppLocalization.of(context)!
                            .getTranslatedValues('forgotPwdLbl')!,
                        size: Constants.bodyNormal,
                        textColor: Constants.primaryColor,
                        weight: FontWeight.w500,
                      ),
                    ),
                    WidgetsUtil.verticalSpace24,
                    const Terms(),
                    WidgetsUtil.verticalSpace24,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showGoogleButton() {
    return BlocConsumer<SignInCubit, SignInState>(
      listener: (context, state) {
        //Exceuting only if authProvider is not email
        if (state is SignInSuccess &&
            state.authProvider != AuthProvider.email) {
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
            print(state.user.uid);
            Navigator.of(context)
                .pushReplacementNamed(Routes.home, arguments: false);
          }
        } else if (state is SignInFailure &&
            state.authProvider != AuthProvider.email) {
          UiUtils.setSnackbar(
              AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage))!,
              context,
              false);
        }
      },
      builder: (context, state) {
        if (state is SignInProgress &&
            state.authProvider == AuthProvider.gmail) {
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

  Widget showEmailForForgotPwd() {
    return CustomTextField(
      controller: edtEmailReset,
      keyboardtype: TextInputType.emailAddress,
      validator: (val) => Validators.validateEmail(
          val!,
          AppLocalization.of(context)!.getTranslatedValues('emailRequiredMsg')!,
          AppLocalization.of(context)!.getTranslatedValues('validEmail')),
      onSaved: (value) => edtEmailReset.text = value!.trim(),
      hint: AppLocalization.of(context)!.getTranslatedValues('enterEmailLbl')!,
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
        if (state is SignInSuccess &&
            state.authProvider != AuthProvider.email) {
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

  Widget showSignIn(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: BlocConsumer<SignInCubit, SignInState>(
        bloc: context.read<SignInCubit>(),
        listener: (context, state) async {
          //Exceuting only if authProvider is email
          if (state is SignInSuccess &&
              state.authProvider == AuthProvider.email) {
            //to update authdetails after successfull sign in
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
              Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.home, (Route<dynamic> route) => false);
            }
          } else if (state is SignInFailure &&
              state.authProvider == AuthProvider.email) {
            UiUtils.setSnackbar(
                AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(state.errorMessage))!,
                context,
                false);
          } else if (state is SignInFailure &&
              state.authProvider == AuthProvider.password) {
            UiUtils.setSnackbar(
                AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(state.errorMessage))!,
                context,
                false);
          }
        },
        builder: (context, state) {
          return CustomButton(
            onPressed: state is SignInProgress
                ? () {}
                : () async {
                    if (_formKey.currentState!.validate()) {
                      {
                        print("${edtEmail.text} AnD ${edtPwd.text}");
                        context.read<SignInCubit>().signInUser(
                            AuthProvider.email,
                            email: edtEmail.text.trim(),
                            password: edtPwd.text.trim());
                      }
                    }
                  },
            text: AppLocalization.of(context)!.getTranslatedValues('loginLbl')!,
            isLoading: state is SignInProgress,
          );
        },
      ),
    );
  }
}
