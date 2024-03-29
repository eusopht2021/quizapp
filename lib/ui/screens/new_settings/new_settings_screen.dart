import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/audioQuestionBookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guessTheWordBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/deleteAccountCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/uploadProfileCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/systemConfig/cubits/appSettingsCubit.dart';
import 'package:flutterquiz/features/systemConfig/systemConfigRepository.dart';
import 'package:flutterquiz/ui/navigation/navbarcubit.dart';
import 'package:flutterquiz/ui/navigation/navbaritems.dart';
import 'package:flutterquiz/ui/screens/home/widgets/languageBottomSheetContainer.dart';
import 'package:flutterquiz/ui/screens/new_settings/FAQ%20Screens/about.dart';
import 'package:flutterquiz/ui/screens/new_settings/FAQ%20Screens/contactUs.dart';
import 'package:flutterquiz/ui/screens/new_settings/FAQ%20Screens/faq_screen.dart';
import 'package:flutterquiz/ui/screens/profile/widgets/editProfileFieldBottomSheetContainer.dart';
import 'package:recase/recase.dart';

import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/custom_appbar.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutterquiz/utils/widgets_util.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:launch_review/launch_review.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewSettingsScreen extends StatefulWidget {
  final String title;

  const NewSettingsScreen({Key? key, required this.title}) : super(key: key);

  static Route<NewSettingsScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: ((_) => MultiBlocProvider(
            providers: [
              BlocProvider<AppSettingsCubit>(
                create: (_) => AppSettingsCubit(
                  SystemConfigRepository(),
                ),
              ),
              BlocProvider<DeleteAccountCubit>(
                  create: (_) =>
                      DeleteAccountCubit(ProfileManagementRepository())),
              BlocProvider<UploadProfileCubit>(
                create: (context) => UploadProfileCubit(
                  ProfileManagementRepository(),
                ),
              ),
              BlocProvider<UpdateUserDetailCubit>(
                create: (context) => UpdateUserDetailCubit(
                  ProfileManagementRepository(),
                ),
              ),
            ],
            child: NewSettingsScreen(title: routeSettings.arguments as String),
          )),
    );
  }

  @override
  State<NewSettingsScreen> createState() => _NewSettingsScreenState();
}

class _NewSettingsScreenState extends State<NewSettingsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  TextEditingController? oldPassword;
  TextEditingController? newPassword;
  TextEditingController? confirmPassword;
  bool _isOn = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadProfileCubit, UploadProfileState>(
      listener: (context, state) {
        if (state is UploadProfileFailure) {
          UiUtils.setSnackbar(
              AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage))!,
              context,
              false);
        } else if (state is UploadProfileSuccess) {
          context.read<UserDetailsCubit>().updateUserProfileUrl(state.imageUrl);
        }
      },
      builder: (context, state) {
        return BlocBuilder<UserDetailsCubit, UserDetailsState>(
            bloc: context.read<UserDetailsCubit>(),
            builder: (context, state) {
              if (state is UserDetailsFetchSuccess) {
                return Scaffold(
                  backgroundColor: Constants.white,
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                    child: CustomAppBar(
                      title: "Settings",
                      showBackButton: true,
                      backgroundColor: Constants.white,
                      textColor: Constants.black1,
                      iconColor: Constants.black1,
                      onBackTapped: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          WidgetsUtil.verticalSpace24,
                          TitleText(
                            text: AppLocalization.of(context)!
                                .getTranslatedValues("account")!,
                            textColor: Constants.black1.withOpacity(0.5),
                            weight: FontWeight.w500,
                            size: Constants.bodyNormal,
                          ),
                          WidgetsUtil.verticalSpace16,

                          _settingsOptionsContainer(
                            listTileicon: Image.asset(
                              Assets.person,
                              height: 25,
                              width: 25,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: AppLocalization.of(context)!
                                .getTranslatedValues("updateUsername")!,
                            subtitle: state.userProfile.name!.titleCase,
                            onTap: () {
                              editProfileFieldBottomSheet(
                                nameLbl,
                                state.userProfile.name!.isEmpty
                                    ? ""
                                    : state.userProfile.name!,
                                false,
                                context,
                                context.read<UpdateUserDetailCubit>(),
                              );
                            },
                          ),
                          WidgetsUtil.verticalSpace16,

                          _settingsOptionsContainer(
                            showIcon: false,
                            listTileicon: Image.asset(
                              Assets.mail,
                              height: 25,
                              width: 25,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: "Change Email Address",
                            subtitle: state.userProfile.email!.isEmpty
                                ? "-"
                                : state.userProfile.email!,
                          ),
                          WidgetsUtil.verticalSpace16,

                          _settingsOptionsContainer(
                            listTileicon: Image.asset(
                              Assets.password,
                              height: 25,
                              width: 25,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: AppLocalization.of(context)!
                                .getTranslatedValues("changePassword")!,
                            subtitle: "last change 1 year ago",
                            onTap: () {
                              editpasswordFieldBottomSheet(
                                  fieldTitle: pwdLbl,
                                  fieldValue: "",
                                  isPassword: true,
                                  isNumericKeyboardEnable: false,
                                  context: context,
                                  updateUserDetailCubit:
                                      context.read<UpdateUserDetailCubit>(),
                                  userDetailsCubit:
                                      context.read<UserDetailsCubit>());
                            },
                          ),
                          WidgetsUtil.verticalSpace16,

                          _settingsOptionsContainer(
                            title: AppLocalization.of(context)!
                                .getTranslatedValues("language")!,
                            subtitle: "Change Language",
                            onTap: () {
                              Navigator.of(context).pop();
                              showDialog(
                                  context: context,
                                  builder: (_) => LanguageDailogContainer());
                            },
                            listTileicon: Icon(
                              Icons.language,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          WidgetsUtil.verticalSpace16,

                          // _settingsOptionsContainer(
                          //   listTileicon: Icon(
                          //     Icons.brightness_7,
                          //     color: Theme.of(context).primaryColor,
                          //   ),
                          //   onTap: () {
                          //     Navigator.of(context).pop();
                          //     showDialog(
                          //         context: context,
                          //         builder: (_) => const ThemeDialog());
                          //   },
                          //   title: "Theme",
                          //   subtitle: "Change App Theme",
                          // ),
                          // WidgetsUtil.verticalSpace16,
                          _settingsOptionsContainer(
                            title: AppLocalization.of(context)!
                                .getTranslatedValues(coinStoreKey)!,
                            subtitle: "View Coin Store",
                            onTap: () {
                              Navigator.of(context).pushNamed(Routes.coinStore);
                            },
                            listTileicon: FaIcon(
                              FontAwesomeIcons.coins,
                              color: Constants.primaryColor,
                            ),
                          ),
                          WidgetsUtil.verticalSpace16,

                          _settingsOptionsContainer(
                            title: AppLocalization.of(context)!
                                .getTranslatedValues(rewardsLbl)!,
                            subtitle: "View Rewards",
                            onTap: () {
                              Navigator.of(context).pushNamed(Routes.rewards);
                            },
                            listTileicon: Icon(
                              Icons.redeem,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          WidgetsUtil.verticalSpace16,

                          _settingsOptionsContainer(
                            listTileicon: Icon(
                              Icons.brightness_7,
                              color: Theme.of(context).primaryColor,
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(Routes.wallet);
                            },
                            title: AppLocalization.of(context)!
                                .getTranslatedValues(walletKey)!,
                            subtitle: "Wallet",
                          ),
                          WidgetsUtil.verticalSpace16,

                          _settingsOptionsContainer(
                              listTileicon: Icon(
                                Icons.toll,
                                color: Constants.primaryColor,
                              ),
                              title: "Coin History",
                              subtitle: "View Coin History",
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(Routes.coinHistory);
                              }),
                          WidgetsUtil.verticalSpace16,

                          _settingsOptionsContainer(
                              title: AppLocalization.of(context)!
                                  .getTranslatedValues("deleteAccount")!,
                              subtitle: "Delete your Account",
                              listTileicon: Icon(
                                Icons.delete_outline_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                              onTap: () {
                                showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          content: Text(
                                            AppLocalization.of(context)!
                                                .getTranslatedValues(
                                                    deleteAccountConfirmationKey)!,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                  Navigator
                                                      .pushNamedAndRemoveUntil(
                                                          context,
                                                          Routes
                                                              .onBoardingScreen,
                                                          (route) => false);
                                                  BlocProvider.of<
                                                              NavigationCubit>(
                                                          context)
                                                      .getNavBarItem(
                                                          NavbarItems.newhome);
                                                },
                                                child: Text(
                                                  AppLocalization.of(context)!
                                                      .getTranslatedValues(
                                                          "yesBtn")!,
                                                  style: TextStyle(
                                                      color: Constants
                                                          .primaryColor),
                                                )),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                child: Text(
                                                  AppLocalization.of(context)!
                                                      .getTranslatedValues(
                                                          "noBtn")!,
                                                  style: TextStyle(
                                                      color: Constants
                                                          .primaryColor),
                                                )),
                                          ],
                                        )).then((value) {
                                  if (value != null && value) {
                                    context
                                        .read<DeleteAccountCubit>()
                                        .deleteUserAccount(
                                            userId: context
                                                .read<UserDetailsCubit>()
                                                .getUserId());
                                  }
                                });
                              }),

                          WidgetsUtil.verticalSpace24,
                          TitleText(
                            text: "OTHER",
                            textColor: Constants.black1.withOpacity(0.5),
                            weight: FontWeight.w500,
                            size: Constants.bodyNormal,
                          ),
                          WidgetsUtil.verticalSpace24,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TitleText(
                                text: AppLocalization.of(context)!
                                    .getTranslatedValues("notificationLbl")!,
                                textColor: Constants.black1,
                                weight: FontWeight.w500,
                                size: Constants.bodyNormal,
                              ),
                              FlutterSwitch(
                                padding: 2,
                                height: 24,
                                width: 44,
                                value: _isOn,
                                onToggle: (value) {
                                  setState(() {
                                    _isOn = value;
                                  });
                                },
                                activeColor: Theme.of(context).primaryColor,
                              )
                            ],
                          ),
                          WidgetsUtil.verticalSpace24,
                          // _settingsOptionsContainer(
                          //   listTileicon: SvgPicture.asset(
                          //     Assets.puzzleIcon,
                          //     height: 25,
                          //     width: 25,
                          //     color: Theme.of(context).primaryColor,
                          //   ),
                          //   title: "Change Difficulty",
                          //   subtitle: "Easy, normal, hard",
                          //   onTap: () {
                          //     // Navigator.push(
                          //     //     context,
                          //     //     MaterialPageRoute(
                          //     //         builder: (_) => const VoiceNoteScreen()));
                          //   },
                          // ),
                          // WidgetsUtil.verticalSpace16,
                          _settingsOptionsContainer(
                            listTileicon: Icon(
                              Icons.question_mark,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: "FAQ",
                            subtitle: "Most frequently asked questions",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const FaqScreen()));
                            },
                          ),
                          WidgetsUtil.verticalSpace16,
                          _settingsOptionsContainer(
                            title: AppLocalization.of(context)!
                                .getTranslatedValues("contactUs")!,
                            listTileicon: Icon(
                              Icons.contacts_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            subtitle: "for any Enquiry",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ContactUs()));
                            },
                          ),
                          WidgetsUtil.verticalSpace16,
                          _settingsOptionsContainer(
                            title: AppLocalization.of(context)!
                                .getTranslatedValues("aboutUs")!,
                            listTileicon: Icon(
                              Icons.info_outline,
                              color: Theme.of(context).primaryColor,
                            ),
                            subtitle: AppLocalization.of(context)!
                                .getTranslatedValues("aboutUs")!,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AboutUs()));
                            },
                          ),
                          WidgetsUtil.verticalSpace16,
                          _settingsOptionsContainer(
                            listTileicon: Icon(
                              Icons.stars,
                              color: Theme.of(context).primaryColor,
                            ),
                            subtitle: AppLocalization.of(context)!
                                .getTranslatedValues("rateUsLbl")!,
                            title: AppLocalization.of(context)!
                                .getTranslatedValues("rateUsLbl")!,
                            onTap: () {
                              /// rate us button
                              Navigator.of(context).pop();
                              LaunchReview.launch(
                                androidAppId: packageName,
                                iOSAppId: "585027354",
                              );
                            },
                          ),
                          WidgetsUtil.verticalSpace32,
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                        content: Text(
                                          AppLocalization.of(context)!
                                              .getTranslatedValues(
                                                  "logoutDialogLbl")!,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();

                                                context
                                                    .read<BadgesCubit>()
                                                    .updateState(
                                                        BadgesInitial());
                                                context
                                                    .read<BookmarkCubit>()
                                                    .updateState(
                                                        BookmarkInitial());
                                                context
                                                    .read<
                                                        GuessTheWordBookmarkCubit>()
                                                    .updateState(
                                                        GuessTheWordBookmarkInitial());

                                                context
                                                    .read<
                                                        AudioQuestionBookmarkCubit>()
                                                    .updateState(
                                                        AudioQuestionBookmarkInitial());

                                                context
                                                    .read<AuthCubit>()
                                                    .signOut();

                                                Navigator.of(context)
                                                    .pushNamedAndRemoveUntil(
                                                  Routes.onBoardingScreen,
                                                  (route) => false,
                                                );
                                                BlocProvider.of<
                                                            NavigationCubit>(
                                                        context)
                                                    .getNavBarItem(
                                                        NavbarItems.newhome);
                                              },
                                              child: Text(
                                                AppLocalization.of(context)!
                                                    .getTranslatedValues(
                                                        "yesBtn")!,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              )),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                AppLocalization.of(context)!
                                                    .getTranslatedValues(
                                                        "noBtn")!,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              )),
                                        ],
                                      ));

                              log('Settings');
                            },
                            child: Center(
                              child: TitleText(
                                text: AppLocalization.of(context)!
                                    .getTranslatedValues("logoutLbl")!,
                                textColor: Colors.red,
                                weight: FontWeight.w500,
                                size: Constants.bodyNormal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return Container();
            });
      },
    );
  }
}

Widget _settingsOptionsContainer({
  final Widget? listTileicon,
  final String? title,
  final String? subtitle,
  final bool? showIcon = true,
  final Function()? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Ink(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(16),
        ),
        color: Constants.grey5,
      ),
      height: SizeConfig.screenHeight * 0.09,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Constants.white,
            child: listTileicon,
          ),
          title: TitleText(
            text: title!,
            size: Constants.bodyNormal,
            weight: FontWeight.w500,
          ),
          subtitle: TitleText(
            text: subtitle!,
            size: Constants.bodyXSmall,
            weight: FontWeight.w400,
            maxlines: 1,
          ),
          trailing: showIcon!
              ? Icon(
                  Icons.arrow_forward_ios,
                  color: Constants.black1,
                )
              : const SizedBox(),
        ),
      ),
    ),
  );
}

webView(context, state) {
  return Padding(
      padding: EdgeInsets.only(
        top: (MediaQuery.of(context).size.height *
                (UiUtils.appBarHeightPercentage)) +
            15.0,
      ),
      child: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: Uri.dataFromString(
                (state as AppSettingsFetchSuccess).settingsData,
                mimeType: 'text/html',
                encoding: Encoding.getByName('utf-8'))
            .toString(),
      ));
}

void editProfileFieldBottomSheet(
    String fieldTitle,
    String fieldValue,
    bool isNumericKeyboardEnable,
    BuildContext context,
    UpdateUserDetailCubit updateUserDetailCubit) {
  showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      elevation: 5.0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      )),
      context: context,
      builder: (context) {
        return EditProfileFieldBottomSheetContainer(
            canCloseBottomSheet: true,
            fieldTitle: fieldTitle,
            fieldValue: fieldValue,
            password: false,
            // userDetailCubit: userDetailsC,
            numericKeyboardEnable: isNumericKeyboardEnable,
            updateUserDetailCubit: updateUserDetailCubit);
      }).then((value) {
    context
        .read<UpdateUserDetailCubit>()
        .updateState(UpdateUserDetailInitial());
  });
}

void editpasswordFieldBottomSheet({
  String? fieldTitle,
  String? fieldValue,
  bool? isNumericKeyboardEnable,
  BuildContext? context,
  bool? isPassword,
  UpdateUserDetailCubit? updateUserDetailCubit,
  UserDetailsCubit? userDetailsCubit,
}) {
  showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      elevation: 5.0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      )),
      context: context!,
      builder: (context) {
        return EditProfileFieldBottomSheetContainer(
            canCloseBottomSheet: true,
            fieldTitle: fieldTitle!,
            password: isPassword,
            fieldValue: fieldValue!,
            numericKeyboardEnable: isNumericKeyboardEnable!,
            userDetailCubit: userDetailsCubit!,
            updateUserDetailCubit: updateUserDetailCubit!);
      });
}
