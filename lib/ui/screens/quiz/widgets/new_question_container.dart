import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/answerOption.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/ui/screens/quiz/new_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/audioQuestionContainer.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/guessTheWordQuestionContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/custom_card.dart';
import 'package:flutterquiz/ui/widgets/horizontalTimerContainer.dart';
import 'package:flutterquiz/ui/widgets/new_option_container.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/answerEncryption.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/lifeLineOptions.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class NewQuestionsContainer extends StatefulWidget {
  final List<GlobalKey> guessTheWordQuestionContainerKeys;

  final List<GlobalKey>? audioQuestionContainerKeys;
  final QuizTypes quizType;
  final Function hasSubmittedAnswerForCurrentQuestion;
  final int currentQuestionIndex;
  final Function submitAnswer;
  final AnimationController questionContentAnimationController;
  final AnimationController questionAnimationController;
  final Animation<double> questionSlideAnimation;
  final Animation<double> questionScaleUpAnimation;
  final Animation<double> questionScaleDownAnimation;
  final Animation<double> questionContentAnimation;
  final List<Question> questions;
  final List<GuessTheWordQuestion> guessTheWordQuestions;
  final double? topPadding;
  final String? level;
  final Map<String, LifelineStatus> lifeLines;
  final bool? showAnswerCorrectness;
  final AnimationController timerAnimationController;
  final bool? showGuessTheWordHint;

  const NewQuestionsContainer({
    Key? key,
    required this.submitAnswer,
    required this.quizType,
    required this.guessTheWordQuestionContainerKeys,
    required this.hasSubmittedAnswerForCurrentQuestion,
    required this.currentQuestionIndex,
    required this.guessTheWordQuestions,
    required this.questionAnimationController,
    required this.questionContentAnimationController,
    required this.questionContentAnimation,
    required this.questionScaleDownAnimation,
    required this.questionScaleUpAnimation,
    required this.questionSlideAnimation,
    required this.questions,
    required this.lifeLines,
    this.showGuessTheWordHint,
    this.audioQuestionContainerKeys,
    this.showAnswerCorrectness,
    required this.timerAnimationController,
    this.level,
    this.topPadding,
  }) : super(key: key);

  @override
  State<NewQuestionsContainer> createState() => _NewQuestionsContainerState();
}

class _NewQuestionsContainerState extends State<NewQuestionsContainer> {
  List<AnswerOption> fiftyFiftyAnswerOptions = [];
  List<int> percentages = [];

  double textSize = 14;

  //to get question length
  int getQuestionsLength() {
    if (widget.questions.isNotEmpty) {
      return widget.questions.length;
    }
    return widget.guessTheWordQuestions.length;
  }

  Widget _buildOptions(Question question, BoxConstraints constraints) {
    if (widget.lifeLines.isNotEmpty) {
      if (widget.lifeLines[fiftyFifty] == LifelineStatus.using) {
        if (!question.attempted) {
          fiftyFiftyAnswerOptions = LifeLineOptions.getFiftyFiftyOptions(
            question.answerOptions!,
            AnswerEncryption.decryptCorrectAnswer(
              rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
              correctAnswer: question.correctAnswer!,
            ),
          );
        }
        //build lifeline when using 50/50 lifelines
        return Column(
            children: fiftyFiftyAnswerOptions
                .map((answerOption) => NewOptionContainer(
                      quizType: widget.quizType,
                      submittedAnswerId: question.submittedAnswerId,
                      showAnswerCorrectness: widget.showAnswerCorrectness!,
                      showAudiencePoll: false,
                      hasSubmittedAnswerForCurrentQuestion:
                          widget.hasSubmittedAnswerForCurrentQuestion,
                      constraints: constraints,
                      answerOption: answerOption,
                      correctOptionId: AnswerEncryption.decryptCorrectAnswer(
                          rawKey: context
                              .read<UserDetailsCubit>()
                              .getUserFirebaseId(),
                          correctAnswer: question.correctAnswer!),
                      submitAnswer: widget.submitAnswer,
                    ))
                .toList());
      }

      if (widget.lifeLines[audiencePoll] == LifelineStatus.using) {
        if (!question.attempted) {
          percentages = LifeLineOptions.getAudiencePollPercentage(
              question.answerOptions!,
              AnswerEncryption.decryptCorrectAnswer(
                  rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
                  correctAnswer: question.correctAnswer!));
        }

        //build options when using audience poll lifeline
        return Column(
            children: question.answerOptions!.map((option) {
          int percentageIndex = question.answerOptions!.indexOf(option);
          return NewOptionContainer(
            quizType: widget.quizType,
            submittedAnswerId: question.submittedAnswerId,
            showAnswerCorrectness: widget.showAnswerCorrectness!,
            showAudiencePoll: true,
            audiencePollPercentage: percentages[percentageIndex],
            hasSubmittedAnswerForCurrentQuestion:
                widget.hasSubmittedAnswerForCurrentQuestion,
            constraints: constraints,
            answerOption: option,
            correctOptionId: AnswerEncryption.decryptCorrectAnswer(
                rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
                correctAnswer: question.correctAnswer!),
            submitAnswer: widget.submitAnswer,
          );
        }).toList());
      }
      //build answer when no lifeline is in using state
      return Column(
        children: question.answerOptions!.map((option) {
          return NewOptionContainer(
            quizType: widget.quizType,
            submittedAnswerId: question.submittedAnswerId,
            showAnswerCorrectness: widget.showAnswerCorrectness!,
            showAudiencePoll: false,
            hasSubmittedAnswerForCurrentQuestion:
                widget.hasSubmittedAnswerForCurrentQuestion,
            constraints: constraints,
            answerOption: option,
            correctOptionId: AnswerEncryption.decryptCorrectAnswer(
                rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
                correctAnswer: question.correctAnswer!),
            submitAnswer: widget.submitAnswer,
          );
        }).toList(),
      );
    }
    //build options when no need to use lifeline
    return Column(
      children: question.answerOptions!.map((option) {
        return NewOptionContainer(
          quizType: widget.quizType,
          submittedAnswerId: question.submittedAnswerId,
          showAnswerCorrectness: widget.showAnswerCorrectness!,
          showAudiencePoll: false,
          hasSubmittedAnswerForCurrentQuestion:
              widget.hasSubmittedAnswerForCurrentQuestion,
          constraints: constraints,
          answerOption: option,
          correctOptionId: AnswerEncryption.decryptCorrectAnswer(
              rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
              correctAnswer: question.correctAnswer!),
          submitAnswer: widget.submitAnswer,
        );
      }).toList(),
    );
  }

  Widget _buildLevelContainer() {
    if (widget.level == null) {
      return Container();
    }
    if (widget.level!.isEmpty) {
      return Container();
    }
    return Container(
      child: Text(
        AppLocalization.of(context)!.getTranslatedValues("levelLbl")! +
            " : ${widget.level}",
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }

  // Widget _buildCurrentCoins() {
  //   if (widget.lifeLines.isEmpty) {
  //     return Container();
  //   }
  //   return BlocBuilder<UserDetailsCubit, UserDetailsState>(
  //       bloc: context.read<UserDetailsCubit>(),
  //       builder: (context, state) {
  //         if (state is UserDetailsFetchSuccess) {
  //           return Align(
  //             alignment: AlignmentDirectional.topEnd,
  //             child: Text(
  //               AppLocalization.of(context)!.getTranslatedValues("coinsLbl")! +
  //                   " : ${state.userProfile.coins}",
  //               style:
  //                   TextStyle(color: Theme.of(context).colorScheme.secondary),
  //             ),
  //           );
  //         }
  //         return Container();
  //       });
  // }

  Widget _buildCurrentQuestionIndex() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TitleText(
        text:
            'QUESTION ${widget.currentQuestionIndex + 1} OF ${widget.questions.length}',
        weight: FontWeight.w500,
        size: Constants.bodySmall,
        textColor: Constants.grey2,
      ),
      // child: Text(
      //   "${widget.currentQuestionIndex + 1} | ${widget.questions.length}",
      //   style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      // ),
    );
  }

  Widget _buildQuestionText({
    required String questionText,
  }) {
    return widget.quizType == QuizTypes.mathMania
        ? TeXView(
            onRenderFinished: (height) {
              widget.timerAnimationController.forward();
            },
            child: TeXViewDocument(
              questionText,
            ),
            style: TeXViewStyle(
              contentColor: Theme.of(context).colorScheme.secondary,
              backgroundColor: Theme.of(context).backgroundColor,
              sizeUnit: TeXViewSizeUnit.pixels,
              textAlign: TeXViewTextAlign.center,
              fontStyle: TeXViewFontStyle(
                fontSize: textSize.toInt() + 5,
              ),
            ),
          )
        : TitleText(
            text: questionText,
            weight: FontWeight.w500,
            size: Constants.bodyXLarge,
            textColor: Constants.black1,
          );
  }

  Widget _buildQuesitonContainer(
      double scale, int index, bool showContent, BuildContext context) {
    Widget child = LayoutBuilder(builder: (context, constraints) {
      if (widget.questions.isEmpty) {
        return GuessTheWordQuestionContainer(
          showHint: widget.showGuessTheWordHint ?? true,
          timerAnimationController: widget.timerAnimationController,
          key: showContent
              ? widget.guessTheWordQuestionContainerKeys[
                  widget.currentQuestionIndex]
              : null,
          submitAnswer: widget.submitAnswer,
          constraints: constraints,
          currentQuestionIndex: widget.currentQuestionIndex,
          questions: widget.guessTheWordQuestions,
        );
      } else {
        if (widget.quizType == QuizTypes.audioQuestions) {
          return AudioQuestionContainer(
            showAnswerCorrectness: widget.showAnswerCorrectness ?? false,
            key:
                widget.audioQuestionContainerKeys![widget.currentQuestionIndex],
            hasSubmittedAnswerForCurrentQuestion:
                widget.hasSubmittedAnswerForCurrentQuestion,
            constraints: constraints,
            currentQuestionIndex: widget.currentQuestionIndex,
            questions: widget.questions,
            submitAnswer: widget.submitAnswer,
            timerAnimationController: widget.timerAnimationController,
          );
        }
        Question question = widget.questions[index];
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 17.5,
              ),
              widget.quizType == QuizTypes.battle ||
                      widget.quizType == QuizTypes.groupPlay
                  ? const SizedBox()
                  : HorizontalTimerContainer(
                      quizTypes: widget.quizType,
                      timerAnimationController:
                          widget.timerAnimationController),
              widget.quizType == QuizTypes.battle ||
                      widget.quizType == QuizTypes.groupPlay
                  ? const SizedBox()
                  : const SizedBox(
                      height: 15,
                    ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: _buildLevelContainer(),
                  ),
                  // _buildCurrentCoins(),
                  WidgetsUtil.verticalSpace24,
                  _buildCurrentQuestionIndex(),
                ],
              ),
              WidgetsUtil.verticalSpace8,
              Container(
                alignment: Alignment.center,
                child: _buildQuestionText(
                  questionText: question.question!,
                ),
              ),
              question.imageUrl != null && question.imageUrl!.isNotEmpty
                  ? SizedBox(
                      height: constraints.maxHeight * (0.0175),
                    )
                  : WidgetsUtil.verticalSpace24,
              question.imageUrl != null && question.imageUrl!.isNotEmpty
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: constraints.maxHeight * (0.225),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: CachedNetworkImage(
                          placeholder: (context, _) {
                            return Center(
                                child: CircularProgressIndicator(
                              color: Constants.primaryColor,
                            ));
                          },
                          imageUrl: question.imageUrl!,
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            );
                          },
                          errorWidget: (context, image, error) {
                            return Center(
                              child: Icon(
                                Icons.error,
                                color: Theme.of(context).primaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : const SizedBox(),
              _buildOptions(question, constraints),
              WidgetsUtil.verticalSpace16,
            ],
          ),
        );
      }
    });

    // return Container(
    // transform: Matrix4.identity()..scale(scale),
    // transformAlignment: Alignment.center,
    // padding: const EdgeInsets.symmetric(horizontal: 25.0),
    // width: MediaQuery.of(context).size.width *
    //     UiUtils.quesitonContainerWidthPercentage,
    // height: MediaQuery.of(context).size.height *
    //     (UiUtils.questionContainerHeightPercentage -
    //         0.045 * (widget.quizType == QuizTypes.groupPlay ? 1.0 : 0.0)),
    // decoration: BoxDecoration(
    //   color: Theme.of(context).backgroundColor,
    //   borderRadius: BorderRadius.circular(
    //     25,
    //   ),
    // ),
    // child: showContent
    //     ? SlideTransition(
    //         position: widget.questionContentAnimation.drive(Tween<Offset>(
    //             begin: const Offset(0.5, 0.0), end: Offset.zero)),
    //         child: FadeTransition(
    //           opacity: widget.questionContentAnimation,
    //           child: child,
    //         ),
    //       )
    //     : Container(),
    // );
    return CustomCard(
      padding: const EdgeInsets.all(8.0),
      child: showContent
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SlideTransition(
                position: widget.questionContentAnimation.drive(
                  Tween<Offset>(
                    begin: const Offset(0.5, 0.0),
                    end: Offset.zero,
                  ),
                ),
                child: FadeTransition(
                  opacity: widget.questionContentAnimation,
                  child: child,
                ),
              ),
            )
          : Container(),
    );
  }

  Widget _buildQuestion(int questionIndex, BuildContext context) {
    //print(questionIndex);
    //if current question index is same as question index means
    //it is current question and will be on top
    //so we need to add animation that slide and fade this question
    if (widget.currentQuestionIndex == questionIndex) {
      return FadeTransition(
        opacity: widget.questionSlideAnimation
            .drive(Tween<double>(begin: 1.0, end: 0.0)),
        child: SlideTransition(
          position: widget.questionSlideAnimation.drive(
            Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(
                -1.5,
                0.0,
              ),
            ),
          ),
          child: _buildQuesitonContainer(
            1.0,
            questionIndex,
            true,
            context,
          ),
        ),
      );
    }
    //if the question is second or after current question
    //so we need to animation that scale this question
    //initial scale of this question is 0.95

    else if (questionIndex > widget.currentQuestionIndex &&
        (questionIndex == widget.currentQuestionIndex + 1)) {
      return AnimatedBuilder(
        animation: widget.questionAnimationController,
        builder: (context, child) {
          double scale = 0.95 +
              widget.questionScaleUpAnimation.value -
              widget.questionScaleDownAnimation.value;
          return _buildQuesitonContainer(
            scale,
            questionIndex,
            false,
            context,
          );
        },
      );
    }
    //to build question except top 2

    else if (questionIndex > widget.currentQuestionIndex) {
      return _buildQuesitonContainer(1.0, questionIndex, false, context);
    }
    //if the question is already animated that show empty container
    return Container();
  }

  //to build questions
  List<Widget> _buildQuesitons(BuildContext context) {
    List<Widget> children = [];

    //loop terminate condition will be questions.length instead of 4
    for (var i = 0; i < getQuestionsLength(); i++) {
      //add question
      children.add(_buildQuestion(i, context));
    }
    //need to reverse the list in order to display 1st question in top
    children = children.reversed.toList();

    return children;
  }

  @override
  Widget build(BuildContext context) {
    //Font Size change Lister to change questions font size
    return BlocListener<SettingsCubit, SettingsState>(
      bloc: context.read<SettingsCubit>(),
      listener: (context, state) {
        if (state.settingsModel!.playAreaFontSize != textSize) {
          setState(() {
            textSize =
                context.read<SettingsCubit>().getSettings().playAreaFontSize;
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + (widget.topPadding ?? 7.5),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ..._buildQuesitons(context),
          ],
        ),
      ),
    );
  }
}
