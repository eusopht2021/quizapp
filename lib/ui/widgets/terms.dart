// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/ui/screens/new_settings/FAQ%20Screens/privacyPolicy.dart';
import 'package:flutterquiz/ui/screens/new_settings/FAQ%20Screens/terms.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';

class Terms extends StatelessWidget {
  const Terms({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 24,
        right: 24,
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: AppLocalization.of(context)!.getTranslatedValues('termsLbl'),
          style: GoogleFonts.rubik(
            fontSize: Constants.bodySmall,
            fontWeight: FontWeight.w400,
            color: Constants.grey3,
          ),
          children: [
            TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  log('Terms of services');
                },
              text: AppLocalization.of(context)!
                  .getTranslatedValues('termsAndServicesLbl'),
              style: GoogleFonts.rubik(
                  fontSize: Constants.bodySmall,
                  fontWeight: FontWeight.w500,
                  color: Constants.black1),
            ),
            TextSpan(
              text: AppLocalization.of(context)!
                  .getTranslatedValues('termsLblAnd'),
              style: GoogleFonts.rubik(
                fontSize: Constants.bodySmall,
                fontWeight: FontWeight.w400,
                color: Constants.grey3,
              ),
            ),
            TextSpan(
              text: AppLocalization.of(context)!
                  .getTranslatedValues('termsLblPrivacyPolicy'),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  log('Privacy Policy');

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen()));
                },
              style: GoogleFonts.rubik(
                fontSize: Constants.bodySmall,
                fontWeight: FontWeight.w500,
                color: Constants.black1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
