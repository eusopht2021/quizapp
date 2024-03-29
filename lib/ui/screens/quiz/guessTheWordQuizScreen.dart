import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/guessTheWordBookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/guessTheWordQuizCubit.dart';

import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/guessTheWordQuestionContainer.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/new_question_container.dart';

import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/custom_button.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/exitGameDailog.dart';
import 'package:flutterquiz/ui/widgets/settingButton.dart';
import 'package:flutterquiz/ui/widgets/settingsDialogContainer.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class GuessTheWordQuizScreen extends StatefulWidget {
  final String type; //category or subcategory
  final String typeId; //id of category or subcategory
  final bool isPlayed;
  GuessTheWordQuizScreen(
      {Key? key,
      required this.type,
      required this.typeId,
      required this.isPlayed})
      : super(key: key);

  @override
  _GuessTheWordQuizScreenState createState() => _GuessTheWordQuizScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<UpdateScoreAndCoinsCubit>(
                  create: (_) =>
                      UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
                ),
                BlocProvider<UpdateBookmarkCubit>(
                    create: (_) => UpdateBookmarkCubit(BookmarkRepository())),
                BlocProvider<GuessTheWordQuizCubit>(
                    create: (_) => GuessTheWordQuizCubit(QuizRepository()))
              ],
              child: GuessTheWordQuizScreen(
                isPlayed: arguments['isPlayed'],
                type: arguments['type'],
                typeId: arguments['typeId'],
              ),
            ));
  }
}

class _GuessTheWordQuizScreenState extends State<GuessTheWordQuizScreen>
    with TickerProviderStateMixin {
  late AnimationController timerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: guessTheWordQuestionDurationInSeconds))
    ..addStatusListener(currentUserTimerAnimationStatusListener);

  //to animate the question container
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;
  //to slide the question container from right to left
  late Animation<double> questionSlideAnimation;
  //to scale up the second question
  late Animation<double> questionScaleUpAnimation;
  //to scale down the second question
  late Animation<double> questionScaleDownAnimation;
  //to slude the question content from right to left
  late Animation<double> questionContentAnimation;

  int _currentQuestionIndex = 0;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  //
  double timeTakenToCompleteQuiz = 0;

  bool isExitDialogOpen = false;

  late List<GlobalKey<GuessTheWordQuestionContainerState>>
      questionContainerKeys = [];

  @override
  void initState() {
    super.initState();
    initializeAnimation();
    //fetching question for quiz
    _getQuestions();
  }

  void _getQuestions() {
    Future.delayed(Duration.zero, () {
      context.read<GuessTheWordQuizCubit>().getQuestion(
            questionLanguageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: widget.type,
            typeId: widget.typeId,
          );
    });
  }

  @override
  void dispose() {
    timerAnimationController
        .removeStatusListener(currentUserTimerAnimationStatusListener);
    timerAnimationController.dispose();
    questionContentAnimationController.dispose();
    questionAnimationController.dispose();

    super.dispose();
  }

  void initializeAnimation() {
    questionAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    questionContentAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));

    questionSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: questionAnimationController, curve: Curves.easeInOut));
    questionScaleUpAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
        CurvedAnimation(
            parent: questionAnimationController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeInQuad)));
    questionScaleDownAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
        CurvedAnimation(
            parent: questionAnimationController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutQuad)));
    questionContentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: questionContentAnimationController,
            curve: Curves.easeInQuad));
  }

  void toggleSettingDialog() {
    isSettingDialogOpen = !isSettingDialogOpen;
  }

  //listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      updateBookmarkAnswer();
      submitAnswer(questionContainerKeys[_currentQuestionIndex]
          .currentState!
          .getSubmittedAnswer());
    }
  }

  void navigateToResultScreen() {
    if (isSettingDialogOpen) {
      Navigator.of(context).pop();
    }
    if (isExitDialogOpen) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).pushReplacementNamed(Routes.result, arguments: {
      "myPoints": context.read<GuessTheWordQuizCubit>().getCurrentPoints(),
      "quizType": QuizTypes.guessTheWord,
      "isPlayed": widget.isPlayed,
      "numberOfPlayer": 1,
      "timeTakenToCompleteQuiz": timeTakenToCompleteQuiz,
      "guessTheWordQuestions":
          context.read<GuessTheWordQuizCubit>().getQuestions(),
    });
  }

  void submitAnswer(List<String> submittedAnswer) async {
    timerAnimationController.stop();
    updateTimeTakenToCompleteQuiz();
    final guessTheWordQuizCubit = context.read<GuessTheWordQuizCubit>();
    //if answer not submitted then submit answer
    if (!guessTheWordQuizCubit
        .getQuestions()[_currentQuestionIndex]
        .hasAnswered) {
      //submitted answer
      guessTheWordQuizCubit.submitAnswer(
          guessTheWordQuizCubit.getQuestions()[_currentQuestionIndex].id,
          submittedAnswer);
      //wait for some seconds
      await Future.delayed(
          const Duration(seconds: inBetweenQuestionTimeInSeconds));
      //if currentQuestion is last then move user to result screen
      if (_currentQuestionIndex ==
          (guessTheWordQuizCubit.getQuestions().length - 1)) {
        navigateToResultScreen();
      } else {
        //change question
        changeQuestion();

        timerAnimationController.forward(from: 0.0);
      }
    }
  }

  void updateTimeTakenToCompleteQuiz() {
    timeTakenToCompleteQuiz = timeTakenToCompleteQuiz +
        UiUtils.timeTakenToSubmitAnswer(
            animationControllerValue: timerAnimationController.value,
            quizType: QuizTypes.guessTheWord);
    print("Time to complete quiz: $timeTakenToCompleteQuiz");
  }

  //next question
  void changeQuestion() {
    questionAnimationController.forward(from: 0.0).then((value) {
      //need to dispose the animation controllers
      questionAnimationController.dispose();
      questionContentAnimationController.dispose();
      //initializeAnimation again
      setState(() {
        initializeAnimation();
        _currentQuestionIndex++;
      });
      //load content(options, image etc) of question
      questionContentAnimationController.forward();
    });
  }

  //
  void updateBookmarkAnswer() {
    //update bookmark answer
    if (context.read<GuessTheWordBookmarkCubit>().hasQuestionBookmarked(context
        .read<GuessTheWordQuizCubit>()
        .getQuestions()[_currentQuestionIndex]
        .id)) {
      context.read<GuessTheWordBookmarkCubit>().updateSubmittedAnswer(
          questionId: context
              .read<GuessTheWordQuizCubit>()
              .getQuestions()[_currentQuestionIndex]
              .id,
          submittedAnswer: UiUtils.buildGuessTheWordQuestionAnswer(
              questionContainerKeys[_currentQuestionIndex]
                  .currentState!
                  .getSubmittedAnswer()),
          userId: context.read<UserDetailsCubit>().getUserId());
    } else {
      print("Quesiton not bookmarked");
    }
  }

  Widget _buildQuesitons(GuessTheWordQuizCubit guessTheWordQuizCubit) {
    return BlocBuilder<GuessTheWordQuizCubit, GuessTheWordQuizState>(
        builder: (context, state) {
      if (state is GuessTheWordQuizIntial ||
          state is GuessTheWordQuizFetchInProgress) {
        return Center(
          child: CircularProgressIndicator(
            color: Constants.white,
          ),
        );
      }
      if (state is GuessTheWordQuizFetchSuccess) {
        return Align(
          alignment: Alignment.topCenter,
          child: NewQuestionsContainer(
            timerAnimationController: timerAnimationController,
            quizType: QuizTypes.guessTheWord,
            showAnswerCorrectness: true,
            lifeLines: {},
            guessTheWordQuestionContainerKeys: questionContainerKeys,
            topPadding: MediaQuery.of(context).size.height *
                UiUtils.getQuestionContainerTopPaddingPercentage(
                    MediaQuery.of(context).size.height),
            guessTheWordQuestions: state.questions,
            hasSubmittedAnswerForCurrentQuestion: () {},
            questions: [],
            submitAnswer: () {},
            questionContentAnimation: questionContentAnimation,
            questionScaleDownAnimation: questionScaleDownAnimation,
            questionScaleUpAnimation: questionScaleUpAnimation,
            questionSlideAnimation: questionSlideAnimation,
            currentQuestionIndex: _currentQuestionIndex,
            questionAnimationController: questionAnimationController,
            questionContentAnimationController:
                questionContentAnimationController,
          ),
        );
      }
      if (state is GuessTheWordQuizFetchFailure) {
        return Center(
          child: ErrorContainer(
              errorMessageColor: Theme.of(context).backgroundColor,
              showBackButton: true,
              errorMessage: AppLocalization.of(context)?.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage)),
              onTapRetry: () {
                _getQuestions();
              },
              showErrorImage: true),
        );
      }
      return Container();
    });
  }

  Widget _buildSubmitButton(GuessTheWordQuizCubit guessTheWordQuizCubit) {
    return BlocBuilder<GuessTheWordQuizCubit, GuessTheWordQuizState>(
      bloc: guessTheWordQuizCubit,
      builder: (context, state) {
        if (state is GuessTheWordQuizFetchSuccess) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * (0.025)),
              child: CustomButton(
                // widthPercentage: 0.5,
                backgroundColor: Theme.of(context).primaryColor,
                text: AppLocalization.of(context)!
                    .getTranslatedValues("submitBtn")!,
                // elevation: 5.0,
                // shadowColor: Colors.black45,
                // titleColor: Theme.of(context).backgroundColor,
                // fontWeight: FontWeight.bold,
                onPressed: () {
                  //
                  log("message");
                  updateBookmarkAnswer();
                  submitAnswer(questionContainerKeys[_currentQuestionIndex]
                      .currentState!
                      .getSubmittedAnswer());
                },
                // radius: 10.0,
                // showBorder: false,
                height: 45,
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  void onTapBackButton() {
    isExitDialogOpen = true;
    showDialog(context: context, builder: (_) => const ExitGameDailog())
        .then((value) => isExitDialogOpen = false);
  }

  Widget _buildBookmarkButton(GuessTheWordQuizCubit guessTheWordQuizCubit) {
    return BlocBuilder<GuessTheWordQuizCubit, GuessTheWordQuizState>(
      bloc: guessTheWordQuizCubit,
      builder: (context, state) {
        if (state is GuessTheWordQuizFetchSuccess) {
          //

          final bookmarkCubit = context.read<GuessTheWordBookmarkCubit>();
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
                      guessTheWordQuizCubit
                          .getQuestions()[_currentQuestionIndex],
                      context.read<UserDetailsCubit>().getUserId());
                } else {
                  //remove again
                  //if unable to add question to bookmark then remove question
                  bookmarkCubit.removeBookmarkQuestion(
                      guessTheWordQuizCubit
                          .getQuestions()[_currentQuestionIndex]
                          .id,
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
            child: BlocBuilder<GuessTheWordBookmarkCubit,
                GuessTheWordBookmarkState>(
              bloc: context.read<GuessTheWordBookmarkCubit>(),
              builder: (context, state) {
                print("State is $state");
                if (state is GuessTheWordBookmarkFetchSuccess) {
                  return InkWell(
                    onTap: () {
                      if (bookmarkCubit.hasQuestionBookmarked(
                          guessTheWordQuizCubit
                              .getQuestions()[_currentQuestionIndex]
                              .id)) {
                        //remove
                        bookmarkCubit.removeBookmarkQuestion(
                            guessTheWordQuizCubit
                                .getQuestions()[_currentQuestionIndex]
                                .id,
                            context.read<UserDetailsCubit>().getUserId());
                        updateBookmarkcubit.updateBookmark(
                          context.read<UserDetailsCubit>().getUserId(),
                          guessTheWordQuizCubit
                              .getQuestions()[_currentQuestionIndex]
                              .id,
                          "0",
                          "3", //type is 3 for guess the word questions
                        );
                      } else {
                        //add
                        bookmarkCubit.addBookmarkQuestion(
                            guessTheWordQuizCubit
                                .getQuestions()[_currentQuestionIndex],
                            context.read<UserDetailsCubit>().getUserId());
                        updateBookmarkcubit.updateBookmark(
                            context.read<UserDetailsCubit>().getUserId(),
                            guessTheWordQuizCubit
                                .getQuestions()[_currentQuestionIndex]
                                .id,
                            "1",
                            "3");
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: bookmarkCubit.hasQuestionBookmarked(
                              guessTheWordQuizCubit
                                  .getQuestions()[_currentQuestionIndex]
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
                if (state is GuessTheWordBookmarkFetchFailure) {
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

  // Widget _buildTopMenu() {
  //   return Align(
  //     alignment: Alignment.topCenter,
  //     child: Container(
  //       margin: EdgeInsets.only(
  //           right: MediaQuery.of(context).size.width *
  //               ((1.0 - UiUtils.quesitonContainerWidthPercentage) * 0.5),
  //           left: MediaQuery.of(context).size.width *
  //               ((1.0 - UiUtils.quesitonContainerWidthPercentage) * 0.5),
  //           top: MediaQuery.of(context).padding.top),
  //       child: Row(
  //         children: [
  //           CustomBackButton(
  //             onTap: () {
  //               onTapBackButton();
  //             },
  //             iconColor: Theme.of(context).backgroundColor,
  //           ),
  //           Spacer(),
  //           SettingButton(onPressed: () {
  //             toggleSettingDialog();
  //             showDialog(
  //                 context: context,
  //                 builder: (_) => SettingsDialogContainer()).then((value) {
  //               toggleSettingDialog();
  //             });
  //           }),
  //           _buildBookmarkButton(context.read<GuessTheWordQuizCubit>()),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final GuessTheWordQuizCubit guessTheWordQuizCubit =
        context.read<GuessTheWordQuizCubit>();
    return WillPopScope(
      onWillPop: () {
        onTapBackButton();
        return Future.value(false);
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<GuessTheWordQuizCubit, GuessTheWordQuizState>(
            bloc: guessTheWordQuizCubit,
            listener: (context, state) {
              if (state is GuessTheWordQuizFetchSuccess) {
                if (_currentQuestionIndex == 0 &&
                    !state.questions[_currentQuestionIndex].hasAnswered) {
                  state.questions.forEach((element) {
                    questionContainerKeys
                        .add(GlobalKey<GuessTheWordQuestionContainerState>());
                  });
                  //start timer
                  timerAnimationController.forward();
                  questionContentAnimationController.forward();
                }
              } else if (state is GuessTheWordQuizFetchFailure) {
                if (state.errorMessage == unauthorizedAccessCode) {
                  UiUtils.showAlreadyLoggedInDialog(context: context);
                }
              }
            },
          ),
          BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
            listener: (context, state) {
              if (state is UpdateScoreAndCoinsFailure) {
                if (state.errorMessage == unauthorizedAccessCode) {
                  timerAnimationController.stop();
                  UiUtils.showAlreadyLoggedInDialog(context: context);
                }
              }
            },
          ),
        ],
        // child: Scaffold(
        //   backgroundColor: Theme.of(context).primaryColor,
        //   body: Stack(
        //     children: [
        //       // Align(
        //       //   alignment: Alignment.topCenter,
        //       //   child: QuizPlayAreaBackgroundContainer(heightPercentage: 0.885),
        //       // ),
        //       _buildQuesitons(guessTheWordQuizCubit),
        //       _buildSubmitButton(guessTheWordQuizCubit),
        //       _buildTopMenu(),
        //     ],
        //   ),
        // ),

        child: DefaultLayout(
            expandBodyBehindAppBar: true,
            showBackButton: false,
            action: SizedBox(
              width: SizeConfig.screenWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    CustomBackButton(
                      onTap: () {
                        onTapBackButton();
                      },
                      iconColor: Theme.of(context).backgroundColor,
                    ),
                    const Spacer(),
                    SettingButton(
                      onPressed: () {
                        toggleSettingDialog();
                        showDialog(
                                context: context,
                                builder: (_) => SettingsDialogContainer())
                            .then((value) {
                          toggleSettingDialog();
                        });
                      },
                    ),
                    _buildBookmarkButton(context.read<GuessTheWordQuizCubit>()),
                  ],
                ),
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            title: "",
            child: SizedBox(
              height: SizeConfig.screenHeight,
              child: Stack(
                children: [
                  _buildQuesitons(guessTheWordQuizCubit),
                  _buildSubmitButton(guessTheWordQuizCubit),
                  // _buildTopMenu(),
                ],
              ),
            )),
      ),
    );
  }
}
