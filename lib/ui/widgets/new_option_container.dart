import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/features/quiz/models/answerOption.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
// Import package
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class NewOptionContainer extends StatefulWidget {
  final Function hasSubmittedAnswerForCurrentQuestion;
  final Function submitAnswer;
  final AnswerOption answerOption;
  final BoxConstraints constraints;
  final String correctOptionId;
  final String submittedAnswerId;
  final bool showAudiencePoll;
  final int? audiencePollPercentage;
  final bool showAnswerCorrectness;
  final QuizTypes quizType;
  const NewOptionContainer(
      {Key? key,
      required this.quizType,
      required this.showAnswerCorrectness,
      required this.showAudiencePoll,
      required this.hasSubmittedAnswerForCurrentQuestion,
      required this.constraints,
      required this.answerOption,
      required this.correctOptionId,
      required this.submitAnswer,
      required this.submittedAnswerId,
      this.audiencePollPercentage})
      : super(key: key);

  @override
  _NewOptionContainerState createState() => _NewOptionContainerState();
}

class _NewOptionContainerState extends State<NewOptionContainer>
    with TickerProviderStateMixin {
  late AnimationController animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 90));
  late Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(
          parent: animationController, curve: Curves.easeInQuad));

  late AnimationController topContainerAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 180,
    ),
  );
  late Animation<double> topContainerOpacityAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: topContainerAnimationController,
      curve: const Interval(
        0.0,
        0.25,
        curve: Curves.easeInQuad,
      ),
    ),
  );

  late Animation<double> topContainerAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: topContainerAnimationController,
      curve: const Interval(
        0.0,
        0.5,
        curve: Curves.easeInQuad,
      ),
    ),
  );

  late Animation<double> answerCorrectnessAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: topContainerAnimationController,
      curve: const Interval(
        0.5,
        1.0,
        curve: Curves.easeInQuad,
      ),
    ),
  );

  late double heightPercentage = 0.105;
  late AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  late TextSpan textSpan = TextSpan(
    text: widget.answerOption.title,
    style: TextStyle(
      color: Constants.black1,
      height: 1.0,
      fontSize: 16.0,
    ),
  );

  @override
  void dispose() {
    animationController.dispose();
    topContainerAnimationController.dispose();
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  void playSound(String trackName) {
    if (context.read<SettingsCubit>().getSettings().sound) {
      if (assetsAudioPlayer.isPlaying.value) {
        assetsAudioPlayer.stop();
      }
      assetsAudioPlayer.open(Audio("$trackName"));
      assetsAudioPlayer.play();
    }
  }

  void playVibrate() async {
    if (context.read<SettingsCubit>().getSettings().vibration) {
      UiUtils.vibrate();
    }
  }

  int calculateMaxLines() {
    TextPainter textPainter =
        TextPainter(text: textSpan, textDirection: Directionality.of(context));

    textPainter.layout(
      maxWidth: widget.constraints.maxWidth * (0.85),
    );

    return textPainter.computeLineMetrics().length;
  }

  Color _buildOptionBackgroundColor() {
    if (widget.showAnswerCorrectness) {
      return Constants.white;
    }
    if (widget.hasSubmittedAnswerForCurrentQuestion() &&
        widget.submittedAnswerId == widget.answerOption.id) {
      return Constants.secondaryColor;
    }
    return Constants.grey5;
  }

  void _onTapOptionContainer() {
    if (widget.showAnswerCorrectness) {
      //if user has submitted the answer then do not show correctness of the answer
      if (!widget.hasSubmittedAnswerForCurrentQuestion()) {
        widget.submitAnswer(widget.answerOption.id);

        topContainerAnimationController.forward();

        //play sound
        if (widget.correctOptionId == widget.answerOption.id) {
          playSound(correctAnswerSoundTrack);
        } else {
          playSound(wrongAnswerSoundTrack);
        }
        playVibrate();
      }
    } else {
      widget.submitAnswer(widget.answerOption.id);
      //play sound
      playSound(clickEventSoundTrack);
      playVibrate();
    }
  }

  Widget _buildOptionDetails(double optionWidth) {
    int maxLines = calculateMaxLines();
    if (!widget.hasSubmittedAnswerForCurrentQuestion()) {
      heightPercentage = maxLines > 2
          ? (heightPercentage + (0.03 * (maxLines - 2)))
          : heightPercentage;
    }

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.drive(Tween<double>(begin: 1.0, end: 0.9)).value,
          child: child,
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          top: widget.constraints.maxHeight * (0.015),
        ),
        height: widget.constraints.maxHeight * heightPercentage,
        width: optionWidth,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: maxLines > 2 ? 7.50 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: _buildOptionBackgroundColor(),
                    borderRadius: BorderRadius.circular(
                      Constants.cardsRadius,
                    ),
                    border: Border.all(
                      color: Constants.grey5,
                    ),
                  ),
                  alignment: AlignmentDirectional.centerStart,
                  child:
                      //if question type is 1 means render latex question
                      widget.quizType == QuizTypes.mathMania
                          ? TeXView(
                              child: TeXViewInkWell(
                                rippleEffect: false,
                                onTap: (_) {
                                  //
                                  _onTapOptionContainer();
                                },
                                child: TeXViewDocument(
                                  widget.answerOption.title!,
                                ),
                                id: widget.answerOption.id!,
                              ),
                              style: TeXViewStyle(
                                contentColor: Constants.black1,
                                backgroundColor: Constants.white,
                                sizeUnit: TeXViewSizeUnit.pixels,
                                textAlign: TeXViewTextAlign.center,
                                fontStyle: TeXViewFontStyle(
                                  fontSize: Constants.bodyNormal.toInt(),
                                  fontWeight: TeXViewFontWeight.w500,
                                  fontFamily: 'Rubik',
                                ),
                              ),
                            )
                          : Center(
                              child: TitleText(
                                text: widget.answerOption.title!,
                                textColor: Constants.black1,
                                weight: FontWeight.w400,
                                size: 16,
                              ),
                            )
                  // : RichText(
                  //     text: textSpan,
                  //   ),
                  ),
              widget.showAnswerCorrectness
                  ? IgnorePointer(
                      ignoring: true,
                      child: AnimatedBuilder(
                        builder: (context, child) {
                          final height = topContainerAnimation
                              .drive(
                                Tween<double>(
                                  begin: 0.085,
                                  end: heightPercentage,
                                ),
                              )
                              .value;
                          final width = topContainerAnimation
                              .drive(Tween<double>(begin: 0.2, end: 1.0))
                              .value;

                          final borderRadius = topContainerAnimation
                              .drive(Tween<double>(begin: 40.0, end: 20))
                              .value;

                          return Opacity(
                            opacity: topContainerOpacityAnimation.value,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: widget.answerOption.id ==
                                        widget.correctOptionId
                                    ? Constants.lightGreen
                                    : Constants.wrongAnswer,
                                borderRadius: BorderRadius.circular(
                                  borderRadius,
                                ),
                              ),
                              width: optionWidth * width,
                              height: widget.constraints.maxHeight * height,
                              child: Transform.scale(
                                scale: answerCorrectnessAnimation.value,
                                child: Opacity(
                                  opacity: answerCorrectnessAnimation.value,
                                  child: widget.answerOption.id ==
                                          widget.correctOptionId
                                      ? Icon(
                                          Icons.check,
                                          color:
                                              Theme.of(context).backgroundColor,
                                        )
                                      : Icon(
                                          Icons.close,
                                          color:
                                              Theme.of(context).backgroundColor,
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                        animation: topContainerAnimationController,
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    textSpan = TextSpan(
      text: widget.answerOption.title,
      style: TextStyle(
        color: Theme.of(context).backgroundColor,
        height: 1.0,
        fontSize: 16.0,
      ),
    );
    return GestureDetector(
      onTapCancel: () {
        animationController.reverse();
      },
      onTap: () async {
        animationController.reverse();
        _onTapOptionContainer();
      },
      onTapDown: (_) {
        //
        animationController.forward();
      },
      child: widget.showAudiencePoll
          ? Row(
              children: [
                _buildOptionDetails(
                  widget.constraints.maxWidth * (0.85),
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  "${widget.audiencePollPercentage}%",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16.0),
                ),
              ],
            )
          : _buildOptionDetails(widget.constraints.maxWidth),
    );
  }
}
