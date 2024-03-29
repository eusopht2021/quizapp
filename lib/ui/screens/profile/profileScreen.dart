import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
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
import 'package:flutterquiz/ui/screens/profile/widgets/editProfileFieldBottomSheetContainer.dart';
import 'package:flutterquiz/ui/widgets/circularImageContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/menuTile.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class ProfileScreen extends StatelessWidget {
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (context) => MultiBlocProvider(providers: [
              BlocProvider<DeleteAccountCubit>(
                  create: (_) =>
                      DeleteAccountCubit(ProfileManagementRepository())),
              BlocProvider<UploadProfileCubit>(
                  create: (context) => UploadProfileCubit(
                        ProfileManagementRepository(),
                      )),
              BlocProvider<UpdateUserDetailCubit>(
                  create: (context) => UpdateUserDetailCubit(
                        ProfileManagementRepository(),
                      )),
            ], child: ProfileScreen()));
  }

  ProfileScreen({
    Key? key,
  }) : super(key: key);

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
          topLeft: const Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        )),
        context: context,
        builder: (context) {
          return EditProfileFieldBottomSheetContainer(
              canCloseBottomSheet: true,
              fieldTitle: fieldTitle,
              fieldValue: fieldValue,
              numericKeyboardEnable: isNumericKeyboardEnable,
              updateUserDetailCubit: updateUserDetailCubit);
        }).then((value) {
      context
          .read<UpdateUserDetailCubit>()
          .updateState(UpdateUserDetailInitial());
    });
  }

  Widget _buildProfileTile(
      {required BuildContext context,
      required String title,
      required String subTitle,
      required String leadingIcon,
      required VoidCallback onEdit,
      required bool canEditField}) {
    return LayoutBuilder(builder: (context, boxConstraints) {
      return Container(
        //decoration: BoxDecoration(border: Border.all()),
        width: boxConstraints.maxWidth * (0.85),
        height: 50,
        //decoration: BoxDecoration(border: Border.all()),
        child: Row(
          children: [
            Container(
                width: 30.0,
                transform: Matrix4.identity()..scale(0.7),
                transformAlignment: Alignment.center,
                child: SvgPicture.asset(UiUtils.getImagePath(leadingIcon))),
            SizedBox(
              width: boxConstraints.maxWidth * (0.03),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalization.of(context)!.getTranslatedValues(title)!,
                  style: TextStyle(
                      fontSize: 13.0,
                      color: Theme.of(context).primaryColor.withOpacity(0.6)),
                ),
                SizedBox(
                  //decoration: BoxDecoration(border: Border.all()),
                  width: boxConstraints.maxWidth * (0.625),
                  child: Text(
                    subTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15.0,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const Spacer(),
            canEditField
                ? GestureDetector(
                    onTap: onEdit,
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      );
    });
  }

  Widget _buildProfileContainer(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * (0.84),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Theme.of(context).backgroundColor,
          boxShadow: [UiUtils.buildBoxShadow()],
        ),
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
        }, builder: (context, state) {
          return BlocBuilder<UserDetailsCubit, UserDetailsState>(
            bloc: context.read<UserDetailsCubit>(),
            builder: (context, state) {
              if (state is UserDetailsFetchSuccess) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (0.025),
                    ),
                    Container(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: CustomBackButton(
                                iconColor: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("profileLbl")!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (0.025),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Container(
                            color: Theme.of(context).primaryColor,
                            width: MediaQuery.of(context).size.width * (0.65),
                            height: 1.75,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(7.5),
                          decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              border: Border.all(
                                  color: Theme.of(context).primaryColor),
                              shape: BoxShape.circle),
                          child: CircularImageContainer(
                            height: MediaQuery.of(context).size.height * (0.15),
                            width: MediaQuery.of(context).size.width * (0.3),
                            imagePath: state.userProfile.profileUrl!,
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width * (0.225),
                              left: MediaQuery.of(context).size.width * (0.275),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.width * (0.07)),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        Routes.selectProfile,
                                        arguments: false);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .backgroundColor
                                            .withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(
                                            MediaQuery.of(context).size.width *
                                                (0.07))),
                                    height: MediaQuery.of(context).size.width *
                                        (0.14),
                                    width: MediaQuery.of(context).size.width *
                                        (0.14),
                                    child: Icon(
                                      Icons.edit,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (0.025),
                    ),
                    Container(
                      color: Theme.of(context).primaryColor.withOpacity(0.25),
                      height: 1.75,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (0.015),
                    ),
                    _buildProfileTile(
                      canEditField: true,
                      context: context,
                      leadingIcon: "name_icon.svg",
                      onEdit: () {
                        // state.userProfile.
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
                      subTitle: state.userProfile.name!.isEmpty
                          ? "-"
                          : state.userProfile.name!,
                      title: nameLbl,
                    ),
                    _buildProfileTile(
                      canEditField:
                          !(context.read<AuthCubit>().getAuthProvider() ==
                              AuthProvider.mobile),
                      context: context,
                      leadingIcon: "mobile_number.svg",
                      onEdit: () {
                        editProfileFieldBottomSheet(
                            mobileNumberLbl,
                            state.userProfile.mobileNumber!.isEmpty
                                ? ""
                                : state.userProfile.mobileNumber!,
                            true,
                            context,
                            context.read<UpdateUserDetailCubit>());
                      },
                      subTitle: state.userProfile.mobileNumber!.isEmpty
                          ? "-"
                          : state.userProfile.mobileNumber!,
                      title: mobileNumberLbl,
                    ),
                    _buildProfileTile(
                      canEditField:
                          !(context.read<AuthCubit>().getAuthProvider() !=
                              AuthProvider.mobile),
                      context: context,
                      leadingIcon: "email_icon.svg",
                      onEdit: () {
                        editProfileFieldBottomSheet(
                            emailLbl,
                            state.userProfile.email!.isEmpty
                                ? ""
                                : state.userProfile.email!,
                            false,
                            context,
                            context.read<UpdateUserDetailCubit>());
                      },
                      subTitle: state.userProfile.email!.isEmpty
                          ? "-"
                          : state.userProfile.email!,
                      title: emailLbl,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (0.015),
                    ),
                    Container(
                      color: Theme.of(context).primaryColor.withOpacity(0.25),
                      width: MediaQuery.of(context).size.width * (0.825),
                      height: 1.75,
                    ),
                    MenuTile(
                      isSvgIcon: true,
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.bookmark);
                      },
                      title: "bookmarkLbl",
                      leadingIcon: "bookmark_icon.svg", //theme icon
                    ),
                    MenuTile(
                      isSvgIcon: true,
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.referAndEarn);
                      },
                      title: "inviteFriendsLbl",
                      leadingIcon: "invite_friends.svg", //theme icon
                    ),
                    MenuTile(
                      isSvgIcon: true,
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
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text(
                                          AppLocalization.of(context)!
                                              .getTranslatedValues("yesBtn")!,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        )),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text(
                                          AppLocalization.of(context)!
                                              .getTranslatedValues("noBtn")!,
                                          style: TextStyle(
                                              color: Theme.of(context)
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
                      },
                      title: deleteAccountKey,
                      leadingIcon: "delete.svg", //theme icon
                    ),
                    MenuTile(
                      isSvgIcon: true,
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
                                              .updateState(BadgesInitial());
                                          context
                                              .read<BookmarkCubit>()
                                              .updateState(BookmarkInitial());
                                          context
                                              .read<GuessTheWordBookmarkCubit>()
                                              .updateState(
                                                  GuessTheWordBookmarkInitial());

                                          context
                                              .read<
                                                  AudioQuestionBookmarkCubit>()
                                              .updateState(
                                                  AudioQuestionBookmarkInitial());

                                          context.read<AuthCubit>().signOut();
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  Routes.loginScreen);
                                        },
                                        child: Text(
                                          AppLocalization.of(context)!
                                              .getTranslatedValues("yesBtn")!,
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
                                              .getTranslatedValues("noBtn")!,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        )),
                                  ],
                                ));
                      },
                      title: "logoutLbl",
                      leadingIcon: "logout_icon.svg", //theme icon
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (0.025),
                    ),
                  ],
                );
              }
              return Container();
            },
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const PageBackgroundGradientContainer(),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  _buildProfileContainer(context),
                  const SizedBox(
                    height: 30.0,
                  ),
                ],
              ),
            ),
          ),
          BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
            listener: (context, state) {
              if (state is DeleteAccountSuccess) {
                //Update state for gloabally cubits
                context.read<BadgesCubit>().updateState(BadgesInitial());
                context.read<BookmarkCubit>().updateState(BookmarkInitial());

                //set local auth details to empty
                AuthRepository().setLocalAuthDetails(
                    authStatus: false,
                    authType: "",
                    jwtToken: "",
                    firebaseId: "",
                    isNewUser: false);
                //
                UiUtils.setSnackbar(
                    AppLocalization.of(context)!
                        .getTranslatedValues(accountDeletedSuccessfullyKey)!,
                    context,
                    false);
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(Routes.loginScreen);
              } else if (state is DeleteAccountFailure) {
                UiUtils.setSnackbar(
                    AppLocalization.of(context)!.getTranslatedValues(
                        convertErrorCodeToLanguageKey(state.errorMessage))!,
                    context,
                    false);
              }
            },
            bloc: context.read<DeleteAccountCubit>(),
            builder: (context, state) {
              if (state is DeleteAccountInProgress) {
                return Container(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withOpacity(0.275),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: AlertDialog(
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressContainer(
                            useWhiteLoader: false,
                            heightAndWidth: 45.0,
                          ),
                          const SizedBox(
                            width: 15.0,
                          ),
                          Text(
                            AppLocalization.of(context)!
                                .getTranslatedValues(deletingAccountKey)!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
