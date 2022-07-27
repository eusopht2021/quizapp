import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../app/appLocalization.dart';
import '../../../app/routes.dart';
import '../../../features/auth/authRemoteDataSource.dart';
import '../../../utils/assets.dart';
import '../../../utils/constants.dart';
import '../../../utils/uiUtils.dart';
import '../../../utils/validators.dart';
import '../../../utils/widgets_util.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/default_layout.dart';
import '../../widgets/title_text.dart';

class ResetPassword extends StatelessWidget {
  ResetPassword({Key? key}) : super(key: key);

  final _formKeyDialog = GlobalKey<FormState>();
  TextEditingController edtEmailReset = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: AppLocalization.of(context)!.getTranslatedValues('resetPwdLbl')!,
      child: Form(
        key: _formKeyDialog,
        child: Column(
          children: [
            WidgetsUtil.verticalSpace24,
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
              ),
              child: TitleText(
                text: AppLocalization.of(context)!
                    .getTranslatedValues('enterEmlTextLbl')!,
                size: Constants.bodyNormal,
                weight: FontWeight.w400,
              ),
            ),
            WidgetsUtil.verticalSpace24,
            CustomTextField(
              controller: edtEmailReset,
              validator: (val) => Validators.validateEmail(
                  val!,
                  AppLocalization.of(context)!
                      .getTranslatedValues('emailRequiredMsg')!,
                  AppLocalization.of(context)!
                      .getTranslatedValues('validEmail')),
              onSaved: (value) => edtEmailReset.text = value!.trim(),
              label: AppLocalization.of(context)!
                  .getTranslatedValues('emailFldLbl')!,
              hint: AppLocalization.of(context)!
                  .getTranslatedValues('enterEmailLbl')!,
              prefixIcon: Assets.mail,
            ),
            const Spacer(),
            CustomButton(
              text: AppLocalization.of(context)!
                  .getTranslatedValues('resetPwdLbl')!,
              onPressed: () {
                resetPswd(context);
                // Navigator.of(context).pushNamed(Routes.loginScreen);
              },
            ),
            WidgetsUtil.verticalSpace24,
          ],
        ),
      ),
    );
  }

  resetPswd(context) {
    //submit button
    final form = _formKeyDialog.currentState;
    if (form!.validate()) {
      form.save();
      UiUtils.setSnackbar(
          AppLocalization.of(context)!.getTranslatedValues('pwdResetLinkLbl')!,
          context,
          false);
      AuthRemoteDataSource()
          .resetPassword(edtEmailReset.text.trim())
          .then((value) {
        log("link sent");
      });
      Future.delayed(const Duration(seconds: 1), () {});
    }
  }
}
