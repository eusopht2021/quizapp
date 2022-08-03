// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;

import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/uploadProfileCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/customDialog.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/social_button.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/custom_appbar.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({Key? key}) : super(key: key);

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, bool>;
    return MaterialPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
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
        child: const InviteFriendsScreen(),
      ),
    );
  }

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  final Random randomAvatar = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.primaryColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomAppBar(
            title: "Invite Friends",
            showBackButton: true,
            textColor: Constants.white,
            iconColor: Constants.white,
            onBackTapped: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 110, right: 24, left: 24),
          child: CustomDialog(
            showbackButton: false,
            child: BlocConsumer<UploadProfileCubit, UploadProfileState>(
              listener: (context, state) {
                if (state is UploadProfileFailure) {
                  UiUtils.setSnackbar(
                      AppLocalization.of(context)!.getTranslatedValues(
                          convertErrorCodeToLanguageKey(state.errorMessage))!,
                      context,
                      false);
                } else if (state is UploadProfileSuccess) {
                  context
                      .read<UserDetailsCubit>()
                      .updateUserProfileUrl(state.imageUrl);
                }
              },
              builder: (context, state) {
                return BlocBuilder<UserDetailsCubit, UserDetailsState>(
                  bloc: context.read<UserDetailsCubit>(),
                  builder: (BuildContext context, UserDetailsState state) {
                    if (state is UserDetailsFetchSuccess) {
                      return _inviteFriendsDialog(
                          context: context, state: state);
                    }
                    return const SizedBox();
                  },
                );
              },
            ),
          ),
        ));
  }

  Widget _inviteFriendsDialog({BuildContext? context, state}) {
    return Stack(
      children: [
        Container(
          height: 190,
          width: SizeConfig.screenWidth * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: Constants.secondaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),

            // image: DecorationImage(
            //   image: AssetImage(Assets.backgroundCircle),
            // ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  Assets.backgroundCircle,
                  height: 180,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 35,
                      child: CachedNetworkImage(
                          imageUrl: state.userProfile.profileUrl!),
                    ),
                    TitleText(
                      text: "VS",
                      weight: FontWeight.w500,
                      size: Constants.heading1,
                      textColor: Constants.white,
                    ),
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: svg.Svg(Assets.menAvatars[
                          randomAvatar.nextInt(Assets.menAvatars.length)]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        //profiles section end
        // WidgetsUtil.verticalSpace20,
        Positioned(
          top: SizeConfig.screenHeight * 0.2,
          child: SizedBox(
            width: SizeConfig.screenWidth * 0.85,
            child: Stack(
              children: [
                SvgPicture.asset(
                  Assets.inviteFriendsContainer,
                  width: SizeConfig.screenWidth * 0.85,
                  height: SizeConfig.screenWidth * 0.85,
                  fit: BoxFit.fill,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WidgetsUtil.verticalSpace24,
                      TitleText(
                        text:
                            "Invite friends and get a bonus points for every new player!",
                        weight: FontWeight.w500,
                        size: Constants.bodyXLarge,
                        textColor: Constants.black1,
                        align: TextAlign.center,
                      ),
                      WidgetsUtil.verticalSpace24,
                      _customContainer(
                          text:
                              " ${context!.read<UserDetailsCubit>().getUserProfile().referCode!}"),
                      WidgetsUtil.verticalSpace32,
                      Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: SocialButton(
                                icon: Assets.clipboard,
                                background: Constants.primaryColor,
                                textColor: Constants.white,
                                onTap: () async {
                                  await Clipboard.setData(ClipboardData(
                                      text: context
                                          .read<UserDetailsCubit>()
                                          .getUserProfile()
                                          .referCode!));
                                  UiUtils.setSnackbar(
                                      AppLocalization.of(context)!
                                          .getTranslatedValues(
                                              "referCodeCopyMsg")!,
                                      context,
                                      false,
                                      backgroundColor: Constants.white,
                                      textColor: Constants.primaryColor);
                                },
                                text: "Copy Code",
                                horizontalMargin: 0,
                                showBorder: false),
                          ),
                          WidgetsUtil.horizontalSpace16,
                          Expanded(
                            flex: 2,
                            child: SocialButton(
                              textColor: Constants.primaryColor,
                              onTap: () {},
                              text: "",
                              itemSpace: 0,
                              showBorder: true,
                              horizontalMargin: 0,
                              icon: Assets.shareIcon,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _customContainer({String? text}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          20,
        ),
        border: Border.all(color: Constants.grey5, width: 2),
        color: Constants.grey5,
      ),
      height: 56,
      child: Center(
        child: TitleText(
          text: text!,
          textColor: Constants.black1,
          weight: FontWeight.w500,
        ),
      ),
    );
  }
}
