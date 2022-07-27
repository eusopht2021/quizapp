import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/auth/cubits/signUpCubit.dart';
import 'package:flutterquiz/ui/widgets/custom_button.dart';
import 'package:flutterquiz/ui/widgets/custom_text_field.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutterquiz/utils/validators.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class SignUpProcess extends StatefulWidget {
  SignUpProcess({Key? key}) : super(key: key);

  @override
  State<SignUpProcess> createState() => _SignUpProcessState();
}

class _SignUpProcessState extends State<SignUpProcess> {
  TextEditingController edtEmail = TextEditingController();
  TextEditingController edtPwd = TextEditingController();
  TextEditingController edtCPwd = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FocusNode emailFocus = FocusNode(),
      passwordFocus = FocusNode(),
      cPasswordFocus = FocusNode();
  bool _obscureText = true, _obscureTextCn = true, isLoading = false;

  PageController pageController = PageController();

  int selectedProcess = 0;

  List<String?> signUpProcess = [];

  @override
  Widget build(BuildContext context) {
    signUpProcess = [
      AppLocalization.of(context)!.getTranslatedValues('whatIsEmail'),
      AppLocalization.of(context)!.getTranslatedValues('whatIsPassword'),
      AppLocalization.of(context)!.getTranslatedValues('confirmPassword'),
    ];
    return BlocProvider<SignUpCubit>(
      create: (context) => SignUpCubit(AuthRepository()),
      child: Builder(
        builder: (context) => body(),
      ),
    );
  }

  Widget body() {
    return DefaultLayout(
      title: signUpProcess[selectedProcess]!,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            WidgetsUtil.verticalSpace24,
            Expanded(
              child: PageView.builder(
                // physics: NeverScrollableScrollPhysics(),
                controller: pageController,
                itemCount: signUpProcess.length,
                onPageChanged: (value) {
                  setState(() {
                    selectedProcess = value;
                  });
                },
                itemBuilder: (context, index) {
                  return getTextField(index);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                bottom: 8,
                right: 24,
              ),
              alignment: Alignment.centerRight,
              child: TitleText(
                text: '${selectedProcess + 1} of 3',
                size: Constants.bodyNormal,
                weight: FontWeight.w500,
                textColor: Constants.primaryColor,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 24,
                right: 24,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Constants.primaryColor,
                ),
                value: (selectedProcess + 1) / 3,
                backgroundColor: Constants.primaryColor.withOpacity(0.3),
              ),
            ),
            WidgetsUtil.verticalSpace24,
            signUpButton(),
            WidgetsUtil.verticalSpace24,
          ],
        ),
      ),
    );
  }

  Widget signUpButton() {
    return BlocConsumer<SignUpCubit, SignUpState>(
      listener: (context, state) async {
        if (state is SignUpSuccess) {
          //on signup success navigate user to sign in screen
          UiUtils.setSnackbar(
            "${AppLocalization.of(context)!.getTranslatedValues('emailVerify')} ${edtEmail.text.trim()}",
            context,
            false,
          );
          setState(() {
            Navigator.pop(context);
          });
        } else if (state is SignUpFailure) {
          //show error message
          UiUtils.setSnackbar(
            AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessage))!,
            context,
            false,
          );
        }
      },
      builder: (context, state) {
        return CustomButton(
          isLoading: state is SignUpProgress,
          text: selectedProcess == 2
              ? AppLocalization.of(context)!.getTranslatedValues('signUpLbl')
              : 'Next',
          onPressed: () {
            if (selectedProcess != signUpProcess.length) {
              if (selectedProcess == 0) {
                if (_formKey.currentState!.validate()) {
                  emailFocus.unfocus();
                  selectedProcess++;
                  pageController.animateToPage(
                    selectedProcess,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInCirc,
                  );
                  passwordFocus.requestFocus();
                }
              } else if (selectedProcess == 1) {
                if (_formKey.currentState!.validate()) {
                  passwordFocus.unfocus();
                  selectedProcess++;
                  pageController.animateToPage(
                    selectedProcess,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInCirc,
                  );
                  cPasswordFocus.requestFocus();
                }
              } else if (selectedProcess == 2) {
                if (_formKey.currentState!.validate()) {
                  log('Validation complete!');
                  cPasswordFocus.unfocus();
                  context.read<SignUpCubit>().signUpUser(
                        AuthProvider.email,
                        edtEmail.text.trim(),
                        edtPwd.text.trim(),
                      );
                }
              }
            }
          },
        );
      },
    );
  }

  Widget getTextField(int index) {
    if (index == 0) {
      return CustomTextField(
        controller: edtEmail,
        node: emailFocus,
        textInputType: TextInputType.emailAddress,
        validator: (val) => Validators.validateEmail(
          val!,
          AppLocalization.of(context)!.getTranslatedValues('emailRequiredMsg')!,
          AppLocalization.of(context)!.getTranslatedValues('invalidEmail'),
        ),
        label: AppLocalization.of(context)!.getTranslatedValues(
          'emailLbl',
        ),
        hint: AppLocalization.of(context)!.getTranslatedValues(
              'emailLbl',
            )! +
            "*",
        prefixIcon: Assets.mail,
      );
    } else if (index == 1) {
      return CustomTextField(
        controller: edtPwd,
        node: passwordFocus,
        hidetext: _obscureText,
        label: 'Password',
        textInputType: TextInputType.visiblePassword,
        hint: AppLocalization.of(context)!.getTranslatedValues('pwdLbl')! + "*",
        validator: (value) => Validators.validatePassword(
          value!,
          '${AppLocalization.of(context)!.getTranslatedValues('pwdLengthMsg')}',
        ),
        prefixIcon: Assets.password,
        suffixIcon: _obscureText ? Assets.eye : Assets.closeEye,
        onSuffixTap: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else {
      return CustomTextField(
        controller: edtCPwd,
        node: cPasswordFocus,
        label: 'Confirm Password',
        hint:
            AppLocalization.of(context)!.getTranslatedValues('cnPwdLbl')! + "*",
        prefixIcon: Assets.password,
        suffixIcon: _obscureTextCn ? Assets.eye : Assets.closeEye,
        hidetext: _obscureTextCn,
        validator: (value) {
          String password = edtPwd.text;
          print(password);
          if (value != password) {
            return AppLocalization.of(context)!
                .getTranslatedValues('passwordNotMatch');
          }
          return null;
        },
        onSuffixTap: () {
          setState(() {
            _obscureTextCn = !_obscureTextCn;
          });
        },
      );
    }
  }
}
