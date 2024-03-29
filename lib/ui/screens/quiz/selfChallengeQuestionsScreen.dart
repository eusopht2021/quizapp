import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/questionsCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/new_question_container.dart';

import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/exitGameDailog.dart';
import 'package:flutterquiz/ui/widgets/settingButton.dart';
import 'package:flutterquiz/ui/widgets/settingsDialogContainer.dart';
import 'package:flutterquiz/utils/constants.dart';

import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/size_config.dart';

import 'package:flutterquiz/utils/uiUtils.dart';

class SelfChallengeQuestionsScreen extends StatefulWidget {
  final String? categoryId;
  final String? subcategoryId;
  final int? minutes;
  final String? numberOfQuestions;
  SelfChallengeQuestionsScreen(
      {Key? key,
      required this.categoryId,
      required this.minutes,
      required this.numberOfQuestions,
      required this.subcategoryId})
      : super(key: key);

  @override
  _SelfChallengeQuestionsScreenState createState() =>
      _SelfChallengeQuestionsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map<dynamic, dynamic>?;

    //keys of map are categoryId,subcategoryId,minutes,numberOfQuestions
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<QuestionsCubit>(
                      create: (_) => QuestionsCubit(QuizRepository())),
                  BlocProvider<UpdateBookmarkCubit>(
                      create: (_) => UpdateBookmarkCubit(BookmarkRepository())),
                ],
                child: SelfChallengeQuestionsScreen(
                  categoryId: arguments!['categoryId'],
                  minutes: arguments['minutes'],
                  numberOfQuestions: arguments['numberOfQuestions'],
                  subcategoryId: arguments['subcategoryId'],
                )));
  }
}

class _SelfChallengeQuestionsScreenState
    extends State<SelfChallengeQuestionsScreen> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  late List<Question> ques;
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;
  late AnimationController timerAnimationController;
  late Animation<double> questionSlideAnimation;
  late Animation<double> questionScaleUpAnimation;
  late Animation<double> questionScaleDownAnimation;
  late Animation<double> questionContentAnimation;
  late AnimationController animationController;
  late AnimationController topContainerAnimationController;

  bool isBottomSheetOpen = false;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  bool isExitDialogOpen = false;

  double? timeTakenToCompleteQuiz = 0;

  void _getQuestions() {
    Future.delayed(Duration.zero, () {
      context.read<QuestionsCubit>().getQuestions(
            QuizTypes.selfChallenge,
            categoryId: widget.categoryId,
            subcategoryId: widget.subcategoryId,
            numberOfQuestions: widget.numberOfQuestions,
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
          );
    });
  }

  @override
  void initState() {
    initializeAnimation();
    timerAnimationController = AnimationController(
        vsync: this, duration: Duration(minutes: widget.minutes!))
      ..addStatusListener(currentUserTimerAnimationStatusListener);

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    topContainerAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _getQuestions();
    super.initState();
  }

  void initializeAnimation() {
    questionContentAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250))
      ..forward();
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
    super.dispose();
  }

  void toggleSettingDialog() {
    isSettingDialogOpen = !isSettingDialogOpen;
  }

  void changeQuestion(
      {required bool increaseIndex, required int newQuestionIndex}) {
    questionAnimationController.forward(from: 0.0).then((value) {
      //need to dispose the animation controllers
      questionAnimationController.dispose();
      questionContentAnimationController.dispose();
      //initializeAnimation again
      setState(() {
        initializeAnimation();
        if (newQuestionIndex != -1) {
          currentQuestionIndex = newQuestionIndex;
        } else {
          if (increaseIndex) {
            currentQuestionIndex++;
          } else {
            currentQuestionIndex--;
          }
        }
      });
      //load content(options, image etc) of question
      questionContentAnimationController.forward();
    });
  }

  //if user has submitted the answer for current question
  bool hasSubmittedAnswerForCurrentQuestion() {
    return ques[currentQuestionIndex].attempted;
  }

  //update answer locally and on cloud
  void submitAnswer(String submittedAnswer) async {
    context.read<QuestionsCubit>().updateQuestionWithAnswerAndLifeline(
        ques[currentQuestionIndex].id,
        submittedAnswer,
        context.read<UserDetailsCubit>().getUserFirebaseId());
    //change question
    await Future.delayed(const Duration(milliseconds: 500));
  }

  //listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      navigateToResult();
    }
  }

  void updateTimeTakenToCompleteQuiz() {
    timeTakenToCompleteQuiz = timeTakenToCompleteQuiz! +
        UiUtils.timeTakenToSubmitAnswer(
            animationControllerValue: timerAnimationController.value,
            quizType: QuizTypes.guessTheWord);
    print("Time to complete quiz: $timeTakenToCompleteQuiz");
  }

  void navigateToResult() {
    if (isBottomSheetOpen) {
      Navigator.of(context).pop();
    }
    if (isSettingDialogOpen) {
      Navigator.of(context).pop();
    }
    if (isExitDialogOpen) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pushReplacementNamed(Routes.result, arguments: {
      "numberOfPlayer": 1,
      "myPoints": context.read<QuestionsCubit>().currentPoints(),
      "quizType": QuizTypes.selfChallenge,
      "questions": context.read<QuestionsCubit>().questions(),
      "timeTakenToCompleteQuiz": timeTakenToCompleteQuiz,
      "entryFee": 0
    });
  }

  Widget hasQuestionAttemptedContainer(int questionIndex, bool attempted) {
    return GestureDetector(
      onTap: () {
        if (questionIndex != currentQuestionIndex) {
          changeQuestion(increaseIndex: true, newQuestionIndex: questionIndex);
        }
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        color: attempted ? Theme.of(context).primaryColor : Constants.secondaryColor,
        height: 30.0,
        width: 30.0,
        child: Text(
          "${questionIndex + 1}",
          style: TextStyle(color: Constants.white),
        ),
      ),
    );
  }

  void onTapBackButton() {
    isExitDialogOpen = true;
    showDialog(context: context, builder: (context) => const ExitGameDailog())
        .then((value) => isExitDialogOpen = false);
  }

  void openBottomSheet(List<Question> questions) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * (0.6)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Wrap(
                  children: List.generate(questions.length, (index) => index)
                      .map(
                        (index) => hasQuestionAttemptedContainer(
                          index,
                          questions[index].attempted,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * (0.25),
                  child: CustomRoundedButton(
                    onTap: () {
                      timerAnimationController.stop();
                      Navigator.of(context).pop();
                      navigateToResult();
                    },
                    widthPercentage: MediaQuery.of(context).size.width,
                    backgroundColor: Theme.of(context).primaryColor,
                    buttonTitle: AppLocalization.of(context)!
                        .getTranslatedValues("submitBtn")!,
                    radius: 10,
                    showBorder: false,
                    titleColor: Constants.white,
                    height: 30.0,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 15,
                        child: Center(
                          child: Icon(
                            Icons.check,
                            color: Constants.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues("attemptedLbl")!,
                        style: TextStyle(
                            fontSize: 12.5, color: Theme.of(context).primaryColor),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Constants.secondaryColor,
                        child: Center(
                          child: Icon(
                            Icons.check,
                            color: Constants.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues("unAttemptedLbl")!,
                        style: TextStyle(
                            fontSize: 12.5, color: Constants.secondaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          )),
    ).then((value) {
      isBottomSheetOpen = false;
    });
  }

  Widget _buildTopMenu() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.only(
            right: MediaQuery.of(context).size.width *
                ((1.0 - UiUtils.quesitonContainerWidthPercentage) * 0.5),
            left: MediaQuery.of(context).size.width *
                ((1.0 - UiUtils.quesitonContainerWidthPercentage) * 0.5),
            top: MediaQuery.of(context).padding.top),
        child: Row(
          children: [
            CustomBackButton(
              onTap: () {
                onTapBackButton();
              },
              iconColor: Theme.of(context).backgroundColor,
            ),
            const Spacer(),
            SettingButton(onPressed: () {
              toggleSettingDialog();
              showDialog(
                  context: context,
                  builder: (_) => SettingsDialogContainer()).then((value) {
                toggleSettingDialog();
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomMenu(BuildContext context) {
    return BlocBuilder<QuestionsCubit, QuestionsState>(
      bloc: context.read<QuestionsCubit>(),
      builder: (context, state) {
        if (state is QuestionsFetchSuccess) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 16, right: 16),
            child: Row(
              children: [
                Opacity(
                  opacity: 1.0,
                  child: IconButton(
                      onPressed: () {
                        if (!questionAnimationController.isAnimating) {
                          if (currentQuestionIndex != 0) {
                            changeQuestion(
                                increaseIndex: false, newQuestionIndex: -1);
                          }
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Constants.white,
                      )),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    isBottomSheetOpen = true;
                    openBottomSheet(state.questions);
                  },
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SvgPicture.asset(
                          UiUtils.getImagePath("moveto_icon.svg")),
                    ),
                  ),
                ),
                const Spacer(),
                Opacity(
                  opacity: 1,
                  child: IconButton(
                      onPressed: () {
                        if (!questionAnimationController.isAnimating) {
                          if (currentQuestionIndex !=
                              (state.questions.length - 1)) {
                            changeQuestion(
                                increaseIndex: true, newQuestionIndex: -1);
                          }
                        }
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Constants.white,
                      )),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget backButton() {
    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).padding.top - 10),
            child: CustomBackButton(
              iconColor: Theme.of(context).primaryColor,
            )));
  }

  @override
  Widget build(BuildContext context) {
    final quesCubit = context.read<QuestionsCubit>();
    return WillPopScope(
      onWillPop: () {
        onTapBackButton();
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SizedBox(
          height: SizeConfig.screenHeight,
          child: Stack(
            children: [
              // const PageBackgroundGradientContainer(),
              // Align(
              //   alignment: Alignment.topCenter,
              //   child: QuizPlayAreaBackgroundContainer(
              //     heightPercentage: 0.9,
              //   ),
              // ),
              BlocConsumer<QuestionsCubit, QuestionsState>(
                  bloc: quesCubit,
                  listener: (context, state) {
                    if (state is QuestionsFetchSuccess) {
                      if (!timerAnimationController.isAnimating) {
                        timerAnimationController.forward();
                      }
                    }
                  },
                  builder: (context, state) {
                    if (state is QuestionsFetchInProgress ||
                        state is QuestionsIntial) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Constants.white,
                        ),
                      );
                    }
                    if (state is QuestionsFetchFailure) {
                      return Center(
                        child: ErrorContainer(
                          showBackButton: true,
                          errorMessageColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          errorMessage: AppLocalization.of(context)!
                              .getTranslatedValues(
                                  convertErrorCodeToLanguageKey(
                                      state.errorMessage)),
                          onTapRetry: () {
                            _getQuestions();
                          },
                          showErrorImage: true,
                        ),
                      );
                    }
                    final questions =
                        (state as QuestionsFetchSuccess).questions;
                    ques = questions;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: Align(
                          alignment: Alignment.topCenter,
                          child: NewQuestionsContainer(
                            timerAnimationController: timerAnimationController,
                            quizType: QuizTypes.selfChallenge,
                            showAnswerCorrectness: false,
                            lifeLines: {},
                            topPadding: MediaQuery.of(context).size.height *
                                UiUtils
                                    .getQuestionContainerTopPaddingPercentage(
                                        MediaQuery.of(context).size.height),
                            hasSubmittedAnswerForCurrentQuestion:
                                hasSubmittedAnswerForCurrentQuestion,
                            questions: questions,
                            submitAnswer: submitAnswer,
                            questionContentAnimation: questionContentAnimation,
                            questionScaleDownAnimation:
                                questionScaleDownAnimation,
                            questionScaleUpAnimation: questionScaleUpAnimation,
                            questionSlideAnimation: questionSlideAnimation,
                            currentQuestionIndex: currentQuestionIndex,
                            questionAnimationController:
                                questionAnimationController,
                            questionContentAnimationController:
                                questionContentAnimationController,
                            guessTheWordQuestions: [],
                            guessTheWordQuestionContainerKeys: [],
                            // quizType: QuizTypes.selfChallenge,
                          )),
                    );
                  }),
              BlocBuilder<QuestionsCubit, QuestionsState>(
                bloc: quesCubit,
                builder: (context, state) {
                  if (state is QuestionsFetchSuccess) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildBottomMenu(context),
                    );
                  }
                  return const SizedBox();
                },
              ),
              _buildTopMenu(),
            ],
          ),
        ),
      ),
    );
  }
}
