import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/widgets/social_button.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutterquiz/utils/validators.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class EditProfileFieldBottomSheetContainer extends StatefulWidget {
  final String?
      fieldTitle; //value of fieldTitle will be from :  Email,Mobile Number,Name
  final String fieldValue; //
  final bool numericKeyboardEnable;
  bool? password;
  UserDetailsCubit? userDetailCubit;
  final UpdateUserDetailCubit updateUserDetailCubit;
  //To determine if to close bottom sheet without updating name or not
  final bool canCloseBottomSheet;
  EditProfileFieldBottomSheetContainer(
      {Key? key,
      required this.fieldTitle,
      required this.fieldValue,
      required this.canCloseBottomSheet,
      required this.numericKeyboardEnable,
      this.password,
      this.userDetailCubit,
      required this.updateUserDetailCubit})
      : super(key: key);

  @override
  _EditProfileFieldBottomSheetContainerState createState() =>
      _EditProfileFieldBottomSheetContainerState();
}

class _EditProfileFieldBottomSheetContainerState
    extends State<EditProfileFieldBottomSheetContainer> {
  late TextEditingController textEditingController =
      TextEditingController(text: widget.fieldValue);

  late TextEditingController oldPassword = TextEditingController();
  late TextEditingController newPassword = TextEditingController();
  late TextEditingController cnfrmPassword = TextEditingController();

  late String errorMessage = "";

  String _buildButtonTitle(UpdateUserDetailState state) {
    if (state is UpdateUserDetailInProgress) {
      return AppLocalization.of(context)!.getTranslatedValues("updatingLbl")!;
    }
    if (state is UpdateUserDetailFailure) {
      return AppLocalization.of(context)!.getTranslatedValues("retryLbl")!;
    }
    return AppLocalization.of(context)!.getTranslatedValues("updateLbl")!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateUserDetailCubit, UpdateUserDetailState>(
      bloc: widget.updateUserDetailCubit,
      listener: (context, state) {
        if (state is UpdateUserDetailSuccess) {
          context.read<UserDetailsCubit>().updateUserProfile(
                email: widget.fieldTitle == emailLbl
                    ? textEditingController.text.trim()
                    : null,
                mobile: widget.fieldTitle == mobileNumberLbl
                    ? textEditingController.text.trim()
                    : null,
                name: widget.fieldTitle == nameLbl
                    ? textEditingController.text.trim()
                    : null,
              );
          Navigator.of(context).pop();
        } else if (state is UpdateUserDetailFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
            return;
          }
          setState(() {
            errorMessage = AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessage))!;
          });
        }
      },
      child: WillPopScope(
        onWillPop: () {
          if (widget.canCloseBottomSheet) {
            if (widget.updateUserDetailCubit.state
                is UpdateUserDetailInProgress) {
              return Future.value(false);
            }
            return Future.value(true);
          } else {
            return Future.value(false);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: const Radius.circular(20.0),
            ),
            color: Constants.secondaryColor,
          ),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          onPressed: () {
                            //
                            if (!widget.canCloseBottomSheet) {
                              return;
                            }
                            if (widget.updateUserDetailCubit.state
                                is! UpdateUserDetailInProgress) {
                              Navigator.of(context).pop();
                            }
                          },
                          icon: const Icon(
                            Icons.close,
                            size: 28.0,
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.center,
                  child: TitleText(
                      text: AppLocalization.of(context)!
                          .getTranslatedValues(widget.fieldTitle)!,
                      size: 20.0,
                      textColor: Colors.white,
                      weight: FontWeight.bold),
                ),

                const SizedBox(
                  height: 15.0,
                ),
                //
                widget.password!
                    ? Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * (0.125),
                            ),
                            padding:
                                const EdgeInsetsDirectional.only(start: 20.0),
                            height: 60.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              // color: Theme.of(context).backgroundColor,
                              color: Constants.white,
                            ),
                            child: TextFormField(
                              controller: oldPassword,
                              keyboardType: widget.numericKeyboardEnable
                                  ? TextInputType.number
                                  : TextInputType.text,
                              decoration: const InputDecoration(
                                hintText: "old password",
                                border: InputBorder.none,
                              ),
                              // validator: (val) => val!.isEmpty
                              //     ? '${AppLocalization.of(context)!.getTranslatedValues('pwdLengthMsg')}'
                              //     : null,
                              validator: (val) => Validators.validatePassword(
                                  oldPassword.text, "password does not match"),
                            ),
                          ),
                          WidgetsUtil.verticalSpace16,
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * (0.125),
                            ),
                            padding:
                                const EdgeInsetsDirectional.only(start: 20.0),
                            height: 60.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              // color: Theme.of(context).backgroundColor,
                              color: Constants.white,
                            ),
                            child: TextFormField(
                              controller: newPassword,
                              keyboardType: widget.numericKeyboardEnable
                                  ? TextInputType.number
                                  : TextInputType.text,
                              decoration: const InputDecoration(
                                hintText: "new password",
                                border: InputBorder.none,
                              ),
                              validator: (val) => val!.isEmpty
                                  ? '${AppLocalization.of(context)!.getTranslatedValues('pwdLengthMsg')}'
                                  : null,
                            ),
                          ),
                          WidgetsUtil.verticalSpace16,
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * (0.125),
                            ),
                            padding:
                                const EdgeInsetsDirectional.only(start: 20.0),
                            height: 60.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              // color: Theme.of(context).backgroundColor,
                              color: Constants.white,
                            ),
                            child: TextFormField(
                              controller: cnfrmPassword,
                              keyboardType: widget.numericKeyboardEnable
                                  ? TextInputType.number
                                  : TextInputType.text,
                              decoration: const InputDecoration(
                                hintText: "confirm password",
                                border: InputBorder.none,
                              ),
                              validator: (val) => val!.isEmpty
                                  ? '${AppLocalization.of(context)!.getTranslatedValues('pwdLengthMsg')}'
                                  : null,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(
                          horizontal:
                              MediaQuery.of(context).size.width * (0.125),
                        ),
                        padding: const EdgeInsetsDirectional.only(start: 20.0),
                        height: 60.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          // color: Theme.of(context).backgroundColor,
                          color: Constants.white,
                        ),
                        child: TextField(
                          controller: textEditingController,
                          keyboardType: widget.numericKeyboardEnable
                              ? TextInputType.number
                              : TextInputType.text,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.02),
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: errorMessage.isEmpty
                      ? const SizedBox(
                          height: 20.0,
                        )
                      : Container(
                          height: 20.0,
                          child: TitleText(
                            text: errorMessage,
                            textColor: Constants.secondaryColor,
                          ),
                        ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.02),
                ),
                //
                BlocBuilder<UpdateUserDetailCubit, UpdateUserDetailState>(
                  bloc: widget.updateUserDetailCubit,
                  builder: (context, state) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * (0.3),
                      ),
                      child: SocialButton(
                        // widthPercentage: MediaQuery.of(context).size.width,
                        showBorder: false,
                        horizontalMargin: 0,
                        background: Constants.primaryColor,
                        text: _buildButtonTitle(state),
                        // radius: 10.0,
                        // showBorder: false,
                        onTap: state is UpdateUserDetailInProgress
                            ? () {}
                            : () {
                                if (errorMessage.isNotEmpty) {
                                  setState(() {
                                    errorMessage = "";
                                  });
                                }
                                final userProfile = context
                                    .read<UserDetailsCubit>()
                                    .getUserProfile();
                                //means it is not
                                if (widget.fieldTitle == mobileNumberLbl) {
                                  if (!Validators.isCorrectMobileNumber(
                                      textEditingController.text.trim())) {
                                    setState(() {
                                      errorMessage = AppLocalization.of(
                                              context)!
                                          .getTranslatedValues("validMobMsg")!;
                                    });

                                    return;
                                  }
                                } else if (widget.fieldTitle == emailLbl) {
                                  if (!Validators.isValidEmail(
                                      textEditingController.text.trim())) {
                                    setState(() {
                                      errorMessage =
                                          AppLocalization.of(context)!
                                              .getTranslatedValues(
                                                  "enterValidEmailMsg")!;
                                    });
                                    return;
                                  }
                                } else if (widget.fieldTitle == pwdLbl) {
                                  if (state is UserDetailsFetchInProgress) {
                                    log("changing password");
                                  } else if (state is UserDetailsFetchSuccess) {
                                    log("Password change sheet");

                                    context
                                        .read<UserDetailsCubit>()
                                        .changePassword(
                                            context: context,
                                            oldPassword: oldPassword.text,
                                            newPassword: newPassword.text,
                                            confrimPassword:
                                                cnfrmPassword.text);

                                    return;
                                  }
                                }

                                widget.updateUserDetailCubit.updateProfile(
                                  userId: context
                                      .read<UserDetailsCubit>()
                                      .getUserId(),
                                  email: widget.fieldTitle == emailLbl
                                      ? textEditingController.text.trim()
                                      : userProfile.email ?? "",
                                  mobile: widget.fieldTitle == mobileNumberLbl
                                      ? textEditingController.text.trim()
                                      : userProfile.mobileNumber ?? "",
                                  name: widget.fieldTitle == nameLbl
                                      ? textEditingController.text.trim()
                                      : userProfile.name ?? "",
                                );
                              },
                        textColor: Constants.white,
                        height: 40.0,
                      ),
                    );
                  },
                ),

                //
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.05),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
