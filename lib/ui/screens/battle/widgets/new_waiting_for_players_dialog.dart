import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/widgets/custom_button.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/exitGameDailog.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/utils/widgets_util.dart';
import 'package:share_plus/share_plus.dart';

class NewWaitingForPlayerDialog extends StatefulWidget {
  final QuizTypes quizType;
  final String? battleLbl;
  NewWaitingForPlayerDialog({Key? key, required this.quizType, this.battleLbl})
      : super(key: key);

  @override
  State<NewWaitingForPlayerDialog> createState() =>
      _NewWaitingForPlayerDialogState();
}

class _NewWaitingForPlayerDialogState extends State<NewWaitingForPlayerDialog> {
  Widget profileAndNameContainer(
      BuildContext context,
      BoxConstraints constraints,
      String name,
      String profileUrl,
      Color borderColor) {
    return Column(
      children: [
        Container(
          // width: constraints.maxWidth * (0.285),
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          // decoration: BoxDecoration(
          //     border:
          //         Border.all(color: Theme.of(context).colorScheme.secondary)),
          // height: constraints.maxHeight * (0.19),
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 5,
          ),
          child: profileUrl.isEmpty
              ? Column(
                  children: [
                    Container(
                      height: constraints.maxHeight * 0.09,
                      width: constraints.maxHeight * 0.09,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // borderRadius: BorderRadius.circular(10),
                        color: Constants.white,
                      ),
                      child: SvgPicture.asset(
                        UiUtils.getImagePath(
                          "friend.svg",
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  height: constraints.maxHeight * 0.09,
                  width: constraints.maxHeight * 0.09,
                  child: CachedNetworkImage(
                    imageUrl: profileUrl,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
        ),
        // SizedBox(
        //   height: constraints.maxHeight * (0.015),
        // ),
        Container(
          width: constraints.maxWidth * (0.3),
          height: constraints.maxHeight * (0.05),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: 5.0,
          ),
          decoration: BoxDecoration(
            color: Constants.primaryColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            name.isEmpty
                ? AppLocalization.of(context)!
                    .getTranslatedValues('waitingLbl')!
                : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Constants.white),
          ),
        ),
      ],
    );
  }

  void showRoomDestroyed(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: AlertDialog(
              content: Text(
                AppLocalization.of(context)!
                    .getTranslatedValues('roomDeletedOwnerLbl')!,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues('okayLbl')!,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ))
              ],
            )));
  }

  void onBackEvent() {
    if (widget.quizType == QuizTypes.battle) {
      if (context.read<BattleRoomCubit>().state is BattleRoomCreated ||
          context.read<BattleRoomCubit>().state is BattleRoomUserFound) {
        //if user
        showDialog(
            context: context,
            builder: (context) => ExitGameDailog(
                  onTapYes: () {
                    bool createdRoom = false;

                    if (context.read<BattleRoomCubit>().state
                        is BattleRoomUserFound) {
                      createdRoom = (context.read<BattleRoomCubit>().state
                                  as BattleRoomUserFound)
                              .battleRoom
                              .user1!
                              .uid ==
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId;
                    } else {
                      createdRoom = (context.read<BattleRoomCubit>().state
                                  as BattleRoomCreated)
                              .battleRoom
                              .user1!
                              .uid ==
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId;
                    }
                    //if room is created by current user then delete room
                    if (createdRoom) {
                      context.read<BattleRoomCubit>().deleteBattleRoom(
                          false); // : context.read<MultiUserBattleRoomCubit>().deleteMultiUserBattleRoom();
                    } else {
                      context
                          .read<BattleRoomCubit>()
                          .removeOpponentFromBattleRoom();
                    }
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ));
      }
    } else {
      //
      showDialog(
          context: context,
          builder: (context) => ExitGameDailog(
                onTapYes: () {
                  bool createdRoom = (context
                              .read<MultiUserBattleRoomCubit>()
                              .state as MultiUserBattleRoomSuccess)
                          .battleRoom
                          .user1!
                          .uid ==
                      context.read<UserDetailsCubit>().getUserProfile().userId;

                  //if room is created by current user then delete room
                  if (createdRoom) {
                    context
                        .read<MultiUserBattleRoomCubit>()
                        .deleteMultiUserBattleRoom();
                  } else {
                    //if room is not created by current user then remove user from room
                    context.read<MultiUserBattleRoomCubit>().deleteUserFromRoom(
                        context
                            .read<UserDetailsCubit>()
                            .getUserProfile()
                            .userId!);
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '',
      backgroundColor: Constants.primaryColor,
      titleColor: Constants.white,
      child: Container(
        child: widget.quizType == QuizTypes.battle
            ? BlocListener<BattleRoomCubit, BattleRoomState>(
                bloc: context.read<BattleRoomCubit>(),
                listener: (context, state) {
                  if (state is BattleRoomUserFound) {
                    //if game is ready to play
                    if (state.battleRoom.readyToPlay!) {
                      //if user has joined room then navigate to quiz screen
                      if (state.battleRoom.user1!.uid !=
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId) {
                        Navigator.of(context).pushReplacementNamed(
                            Routes.battleRoomQuiz,
                            arguments: {
                              "battleLbl": widget.battleLbl,
                              "isTournamentBattle": false
                            });
                      }
                    }

                    //if owner deleted the room then show this dialog
                    if (!state.isRoomExist) {
                      if (context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId !=
                          state.battleRoom.user1!.uid) {
                        //Room destroyed by owner
                        showRoomDestroyed(context);
                      }
                    }
                  }
                },
                ////////////// comment ////////////////////////
                child: LayoutBuilder(builder: (context, constraints) {
                  return Column(
                    children: [
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.04),
                      // ),
                      BlocBuilder<MultiUserBattleRoomCubit,
                          MultiUserBattleRoomState>(
                        bloc: context.read<MultiUserBattleRoomCubit>(),
                        builder: (context, state) {
                          if (state is MultiUserBattleRoomSuccess) {
                            return SizedBox(
                              height: SizeConfig.screenHeight * 0.7,
                              child: Stack(
                                ////////////////////////////////////////////////////////////////////////////////////
                                // clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    top: constraints.maxHeight * 0.20,
                                    child: Container(
                                      height: constraints.maxHeight * 0.20,
                                      width: constraints.maxWidth * 0.96,
                                      // padding: const EdgeInsets.symmetric(horizontal: 28),
                                      padding: const EdgeInsets.all(8),
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Constants.secondaryColor,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                        image: DecorationImage(
                                          alignment: Alignment.center,
                                          fit: BoxFit.scaleDown,
                                          image: AssetImage(
                                              Assets.backgroundCircle2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          profileAndNameContainer(
                                            context,
                                            constraints,
                                            state.battleRoom.user1!.name,
                                            state.battleRoom.user1!.profileUrl,
                                            Theme.of(context).backgroundColor,
                                          ),
                                          Text(
                                            AppLocalization.of(context)!
                                                .getTranslatedValues('vsLbl')!,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .backgroundColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 32,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: BlocBuilder<
                                                MultiUserBattleRoomCubit,
                                                MultiUserBattleRoomState>(
                                              bloc: context.read<
                                                  MultiUserBattleRoomCubit>(),
                                              builder: (context, state) {
                                                if (state
                                                    is MultiUserBattleRoomSuccess) {
                                                  return widget.quizType ==
                                                          QuizTypes.battle
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            profileAndNameContainer(
                                                                context,
                                                                constraints,
                                                                state
                                                                    .battleRoom
                                                                    .user2!
                                                                    .name,
                                                                state
                                                                    .battleRoom
                                                                    .user2!
                                                                    .profileUrl,
                                                                Colors.black54),
                                                          ],
                                                        )
                                                      : Row(
                                                          children: [
                                                            profileAndNameContainer(
                                                                context,
                                                                constraints,
                                                                state
                                                                    .battleRoom
                                                                    .user2!
                                                                    .name,
                                                                state
                                                                    .battleRoom
                                                                    .user2!
                                                                    .profileUrl,
                                                                Colors.black54),
                                                          ],
                                                        );
                                                } else {
                                                  return Container();
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: const [
                                      // Positioned(
                                      //   left: constraints.maxWidth / 2,
                                      //   top: constraints.maxHeight * .23,
                                      //   child: Padding(
                                      //     padding: const EdgeInsets.symmetric(
                                      //         horizontal: 5),
                                      //     child: BlocBuilder<
                                      //         MultiUserBattleRoomCubit,
                                      //         MultiUserBattleRoomState>(
                                      //       bloc: context
                                      //           .read<MultiUserBattleRoomCubit>(),
                                      //       builder: (context, state) {
                                      //         if (state
                                      //             is MultiUserBattleRoomSuccess) {
                                      //           return widget.quizType ==
                                      //                   QuizTypes.battle
                                      //               ? Row(
                                      //                   mainAxisAlignment:
                                      //                       MainAxisAlignment
                                      //                           .center,
                                      //                   children: [
                                      //                     profileAndNameContainer(
                                      //                         context,
                                      //                         constraints,
                                      //                         state.battleRoom
                                      //                             .user2!.name,
                                      //                         state
                                      //                             .battleRoom
                                      //                             .user2!
                                      //                             .profileUrl,
                                      //                         Colors.black54),
                                      //                   ],
                                      //                 )
                                      //               : Row(
                                      //                   children: [
                                      //                     profileAndNameContainer(
                                      //                         context,
                                      //                         constraints,
                                      //                         state.battleRoom
                                      //                             .user2!.name,
                                      //                         state
                                      //                             .battleRoom
                                      //                             .user2!
                                      //                             .profileUrl,
                                      //                         Colors.black54),
                                      //                   ],
                                      //                 );
                                      //         } else {
                                      //           return Container();
                                      //         }
                                      //       },
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  Positioned(
                                    top: SizeConfig.screenHeight * .354,
                                    right: 8,
                                    left: 8,
                                    child: Image.asset(
                                      Assets.whiteBox,
                                      width: SizeConfig.screenWidth,
                                      height: SizeConfig.screenWidth * 0.67,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: constraints.maxHeight * .42,
                                    child: Text(
                                      AppLocalization.of(context)!
                                          .getTranslatedValues(
                                              'shareRoomCodeLbl')!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        height: 1.2,
                                        color: Constants.black2,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: SizeConfig.screenHeight * 0.45,
                                    left: SizeConfig.screenWidth * 0.065,
                                    child: Row(
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height:
                                              SizeConfig.screenHeight * 0.073,
                                          width: SizeConfig.screenWidth / 1.15,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: Constants.grey5,
                                            border: Border.all(
                                              color: Constants.bluecolor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: SizeConfig.screenHeight * 0.475,
                                    left: SizeConfig.screenWidth * 0.25,
                                    child: Text(
                                      "${AppLocalization.of(context)!.getTranslatedValues('roomCodeLbl')!} : ${context.read<MultiUserBattleRoomCubit>().getRoomCode()}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18.0,
                                        color: Constants.black2,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: SizeConfig.screenHeight * 0.55,
                                    left: SizeConfig.screenWidth * 0.065,
                                    child: SizedBox(
                                        height: SizeConfig.screenHeight * 0.07,
                                        width: SizeConfig.screenWidth / 1.5,
                                        child: CustomButton(
                                          onPressed: () async {
                                            //need minimum 2 player to start the game
                                            //mark as ready to play in database
                                            if (state.battleRoom.user2!.uid
                                                .isEmpty) {
                                              UiUtils.errorMessageDialog(
                                                  context,
                                                  AppLocalization.of(context)!
                                                      .getTranslatedValues(
                                                          convertErrorCodeToLanguageKey(
                                                              canNotStartGameCode)));
                                            } else {
                                              context
                                                  .read<BattleRoomCubit>()
                                                  .startGame();
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500));
                                              //navigate to quiz screen
                                              Navigator.of(context)
                                                  .pushReplacementNamed(
                                                      Routes.battleRoomQuiz,
                                                      arguments: {
                                                    "battleLbl":
                                                        widget.battleLbl,
                                                    "isTournamentBattle": false
                                                  });
                                            }
                                          },
                                          backgroundColor:
                                              Constants.primaryColor,
                                          height: 12,
                                          horizontalMargin: 0,
                                          isLoading: false,
                                          text: 'Start',
                                          textColor: Constants.white,
                                          verticalMargin: 0,
                                        )),
                                  ),
                                  Positioned(
                                    top: SizeConfig.screenHeight * 0.55,
                                    left: SizeConfig.screenWidth * 0.79,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        log("share Battle");
                                        try {
                                          String inviteMessage =
                                              "$groupBattleInviteMessage${context.read<BattleRoomCubit>().getRoomCode()}";
                                          Share.share(inviteMessage);
                                        } catch (e) {
                                          UiUtils.setSnackbar(
                                              AppLocalization.of(context)!
                                                  .getTranslatedValues(
                                                      convertErrorCodeToLanguageKey(
                                                          defaultErrorMessageCode))!,
                                              context,
                                              false);
                                        }
                                      },
                                      child: Container(
                                        height: SizeConfig.screenHeight * 0.07,
                                        width: SizeConfig.screenWidth * 0.15,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Constants.grey4,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.share,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                          return profileAndNameContainer(context, constraints,
                              "", "", Theme.of(context).backgroundColor);
                        },
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.027),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.03),
                      ),
                      const Spacer(),
                      BlocBuilder<MultiUserBattleRoomCubit,
                          MultiUserBattleRoomState>(
                        bloc: context.read<MultiUserBattleRoomCubit>(),
                        builder: (context, state) {
                          if (state is MultiUserBattleRoomSuccess) {
                            if (state.battleRoom.user1!.uid !=
                                context
                                    .read<UserDetailsCubit>()
                                    .getUserProfile()
                                    .userId) {
                              return Container();
                            }
                            return TextButton(
                              onPressed: () {
                                //need minimum 2 player to start the game
                                //mark as ready to play in database
                                if (state.battleRoom.user2!.uid.isEmpty) {
                                  UiUtils.errorMessageDialog(
                                    context,
                                    AppLocalization.of(context)!
                                        .getTranslatedValues(
                                      convertErrorCodeToLanguageKey(
                                          canNotStartGameCode),
                                    ),
                                  );
                                } else {
                                  //start quiz
                                  /*    widget.quizType==QuizTypes.battle?context.read<BattleRoomCubit>().startGame():*/ context
                                      .read<MultiUserBattleRoomCubit>()
                                      .startGame();
                                  //navigate to quiz screen
                                  widget.quizType == QuizTypes.battle
                                      ? Navigator.of(context)
                                          .pushReplacementNamed(
                                              Routes.battleRoomQuiz,
                                              arguments: {
                                              "battleLbl": widget.battleLbl,
                                              "isTournamentBattle": false
                                            })
                                      : Navigator.of(context)
                                          .pushReplacementNamed(
                                              Routes.multiUserBattleRoomQuiz);
                                }
                              },
                              child: Text(
                                  AppLocalization.of(context)!
                                      .getTranslatedValues('startLbl')!,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Constants.primaryColor,
                                  )),
                            );
                          }
                          return Container();
                        },
                      ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.01),
                      // ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.025),
                      // ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.0275),
                      // ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.027),
                      // ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.03),
                      // ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.01),
                      // ),
                    ],
                  );
                }),
              )
            : BlocListener<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
                listener: (context, state) {
                  if (state is MultiUserBattleRoomSuccess) {
                    //if game is ready to play
                    if (state.battleRoom.readyToPlay!) {
                      //if user has joined room then navigate to quiz screen
                      if (state.battleRoom.user1!.uid !=
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId) {
                        Navigator.of(context).pushReplacementNamed(
                            Routes.multiUserBattleRoomQuiz);
                      }
                    }

                    //if owner deleted the room then show this dialog
                    if (!state.isRoomExist) {
                      if (context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId !=
                          state.battleRoom.user1!.uid) {
                        //Room destroyed by owner
                        showRoomDestroyed(context);
                      }
                    }
                  }
                },
                child: LayoutBuilder(builder: (context, constraints) {
                  return Column(
                    children: [
                      SizedBox(
                        height: constraints.maxHeight * (0.03),
                      ),
                      BlocBuilder<MultiUserBattleRoomCubit,
                          MultiUserBattleRoomState>(
                        bloc: context.read<MultiUserBattleRoomCubit>(),
                        builder: (context, state) {
                          if (state is MultiUserBattleRoomSuccess) {
                            return Stack(
                              ////////////////////////////////////////////////////////////////////////////////////
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: constraints.maxHeight * 0.69,
                                  width: constraints.maxWidth / .2,
                                  // padding: const EdgeInsets.symmetric(horizontal: 28),
                                  padding: const EdgeInsets.all(8),

                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Constants.secondaryColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                    image: DecorationImage(
                                      alignment: Alignment.topCenter,
                                      fit: BoxFit.scaleDown,
                                      image: AssetImage(
                                        Assets.backgroundCircle2,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      profileAndNameContainer(
                                        context,
                                        constraints,
                                        state.battleRoom.user1!.name,
                                        state.battleRoom.user1!.profileUrl,
                                        Theme.of(context).backgroundColor,
                                      ),
                                      Text(
                                        AppLocalization.of(context)!
                                            .getTranslatedValues('vsLbl')!,
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).backgroundColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 32,
                                        ),
                                      ),
                                      BlocBuilder<MultiUserBattleRoomCubit,
                                          MultiUserBattleRoomState>(
                                        bloc: context
                                            .read<MultiUserBattleRoomCubit>(),
                                        builder: (context, state) {
                                          if (state
                                              is MultiUserBattleRoomSuccess) {
                                            return widget.quizType ==
                                                    QuizTypes.battle
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      profileAndNameContainer(
                                                          context,
                                                          constraints,
                                                          state.battleRoom
                                                              .user2!.name,
                                                          state
                                                              .battleRoom
                                                              .user2!
                                                              .profileUrl,
                                                          Colors.black54),
                                                    ],
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      profileAndNameContainer(
                                                          context,
                                                          constraints,
                                                          state.battleRoom
                                                              .user2!.name,
                                                          state
                                                              .battleRoom
                                                              .user2!
                                                              .profileUrl,
                                                          Colors.black54),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      profileAndNameContainer(
                                                          context,
                                                          constraints,
                                                          state.battleRoom
                                                              .user3!.name,
                                                          state
                                                              .battleRoom
                                                              .user3!
                                                              .profileUrl,
                                                          Colors.black54),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      profileAndNameContainer(
                                                          context,
                                                          constraints,
                                                          state.battleRoom
                                                              .user4!.name,
                                                          state
                                                              .battleRoom
                                                              .user4!
                                                              .profileUrl,
                                                          Colors.black54),
                                                    ],
                                                  );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // Positioned(
                                //   left: constraints.maxWidth * .45,
                                //   top: constraints.maxHeight * .175,
                                //   child: Text(
                                //     AppLocalization.of(context)!
                                //         .getTranslatedValues('vsLbl')!,
                                //     style: TextStyle(
                                //       color: Theme.of(context).backgroundColor,
                                //       fontWeight: FontWeight.w700,
                                //       fontSize: 32,
                                //     ),
                                //   ),
                                // ),
                                // Positioned(
                                //   left: constraints.maxWidth / 25,
                                //   top: constraints.maxHeight * .23,
                                //   child: Padding(
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: 5),
                                //     child: BlocBuilder<MultiUserBattleRoomCubit,
                                //         MultiUserBattleRoomState>(
                                //       bloc: context
                                //           .read<MultiUserBattleRoomCubit>(),
                                //       builder: (context, state) {
                                //         if (state
                                //             is MultiUserBattleRoomSuccess) {
                                //           return widget.quizType ==
                                //                   QuizTypes.battle
                                //               ? Row(
                                //                   mainAxisAlignment:
                                //                       MainAxisAlignment.center,
                                //                   children: [
                                //                     profileAndNameContainer(
                                //                         context,
                                //                         constraints,
                                //                         state.battleRoom.user2!
                                //                             .name,
                                //                         state.battleRoom.user2!
                                //                             .profileUrl,
                                //                         Colors.black54),
                                //                   ],
                                //                 )
                                //               : Row(
                                //                   mainAxisAlignment:
                                //                       MainAxisAlignment
                                //                           .spaceBetween,
                                //                   children: [
                                //                     profileAndNameContainer(
                                //                         context,
                                //                         constraints,
                                //                         state.battleRoom.user2!
                                //                             .name,
                                //                         state.battleRoom.user2!
                                //                             .profileUrl,
                                //                         Colors.black54),
                                //                     const SizedBox(
                                //                       width: 2,
                                //                     ),
                                //                     profileAndNameContainer(
                                //                         context,
                                //                         constraints,
                                //                         state.battleRoom.user3!
                                //                             .name,
                                //                         state.battleRoom.user3!
                                //                             .profileUrl,
                                //                         Colors.black54),
                                //                     const SizedBox(
                                //                       width: 2,
                                //                     ),
                                //                     profileAndNameContainer(
                                //                         context,
                                //                         constraints,
                                //                         state.battleRoom.user4!
                                //                             .name,
                                //                         state.battleRoom.user4!
                                //                             .profileUrl,
                                //                         Colors.black54),
                                //                   ],
                                //                 );
                                //         } else {
                                //           return Container();
                                //         }
                                //       },
                                //     ),
                                //   ),
                                // ),
                                Positioned(
                                  top: SizeConfig.screenHeight * .4,
                                  right: 8,
                                  left: 8,
                                  child: Image.asset(
                                    Assets.whiteBox,
                                    width: SizeConfig.screenWidth,
                                    height: SizeConfig.screenWidth * 0.67,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: constraints.maxHeight * .47,
                                  child: Text(
                                    AppLocalization.of(context)!
                                        .getTranslatedValues(
                                            'shareRoomCodeLbl')!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      height: 1.2,
                                      color: Constants.black2,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: SizeConfig.screenHeight * 0.5,
                                  left: SizeConfig.screenWidth * 0.065,
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: SizeConfig.screenHeight * 0.073,
                                        width: SizeConfig.screenWidth / 1.15,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: Constants.grey5,
                                          border: Border.all(
                                            color: Constants.bluecolor,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${AppLocalization.of(context)!.getTranslatedValues('roomCodeLbl')!} : ${context.read<MultiUserBattleRoomCubit>().getRoomCode()}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18.0,
                                              color: Constants.black2,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Positioned(
                                //   // top: SizeConfig.screenHeight * 0.475,
                                //   // left: SizeConfig.screenWidth * 0.25,
                                //   left: 0,
                                //   right: 0,
                                //   child:
                                // ),
                                Positioned(
                                  top: SizeConfig.screenHeight * 0.6,
                                  // left: SizeConfig.screenWidth * 0.065,
                                  right: 0,
                                  left: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: CustomButton(
                                            onPressed: () {
                                              //need minimum 2 player to start the game
                                              //mark as ready to play in database
                                              //need minimum 2 player to start the game
                                              //mark as ready to play in database
                                              if (state.battleRoom.user2!.uid
                                                  .isEmpty) {
                                                UiUtils.errorMessageDialog(
                                                    context,
                                                    AppLocalization.of(context)!
                                                        .getTranslatedValues(
                                                            convertErrorCodeToLanguageKey(
                                                                canNotStartGameCode)));
                                              } else {
                                                //start quiz
                                                /*    widget.quizType==QuizTypes.battle?context.read<BattleRoomCubit>().startGame():*/ context
                                                    .read<
                                                        MultiUserBattleRoomCubit>()
                                                    .startGame();
                                                //navigate to quiz screen
                                                widget.quizType ==
                                                        QuizTypes.battle
                                                    ? Navigator.of(context)
                                                        .pushReplacementNamed(
                                                            Routes
                                                                .battleRoomQuiz,
                                                            arguments: {
                                                            "battleLbl": widget
                                                                .battleLbl,
                                                            "isTournamentBattle":
                                                                false
                                                          })
                                                    : Navigator.of(context)
                                                        .pushReplacementNamed(Routes
                                                            .multiUserBattleRoomQuiz);
                                              }
                                            },
                                            backgroundColor:
                                                Constants.primaryColor,
                                            height: 56,
                                            horizontalMargin: 10,
                                            isLoading: false,
                                            text: 'Start',
                                            textColor: Constants.white,
                                            verticalMargin: 0,
                                          ),
                                        ),
                                        // WidgetsUtil.horizontalSpace16,
                                        Expanded(
                                          child: GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            onTap: () {
                                              log("message");
                                              String inviteMessage =
                                                  "$groupBattleInviteMessage${context.read<MultiUserBattleRoomCubit>().getRoomCode()}";
                                              Share.share(inviteMessage);
                                              try {} catch (e) {
                                                log(" $e message");
                                                UiUtils.setSnackbar(
                                                    AppLocalization.of(context)!
                                                        .getTranslatedValues(
                                                            convertErrorCodeToLanguageKey(
                                                                defaultErrorMessageCode))!,
                                                    context,
                                                    false);
                                              }
                                            },
                                            child: Container(
                                              height: SizeConfig.screenHeight *
                                                  0.07,
                                              width:
                                                  SizeConfig.screenWidth * 0.15,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Constants.grey4,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  20,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.share,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Positioned(
                                //   top: SizeConfig.screenHeight * 0.6,
                                //   left: SizeConfig.screenWidth * 0.79,
                                //   child:
                                // )
                              ],
                            );
                          }
                          return profileAndNameContainer(context, constraints,
                              "", "", Theme.of(context).backgroundColor);
                        },
                      ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.027),
                      // ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.03),
                      // ),
                      // const Spacer(),
                      // BlocBuilder<MultiUserBattleRoomCubit,
                      //     MultiUserBattleRoomState>(
                      //   bloc: context.read<MultiUserBattleRoomCubit>(),
                      //   builder: (context, state) {
                      //     if (state is MultiUserBattleRoomSuccess) {
                      //       if (state.battleRoom.user1!.uid !=
                      //           context
                      //               .read<UserDetailsCubit>()
                      //               .getUserProfile()
                      //               .userId) {
                      //         return Container();
                      //       }
                      //       return TextButton(
                      //         onPressed: () {
                      //           //need minimum 2 player to start the game
                      //           //mark as ready to play in database
                      //           if (state.battleRoom.user2!.uid.isEmpty) {
                      //             UiUtils.errorMessageDialog(
                      //               context,
                      //               AppLocalization.of(context)!
                      //                   .getTranslatedValues(
                      //                 convertErrorCodeToLanguageKey(
                      //                     canNotStartGameCode),
                      //               ),
                      //             );
                      //           } else {
                      //             //start quiz
                      //             /*    widget.quizType==QuizTypes.battle?context.read<BattleRoomCubit>().startGame():*/ context
                      //                 .read<MultiUserBattleRoomCubit>()
                      //                 .startGame();
                      //             //navigate to quiz screen
                      //             widget.quizType == QuizTypes.battle
                      //                 ? Navigator.of(context)
                      //                     .pushReplacementNamed(
                      //                         Routes.battleRoomQuiz,
                      //                         arguments: {
                      //                         "battleLbl": widget.battleLbl,
                      //                         "isTournamentBattle": false
                      //                       })
                      //                 : Navigator.of(context)
                      //                     .pushReplacementNamed(
                      //                         Routes.multiUserBattleRoomQuiz);
                      //           }
                      //         },
                      //         child: Text(
                      //             AppLocalization.of(context)!
                      //                 .getTranslatedValues('startLbl')!,
                      //             style: TextStyle(
                      //               fontSize: 20.0,
                      //               color: Constants.primaryColor,
                      //             )),
                      //       );
                      //     }
                      //     return Container();
                      //   },
                      // ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.01),
                      // ),
                      //entry amount card
                      // Container(
                      //   height: constraints.maxHeight * (0.10),
                      //   width: constraints.maxWidth,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.only(
                      //       topLeft: Radius.circular(UiUtils.dailogRadius),
                      //       topRight: Radius.circular(UiUtils.dailogRadius),
                      //     ),
                      //     color: Constants.primaryColor,
                      //   ),
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      //     child: Stack(
                      //       children: [
                      //         Align(
                      //           alignment: Alignment.center,
                      //           child: Text(
                      //             "${AppLocalization.of(context)!.getTranslatedValues('entryAmountLbl')!} : ${context.read<MultiUserBattleRoomCubit>().getEntryFee()}",
                      //             textAlign: TextAlign.center,
                      //             style: TextStyle(
                      //               color: Constants.white,
                      //               fontSize: 16.0,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ),
                      //         Align(
                      //             alignment: Alignment.centerRight,
                      //             child: IconButton(
                      //               onPressed: () {
                      //                 log("message");
                      //                 try {
                      //                   String inviteMessage =
                      //                       "$groupBattleInviteMessage${context.read<MultiUserBattleRoomCubit>().getRoomCode()}";
                      //                   Share.share(inviteMessage);
                      //                 } catch (e) {
                      //                   UiUtils.setSnackbar(
                      //                       AppLocalization.of(context)!
                      //                           .getTranslatedValues(
                      //                               convertErrorCodeToLanguageKey(
                      //                                   defaultErrorMessageCode))!,
                      //                       context,
                      //                       false);
                      //                 }
                      //               },
                      //               iconSize: 20,
                      //               icon: const Icon(Icons.share),
                      //               color: Theme.of(context).backgroundColor,
                      //             ))
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.025),
                      // ),
                      //room code card
                      // Container(
                      //   width: constraints.maxWidth * (0.85),
                      //   height: constraints.maxHeight * (0.175),
                      //   decoration: BoxDecoration(
                      //     border: Border.all(
                      //         color: Theme.of(context).colorScheme.secondary),
                      //     borderRadius: BorderRadius.circular(15.0),
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Padding(
                      //         padding:
                      //             const EdgeInsets.symmetric(horizontal: 15.0),
                      //         child: Row(
                      //           children: [
                      //             Expanded(
                      //               //
                      //               child: Text(
                      //                   "${AppLocalization.of(context)!.getTranslatedValues('roomCodeLbl')!} : ${context.read<MultiUserBattleRoomCubit>().getRoomCode()}",
                      //                   textAlign: TextAlign.center,
                      //                   style: TextStyle(
                      //                     fontWeight: FontWeight.w600,
                      //                     fontSize: 18.0,
                      //                     color: Theme.of(context)
                      //                         .colorScheme
                      //                         .secondary,
                      //                     height: 1.2,
                      //                   )),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       const SizedBox(
                      //         height: 5.0,
                      //       ),
                      //       Text(
                      //           AppLocalization.of(context)!
                      //               .getTranslatedValues('shareRoomCodeLbl')!,
                      //           textAlign: TextAlign.center,
                      //           style: TextStyle(
                      //             fontWeight: FontWeight.w300,
                      //             fontSize: 13.5,
                      //             height: 1.2,
                      //             color:
                      //                 Theme.of(context).colorScheme.secondary,
                      //           )),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.0275),
                      // ),
                      //user imiage
                      // BlocBuilder<MultiUserBattleRoomCubit,
                      //     MultiUserBattleRoomState>(
                      //   bloc: context.read<MultiUserBattleRoomCubit>(),
                      //   builder: (context, state) {
                      //     if (state is MultiUserBattleRoomSuccess) {
                      //       return profileAndNameContainer(
                      //           context,
                      //           constraints,
                      //           state.battleRoom.user1!.name,
                      //           state.battleRoom.user1!.profileUrl,
                      //           Theme.of(context).backgroundColor);
                      //     }
                      //     return profileAndNameContainer(context, constraints,
                      //         "", "", Theme.of(context).backgroundColor);
                      //   },
                      // ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.027),
                      // ),
                      //vs card
                      // CircleAvatar(
                      //   backgroundColor: Constants.primaryColor,
                      //   child: Text(
                      //     AppLocalization.of(context)!
                      //         .getTranslatedValues('vsLbl')!,
                      //     style: TextStyle(
                      //         color: Theme.of(context).backgroundColor),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.03),
                      // ),
                      //opponent card
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 5),
                      //   child: BlocBuilder<MultiUserBattleRoomCubit,
                      //       MultiUserBattleRoomState>(
                      //     bloc: context.read<MultiUserBattleRoomCubit>(),
                      //     builder: (context, state) {
                      //       if (state is MultiUserBattleRoomSuccess) {
                      //         return widget.quizType == QuizTypes.battle
                      //             ? Row(
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.center,
                      //                 children: [
                      //                   profileAndNameContainer(
                      //                       context,
                      //                       constraints,
                      //                       state.battleRoom.user2!.name,
                      //                       state.battleRoom.user2!.profileUrl,
                      //                       Colors.black54),
                      //                 ],
                      //               )
                      //             : Row(
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.spaceAround,
                      //                 children: [
                      //                   profileAndNameContainer(
                      //                       context,
                      //                       constraints,
                      //                       state.battleRoom.user2!.name,
                      //                       state.battleRoom.user2!.profileUrl,
                      //                       Colors.black54),
                      //                   profileAndNameContainer(
                      //                       context,
                      //                       constraints,
                      //                       state.battleRoom.user3!.name,
                      //                       state.battleRoom.user3!.profileUrl,
                      //                       Colors.black54),
                      //                   profileAndNameContainer(
                      //                       context,
                      //                       constraints,
                      //                       state.battleRoom.user4!.name,
                      //                       state.battleRoom.user4!.profileUrl,
                      //                       Colors.black54),
                      //                 ],
                      //               );
                      //       } else {
                      //         return Container();
                      //       }
                      //     },
                      //   ),
                      // ),
                      // const Spacer(),
//start button
                      // BlocBuilder<MultiUserBattleRoomCubit,
                      //     MultiUserBattleRoomState>(
                      //   bloc: context.read<MultiUserBattleRoomCubit>(),
                      //   builder: (context, state) {
                      //     if (state is MultiUserBattleRoomSuccess) {
                      //       if (state.battleRoom.user1!.uid !=
                      //           context
                      //               .read<UserDetailsCubit>()
                      //               .getUserProfile()
                      //               .userId) {
                      //         return Container();
                      //       }
                      //       return TextButton(
                      //         onPressed: () {
                      //           //need minimum 2 player to start the game
                      //           //mark as ready to play in database
                      //           if (state.battleRoom.user2!.uid.isEmpty) {
                      //             UiUtils.errorMessageDialog(
                      //                 context,
                      //                 AppLocalization.of(context)!
                      //                     .getTranslatedValues(
                      //                         convertErrorCodeToLanguageKey(
                      //                             canNotStartGameCode)));
                      //           } else {
                      //             //start quiz
                      //             /*    widget.quizType==QuizTypes.battle?context.read<BattleRoomCubit>().startGame():*/ context
                      //                 .read<MultiUserBattleRoomCubit>()
                      //                 .startGame();
                      //             //navigate to quiz screen
                      //             widget.quizType == QuizTypes.battle
                      //                 ? Navigator.of(context)
                      //                     .pushReplacementNamed(
                      //                         Routes.battleRoomQuiz,
                      //                         arguments: {
                      //                         "battleLbl": widget.battleLbl,
                      //                         "isTournamentBattle": false
                      //                       })
                      //                 : Navigator.of(context)
                      //                     .pushReplacementNamed(
                      //                         Routes.multiUserBattleRoomQuiz);
                      //           }
                      //         },
                      //         child: Text(
                      //             AppLocalization.of(context)!
                      //                 .getTranslatedValues('startLbl')!,
                      //             style: TextStyle(
                      //               fontSize: 20.0,
                      //               color: Constants.primaryColor,
                      //             )),
                      //       );
                      //     }
                      //     return Container();
                      //   },
                      // ),
                      // SizedBox(
                      //   height: constraints.maxHeight * (0.01),
                      // ),
                    ],
                  );
                }),
              ),
      ),
    );
  }
}
