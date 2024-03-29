import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/rewardedAdCubit.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/audioQuestionBookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/questionsCubit.dart';
import 'package:flutterquiz/features/quiz/models/comprehension.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/audioQuestionContainer.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/new_question_container.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/exitGameDailog.dart';
import 'package:flutterquiz/ui/widgets/settingButton.dart';
import 'package:flutterquiz/ui/widgets/settingsDialogContainer.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/ui/widgets/watchRewardAdDialog.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

enum LifelineStatus { unused, using, used }

class NewQuizScreen extends StatefulWidget {
  final int numberOfPlayer;
  final QuizTypes quizType;
  final String level; //will be in use for quizZone quizType
  final String categoryId; //will be in use for quizZone quizType
  final String subcategoryId; //will be in use for quizZone quizType
  final String
      subcategoryMaxLevel; //will be in use for quizZone quizType (to pass in result screen)
  final int unlockedLevel;
  final bool isPlayed; //Only in use when quiz type is audio questions
  final String contestId;
  final Comprehension
      comprehension; // will be in use for fun n learn quizType (to pass in result screen)

  const NewQuizScreen({
    Key? key,
    required this.isPlayed,
    required this.numberOfPlayer,
    required this.subcategoryMaxLevel,
    required this.quizType,
    required this.categoryId,
    required this.level,
    required this.subcategoryId,
    required this.unlockedLevel,
    required this.contestId,
    required this.comprehension,
  }) : super(key: key);

  @override
  _NewQuizScreenState createState() => _NewQuizScreenState();

  //to provider route
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    //keys of arguments are numberOfPlayer and quizType (required)
    //if quizType is quizZone then need to pass following keys
    //categoryId, subcategoryId, level, subcategoryMaxLevel and unlockedLevel

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          //for quesitons and points
          BlocProvider<QuestionsCubit>(
            create: (_) => QuestionsCubit(QuizRepository()),
          ),
          //to update user coins after using lifeline
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateBookmarkCubit>(
              create: (_) => UpdateBookmarkCubit(BookmarkRepository())),
        ],
        child: NewQuizScreen(
          isPlayed: arguments['isPlayed'] ?? true,
          numberOfPlayer: arguments['numberOfPlayer'] as int,
          quizType: arguments['quizType'] as QuizTypes,
          categoryId: arguments['categoryId'] ?? "",
          level: arguments['level'] ?? "",
          subcategoryId: arguments['subcategoryId'] ?? "",
          subcategoryMaxLevel: arguments['subcategoryMaxLevel'] ?? "",
          unlockedLevel: arguments['unlockedLevel'] ?? 0,
          contestId: arguments["contestId"] ?? "",
          comprehension:
              arguments["comprehension"] ?? Comprehension.fromJson({}),
        ),
      ),
    );
  }
}

class _NewQuizScreenState extends State<NewQuizScreen>
    with TickerProviderStateMixin {
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;
  // late AnimationController audioAnimationController = AnimationController(
  //     vsync: this, duration: Duration(seconds: latexQuestionDurationInSeconds))
  //   ..addStatusListener(currentUserTimerAnimationStatusListener);
  late AnimationController timerAnimationController = AnimationController(
      vsync: this,
      duration: Duration(
          seconds: widget.quizType == QuizTypes.mathMania
              ? latexQuestionDurationInSeconds
              : questionDurationInSeconds))
    ..addStatusListener(currentUserTimerAnimationStatusListener);

  late Animation<double> questionSlideAnimation;
  late Animation<double> questionScaleUpAnimation;
  late Animation<double> questionScaleDownAnimation;
  late Animation<double> questionContentAnimation;
  late AnimationController animationController;
  late AnimationController topContainerAnimationController;
  late List<GlobalKey<AudioQuestionContainerState>> audioQuestionContainerKeys =
      [];
  int currentQuestionIndex = 0;
  int totalQuestions = 0;
  final double optionWidth = 0.7;
  final double optionHeight = 0.09;

  late double totalSecondsToCompleteQuiz = 0;

  late Map<String, LifelineStatus> lifelines = {
    fiftyFifty: LifelineStatus.unused,
    audiencePoll: LifelineStatus.unused,
    skip: LifelineStatus.unused,
    resetTime: LifelineStatus.unused,
  };

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;
  bool isExitDialogOpen = false;
  _getQuestions() {
    Future.delayed(
      Duration.zero,
      () {
        //check if languageId need to pass or not
        context.read<QuestionsCubit>().getQuestions(
              widget.quizType,
              userId: context.read<UserDetailsCubit>().getUserId(),
              categoryId: widget.categoryId,
              level: widget.level,
              languageId: UiUtils.getCurrentQuestionLanguageId(context),
              subcategoryId: widget.subcategoryId,
              contestId: widget.contestId,
              funAndLearnId: widget.comprehension.id,
            );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    //init reward ad
    Future.delayed(Duration.zero, () {
      context.read<RewardedAdCubit>().createRewardedAd(context,
          onFbRewardAdCompleted: _addCoinsAfterRewardAd);
    });
    //init animations
    initializeAnimation();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    topContainerAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    //
    // if (widget.quizType != QuizTypes.audioQuestions) {
    //   timerAnimationController.forward(from: 0);
    // }
//  if (!showOptionAnimationController.isAnimating) {
//                   showOptionAnimationController.reverse();
//                   audioQuestionContainerKeys[currentQuestionIndex]
//                       .currentState!
//                       .changeShowOption();
//                 }
    _getQuestions();
  }

  void initializeAnimation() {
    // audioAnimationController =
    //     AnimationController(vsync: this, duration: Duration(milliseconds: 250));

    questionContentAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    questionAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 525));
    questionSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: questionAnimationController, curve: Curves.easeInOut));
    questionScaleUpAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
        CurvedAnimation(
            parent: questionAnimationController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeInQuad)));
    questionContentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: questionContentAnimationController,
            curve: Curves.easeInQuad));
    questionScaleDownAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
        CurvedAnimation(
            parent: questionAnimationController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutQuad)));
  }

  @override
  void dispose() {
    timerAnimationController
        .removeStatusListener(currentUserTimerAnimationStatusListener);
    timerAnimationController.dispose();
    questionAnimationController.dispose();
    questionContentAnimationController.dispose();
    // audioAnimationController.dispose();

    super.dispose();
  }

  void toggleSettingDialog() {
    isSettingDialogOpen = !isSettingDialogOpen;
  }

  void navigateToResultScreen() {
    if (isSettingDialogOpen) {
      Navigator.of(context).pop();
    }
    if (isExitDialogOpen) {
      Navigator.of(context).pop();
    }

    log('TIME: ${totalSecondsToCompleteQuiz} ${timerAnimationController.value}');

    //move to result page
    //to see the what are the keys to pass in arguments for result screen
    //visit static route function in resultScreen.dart
    Navigator.of(context).pushReplacementNamed(Routes.result, arguments: {
      "numberOfPlayer": widget.numberOfPlayer,
      "myPoints": context.read<QuestionsCubit>().currentPoints(),
      "quizType": widget.quizType,
      "questions": context.read<QuestionsCubit>().questions(),
      "subcategoryMaxLevel": widget.subcategoryMaxLevel,
      "unlockedLevel": widget.unlockedLevel,
      "contestId": widget.contestId,
      "isPlayed": widget.isPlayed,
      "comprehension": widget.comprehension,
      "timeTakenToCompleteQuiz": totalSecondsToCompleteQuiz,
      "hasUsedAnyLifeline": checkHasUsedAnyLifeline(),
      "entryFee": 0
    });
  }

  void updateSubmittedAnswerForBookmark(Question question) {
    if (widget.quizType == QuizTypes.audioQuestions) {
      if (context
          .read<AudioQuestionBookmarkCubit>()
          .hasQuestionBookmarked(question.id)) {
        context.read<AudioQuestionBookmarkCubit>().updateSubmittedAnswerId(
            context.read<QuestionsCubit>().questions()[currentQuestionIndex],
            context.read<UserDetailsCubit>().getUserId());
      }
    } else if (widget.quizType == QuizTypes.quizZone) {
      if (context.read<BookmarkCubit>().hasQuestionBookmarked(question.id)) {
        context.read<BookmarkCubit>().updateSubmittedAnswerId(
              context.read<QuestionsCubit>().questions()[currentQuestionIndex],
              context.read<UserDetailsCubit>().getUserId(),
            );
      }
    }
  }

  void markLifeLineUsed() {
    if (lifelines[fiftyFifty] == LifelineStatus.using) {
      lifelines[fiftyFifty] = LifelineStatus.used;
    }
    if (lifelines[audiencePoll] == LifelineStatus.using) {
      lifelines[audiencePoll] = LifelineStatus.used;
    }
    if (lifelines[resetTime] == LifelineStatus.using) {
      lifelines[resetTime] = LifelineStatus.used;
    }
    if (lifelines[skip] == LifelineStatus.using) {
      lifelines[skip] = LifelineStatus.used;
    }
  }

  bool checkHasUsedAnyLifeline() {
    bool hasUsedAnyLifeline = false;

    for (var lifelineStatus in lifelines.values) {
      if (lifelineStatus == LifelineStatus.used) {
        hasUsedAnyLifeline = true;
        break;
      }
    }
    //
    print("Has used any lifeline : $hasUsedAnyLifeline");
    return hasUsedAnyLifeline;
  }

  //change to next Question

  void changeQuestion() {
    questionAnimationController.forward(from: 0.0).then((value) {
      //need to dispose the animation controllers
      questionAnimationController.dispose();
      // audioAnimationController.dispose();
      questionContentAnimationController.dispose();
      //initializeAnimation again
      setState(() {
        initializeAnimation();
        currentQuestionIndex++;
        markLifeLineUsed();
      });
      //load content(options, image etc) of question
      questionContentAnimationController.forward();
      timerAnimationController.forward(from: 0.0);
      // audioAnimationController.forward();
      log("change questions");
    });
  }

  //if user has submitted the answer for current question
  bool hasSubmittedAnswerForCurrentQuestion() {
    return context
        .read<QuestionsCubit>()
        .questions()[currentQuestionIndex]
        .attempted;
  }

  Map<String, LifelineStatus> getLifeLines() {
    if (widget.quizType == QuizTypes.quizZone ||
        widget.quizType == QuizTypes.dailyQuiz) {
      return lifelines;
    }
    return {};
  }

  void updateTotalSecondsToCompleteQuiz() {
    totalSecondsToCompleteQuiz = totalSecondsToCompleteQuiz +
        UiUtils.timeTakenToSubmitAnswer(
          animationControllerValue: timerAnimationController.value,
          quizType: widget.quizType,
        );
  }

  //update answer locally and on cloud
  void submitAnswer(String submittedAnswer) async {
    timerAnimationController.stop();
    if (!context
        .read<QuestionsCubit>()
        .questions()[currentQuestionIndex]
        .attempted) {
      context.read<QuestionsCubit>().updateQuestionWithAnswerAndLifeline(
          context.read<QuestionsCubit>().questions()[currentQuestionIndex].id,
          submittedAnswer,
          context.read<UserDetailsCubit>().getUserFirebaseId());
      updateTotalSecondsToCompleteQuiz();
      //change question
      await Future.delayed(Duration(seconds: inBetweenQuestionTimeInSeconds));

      if (currentQuestionIndex !=
          (context.read<QuestionsCubit>().questions().length - 1)) {
        updateSubmittedAnswerForBookmark(
            context.read<QuestionsCubit>().questions()[currentQuestionIndex]);
        changeQuestion();
        //if quizType is not audio or latex(math or chemistry) then start timer again
        if (widget.quizType == QuizTypes.mathMania) {
          // timerAnimationController.value = 0.0;
          timerAnimationController.forward(from: 0.0);

          // showOptionAnimationController.forward();
        } else {
          timerAnimationController.forward(from: 0.0);
        }
      } else {
        updateSubmittedAnswerForBookmark(
            context.read<QuestionsCubit>().questions()[currentQuestionIndex]);
        navigateToResultScreen();
      }
    }
  }

//listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      submitAnswer("-1");
    } else if (status == AnimationStatus.forward) {
      // if (widget.quizType == QuizTypes.audioQuestions) {
      //   timerAnimationController.forward(from: 0.0);
      // }
    }
  }

  bool hasEnoughCoinsForLifeline(BuildContext context) {
    int currentCoins = int.parse(context.read<UserDetailsCubit>().getCoins()!);
    //cost of using lifeline is 5 coins
    if (currentCoins < lifeLineDeductCoins) {
      return false;
    }
    return true;
  }

  // Widget _buildShowOptionButton() {
  //   if (widget.quizType == QuizTypes.audioQuestions) {
  //     return Align(
  //       alignment: Alignment.bottomCenter,
  //       child: SlideTransition(
  //         position: showOptionAnimation.drive<Offset>(Tween<Offset>(
  //           begin: const Offset(0.0, 1.5),
  //           end: Offset.zero,
  //         )),
  //         child: Padding(
  //           padding: EdgeInsets.only(
  //             bottom: MediaQuery.of(context).size.height * (0.025),
  //             left: MediaQuery.of(context).size.width * (0.2),
  //             right: MediaQuery.of(context).size.width * (0.2),
  //           ),
  //           child: CustomRoundedButton(
  //             widthPercentage: MediaQuery.of(context).size.width * (0.5),
  //             backgroundColor: Theme.of(context).primaryColor,
  //             buttonTitle: AppLocalization.of(context)!
  //                 .getTranslatedValues(showOptionsKey)!,
  //             radius: 5,
  //             onTap: () {
  //               if (!showOptionAnimationController.isAnimating) {
  //                 showOptionAnimationController.reverse();
  //                 audioQuestionContainerKeys[currentQuestionIndex]
  //                     .currentState!
  //                     .changeShowOption();
  //                 timerAnimationController.forward(from: 0.0);
  //               }
  //             },
  //             titleColor: Theme.of(context).backgroundColor,
  //             showBorder: false,
  //             height: 40.0,
  //             elevation: 5.0,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  //   return const SizedBox();
  // }

  // Widget _showOption() {
  //   return CustomRoundedButton(
  //     widthPercentage: MediaQuery.of(context).size.width * (0.5),
  //     backgroundColor: Theme.of(context).primaryColor,
  //     buttonTitle:
  //         AppLocalization.of(context)!.getTranslatedValues(showOptionsKey)!,
  //     radius: 5,
  //     onTap: () {
  //       if (!showOptionAnimationController.isAnimating) {
  //         showOptionAnimationController.reverse();
  //         audioQuestionContainerKeys[currentQuestionIndex]
  //             .currentState!
  //             .changeShowOption();
  //         timerAnimationController.forward(from: 0.0);
  //       }
  //     },
  //     titleColor: Theme.of(context).backgroundColor,
  //     showBorder: false,
  //     height: 40.0,
  //     elevation: 5.0,
  //     fontWeight: FontWeight.bold,
  //   );
  // }

  Widget _buildBookmarkButton(QuestionsCubit questionsCubit) {
    //if quiz type is quiuzzone
    if (widget.quizType == QuizTypes.quizZone) {
      return BlocBuilder<QuestionsCubit, QuestionsState>(
        bloc: questionsCubit,
        builder: (context, state) {
          if (state is QuestionsFetchSuccess) {
            //

            final bookmarkCubit = context.read<BookmarkCubit>();
            final updateBookmarkcubit = context.read<UpdateBookmarkCubit>();
            return BlocListener<UpdateBookmarkCubit, UpdateBookmarkState>(
              bloc: updateBookmarkcubit,
              listener: (context, state) {
                //if failed to update bookmark status
                if (state is UpdateBookmarkFailure) {
                  if (state.errorMessageCode == unauthorizedAccessCode) {
                    timerAnimationController.stop();
                    UiUtils.showAlreadyLoggedInDialog(context: context);
                    return;
                  }
                  //remove bookmark question
                  if (state.failedStatus == "0") {
                    //if unable to remove question from bookmark then add question
                    //add again
                    bookmarkCubit.addBookmarkQuestion(
                        questionsCubit.questions()[currentQuestionIndex],
                        context.read<UserDetailsCubit>().getUserId());
                  } else {
                    //remove again
                    //if unable to add question to bookmark then remove question
                    bookmarkCubit.removeBookmarkQuestion(
                        questionsCubit.questions()[currentQuestionIndex].id,
                        context.read<UserDetailsCubit>().getUserId());
                  }
                  UiUtils.setSnackbar(
                      AppLocalization.of(context)!.getTranslatedValues(
                          convertErrorCodeToLanguageKey(
                              updateBookmarkFailureCode))!,
                      context,
                      false);
                }
                if (state is UpdateBookmarkSuccess) {
                  print("Success");
                }
              },
              child: BlocBuilder<BookmarkCubit, BookmarkState>(
                bloc: bookmarkCubit,
                builder: (context, state) {
                  if (state is BookmarkFetchSuccess) {
                    return InkWell(
                      onTap: () {
                        if (bookmarkCubit.hasQuestionBookmarked(questionsCubit
                            .questions()[currentQuestionIndex]
                            .id)) {
                          //remove
                          bookmarkCubit.removeBookmarkQuestion(
                              questionsCubit
                                  .questions()[currentQuestionIndex]
                                  .id,
                              context.read<UserDetailsCubit>().getUserId());
                          updateBookmarkcubit.updateBookmark(
                              context.read<UserDetailsCubit>().getUserId(),
                              questionsCubit
                                  .questions()[currentQuestionIndex]
                                  .id!,
                              "0",
                              "1");
                        } else {
                          //add
                          bookmarkCubit.addBookmarkQuestion(
                              questionsCubit.questions()[currentQuestionIndex],
                              context.read<UserDetailsCubit>().getUserId());
                          updateBookmarkcubit.updateBookmark(
                              context.read<UserDetailsCubit>().getUserId(),
                              questionsCubit
                                  .questions()[currentQuestionIndex]
                                  .id!,
                              "1",
                              "1");
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: bookmarkCubit.hasQuestionBookmarked(
                                questionsCubit
                                    .questions()[currentQuestionIndex]
                                    .id)
                            ? Icon(
                                CupertinoIcons.bookmark_fill,
                                color: Theme.of(context).backgroundColor,
                                size: 20,
                              )
                            : Icon(
                                CupertinoIcons.bookmark,
                                color: Theme.of(context).backgroundColor,
                                size: 20,
                              ),
                      ),
                    );
                  }
                  if (state is BookmarkFetchFailure) {
                    return const SizedBox();
                  }

                  return const SizedBox();
                },
              ),
            );
          }
          return const SizedBox();
        },
      );
    }

    //if quiz tyoe is audio questions
    if (widget.quizType == QuizTypes.audioQuestions) {
      return BlocBuilder<QuestionsCubit, QuestionsState>(
        bloc: questionsCubit,
        builder: (context, state) {
          if (state is QuestionsFetchSuccess) {
            //

            final bookmarkCubit = context.read<AudioQuestionBookmarkCubit>();
            final updateBookmarkcubit = context.read<UpdateBookmarkCubit>();
            return BlocListener<UpdateBookmarkCubit, UpdateBookmarkState>(
              bloc: updateBookmarkcubit,
              listener: (context, state) {
                //if failed to update bookmark status
                if (state is UpdateBookmarkFailure) {
                  if (state.errorMessageCode == unauthorizedAccessCode) {
                    timerAnimationController.stop();
                    UiUtils.showAlreadyLoggedInDialog(context: context);
                    return;
                  }
                  //remove bookmark question
                  if (state.failedStatus == "0") {
                    //if unable to remove question from bookmark then add question
                    //add again
                    bookmarkCubit.addBookmarkQuestion(
                        questionsCubit.questions()[currentQuestionIndex],
                        context.read<UserDetailsCubit>().getUserId());
                  } else {
                    //remove again
                    //if unable to add question to bookmark then remove question
                    bookmarkCubit.removeBookmarkQuestion(
                        questionsCubit.questions()[currentQuestionIndex].id,
                        context.read<UserDetailsCubit>().getUserId());
                  }
                  UiUtils.setSnackbar(
                      AppLocalization.of(context)!.getTranslatedValues(
                          convertErrorCodeToLanguageKey(
                              updateBookmarkFailureCode))!,
                      context,
                      false);
                }
                if (state is UpdateBookmarkSuccess) {
                  print("Success");
                }
              },
              child: BlocBuilder<AudioQuestionBookmarkCubit,
                  AudioQuestionBookMarkState>(
                bloc: bookmarkCubit,
                builder: (context, state) {
                  if (state is AudioQuestionBookmarkFetchSuccess) {
                    return InkWell(
                      onTap: () {
                        if (bookmarkCubit.hasQuestionBookmarked(questionsCubit
                            .questions()[currentQuestionIndex]
                            .id)) {
                          //remove
                          bookmarkCubit.removeBookmarkQuestion(
                              questionsCubit
                                  .questions()[currentQuestionIndex]
                                  .id,
                              context.read<UserDetailsCubit>().getUserId());
                          updateBookmarkcubit.updateBookmark(
                              context.read<UserDetailsCubit>().getUserId(),
                              questionsCubit
                                  .questions()[currentQuestionIndex]
                                  .id!,
                              "0",
                              "4"); //type is 4 for audio questions
                        } else {
                          //add
                          bookmarkCubit.addBookmarkQuestion(
                              questionsCubit.questions()[currentQuestionIndex],
                              context.read<UserDetailsCubit>().getUserId());
                          updateBookmarkcubit.updateBookmark(
                              context.read<UserDetailsCubit>().getUserId(),
                              questionsCubit
                                  .questions()[currentQuestionIndex]
                                  .id!,
                              "1",
                              "4"); //type is 4 for audio questions
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                        ),
                        child: bookmarkCubit.hasQuestionBookmarked(
                                questionsCubit
                                    .questions()[currentQuestionIndex]
                                    .id)
                            ? Icon(
                                CupertinoIcons.bookmark_fill,
                                color: Theme.of(context).backgroundColor,
                                size: 20,
                              )
                            : Icon(
                                CupertinoIcons.bookmark,
                                color: Theme.of(context).backgroundColor,
                                size: 20,
                              ),
                      ),
                    );
                  }
                  if (state is AudioQuestionBookmarkFetchFailure) {
                    return const SizedBox();
                  }

                  return const SizedBox();
                },
              ),
            );
          }
          return const SizedBox();
        },
      );
    }

    return const SizedBox();
  }

  Widget _buildLifelineContainer(
      {VoidCallback? onTap,
      String? lifelineTitle,
      String? lifelineIcon,
      Key? toolTipKey,
      String? toolTipMessage}) {
    return GestureDetector(
      onTap: lifelineTitle == fiftyFifty &&
              context
                      .read<QuestionsCubit>()
                      .questions()[currentQuestionIndex]
                      .answerOptions!
                      .length ==
                  2
          ? () {
              UiUtils.setSnackbar(
                  AppLocalization.of(context)!
                      .getTranslatedValues("notAvailable")!,
                  context,
                  false);
              log("gesture detector tapped");
            }
          : onTap,
      child: JustTheTooltip(
        key: toolTipKey!,
        content: Padding(
          padding: const EdgeInsets.all(5.0),
          child: TitleText(
            text: toolTipMessage!,
            textColor: Constants.white,
          ),
        ),
        showDuration: const Duration(seconds: 1),
        triggerMode: TooltipTriggerMode.manual,
        tailBaseWidth: 20.0,
        tailLength: 10.0,
        backgroundColor: Constants.primaryColor,
        child: Container(
          decoration: BoxDecoration(
              color: lifelineTitle == fiftyFifty &&
                      context
                              .read<QuestionsCubit>()
                              .questions()[currentQuestionIndex]
                              .answerOptions!
                              .length ==
                          2
                  ? Theme.of(context).backgroundColor.withOpacity(0.7)
                  : Theme.of(context).backgroundColor,
              boxShadow: [
                UiUtils.buildBoxShadow(),
              ],
              borderRadius: BorderRadius.circular(10.0)),
          width: 45.0,
          height: 45.0,
          padding: const EdgeInsets.all(11),
          child: SvgPicture.asset(
            UiUtils.getImagePath(lifelineIcon!),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }

  void onTapBackButton() {
    isExitDialogOpen = true;
    showDialog(context: context, builder: (_) => const ExitGameDailog())
        .then((value) => isExitDialogOpen = false);
  }

  void _addCoinsAfterRewardAd() {
    //once user sees app then add coins to user wallet
    context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: lifeLineDeductCoins,
        );

    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
        context.read<UserDetailsCubit>().getUserId(),
        lifeLineDeductCoins,
        true,
        watchedRewardAdKey);
    timerAnimationController.forward(from: timerAnimationController.value);
  }

  void showAdDialog() {
    if (context.read<RewardedAdCubit>().state is! RewardedAdLoaded) {
      UiUtils.setSnackbar(
          AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(notEnoughCoinsCode))!,
          context,
          false);
      return;
    }
    //stop timer
    timerAnimationController.stop();
    showDialog<bool>(
        context: context,
        builder: (_) => WatchRewardAdDialog(
              onTapYesButton: () {
                //on tap of yes button show ad
                context.read<RewardedAdCubit>().showAd(
                    context: context,
                    onAdDismissedCallback: _addCoinsAfterRewardAd);
              },
              onTapNoButton: () {
                //pass true to start timer
                Navigator.of(context).pop(true);
              },
            )).then((startTimer) {
      //if user do not want to see ad
      if (startTimer != null && startTimer) {
        timerAnimationController.forward(from: timerAnimationController.value);
      }
    });
  }

  Widget _buildLifeLines() {
    if (widget.quizType == QuizTypes.dailyQuiz ||
        widget.quizType == QuizTypes.quizZone) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * (0.025)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLifelineContainer(
                  toolTipKey: key1,
                  onTap: () {
                    final dynamic toolTip = key1.currentState;
                    toolTip.ensureTooltipVisible();

                    if (lifelines[fiftyFifty] == LifelineStatus.unused) {
                      if (hasEnoughCoinsForLifeline(context)) {
                        if (context
                                .read<QuestionsCubit>()
                                .questions()[currentQuestionIndex]
                                .answerOptions!
                                .length ==
                            2) {
                          UiUtils.setSnackbar(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("notAvailable")!,
                              context,
                              false);
                        } else {
                          //deduct coins for using lifeline
                          context.read<UserDetailsCubit>().updateCoins(
                              addCoin: false, coins: lifeLineDeductCoins);
                          //mark fiftyFifty lifeline as using

                          //update coins in cloud
                          context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                              context.read<UserDetailsCubit>().getUserId(),
                              lifeLineDeductCoins,
                              false,
                              used5050lifelineKey);
                          setState(() {
                            lifelines[fiftyFifty] = LifelineStatus.using;
                          });
                        }
                      } else {
                        showAdDialog();
                      }
                    } else {
                      UiUtils.setSnackbar(
                          AppLocalization.of(context)!.getTranslatedValues(
                              convertErrorCodeToLanguageKey(lifeLineUsedCode))!,
                          context,
                          false);
                    }
                  },
                  lifelineTitle: fiftyFifty,
                  lifelineIcon: "fiftyfifty icon.svg",
                  toolTipMessage: "50 50"),
              _buildLifelineContainer(
                  toolTipKey: key2,
                  onTap: () {
                    final dynamic toolTip = key2.currentState;
                    toolTip.ensureTooltipVisible();

                    if (lifelines[audiencePoll] == LifelineStatus.unused) {
                      if (hasEnoughCoinsForLifeline(context)) {
                        //deduct coins for using lifeline
                        context.read<UserDetailsCubit>().updateCoins(
                            addCoin: false, coins: lifeLineDeductCoins);
                        //update coins in cloud

                        context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                            context.read<UserDetailsCubit>().getUserId(),
                            lifeLineDeductCoins,
                            false,
                            usedAudiencePolllifelineKey);
                        setState(() {
                          lifelines[audiencePoll] = LifelineStatus.using;
                        });
                      } else {
                        showAdDialog();
                      }
                    } else {
                      UiUtils.setSnackbar(
                          AppLocalization.of(context)!.getTranslatedValues(
                              convertErrorCodeToLanguageKey(lifeLineUsedCode))!,
                          context,
                          false);
                    }
                  },
                  lifelineTitle: audiencePoll,
                  lifelineIcon: "audience_poll.svg",
                  toolTipMessage: "AUDIENCE POLL"),
              _buildLifelineContainer(
                  toolTipKey: key3,
                  onTap: () {
                    final dynamic toolTip = key3.currentState;
                    toolTip.ensureTooltipVisible();

                    if (lifelines[resetTime] == LifelineStatus.unused) {
                      if (hasEnoughCoinsForLifeline(context)) {
                        //deduct coins for using lifeline
                        context.read<UserDetailsCubit>().updateCoins(
                            addCoin: false, coins: lifeLineDeductCoins);
                        //mark fiftyFifty lifeline as using

                        //update coins in cloud
                        context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                            context.read<UserDetailsCubit>().getUserId(),
                            lifeLineDeductCoins,
                            false,
                            usedResetTimerlifelineKey);
                        setState(() {
                          lifelines[resetTime] = LifelineStatus.using;
                        });
                        timerAnimationController.stop();
                        timerAnimationController.forward(from: 0.0);
                      } else {
                        showAdDialog();
                      }
                    } else {
                      UiUtils.setSnackbar(
                          AppLocalization.of(context)!.getTranslatedValues(
                              convertErrorCodeToLanguageKey(lifeLineUsedCode))!,
                          context,
                          false);
                    }
                  },
                  lifelineTitle: resetTime,
                  lifelineIcon: "reset_time.svg",
                  toolTipMessage: "RESET TIME"),
              _buildLifelineContainer(
                  toolTipKey: key4,
                  onTap: () {
                    final dynamic toolTip = key4.currentState;
                    toolTip.ensureTooltipVisible();

                    if (lifelines[skip] == LifelineStatus.unused) {
                      if (hasEnoughCoinsForLifeline(context)) {
                        //deduct coins for using lifeline
                        context
                            .read<UserDetailsCubit>()
                            .updateCoins(addCoin: false, coins: 5);
                        //update coins in cloud

                        context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                            context.read<UserDetailsCubit>().getUserId(),
                            lifeLineDeductCoins,
                            false,
                            usedSkiplifelineKey);
                        setState(() {
                          lifelines[skip] = LifelineStatus.using;
                        });
                        submitAnswer("0");
                      } else {
                        showAdDialog();
                      }
                    } else {
                      UiUtils.setSnackbar(
                          AppLocalization.of(context)!.getTranslatedValues(
                              convertErrorCodeToLanguageKey(lifeLineUsedCode))!,
                          context,
                          false);
                    }
                  },
                  lifelineTitle: skip,
                  lifelineIcon: "skip_icon.svg",
                  toolTipMessage: "SKIP QUESTION"),
            ],
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildTopMenu(int questionLength) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.only(
          right: 24,
          left: 24,
          top: MediaQuery.of(context).padding.top,
        ),
        child: Row(
          children: [
            Container(
              height: 34,
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                color: Constants.secondaryColor,
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    Assets.person,
                    color: Constants.white,
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  TitleText(
                    text: widget.numberOfPlayer.toString(),
                    size: Constants.bodyXSmall,
                    textColor: Constants.white,
                    weight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 25,
                  right: 25,
                ),
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Constants.cardsRadius,
                  ),
                  gradient: LinearGradient(
                    stops: [
                      (currentQuestionIndex + 1) / questionLength,
                      (currentQuestionIndex + 1) / questionLength,
                    ],
                    colors: [
                      Constants.white,
                      Constants.secondaryColor,
                    ],
                  ),
                ),
              ),
            ),
            SettingButton(
              onPressed: () {
                toggleSettingDialog();
                showDialog(
                    context: context,
                    builder: (_) => SettingsDialogContainer()).then(
                  (value) {
                    toggleSettingDialog();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  final key1 = GlobalKey();
  final key2 = GlobalKey();
  final key3 = GlobalKey();
  final key4 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final quesCubit = context.read<QuestionsCubit>();
    return WillPopScope(
      onWillPop: () {
        onTapBackButton();
        return Future.value(false);
      },
      child: BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
        listener: (context, state) {
          if (state is UpdateScoreAndCoinsFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              timerAnimationController.stop();
              UiUtils.showAlreadyLoggedInDialog(context: context);
            }
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: Stack(
            children: [
              BlocConsumer<QuestionsCubit, QuestionsState>(
                bloc: quesCubit,
                listener: (context, state) {
                  if (state is QuestionsFetchSuccess) {
                    if (state.questions.isNotEmpty) {
                      if (currentQuestionIndex == 0 &&
                          !state.questions[currentQuestionIndex].attempted) {
                        if (widget.quizType == QuizTypes.audioQuestions) {
                          state.questions.forEach((element) {
                            audioQuestionContainerKeys
                                .add(GlobalKey<AudioQuestionContainerState>());
                          });
                          //
                          // showOptionAnimationController.forward();
                          questionContentAnimationController.forward(from: 0);
                          //add audio question container keys
                        }
                        //
                        else if (widget.quizType == QuizTypes.mathMania) {
                          timerAnimationController.forward(from: 0.0);

                          questionContentAnimationController.forward(from: 0);
                        } else {
                          timerAnimationController.forward(from: 0.0);
                          questionContentAnimationController.forward(from: 0);
                        }
                      }
                    }
                  } else if (state is QuestionsFetchFailure) {
                    if (state.errorMessage == unauthorizedAccessCode) {
                      UiUtils.showAlreadyLoggedInDialog(context: context);
                    }
                  }
                },
                builder: (context, state) {
                  if (state is QuestionsFetchInProgress ||
                      state is QuestionsIntial) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          Constants.white,
                        ),
                      ),
                    );
                  }
                  if (state is QuestionsFetchFailure) {
                    return Center(
                      child: ErrorContainer(
                        errorMessageColor: Theme.of(context).primaryColor,
                        showBackButton: true,
                        errorMessage: AppLocalization.of(context)!
                            .getTranslatedValues(convertErrorCodeToLanguageKey(
                                state.errorMessage)),
                        onTapRetry: () {
                          _getQuestions();
                        },
                        showErrorImage: true,
                      ),
                    );
                  }
                  return Align(
                    alignment: Alignment.topCenter,
                    child: NewQuestionsContainer(
                      audioQuestionContainerKeys: audioQuestionContainerKeys,
                      quizType: widget.quizType,
                      showAnswerCorrectness: context
                          .read<SystemConfigCubit>()
                          .getShowCorrectAnswerMode(),
                      lifeLines: getLifeLines(),
                      timerAnimationController: timerAnimationController,
                      topPadding: MediaQuery.of(context).size.height *
                          UiUtils.getQuestionContainerTopPaddingPercentage(
                              MediaQuery.of(context).size.height),
                      hasSubmittedAnswerForCurrentQuestion:
                          hasSubmittedAnswerForCurrentQuestion,
                      questions: context.read<QuestionsCubit>().questions(),
                      submitAnswer: submitAnswer,
                      questionContentAnimation: questionContentAnimation,
                      questionScaleDownAnimation: questionScaleDownAnimation,
                      questionScaleUpAnimation: questionScaleUpAnimation,
                      questionSlideAnimation: questionSlideAnimation,
                      currentQuestionIndex: currentQuestionIndex,
                      questionAnimationController: questionAnimationController,
                      questionContentAnimationController:
                          questionContentAnimationController,
                      guessTheWordQuestions: [],
                      guessTheWordQuestionContainerKeys: [],
                    ),
                  );
                },
              ),
              BlocBuilder<QuestionsCubit, QuestionsState>(
                bloc: quesCubit,
                builder: (context, state) {
                  if (state is QuestionsFetchSuccess) {
                    return _buildLifeLines();
                  }
                  return const SizedBox();
                },
              ),
              BlocBuilder<QuestionsCubit, QuestionsState>(
                bloc: quesCubit,
                builder: (context, state) {
                  if (state is QuestionsFetchSuccess) {
                    // return _showOption();
                  }
                  return const SizedBox();
                },
              ),
              _buildTopMenu(context.read<QuestionsCubit>().questions().length),
            ],
          ),
        ),
      ),
    );
  }
}
