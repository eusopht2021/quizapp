import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/customDialog.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'fontSizeDialog.dart';

class SettingsDialogContainer extends StatelessWidget {
  SettingsDialogContainer({Key? key}) : super(key: key);

  late final List<SettingItem> settingItems = [
    SettingItem(
        icon: UiUtils.getImagePath("sound_icon.svg"),
        showSwitch: true,
        title: soundLbl),
    SettingItem(
        icon: UiUtils.getImagePath("vibrate_icon.svg"),
        showSwitch: true,
        title: vibrationLbl),
    SettingItem(
        icon: UiUtils.getImagePath("fontsize_icon.svg"),
        showSwitch: false,
        title: fontSizeLbl),
  ];
  Widget _buildSettingsItem(int settingItemIndex, BuildContext context) {
    const sizedBoxHeight = 2.5;
    return Container(
      padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
      child: GestureDetector(
        onTap: () {
          if (settingItemIndex == 0) {
            context.read<SettingsCubit>().changeSound(
                !context.read<SettingsCubit>().state.settingsModel!.sound);
          } else if (settingItemIndex == 1) {
            context.read<SettingsCubit>().changeVibration(
                !context.read<SettingsCubit>().state.settingsModel!.vibration);
          } else if (settingItemIndex == 2) {
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (_) =>
                    FontSizeDialog(bloc: context.read<SettingsCubit>()));
          }
        },
        child: Column(
          children: [
            const SizedBox(
              height: sizedBoxHeight,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 15.0,
                ),
                Container(
                  width: 30.0,
                  height: 27.0,
                  transform: Matrix4.identity()..scale(0.8),
                  child: SvgPicture.asset(
                    settingItems[settingItemIndex].icon!,
                    fit: BoxFit.cover,
                    color: Constants.white,
                  ),
                ),
                const SizedBox(
                  width: 15.0,
                ),
                TitleText(
                    text:
                        "${AppLocalization.of(context)!.getTranslatedValues(settingItems[settingItemIndex].title)}",
                    size: 16,
                    textColor: Constants.white),
                settingItems[settingItemIndex].showSwitch!
                    ? const Spacer()
                    : Container(),
                settingItems[settingItemIndex].showSwitch!
                    ? Transform.translate(
                        offset: const Offset(10.0, 0.0),
                        child: SizedBox(
                            height: 27.50,
                            child: Transform.scale(
                              scale: 0.6,
                              child: BlocBuilder<SettingsCubit, SettingsState>(
                                bloc: context.read<SettingsCubit>(),
                                builder: (context, state) {
                                  bool? value = false;

                                  //see this values in settingItems list
                                  if (settingItemIndex == 0) {
                                    value = state.settingsModel!.sound;
                                  } else if (settingItemIndex == 1) {
                                    value = state.settingsModel!.vibration;
                                  }
                                  return CupertinoSwitch(
                                    value: value,
                                    activeColor: Constants.secondaryColor,
                                    onChanged: (value) {
                                      //see this values in settingItems list
                                      if (settingItemIndex == 0) {
                                        context
                                            .read<SettingsCubit>()
                                            .changeSound(value);
                                      } else if (settingItemIndex == 1) {
                                        context
                                            .read<SettingsCubit>()
                                            .changeVibration(value);
                                      }
                                    },
                                  );
                                },
                              ),
                            )),
                      )
                    : Container()
              ],
            ),
            const SizedBox(
              height: sizedBoxHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: settingItems.map((e) {
        int index = settingItems.indexOf(e);
        return _buildSettingsItem(index, context);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      height: MediaQuery.of(context).size.height * 0.35,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UiUtils.dailogRadius),
            color: Constants.primaryColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.025),
            ),
            TitleText(
                text: AppLocalization.of(context)!
                    .getTranslatedValues("settingLbl")!,
                textColor: Constants.white,
                size: 20,
                weight: FontWeight.bold),
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.025),
            ),
            _buildSettingsContainer(context),
          ],
        ),
      ),
    );
  }
}

class SettingItem {
  final String? icon;
  final String? title;
  final bool? showSwitch;

  SettingItem({this.icon, this.showSwitch, this.title});
}
