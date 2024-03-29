import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/screens/exam/widgets/examQuestionStatusBottomSheetContainer.dart';
import 'package:flutterquiz/ui/screens/exam/widgets/examTimerContainer.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/questionContainer.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/exitGameDailog.dart';
import 'package:flutterquiz/ui/widgets/new_option_container.dart';
import 'package:flutterquiz/utils/answerEncryption.dart';
import 'package:flutterquiz/utils/constants.dart';

import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExamScreen extends StatefulWidget {
  ExamScreen({Key? key}) : super(key: key);

  @override
  _ExamScreenState createState() => _ExamScreenState();

  static Route<ExamScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => ExamScreen(),
    );
  }
}

class _ExamScreenState extends State<ExamScreen> with WidgetsBindingObserver {
  final GlobalKey<ExamTimerContainerState> timerKey =
      GlobalKey<ExamTimerContainerState>();

  late PageController pageController = PageController();

  Timer? canGiveExamAgainTimer;
  bool canGiveExamAgain = true;

  int canGiveExamAgainTimeInSeconds = 5;

  bool isExitDialogOpen = false;
  bool userLeftTheExam = false;

  bool showYouLeftTheExam = false;
  bool isExamQuestionStatusBottomsheetOpen = false;

  int currentQuestionIndex = 0;

  IosInsecureScreenDetector? _iosInsecureScreenDetector;
  late bool isScreenRecordingInIos = false;

  List<String> iosCapturedScreenshotQuestionIds = [];

  @override
  void initState() {
    super.initState();

    //wake lock enable so phone will not lock automatically after sometime

    Wakelock.enable();

    WidgetsBinding.instance.addObserver(this);

    if (Platform.isIOS) {
      initScreenshotAndScreenRecordDetectorInIos();
    } else {
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }

    //start timer
    Future.delayed(Duration.zero, () {
      timerKey.currentState?.startTimer();
    });
  }

  void initScreenshotAndScreenRecordDetectorInIos() async {
    _iosInsecureScreenDetector = IosInsecureScreenDetector();
    await _iosInsecureScreenDetector?.initialize();
    _iosInsecureScreenDetector?.addListener(
        iosScreenshotCallback, iosScreenrecordCallback);
  }

  void iosScreenshotCallback() {
    print("User took screenshot");
    iosCapturedScreenshotQuestionIds.add(
        context.read<ExamCubit>().getQuestions()[currentQuestionIndex].id!);
  }

  void iosScreenrecordCallback(bool isRecording) {
    setState(() {
      isScreenRecordingInIos = isRecording;
    });
  }

  void setCanGiveExamTimer() {
    canGiveExamAgainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (canGiveExamAgainTimeInSeconds == 0) {
        timer.cancel();

        //can give exam again false
        canGiveExamAgain = false;

        //show user left the exam
        setState(() {
          showYouLeftTheExam = true;
        });
        //submit result
        submitResult();
      } else {
        canGiveExamAgainTimeInSeconds--;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(appState) {
    if (appState == AppLifecycleState.paused) {
      setCanGiveExamTimer();
    } else if (appState == AppLifecycleState.resumed) {
      canGiveExamAgainTimer?.cancel();
      //if user can give exam again
      if (canGiveExamAgain) {
        canGiveExamAgainTimeInSeconds = 5;
      }
    }
  }

  @override
  void dispose() {
    canGiveExamAgainTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    Wakelock.disable();
    _iosInsecureScreenDetector?.dispose();
    if (Platform.isAndroid) {
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
    super.dispose();
  }

  void showExamQuestionStatusBottomSheet() {
    isExamQuestionStatusBottomsheetOpen = true;
    showModalBottomSheet(
        isScrollControlled: true,
        elevation: 5.0,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (context) {
          return ExamQuestionStatusBottomSheetContainer(
            navigateToResultScreen: navigateToResultScreen,
            pageController: pageController,
          );
        }).then((value) => isExamQuestionStatusBottomsheetOpen = false);
  }

  bool hasSubmittedAnswerForCurrentQuestion() {
    return context
        .read<ExamCubit>()
        .getQuestions()[currentQuestionIndex]
        .attempted;
  }

  void submitResult() {
    context.read<ExamCubit>().submitResult(
        capturedQuestionIds: iosCapturedScreenshotQuestionIds,
        rulesViolated: iosCapturedScreenshotQuestionIds.isNotEmpty,
        userId: context.read<UserDetailsCubit>().getUserFirebaseId(),
        totalDuration:
            timerKey.currentState?.getCompletedExamDuration().toString() ??
                "0");
  }

  void submitAnswer(String submittedAnswerId) {
    if (hasSubmittedAnswerForCurrentQuestion()) {
      if (context.read<ExamCubit>().canUserSubmitAnswerAgainInExam()) {
        context.read<ExamCubit>().updateQuestionWithAnswer(
            context.read<ExamCubit>().getQuestions()[currentQuestionIndex].id!,
            submittedAnswerId);
      }
    } else {
      context.read<ExamCubit>().updateQuestionWithAnswer(
          context.read<ExamCubit>().getQuestions()[currentQuestionIndex].id!,
          submittedAnswerId);
    }
  }

  void navigateToResultScreen() {
    if (isExitDialogOpen) {
      Navigator.of(context).pop();
    }

    if (isExamQuestionStatusBottomsheetOpen) {
      Navigator.of(context).pop();
    }

    submitResult();

    Navigator.of(context).pushReplacementNamed(Routes.result, arguments: {
      "quizType": QuizTypes.exam,
      "exam": context.read<ExamCubit>().getExam(),
      "obtainedMarks": context
          .read<ExamCubit>()
          .obtainedMarks(context.read<UserDetailsCubit>().getUserFirebaseId()),
      "examCompletedInMinutes":
          timerKey.currentState?.getCompletedExamDuration(),
      "correctExamAnswers": context
          .read<ExamCubit>()
          .correctAnswers(context.read<UserDetailsCubit>().getUserFirebaseId()),
      "incorrectExamAnswers": context.read<ExamCubit>().incorrectAnswers(
          context.read<UserDetailsCubit>().getUserFirebaseId()),
      "numberOfPlayer": 1,
    });
  }

  Widget _buildBottomMenu() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Constants.primaryColor),
      padding:
          const EdgeInsets.only(bottom: 8.0, top: 8.0, left: 20, right: 20),
      child: Row(
        children: [
          Opacity(
            opacity: currentQuestionIndex != 0 ? 1.0 : 0.5,
            child: IconButton(
                onPressed: () {
                  if (currentQuestionIndex != 0) {
                    pageController.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut);
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
              showExamQuestionStatusBottomSheet();
            },
            child: CircleAvatar(
              backgroundColor: Constants.primaryColor,
              radius: 20,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child:
                    SvgPicture.asset(UiUtils.getImagePath("moveto_icon.svg")),
              ),
            ),
          ),
          const Spacer(),
          Opacity(
            opacity: (context.read<ExamCubit>().getQuestions().length - 1) !=
                    currentQuestionIndex
                ? 1.0
                : 0.5,
            child: IconButton(
                onPressed: () {
                  if (context.read<ExamCubit>().getQuestions().length - 1 !=
                      currentQuestionIndex) {
                    pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut);
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

  Widget _buildAppBar() {
    return Container(
      height:
          MediaQuery.of(context).size.height * (UiUtils.appBarHeightPercentage),
      decoration: BoxDecoration(
          boxShadow: [UiUtils.buildAppbarShadow()],
          color: Constants.primaryColor,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0))),
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.only(start: 20.0, bottom: 30.0),
              child: CustomBackButton(
                removeSnackBars: false,
                iconColor: Constants.white,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * (0.65),
                    child: Text(
                      "${context.read<ExamCubit>().getExam().title}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Constants.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 2.5,
                  ),
                  Text(
                    "${context.read<ExamCubit>().getExam().totalMarks} ${AppLocalization.of(context)!.getTranslatedValues(markKey)!}",
                    style: TextStyle(
                      color: Constants.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.only(end: 20.0, bottom: 30.0),
              child: ExamTimerContainer(
                navigateToResultScreen: navigateToResultScreen,
                examDurationInMinutes:
                    int.parse(context.read<ExamCubit>().getExam().duration),
                key: timerKey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouLeftTheExam() {
    if (showYouLeftTheExam) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          child: AlertDialog(
            content: Text(
              AppLocalization.of(context)!
                  .getTranslatedValues(youLeftTheExamKey)!,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalization.of(context)!.getTranslatedValues(okayLbl)!,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ))
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget _buildQuestions() {
    return BlocBuilder<ExamCubit, ExamState>(
      bloc: context.read<ExamCubit>(),
      builder: (context, state) {
        if (state is ExamFetchSuccess) {
          return PageView.builder(
            onPageChanged: (index) {
              currentQuestionIndex = index;
              setState(() {});
            },
            controller: pageController,
            itemCount: state.questions.length,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height *
                          (UiUtils.appBarHeightPercentage) +
                      25,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: QuestionContainer(
                        isMathQuestion: false,
                        questionColor: Constants.black1,
                        questionNumber: index + 1,
                        question: state.questions[index],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    ...state.questions[index].answerOptions!
                        .map((option) => NewOptionContainer(
                            quizType: QuizTypes.exam,
                            showAnswerCorrectness: false,
                            showAudiencePoll: false,
                            hasSubmittedAnswerForCurrentQuestion:
                                hasSubmittedAnswerForCurrentQuestion,
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * (0.85),
                              maxHeight: MediaQuery.of(context).size.height *
                                  UiUtils.questionContainerHeightPercentage,
                            ),
                            answerOption: option,
                            correctOptionId:
                                AnswerEncryption.decryptCorrectAnswer(
                                    rawKey: context
                                        .read<UserDetailsCubit>()
                                        .getUserFirebaseId(),
                                    correctAnswer:
                                        state.questions[index].correctAnswer!),
                            submitAnswer: submitAnswer,
                            submittedAnswerId:
                                state.questions[index].submittedAnswerId))
                        .toList(),
                  ],
                ),
              );
            },
          );
        }
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (showYouLeftTheExam) {
          return Future.value(true);
        }
        isExitDialogOpen = true;
        showDialog(
            context: context,
            builder: (context) => ExitGameDailog(
                  onTapYes: () {
                    //
                    submitResult();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    //submit result of exam
                  },
                )).then((value) {
          isExitDialogOpen = false;
        });
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Constants.white,
        body: Stack(
          children: [
            // const PageBackgroundGradientContainer(),
            _buildAppBar(),
            _buildQuestions(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomMenu(),
            ),
            _buildYouLeftTheExam(),
            isScreenRecordingInIos
                ? Container(
                    color: Colors.black,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
