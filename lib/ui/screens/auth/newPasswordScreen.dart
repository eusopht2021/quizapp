import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/ui/widgets/custom_button.dart';
import 'package:flutterquiz/ui/widgets/custom_text_field.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';

import 'package:flutterquiz/utils/widgets_util.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({Key? key}) : super(key: key);

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  // TextEditingController userPasswordController = TextEditingController();
  TextEditingController edtPwd = TextEditingController();
  bool _obscureText = true, isLoading = false;
  TextEditingController reEdtPwd = TextEditingController();
  bool _reObscureText = true, reIsLoading = false;

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        resizeToAvoidBottomInset: false,
        showBackButton: true,
        title: 'New Password',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WidgetsUtil.verticalSpace24,
              TitleText(
                text:
                    "Your new password must be different from previous used passwords.",
                weight: FontWeight.w400,
                textColor: Constants.grey2,
              ),
              WidgetsUtil.verticalSpace24,
              CustomTextField(
                horizontalMargin: 0,
                showBorder: true,
                controller: edtPwd,
                hidetext: _obscureText,
                obscuringCharacter: "●",
                validator: (val) => val!.isEmpty
                    ? '${AppLocalization.of(context)!.getTranslatedValues('pwdLengthMsg')}'
                    : null,
                label:
                    AppLocalization.of(context)!.getTranslatedValues('pwdLbl')!,
                hint:
                    "${AppLocalization.of(context)!.getTranslatedValues('pwdLbl')!}*",
                prefixIcon: Assets.password,
                suffixIcon: _obscureText ? Assets.closeEye : Assets.eye,
                onSuffixTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });

                  // log('Suffix');
                },
              ),
              WidgetsUtil.verticalSpace10,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TitleText(
                    text: 'Must be atleat 8 characters',
                    size: Constants.bodyXSmall,
                    weight: FontWeight.w400,
                    textColor: Constants.grey2,
                  ),
                  Icon(
                    Icons.check,
                    color: Constants.primaryColor,
                  )
                ],
              ),
              WidgetsUtil.verticalSpace24,
              CustomTextField(
                horizontalMargin: 0,
                showBorder: true,
                controller: reEdtPwd,
                hidetext: _reObscureText,
                obscuringCharacter: "●",
                validator: (val) => val!.isEmpty
                    ? '${AppLocalization.of(context)!.getTranslatedValues('pwdLengthMsg')}'
                    : null,
                label:
                    AppLocalization.of(context)!.getTranslatedValues('pwdLbl')!,
                hint:
                    "${AppLocalization.of(context)!.getTranslatedValues('pwdLbl')!}*",
                prefixIcon: Assets.password,
                suffixIcon: _reObscureText ? Assets.closeEye : Assets.eye,
                onSuffixTap: () {
                  setState(() {
                    _reObscureText = !_reObscureText;
                  });

                  // log('Suffix');
                },
              ),
              CustomButton(
                onPressed: () {},
                text: 'Reset Password',
                backgroundColor: Constants.primaryColor,
              )
            ],
          ),
        ));
  }
}
