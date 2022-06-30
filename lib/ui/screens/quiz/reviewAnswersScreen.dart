import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/musicPlayer/musicPlayerCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/answerOption.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/reportQuestion/reportQuestionCubit.dart';
import 'package:flutterquiz/features/reportQuestion/reportQuestionRepository.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/musicPlayerContainer.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/questionContainer.dart';

import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/custom_button.dart';
import 'package:flutterquiz/ui/widgets/custom_card.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/ui/widgets/roundedAppbar.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/answerEncryption.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/custom_appbar.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class ReviewAnswersScreen extends StatefulWidget {
  final List<Question> questions;
  final QuizTypes quizType;
  final List<GuessTheWordQuestion> guessTheWordQuestions;

  ReviewAnswersScreen(
      {Key? key,
      required this.questions,
      required this.guessTheWordQuestions,
      required this.quizType})
      : super(key: key);

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    //arguments will map and keys of the map are following
    //questions and guessTheWordQuestions
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<UpdateBookmarkCubit>(
                    create: (context) =>
                        UpdateBookmarkCubit(BookmarkRepository()),
                  ),
                  BlocProvider<ReportQuestionCubit>(
                      create: (_) =>
                          ReportQuestionCubit(ReportQuestionRepository())),
                ],
                child: ReviewAnswersScreen(
                  quizType: arguments!['quizType'],
                  guessTheWordQuestions: arguments['guessTheWordQuestions'] ??
                      List<GuessTheWordQuestion>.from([]),
                  questions: arguments['questions'] ?? List<Question>.from([]),
                )));
  }

  @override
  _ReviewAnswersScreenState createState() => _ReviewAnswersScreenState();
}

class _ReviewAnswersScreenState extends State<ReviewAnswersScreen> {
  PageController? _pageController;
  int _currentIndex = 0;
  List<GlobalKey<MusicPlayerContainerState>> musicPlayerContainerKeys = [];

  @override
  void initState() {
    _pageController = PageController();
    if (_hasAudioQuestion()) {
      widget.questions.forEach((element) {
        musicPlayerContainerKeys.add(GlobalKey<MusicPlayerContainerState>());
      });
    }

    super.initState();
  }

  bool _hasAudioQuestion() {
    if (widget.questions.isNotEmpty) {
      return widget.questions.first.audio!.isNotEmpty;
    }
    return false;
  }

  void showNotes() {
    if (widget.questions[_currentIndex].note!.isEmpty) {
      UiUtils.setSnackbar(
          AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(notesNotAvailableCode))!,
          context,
          false);
      return;
    }
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * (0.6)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  AppLocalization.of(context)!.getTranslatedValues("notesLbl")!,
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * (0.1)),
                  child: Text(
                    "${widget.questions[_currentIndex].question}",
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Divider(),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * (0.1)),
                  child: Text(
                    "${widget.questions[_currentIndex].note}",
                    style: TextStyle(
                        fontSize: 17.0, color: Theme.of(context).primaryColor),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.1),
                ),
              ],
            ),
          )),
    );
  }

  int getQuestionsLength() {
    if (widget.questions.isEmpty) {
      return widget.guessTheWordQuestions.length;
    }
    return widget.questions.length;
  }

  bool isGuessTheWordQuizModule() {
    return widget.guessTheWordQuestions.isNotEmpty;
  }

  Widget _newgetOptionsContainer(Question question,
      {String? optionId, AnswerOption? option}) {
    String correctAnswerId = AnswerEncryption.decryptCorrectAnswer(
        rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
        correctAnswer: question.correctAnswer!);

    return Column(
      children: [
        if (question.attempted) ...{
          question.submittedAnswerId == question.correctAnswer
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: getOptionColor(question, option!.id),
                  ),
                  width: MediaQuery.of(context).size.width * (0.8),
                  margin: EdgeInsets.only(top: 15.0),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  child: widget.quizType == QuizTypes.mathMania
                      ? TeXView(
                          child: TeXViewDocument(
                            option.title!,
                          ),
                          style: TeXViewStyle(
                              contentColor: Theme.of(context).backgroundColor,
                              backgroundColor: Colors.transparent,
                              sizeUnit: TeXViewSizeUnit.pixels,
                              textAlign: TeXViewTextAlign.center,
                              fontStyle: TeXViewFontStyle(fontSize: 19)),
                        )
                      : Text(
                          option.title!,
                          style: TextStyle(
                              color: Theme.of(context).backgroundColor),
                        ),
                )
              : Container(
                  color: Constants.accent2,
                  height: 50,
                ),
        }
      ],
    );
  }

  Color getOptionColor(Question question, String? optionId) {
    String correctAnswerId = AnswerEncryption.decryptCorrectAnswer(
        rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
        correctAnswer: question.correctAnswer!);
    if (question.attempted) {
      // if given answer is correct
      if (question.submittedAnswerId == correctAnswerId) {
        //if given option is same as answer
        if (question.submittedAnswerId == optionId) {
          return Colors.green;
        }
        //color will not change for other options
        return Theme.of(context).colorScheme.secondary;
      } else {
        //option id is same as given answer then change color to red
        if (question.submittedAnswerId == optionId) {
          return Colors.red;
        }
        //if given option id is correct as same answer then change color to green
        else if (correctAnswerId == optionId) {
          return Colors.green;
        }
        //do not change color
        return Theme.of(context).colorScheme.secondary;
      }
    } else {
      // if answer not given then only show correct answer
      if (correctAnswerId == optionId) {
        return Colors.green;
      }
      return Theme.of(context).colorScheme.secondary;
    }
  }

  Color getOptionTextColor(Question question, String? optionId) {
    String correctAnswerId = AnswerEncryption.decryptCorrectAnswer(
        rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
        correctAnswer: question.correctAnswer!);
    if (question.attempted) {
      // if given answer is correct
      if (question.submittedAnswerId == correctAnswerId) {
        //if given option is same as answer
        if (question.submittedAnswerId == optionId) {
          return Theme.of(context).primaryColor;
        }
        //color will not change for other options
        return Theme.of(context).colorScheme.secondary;
      } else {
        //option id is same as given answer then change color to red
        if (question.submittedAnswerId == optionId) {
          return Theme.of(context).primaryColor;
        }
        //if given option id is correct as same answer then change color to green
        else if (correctAnswerId == optionId) {
          return Theme.of(context).primaryColor;
        }
        //do not change color
        return Theme.of(context).colorScheme.secondary;
      }
    } else {
      // if answer not given then only show correct answer
      if (correctAnswerId == optionId) {
        return Theme.of(context).primaryColor;
      }
      return Theme.of(context).colorScheme.secondary;
    }
  }

  Widget _newBuildBottomMenu() {
    return _currentIndex == (getQuestionsLength() - 1)
        ? SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      verticalMargin: 5,
                      onPressed: () {
                        if (_currentIndex != 0) {
                          _pageController!.animateToPage(_currentIndex - 1,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                        }
                      },
                      text: "Previous",
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                      verticalMargin: 5,
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      text: "Done",
                    ),
                  ),
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CustomButton(
              verticalMargin: 0,
              onPressed: () {
                if (_currentIndex != (getQuestionsLength() - 1)) {
                  _pageController!.animateToPage(_currentIndex + 1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                }
              },
              text: "Next",
            ),
          );
  }

  Widget _buildBottomMenu(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 5.0)
      ], color: Theme.of(context).backgroundColor),
      height: MediaQuery.of(context).size.height * UiUtils.bottomMenuPercentage,
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                if (_currentIndex != 0) {
                  _pageController!.animateToPage(_currentIndex - 1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                }
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).primaryColor,
              )),
          Spacer(),
          Text(
            "${_currentIndex + 1}/${getQuestionsLength()}",
            style: TextStyle(
                color: Theme.of(context).primaryColor, fontSize: 18.0),
          ),
          Spacer(),
          IconButton(
              onPressed: () {
                if (_currentIndex != (getQuestionsLength() - 1)) {
                  _pageController!.animateToPage(_currentIndex + 1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                }
              },
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
              )),
        ],
      ),
    );
  }

  //to build option of given question
  Widget _buildOption(AnswerOption option, Question question) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: getOptionColor(question, option.id),
      ),
      width: MediaQuery.of(context).size.width * (0.8),
      margin: EdgeInsets.only(top: 15.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: widget.quizType == QuizTypes.mathMania
          ? TeXView(
              child: TeXViewDocument(
                option.title!,
              ),
              style: TeXViewStyle(
                  contentColor: Theme.of(context).backgroundColor,
                  backgroundColor: Colors.transparent,
                  sizeUnit: TeXViewSizeUnit.pixels,
                  textAlign: TeXViewTextAlign.center,
                  fontStyle: TeXViewFontStyle(fontSize: 19)),
            )
          : Text(
              option.title!,
              style: TextStyle(color: Theme.of(context).backgroundColor),
            ),
    );
  }

  Widget _buildOptions(Question question) {
    return Column(
      children: question.answerOptions!.map((option) {
        return _buildOption(option, question);
      }).toList(),
    );
  }

  Widget _buildGuessTheWordOptionAndAnswer(
      GuessTheWordQuestion guessTheWordQuestion) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (0.1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 25.0,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 0.0),
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues("yourAnsLbl")! +
                  " : " +
                  "${UiUtils.buildGuessTheWordQuestionAnswer(guessTheWordQuestion.submittedAnswer)}",
              style: TextStyle(
                  fontSize: 18.0,
                  color: UiUtils.buildGuessTheWordQuestionAnswer(
                              guessTheWordQuestion.submittedAnswer) ==
                          guessTheWordQuestion.answer
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.secondary),
            ),
          ),
          UiUtils.buildGuessTheWordQuestionAnswer(
                      guessTheWordQuestion.submittedAnswer) ==
                  guessTheWordQuestion.answer
              ? SizedBox()
              : Padding(
                  padding: const EdgeInsetsDirectional.only(start: 0.0),
                  child: Text(
                    AppLocalization.of(context)!
                            .getTranslatedValues("correctAndLbl")! +
                        ":" +
                        " ${guessTheWordQuestion.answer}",
                    style: TextStyle(
                        fontSize: 18.0, color: Theme.of(context).primaryColor),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildNotes(String notes) {
    return notes.isEmpty
        ? Container()
        : Container(
            width: MediaQuery.of(context).size.width * (0.8),
            margin: EdgeInsets.only(top: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText(
                    text: AppLocalization.of(context)!
                        .getTranslatedValues(notesKey)!,
                    textColor: Theme.of(context).primaryColor,
                    weight: FontWeight.bold,
                    size: 18.0),
                SizedBox(
                  height: 10.0,
                ),
                TitleText(
                  text: notes,
                  textColor: Constants.primaryColor,
                ),
              ],
            ),
          );
  }

  Widget _buildQuestionAndOptions(Question question, int index) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 35.0,
          bottom: MediaQuery.of(context).size.height *
                  UiUtils.bottomMenuPercentage +
              25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TitleText(
            text: "QUESTIONS ${index + 1} of ${getQuestionsLength()}",
            size: 14,
            weight: FontWeight.w500,
            textColor: Constants.grey2,
          ),
          WidgetsUtil.verticalSpace8,
          QuestionContainer(
            isMathQuestion: widget.quizType == QuizTypes.mathMania,
            question: question,
          ),
          _hasAudioQuestion()
              ? BlocProvider<MusicPlayerCubit>(
                  create: (_) => MusicPlayerCubit(),
                  child: MusicPlayerContainer(
                    currentIndex: _currentIndex,
                    index: index,
                    url: question.audio!,
                    key: musicPlayerContainerKeys[index],
                  ))
              : Container(),

          //build options

          _buildOptions(question),
          // _newgetOptionsContainer(question), start from here
          _buildNotes(question.note!),
        ],
      ),
    );
  }

  Widget _buildGuessTheWordQuestionAndOptions(GuessTheWordQuestion question) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          top: 35.0,
          bottom: MediaQuery.of(context).size.height *
                  UiUtils.bottomMenuPercentage +
              25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          QuestionContainer(
            isMathQuestion: false,
            question: Question(
              marks: "",
              id: question.id,
              question: question.question,
              imageUrl: question.image,
            ),
          ),
          //build options
          _buildGuessTheWordOptionAndAnswer(question),
        ],
      ),
    );
  }

  Widget _buildQuestions() {
    return SizedBox(
      height: SizeConfig.screenHeight,
      child: PageView.builder(
          onPageChanged: (index) {
            if (_hasAudioQuestion()) {
              musicPlayerContainerKeys[_currentIndex].currentState?.stopAudio();
            }
            setState(() {
              _currentIndex = index;
            });
            if (_hasAudioQuestion()) {
              musicPlayerContainerKeys[_currentIndex].currentState?.playAudio();
            }
          },
          controller: _pageController,
          itemCount: getQuestionsLength(),
          itemBuilder: (context, index) {
            if (widget.questions.isEmpty) {
              return _buildGuessTheWordQuestionAndOptions(
                  widget.guessTheWordQuestions[index]);
            }
            return _buildQuestionAndOptions(widget.questions[index], index);
          }),
    );
  }

  Widget _buildReportButton(ReportQuestionCubit reportQuestionCubit) {
    return Transform.translate(
      offset: Offset(-5.0, 10.0),
      child: IconButton(
          onPressed: () {
            showModalBottomSheet(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                )),
                isDismissible: false,
                enableDrag: false,
                isScrollControlled: true,
                context: context,
                builder: (_) => ReportQuestionBottomSheetContainer(
                    questionId: isGuessTheWordQuizModule()
                        ? widget.guessTheWordQuestions[_currentIndex].id
                        : widget.questions[_currentIndex].id!,
                    reportQuestionCubit: reportQuestionCubit));
          },
          icon: Icon(
            Icons.report_problem,
            color: Theme.of(context).primaryColor,
          )),
    );
  }

  Widget _newAppBar() {
    return PreferredSize(
        child: CustomAppBar(onBackTapped: () {}, title: "Answer Explanation"),
        preferredSize: Size.fromHeight(50));
  }

  // Widget _buildAppbar() {
  //   return Align(
  //     alignment: Alignment.topCenter,
  //     child: RoundedAppbar(
  //       title: AppLocalization.of(context)!
  //           .getTranslatedValues("reviewAnswerLbl")!,
  //       trailingWidget: widget.questions.isEmpty
  //           ? _buildReportButton(context.read<ReportQuestionCubit>())
  //           : widget.questions.first.audio!.isNotEmpty
  //               ? _buildReportButton(context.read<ReportQuestionCubit>())
  //               : Row(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     // Transform.translate(
  //                     //   offset: Offset(5.0, 10.0),
  //                     //   child: BookmarkButton(
  //                     //     bookmarkButtonColor: Theme.of(context).primaryColor,
  //                     //     bookmarkFillColor: Theme.of(context).primaryColor,
  //                     //     question: widget.questions[_currentIndex],
  //                     //   ),
  //                     // ),
  //                     _buildReportButton(context.read<ReportQuestionCubit>()),
  //                   ],
  //                 ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.white,
      body: DefaultLayout(
        showBackButton: false,
        backgroundColor: Constants.primaryColor,
        title: "Answers Explanation",
        action: Icon(
          Icons.close,
          size: 40,
        ),
        titleColor: Constants.white,
        child: CustomCard(
          child: Column(
            children: [
              // _newAppBar(),
              Expanded(
                flex: 7,
                child: _buildQuestions(),
              ),
              Spacer(),
              Expanded(child: _newBuildBottomMenu()),

              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: _buildBottomMenu(context),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportQuestionBottomSheetContainer extends StatefulWidget {
  final ReportQuestionCubit reportQuestionCubit;
  final String questionId;
  ReportQuestionBottomSheetContainer(
      {Key? key, required this.reportQuestionCubit, required this.questionId})
      : super(key: key);

  @override
  _ReportQuestionBottomSheetContainerState createState() =>
      _ReportQuestionBottomSheetContainerState();
}

class _ReportQuestionBottomSheetContainerState
    extends State<ReportQuestionBottomSheetContainer> {
  final TextEditingController textEditingController = TextEditingController();
  late String errorMessage = "";

  String _buildButtonTitle(ReportQuestionState state) {
    if (state is ReportQuestionInProgress) {
      return AppLocalization.of(context)!
          .getTranslatedValues(submittingButton)!;
    }
    if (state is ReportQuestionFailure) {
      return AppLocalization.of(context)!.getTranslatedValues(retryLbl)!;
    }
    return AppLocalization.of(context)!.getTranslatedValues(submitBtn)!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportQuestionCubit, ReportQuestionState>(
      bloc: widget.reportQuestionCubit,
      listener: (context, state) {
        if (state is ReportQuestionSuccess) {
          Navigator.of(context).pop();
        }
        if (state is ReportQuestionFailure) {
          if (state.errorMessageCode == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
            return;
          }
          //
          setState(() {
            errorMessage = AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessageCode))!;
          });
        }
      },
      child: WillPopScope(
        onWillPop: () {
          if (widget.reportQuestionCubit.state is ReportQuestionInProgress) {
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              gradient: UiUtils.buildLinerGradient([
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).canvasColor
              ], Alignment.topCenter, Alignment.bottomCenter)),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: IconButton(
                          onPressed: () {
                            if (widget.reportQuestionCubit.state
                                is! ReportQuestionInProgress) {
                              Navigator.of(context).pop();
                            }
                          },
                          icon: Icon(
                            Icons.close,
                            size: 28.0,
                            color: Theme.of(context).primaryColor,
                          )),
                    ),
                  ],
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalization.of(context)!
                        .getTranslatedValues(reportQuestionKey)!,
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                //
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * (0.125),
                  ),
                  padding: EdgeInsets.only(left: 20.0),
                  height: 60.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).backgroundColor,
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: AppLocalization.of(context)!
                          .getTranslatedValues(enterReasonKey)!,
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.02),
                ),

                AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: errorMessage.isEmpty
                      ? SizedBox(
                          height: 20.0,
                        )
                      : Container(
                          height: 20.0,
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.02),
                ),
                //

                BlocBuilder<ReportQuestionCubit, ReportQuestionState>(
                  bloc: widget.reportQuestionCubit,
                  builder: (context, state) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * (0.3),
                      ),
                      child: CustomRoundedButton(
                        widthPercentage: MediaQuery.of(context).size.width,
                        backgroundColor: Theme.of(context).primaryColor,
                        buttonTitle: _buildButtonTitle(state),
                        radius: 10.0,
                        showBorder: false,
                        onTap: () {
                          if (state is! ReportQuestionInProgress) {
                            widget.reportQuestionCubit.reportQuestion(
                                message: textEditingController.text.trim(),
                                questionId: widget.questionId,
                                userId: context
                                    .read<UserDetailsCubit>()
                                    .getUserId());
                          }
                        },
                        fontWeight: FontWeight.bold,
                        titleColor: Theme.of(context).backgroundColor,
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
