import 'package:flutter/material.dart';
import 'package:flutterquiz/features/localization/appLocalizationCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class LanguageDailogContainer extends StatelessWidget {
  LanguageDailogContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final supportedLanguages =
        context.read<SystemConfigCubit>().getSupportedLanguages();
    return BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
      bloc: context.read<AppLocalizationCubit>(),
      builder: (context, state) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: supportedLanguages.map((language) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: state.language ==
                            UiUtils.getLocaleFromLanguageCode(
                                language.languageCode)
                        ? Constants.primaryColor
                        : Constants.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    trailing: state.language ==
                            UiUtils.getLocaleFromLanguageCode(
                                language.languageCode)
                        ? Icon(
                            Icons.check,
                            color: Constants.white,
                          )
                        : SizedBox(),
                    onTap: () {
                      if (state.language !=
                          UiUtils.getLocaleFromLanguageCode(
                              language.languageCode)) {
                        context
                            .read<AppLocalizationCubit>()
                            .changeLanguage(language.languageCode);
                      }
                    },
                    title: Text(
                      language.language,
                      style: TextStyle(
                        color: state.language ==
                                UiUtils.getLocaleFromLanguageCode(
                                    language.languageCode)
                            ? Constants.white
                            : Constants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

/*

 */