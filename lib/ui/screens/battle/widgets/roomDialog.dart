import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/ads/rewardedAdCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/customDialog.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/waitingForPlayersDialog.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/ui/widgets/watchRewardAdDialog.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoomDialog extends StatefulWidget {
  final QuizTypes quizType;
  RoomDialog({Key? key, required this.quizType}) : super(key: key);

  @override
  _RoomDialogState createState() => _RoomDialogState();
}

class _RoomDialogState extends State<RoomDialog> {
  int currentSelectedTab = 1; //1 is create and second is join

  String selectedCategory = selectCategoryKey;
  List<int> entryFees = [minCoinsForGroupBattleCreation, 10, 15, 20];
  int entryFee =
      minCoinsForGroupBattleCreation; //difference between two entries is
  TextEditingController textEditingController = TextEditingController();
  TextEditingController roomCodeEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (isCategoryEnabled()) {
        context.read<QuizCategoryCubit>().getQuizCategory(
              languageId: UiUtils.getCurrentQuestionLanguageId(context),
              type: UiUtils.getCategoryTypeNumberFromQuizType(widget.quizType),
              userId: context.read<UserDetailsCubit>().getUserId(),
            );
      }
      context.read<RewardedAdCubit>().createRewardedAd(context,
          onFbRewardAdCompleted: _addCoinsAfterRewardAd);
      //to get categories
    });
  }

  void _addCoinsAfterRewardAd() {
    //ad rewards here
    //once user sees ad then add coins to user wallet
    context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: lifeLineDeductCoins,
        );

    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
        context.read<UserDetailsCubit>().getUserId(),
        lifeLineDeductCoins,
        true,
        watchedRewardAdKey);
  }

  void showAdDialog() {
    if (context.read<RewardedAdCubit>().state is! RewardedAdLoaded) {
      UiUtils.errorMessageDialog(
          context,
          AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(notEnoughCoinsCode))!);
      return;
    }
    showDialog(
        context: context,
        builder: (_) => WatchRewardAdDialog(onTapYesButton: () {
              //showAd
              context.read<RewardedAdCubit>().showAd(
                  context: context,
                  onAdDismissedCallback: _addCoinsAfterRewardAd);
            }));
  }

  InputBorder _getInputBorder(BuildContext buildContext) {
    return UnderlineInputBorder(
        borderSide: BorderSide(
      color: Constants.primaryColor,
    ));
  }

  bool isCategoryEnabled() {
    if (widget.quizType == QuizTypes.battle) {
      return context
              .read<SystemConfigCubit>()
              .getIsCategoryEnableForBattle()! ==
          "1";
    }
    return context
            .read<SystemConfigCubit>()
            .getIsCategoryEnableForGroupBattle()! ==
        "1";
  }

  String getCategoryId() {
    QuizCategoryCubit quizCategoryCubit = context.read<QuizCategoryCubit>();
    if (quizCategoryCubit.state is QuizCategorySuccess) {
      return (quizCategoryCubit.state as QuizCategorySuccess)
          .categories
          .where((element) => element.categoryName == selectedCategory)
          .toList()
          .first
          .id!;
    }
    return "";
  }

  Widget _buildTabContainer(
      int index, String title, BoxConstraints boxConstraints) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentSelectedTab = index;
        });
      },
      child: AnimatedContainer(
        curve: Curves.easeInOut,
        duration: const Duration(
          milliseconds: 250,
        ),
        alignment: Alignment.center,
        height: boxConstraints.maxHeight * (0.15),
        width: boxConstraints.maxWidth * (0.5),
        decoration: BoxDecoration(
            color: index == currentSelectedTab
                ? Constants.primaryColor
                : Constants.primaryColor.withOpacity(0.6),
            borderRadius: index == 1
                ? BorderRadius.only(
                    topLeft: Radius.circular(UiUtils.dailogRadius),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(UiUtils.dailogRadius),
                  )),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight:
                index == currentSelectedTab ? FontWeight.bold : FontWeight.w500,
            color: index == currentSelectedTab
                ? Constants.white
                : Constants.primaryColor,
          ),
        ),
      ),
    );
  }

  //using for category
  Widget _buildDropdown({
    required List<Map<String, String?>>
        values, //keys of value will be name and id
    required String keyValue, // need to have this keyValues for fade animation
  }) {
    return DropdownButton<String>(
        key: Key(keyValue),
        borderRadius: BorderRadius.circular(20),
        dropdownColor:
            Constants.primaryColor, //same as background of dropdown color
        style: TextStyle(
          color: Constants.white,
          fontSize: 16.0,
        ),
        isExpanded: true,
        iconEnabledColor: Constants.white,
        onChanged: (value) {
          // ScaffoldMessenger.of(context).removeCurrentSnackBar();

          setState(() {
            selectedCategory = value!;
          });
        },
        underline: const SizedBox(),
        //values is map of name and id. only passing name to dropdown
        items: values.map((e) => e['name']).toList().map((name) {
          return DropdownMenuItem(
            value: name,
            child: name! == selectCategoryKey
                ? Text(AppLocalization.of(context)!.getTranslatedValues(name)!)
                : Text(name),
          );
        }).toList(),
        value: selectedCategory);
  }

  Widget _buildEntryFeeContainer(
      int entryFeeValue, BoxConstraints boxConstraints, bool useManualValue) {
    return GestureDetector(
      onTap: useManualValue
          ? null
          : () {
              setState(() {
                entryFee = entryFeeValue;
              });
            },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        width: boxConstraints.maxWidth * (0.145),
        height: boxConstraints.maxHeight * (0.2),
        alignment: Alignment.center,
        padding: useManualValue
            ? const EdgeInsets.symmetric(horizontal: 10.0)
            : null,
        decoration: BoxDecoration(
            boxShadow: entryFeeValue == entryFee
                ? [
                    BoxShadow(
                        color: Constants.primaryColor,
                        blurRadius: 5,
                        offset: const Offset(2.5, 2.5))
                  ]
                : null,
            color: entryFeeValue == entryFee
                ? Constants.primaryColor
                : Constants.primaryColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10.0)),
        child: useManualValue
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      print("Entry fee : $value");
                      entryFee = int.parse(value.trim());
                      setState(() {});
                    },
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: Constants.primaryColor,
                    ),
                    controller: textEditingController,
                    cursorColor: Constants.primaryColor,
                    decoration: InputDecoration(
                      hintText: "00",
                      hintStyle: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: Constants.primaryColor,
                      ),
                      contentPadding: const EdgeInsets.all(0),
                      isDense: true,
                      enabledBorder: _getInputBorder(context),
                      border: _getInputBorder(context),
                      focusedBorder: _getInputBorder(context),
                    ),
                  ),
                  const SizedBox(
                    height: 2.5,
                  ),
                  SvgPicture.asset(UiUtils.getImagePath("coins.svg")),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$entryFeeValue",
                    style: TextStyle(
                      color: entryFeeValue == entryFee
                          ? Constants.white
                          : Constants.primaryColor,
                      fontSize: 16.0,
                      fontWeight: entryFeeValue == entryFee
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 2.5,
                  ),
                  SvgPicture.asset(UiUtils.getImagePath("coins.svg")),
                ],
              ),
      ),
    );
  }

  Widget _buildJoinRoomTab(BoxConstraints constraints) {
    return Column(
      key: const Key("joinTab"),
      children: [
        Container(
          alignment: Alignment.center,
          child: TitleText(
              text: AppLocalization.of(context)!
                  .getTranslatedValues(enterRoomCodeHereKey)!,
              textColor: Constants.primaryColor,
              size: 18.0),
        ),
        SizedBox(
          height: constraints.maxHeight * (0.04),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          margin:
              EdgeInsets.symmetric(horizontal: constraints.maxWidth * (0.1)),
          decoration: BoxDecoration(
              color: Constants.white,
              borderRadius: BorderRadius.circular(25.0)),
          height: constraints.maxHeight * (0.115),
          child: TextField(
            style: TextStyle(
              color: Constants.primaryColor,
            ),
            keyboardType: TextInputType.number,
            cursorColor: Constants.black1,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              hintText: AppLocalization.of(context)!
                  .getTranslatedValues(enterCodeLbl),
              hintStyle: TextStyle(
                color: Constants.secondaryColor,
              ),
            ),
            controller: roomCodeEditingController,
          ),
        ),
        SizedBox(
          height: constraints.maxHeight * (0.1),
        ),
        widget.quizType == QuizTypes.battle
            ? BlocConsumer<BattleRoomCubit, BattleRoomState>(
                listener: (context, state) {
                  if (state is BattleRoomUserFound) {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) =>
                            WaitingForPlayesDialog(quizType: QuizTypes.battle));
                  } else if (state is BattleRoomFailure) {
                    if (state.errorMessageCode == unauthorizedAccessCode) {
                      UiUtils.showAlreadyLoggedInDialog(
                        context: context,
                      );
                      return;
                    }
                    UiUtils.errorMessageDialog(
                        context,
                        AppLocalization.of(context)!.getTranslatedValues(
                            convertErrorCodeToLanguageKey(
                                state.errorMessageCode)));
                  }
                },
                bloc: context.read<BattleRoomCubit>(),
                builder: (context, state) {
                  return CustomRoundedButton(
                    onTap: state is BattleRoomJoining
                        ? () {}
                        : () {
                            if (roomCodeEditingController.text.trim().isEmpty) {
                              return;
                            }
                            UserProfile userProfile = context
                                .read<UserDetailsCubit>()
                                .getUserProfile();
                            context.read<BattleRoomCubit>().joinRoom(
                                  currentCoin: userProfile.coins!,
                                  name: userProfile.name,
                                  uid: userProfile.userId,
                                  profileUrl: userProfile.profileUrl,
                                  roomCode:
                                      roomCodeEditingController.text.trim(),
                                );
                          },
                    widthPercentage: UiUtils.dailogWidthPercentage - 0.1,
                    backgroundColor: Constants.primaryColor,
                    buttonTitle: state is BattleRoomJoining
                        ? AppLocalization.of(context)!
                            .getTranslatedValues('joiningLoadingLbl')!
                        : AppLocalization.of(context)!
                            .getTranslatedValues(joinRoomKey)!,
                    radius: 25.0,
                    elevation: 5.0,
                    titleColor: Theme.of(context).backgroundColor,
                    shadowColor:
                        Theme.of(context).primaryColor.withOpacity(0.3),
                    showBorder: false,
                    height: constraints.maxHeight * (0.115),
                    fontWeight: FontWeight.bold,
                  );
                },
              )
            : BlocConsumer<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
                listener: (context, state) {
                  if (state is MultiUserBattleRoomSuccess) {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) => WaitingForPlayesDialog(
                              quizType: QuizTypes.groupPlay,
                            ));
                  } else if (state is MultiUserBattleRoomFailure) {
                    if (state.errorMessageCode == unauthorizedAccessCode) {
                      UiUtils.showAlreadyLoggedInDialog(
                        context: context,
                      );
                      return;
                    }
                    UiUtils.errorMessageDialog(
                        context,
                        AppLocalization.of(context)!.getTranslatedValues(
                            convertErrorCodeToLanguageKey(
                                state.errorMessageCode)));
                  }
                },
                bloc: context.read<MultiUserBattleRoomCubit>(),
                builder: (context, state) {
                  return CustomRoundedButton(
                    onTap: state is MultiUserBattleRoomInProgress
                        ? () {}
                        : () {
                            if (roomCodeEditingController.text.trim().isEmpty) {
                              return;
                            }
                            UserProfile userProfile = context
                                .read<UserDetailsCubit>()
                                .getUserProfile();
                            context.read<MultiUserBattleRoomCubit>().joinRoom(
                                  currentCoin: userProfile.coins!,
                                  name: userProfile.name,
                                  uid: userProfile.userId,
                                  profileUrl: userProfile.profileUrl,
                                  roomCode:
                                      roomCodeEditingController.text.trim(),
                                );
                          },
                    widthPercentage: UiUtils.dailogWidthPercentage - 0.1,
                    backgroundColor: Constants.primaryColor,
                    buttonTitle: state is MultiUserBattleRoomInProgress
                        ? AppLocalization.of(context)!
                            .getTranslatedValues('joiningLoadingLbl')!
                        : AppLocalization.of(context)!
                            .getTranslatedValues(joinRoomKey)!,
                    radius: 25.0,
                    elevation: 5.0,
                    titleColor: Constants.white,
                    shadowColor:
                        Theme.of(context).primaryColor.withOpacity(0.3),
                    showBorder: false,
                    height: constraints.maxHeight * (0.115),
                    fontWeight: FontWeight.bold,
                  );
                },
              ),
      ],
    );
  }

  Widget _buildCreateRoomTab(BoxConstraints constraints) {
    return Column(
      key: const Key("createTab"),
      children: [
        isCategoryEnabled()
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                margin: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * (0.05)),
                decoration: BoxDecoration(
                    color: Constants.primaryColor,
                    borderRadius: BorderRadius.circular(25.0)),
                height: constraints.maxHeight * (0.115),
                child: BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
                  bloc: context.read<QuizCategoryCubit>(),
                  listener: (context, state) {
                    if (state is QuizCategorySuccess) {
                      setState(() {
                        selectedCategory = state.categories.first.categoryName!;
                      });
                    }
                    if (state is QuizCategoryFailure) {
                      if (state.errorMessage == unauthorizedAccessCode) {
                        UiUtils.showAlreadyLoggedInDialog(
                          context: context,
                        );
                        return;
                      }
                      showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      //context.read<QuizCategoryCubit>().getQuizCategory(UiUtils.getCurrentQuestionLanguageId(context), "");
                                    },
                                    child: Text(
                                      AppLocalization.of(context)!
                                          .getTranslatedValues(retryLbl)!,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  )
                                ],
                                content: Text(AppLocalization.of(context)!
                                    .getTranslatedValues(
                                        convertErrorCodeToLanguageKey(
                                            state.errorMessage))!),
                              )).then((value) {
                        if (value != null && value) {
                          context.read<QuizCategoryCubit>().getQuizCategory(
                                languageId:
                                    UiUtils.getCurrentQuestionLanguageId(
                                        context),
                                type: UiUtils.getCategoryTypeNumberFromQuizType(
                                    widget.quizType),
                                userId: context
                                    .read<UserDetailsCubit>()
                                    .getUserId(),
                              );
                        }
                      });
                    }
                  },
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: state is QuizCategorySuccess
                          ? _buildDropdown(
                              values: state.categories
                                  .map((e) =>
                                      {"name": e.categoryName, "id": e.id})
                                  .toList(),
                              keyValue: "selectCategorySuccess")
                          : Opacity(
                              opacity: 0.65,
                              child: _buildDropdown(values: [
                                {"name": selectCategoryKey, "id": "0"}
                              ], keyValue: "selectCategory"),
                            ),
                    );
                  },
                ),
              )
            : Container(),
        SizedBox(
          height: constraints.maxHeight * (isCategoryEnabled() ? 0.05 : 0),
        ),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: constraints.maxWidth * (0.05)),
          child: Row(
            children: [
              ...entryFees
                  .map((e) => _buildEntryFeeContainer(e, constraints, false))
                  .toList(),
              _buildEntryFeeContainer(-1, constraints, true),
            ],
          ),
        ),
        SizedBox(
          height: constraints.maxHeight * (0.075),
        ),
        Container(
          margin:
              EdgeInsets.symmetric(horizontal: constraints.maxWidth * (0.1)),
          decoration: BoxDecoration(
              color: Constants.primaryColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(25.0)),
          height: constraints.maxHeight * (0.115),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${AppLocalization.of(context)!.getTranslatedValues(currentCoinsKey)!}:  ",
                style: TextStyle(
                  color: Constants.primaryColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              BlocBuilder<UserDetailsCubit, UserDetailsState>(
                bloc: context.read<UserDetailsCubit>(),
                builder: (context, state) {
                  if (state is UserDetailsFetchSuccess) {
                    return Text(
                      state.userProfile.coins!,
                      style: TextStyle(
                        color: Constants.primaryColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: constraints.maxHeight * (0.05),
        ),
        widget.quizType == QuizTypes.battle
            ? BlocConsumer<BattleRoomCubit, BattleRoomState>(
                bloc: context.read<BattleRoomCubit>(),
                //this listener will be in use for both creating and join room callbacks
                listener: (context, state) {
                  if (state is BattleRoomCreated) {
                    //wait for others
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) => WaitingForPlayesDialog(
                            quizType: QuizTypes.battle, battleLbl: "playFrd"));
                  } else if (state is BattleRoomFailure) {
                    if (state.errorMessageCode == unauthorizedAccessCode) {
                      UiUtils.showAlreadyLoggedInDialog(
                        context: context,
                      );
                      return;
                    }
                    UiUtils.errorMessageDialog(
                        context,
                        AppLocalization.of(context)!.getTranslatedValues(
                            convertErrorCodeToLanguageKey(
                                state.errorMessageCode)));
                  }
                },
                builder: (context, state) {
                  return CustomRoundedButton(
                    onTap: state is BattleRoomCreating
                        ? () {}
                        : () {
                            if (isCategoryEnabled() &&
                                getCategoryId().isEmpty) {
                              UiUtils.errorMessageDialog(
                                  context,
                                  AppLocalization.of(context)!
                                      .getTranslatedValues(
                                          pleaseSelectCategoryKey)!);
                              return;
                            }
                            if (entryFee < 0) {
                              UiUtils.errorMessageDialog(
                                  context,
                                  AppLocalization.of(context)!
                                      .getTranslatedValues(
                                          moreThanZeroCoinsKey)!);
                              return;
                            }
                            UserProfile userProfile = context
                                .read<UserDetailsCubit>()
                                .getUserProfile();

                            if (int.parse(userProfile.coins!) < entryFee) {
                              showAdDialog();
                              //UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(notEnoughCoinsCode)));
                              return;
                            }
                            context.read<BattleRoomCubit>().createRoom(
                                  shouldGenerateRoomCode: true,
                                  categoryId: getCategoryId(),
                                  entryFee: entryFee,
                                  name: userProfile.name,
                                  profileUrl: userProfile.profileUrl,
                                  uid: userProfile.userId,
                                  questionLanguageId:
                                      UiUtils.getCurrentQuestionLanguageId(
                                          context),
                                );
                          },
                    widthPercentage: UiUtils.dailogWidthPercentage - 0.1,
                    backgroundColor: Constants.primaryColor,
                    buttonTitle: state is BattleRoomCreating
                        ? AppLocalization.of(context)!
                            .getTranslatedValues(creatingLoadingLbl)
                        : AppLocalization.of(context)!
                            .getTranslatedValues(createRoomKey),
                    radius: 25.0,
                    elevation: 5.0,
                    titleColor: Theme.of(context).backgroundColor,
                    shadowColor:
                        Theme.of(context).primaryColor.withOpacity(0.3),
                    showBorder: false,
                    height: constraints.maxHeight * (0.115),
                    fontWeight: FontWeight.bold,
                  );
                },
              )
            : BlocConsumer<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
                bloc: context.read<MultiUserBattleRoomCubit>(),
                listener: (context, state) {
                  if (state is MultiUserBattleRoomSuccess) {
                    //wait for others
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) => WaitingForPlayesDialog(
                              quizType: QuizTypes.groupPlay,
                              battleLbl: "",
                            ));
                  } else if (state is MultiUserBattleRoomFailure) {
                    if (state.errorMessageCode == unauthorizedAccessCode) {
                      UiUtils.showAlreadyLoggedInDialog(
                        context: context,
                      );
                      return;
                    }
                    UiUtils.errorMessageDialog(
                        context,
                        AppLocalization.of(context)!.getTranslatedValues(
                            convertErrorCodeToLanguageKey(
                                state.errorMessageCode)));
                  }
                },
                builder: (context, state) {
                  return CustomRoundedButton(
                    onTap: state is MultiUserBattleRoomInProgress
                        ? () {}
                        : () {
                            if (isCategoryEnabled() &&
                                getCategoryId().isEmpty) {
                              UiUtils.errorMessageDialog(
                                  context,
                                  AppLocalization.of(context)!
                                      .getTranslatedValues(
                                          pleaseSelectCategoryKey)!);
                              return;
                            }
                            if (entryFee < 0) {
                              UiUtils.errorMessageDialog(
                                  context,
                                  AppLocalization.of(context)!
                                      .getTranslatedValues(
                                          moreThanZeroCoinsKey)!);

                              return;
                            }
                            UserProfile userProfile = context
                                .read<UserDetailsCubit>()
                                .getUserProfile();

                            if (int.parse(userProfile.coins!) < entryFee) {
                              showAdDialog();
                              return;
                            }
                            context.read<MultiUserBattleRoomCubit>().createRoom(
                                  categoryId: getCategoryId(),
                                  entryFee: entryFee,
                                  name: userProfile.name,
                                  profileUrl: userProfile.profileUrl,
                                  roomType: "public",
                                  uid: userProfile.userId,
                                  questionLanguageId:
                                      UiUtils.getCurrentQuestionLanguageId(
                                          context),
                                );
                          },
                    widthPercentage: UiUtils.dailogWidthPercentage - 0.1,
                    backgroundColor: Constants.primaryColor,
                    buttonTitle: state is MultiUserBattleRoomInProgress
                        ? AppLocalization.of(context)!
                            .getTranslatedValues(creatingLoadingLbl)
                        : AppLocalization.of(context)!
                            .getTranslatedValues(createRoomKey),
                    radius: 25.0,
                    elevation: 5.0,
                    titleColor: Theme.of(context).backgroundColor,
                    shadowColor:
                        Theme.of(context).primaryColor.withOpacity(0.3),
                    showBorder: false,
                    height: constraints.maxHeight * (0.115),
                    fontWeight: FontWeight.bold,
                  );
                },
              )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      showbackButton: true,
      onWillPop: () {
        //means user is in create tab
        if (currentSelectedTab == 1) {
          if (widget.quizType == QuizTypes.groupPlay) {
            if (context.read<MultiUserBattleRoomCubit>().state
                is MultiUserBattleRoomInProgress) {
              return Future.value(false);
            }
            return Future.value(true);
          } else {
            if (context.read<BattleRoomCubit>().state is BattleRoomCreating) {
              return Future.value(false);
            }
            return Future.value(true);
          }
        }
        //user in join tab
        else {
          if (widget.quizType == QuizTypes.groupPlay) {
            if (context.read<MultiUserBattleRoomCubit>().state
                is MultiUserBattleRoomInProgress) {
              return Future.value(false);
            }
            return Future.value(true);
          } else {
            if (context.read<BattleRoomCubit>().state is BattleRoomJoining) {
              return Future.value(false);
            }
            return Future.value(true);
          }
        }
      },
      onBackButtonPress: () {
        if (currentSelectedTab == 1) {
          if (widget.quizType == QuizTypes.groupPlay) {
            if (context.read<MultiUserBattleRoomCubit>().state
                is! MultiUserBattleRoomInProgress) {
              Navigator.of(context).pop();
            }
          } else {
            if (context.read<BattleRoomCubit>().state is! BattleRoomCreating) {
              Navigator.of(context).pop();
            }
          }
        } else {
          if (widget.quizType == QuizTypes.groupPlay) {
            if (context.read<MultiUserBattleRoomCubit>().state
                is! MultiUserBattleRoomInProgress) {
              Navigator.of(context).pop();
            }
          } else {
            if (context.read<BattleRoomCubit>().state is! BattleRoomJoining) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      topPadding: Platform.isIOS
          ? MediaQuery.of(context).size.height * (0.065)
          : MediaQuery.of(context).size.height * (0.1),
      height: MediaQuery.of(context).size.height * (0.5),
      child: BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
        listener: (context, state) {
          if (state is UpdateScoreAndCoinsFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              UiUtils.showAlreadyLoggedInDialog(context: context);
            }
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(UiUtils.dailogRadius),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                color: Theme.of(context).backgroundColor,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildTabContainer(
                            1,
                            AppLocalization.of(context)!
                                .getTranslatedValues("creatingLbl")!,
                            constraints),
                        _buildTabContainer(
                            2,
                            AppLocalization.of(context)!
                                .getTranslatedValues("joinLbl")!,
                            constraints),
                      ],
                    ),
                    // Container(
                    //   color: Theme.of(context).primaryColorDark,
                    //   height: 5.0,
                    // ),
                    SizedBox(
                      height: constraints.maxHeight * (0.05),
                    ),
                    currentSelectedTab == 1
                        ? _buildCreateRoomTab(constraints)
                        : _buildJoinRoomTab(constraints)
                    //
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
