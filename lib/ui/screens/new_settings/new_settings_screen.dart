import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:flutterquiz/ui/navigation/navbaritems.dart';
import 'package:flutterquiz/ui/navigation/navigation.dart';
import 'package:flutterquiz/ui/navigation/navigation_bar_state.dart';
import 'package:flutterquiz/ui/screens/appSettingsScreen.dart';
import 'package:flutterquiz/ui/screens/auth/onBoardingScreen.dart';
import 'package:flutterquiz/ui/screens/profile/widgets/editProfileFieldBottomSheetContainer.dart';
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
import 'package:webview_flutter/webview_flutter.dart';

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
                // BlocProvider<UserDetailsCubit>(
                //   create: (context) => UserDetailsCubit(
                //     ProfileManagementRepository(),
                //   ),
                // ),
              ],
              child:
                  NewSettingsScreen(title: routeSettings.arguments as String),
            ))

        // builder: (_) => BlocProvider<AppSettingsCubit>(
        //       create: (_) => AppSettingsCubit(
        //         SystemConfigRepository(),
        //       ),
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
                    preferredSize: Size.fromHeight(kToolbarHeight),
                    child: CustomAppBar(
                      title: "Settings",
                      showBackButton: true,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          WidgetsUtil.verticalSpace24,
                          TitleText(
                            text: "Account",
                            textColor: Constants.black1.withOpacity(0.5),
                            weight: FontWeight.w500,
                            size: Constants.bodyNormal,
                          ),
                          WidgetsUtil.verticalSpace16,
                          GestureDetector(
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
                            child: _settingsOptionsContainer(
                              listTileicon: Image.asset(
                                Assets.person,
                                height: 25,
                                width: 25,
                                color: Constants.primaryColor,
                              ),
                              title: "Update Username",
                              subtitle: state.userProfile.name!,
                            ),
                          ),
                          WidgetsUtil.verticalSpace16,
                          GestureDetector(
                            onTap: () {},
                            child: _settingsOptionsContainer(
                              listTileicon: Image.asset(
                                Assets.mail,
                                height: 25,
                                width: 25,
                                color: Constants.primaryColor,
                              ),
                              title: "Change Email Address",
                              subtitle: state.userProfile.email!.isEmpty
                                  ? "-"
                                  : state.userProfile.email!,
                            ),
                          ),
                          WidgetsUtil.verticalSpace16,
                          GestureDetector(
                            onTap: () {
                              editpasswordFieldBottomSheet(
                                  fieldTitle: pwdLbl,
                                  fieldValue: "",
                                  isPassword: true,
                                  isNumericKeyboardEnable: false,
                                  context: context,
                                  updateUserDetailCubit:
                                      context.read<UpdateUserDetailCubit>(),
                                  oldPassword: oldPassword,
                                  newPassword: newPassword,
                                  confirmPassword: confirmPassword,
                                  userDetailsCubit:
                                      context.read<UserDetailsCubit>());
                            },
                            child: _settingsOptionsContainer(
                              listTileicon: Image.asset(
                                Assets.password,
                                height: 25,
                                width: 25,
                                color: Constants.primaryColor,
                              ),
                              title: "Change Password",
                              subtitle: "last change 1 year ago",
                            ),
                          ),
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
                                text: "Notification",
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
                                activeColor: Constants.primaryColor,
                              )
                            ],
                          ),
                          WidgetsUtil.verticalSpace24,
                          GestureDetector(
                            onTap: () {},
                            child: _settingsOptionsContainer(
                              listTileicon: SvgPicture.asset(
                                Assets.puzzleIcon,
                                height: 25,
                                width: 25,
                                color: Constants.primaryColor,
                              ),
                              title: "Change Difficulty",
                              subtitle: "Easy, normal, hard",
                            ),
                          ),
                          WidgetsUtil.verticalSpace16,
                          GestureDetector(
                            onTap: () {},
                            child: _settingsOptionsContainer(
                              listTileicon: Icon(
                                Icons.question_mark,
                                color: Constants.primaryColor,
                              ),
                              title: "FAQ",
                              subtitle: "Most frequently asked questions",
                            ),
                          ),
                          WidgetsUtil.verticalSpace32,
                          GestureDetector(
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
                                                    .pushReplacementNamed(Routes
                                                        .onBoardingScreen);
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
                                text: "Logout",
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

Widget _settingsOptionsContainer(
    {Widget? listTileicon, String? title, String? subtitle}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(
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
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Constants.black1,
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
      shape: RoundedRectangleBorder(
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
  TextEditingController? oldPassword,
  TextEditingController? newPassword,
  TextEditingController? confirmPassword,
  UpdateUserDetailCubit? updateUserDetailCubit,
  UserDetailsCubit? userDetailsCubit,
}) {
  showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
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
