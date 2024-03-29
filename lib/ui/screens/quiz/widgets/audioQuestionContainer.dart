import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/widgets/horizontalTimerContainer.dart';
import 'package:flutterquiz/ui/widgets/new_option_container.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/answerEncryption.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/widgets_util.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_visualizer/music_visualizer.dart';

class AudioQuestionContainer extends StatefulWidget {
  final BoxConstraints constraints;
  final int currentQuestionIndex;
  final List<Question> questions;
  final Function submitAnswer;
  final Function hasSubmittedAnswerForCurrentQuestion;
  final bool showAnswerCorrectness;
  QuizTypes? quizType;
  AnimationController timerAnimationController;

  AudioQuestionContainer({
    Key? key,
    required this.constraints,
    required this.showAnswerCorrectness,
    required this.currentQuestionIndex,
    required this.questions,
    required this.submitAnswer,
    required this.timerAnimationController,
    required this.hasSubmittedAnswerForCurrentQuestion,
  }) : super(key: key);

  @override
  AudioQuestionContainerState createState() => AudioQuestionContainerState();
}

class AudioQuestionContainerState extends State<AudioQuestionContainer>
    with TickerProviderStateMixin {
  double textSize = 14;
  late bool _showOption = false;
  late AudioPlayer _audioPlayer;
  late StreamSubscription<ProcessingState> _processingStateStreamSubscription;
  late StreamSubscription<Duration> _streamSubscription;
  late bool _isPlaying = true;
  late Duration _audioDuration = Duration.zero;
  Duration bufferedSeconds = Duration.zero;
  late bool _hasCompleted = false;
  late bool _hasError = false;
  late bool _isBuffering = false;
  late bool _isLoading = true;

  //
  @override
  void initState() {
    initializeAudio();

    super.initState();
  }

  void initializeAudio() async {
    _audioPlayer = AudioPlayer();

    try {
      var result = await _audioPlayer
          .setUrl(widget.questions[widget.currentQuestionIndex].audio!);
      _audioDuration = result ?? Duration.zero;

      // widget.timerAnimationController = AnimationController(
      //   vsync: this,
      //   duration: Duration(
      //     seconds: _audioDuration.inSeconds + 15,
      //   ),
      // );
      // _audioDuration + Duration(seconds: 15);

      widget.timerAnimationController.forward();
      _processingStateStreamSubscription =
          _audioPlayer.processingStateStream.listen(_processingStateListener);
      _streamSubscription = _audioPlayer.positionStream.listen((audioDuration) {
        bufferedSeconds = audioDuration;
        // log("Seconds: $bufferedSeconds");
        setState(() {});
      });
    } catch (e) {
      print(e.toString());
      _hasError = true;
    }
    setState(() {});
  }

  void _processingStateListener(ProcessingState event) {
    print(event.toString());
    if (event == ProcessingState.ready) {
      if (_isLoading) {
        _isLoading = false;
      }

      _audioPlayer.play();
      _isPlaying = true;
      _isBuffering = false;
      _hasCompleted = false;
    } else if (event == ProcessingState.buffering) {
      _isBuffering = true;
    } else if (event == ProcessingState.completed) {
      // if (!_showOption) {
      //   _showOption = true;
      //   widget.timerAnimationController.forward(from: 0.0);
      // }
      // widget.timerAnimationController.forward(from: 0.0);

      _hasCompleted = true;
    }

    setState(() {});
  }

// Widget _buildPlayAudioContainer() {
  //   if (_hasError) {
  //     return IconButton(
  //         onPressed: () {
  //           //retry
  //         },
  //         icon: Icon(
  //           Icons.error,
  //           color: Constants.white,
  //         ));
  //   }
  //   if (_isLoading || _isBuffering) {
  //     return IconButton(
  //         onPressed: null,
  //         icon: Container(
  //           height: 20,
  //           width: 20,
  //           child: Center(
  //               child: CircularProgressIndicator(
  //             color: Constants.white,
  //           )),
  //         ));
  //   }
  //   if (_hasCompleted) {
  //     return IconButton(
  //         onPressed: () {
  //           _audioPlayer.seek(Duration.zero);
  //         },
  //         icon: Icon(
  //           Icons.restart_alt,
  //           color: Constants.white,
  //         ));
  //   }
  //   if (_isPlaying) {
  //     return IconButton(
  //         onPressed: () {
  //           //
  //           _audioPlayer.pause();
  //           _isPlaying = false;
  //           setState(() {});
  //         },
  //         icon: Icon(
  //           Icons.pause,
  //           color: Constants.white,
  //         ));
  //   }

  //   return IconButton(
  //       onPressed: () {
  //         _audioPlayer.play();
  //         _isPlaying = true;
  //         setState(() {});
  //       },
  //       icon: Icon(
  //         Icons.play_arrow,
  //         color: Constants.white,
  //       ));
  // }

  @override
  void dispose() {
    _processingStateStreamSubscription.cancel();
    _audioPlayer.dispose();
    _streamSubscription.cancel();

    super.dispose();
  }

  // bool get showOption => _showOption;

  void changeShowOption() {
    _showOption = true;
    setState(() {});
  }

  final List<Color> colors = [
    Constants.primaryColor,
    Constants.accent2,
    Constants.primaryColor,
    Constants.accent2,
    Constants.primaryColor,
    Constants.accent2,
    Constants.primaryColor,
    Constants.accent2,
    Constants.primaryColor,
    Constants.accent2,
    Constants.primaryColor,
    Constants.accent2,
    Constants.primaryColor,
    Constants.accent2,
    Constants.primaryColor,
    Constants.accent2,
    Constants.primaryColor,
    Constants.accent2,
    Constants.primaryColor,
    Constants.accent2,
    Constants.primaryColor,
    Constants.accent2,
  ];

  final List<int> duration = [900, 700, 600, 800, 500];
  final List<int> stopduration = [1, 1];
  bool isAnimating = false;
  @override
  Widget build(BuildContext context) {
    final question = widget.questions[widget.currentQuestionIndex];

    return SingleChildScrollView(
        child: Column(
      children: [
        const SizedBox(
          height: 17.5,
        ),
        HorizontalTimerContainer(
          quizTypes: QuizTypes.audioQuestions,
          timerAnimationController: widget.timerAnimationController,
          duration: _audioDuration.inSeconds,
          isLoading: _isLoading,
        ),
        const SizedBox(
          height: 12.5,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            _buildCurrentQuestionIndex(),
            // Align(
            //   alignment: Alignment.center,
            //   child: Text(
            //     "${widget.currentQuestionIndex + 1} | ${widget.questions.length}",
            //     style: TextStyle(color: Constants.black1),
            //   ),
            // ),
          ],
        ),

        Divider(
          color: Constants.white,
        ),
        const SizedBox(
          height: 5.0,
        ),
        Container(
          alignment: Alignment.center,
          child: Text(
            "${question.question}",
            style: TextStyle(
                height: 1.125, fontSize: textSize, color: Constants.black1),
          ),
        ),

        SizedBox(
          height: widget.constraints.maxHeight * (0.04),
        ),
        Container(
          height: 100,
          width: widget.constraints.maxWidth * 1.2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.transparent),
          padding: EdgeInsets.symmetric(
              horizontal: widget.constraints.maxWidth * (0.05), vertical: 10.0),
          child: Column(
            children: [
              _isLoading
                  ? CircularProgressIndicator(
                      color: Constants.primaryColor,
                    )
                  : SizedBox(
                      height: 50,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (_isPlaying) {
                              _audioPlayer.stop();
                              log("if state");

                              _isPlaying = false;
                              isAnimating = true;
                            } else {
                              _audioPlayer.play();
                              log("else state");

                              _isPlaying = true;
                              isAnimating = false;
                            }
                          });
                        },
                        child: MusicVisualizer(
                          barCount: colors.length,
                          colors: colors,
                          duration: duration,
                          curve: Curves.easeInOut,
                          isAnimating: isAnimating,
                        ),
                      ),
                    ),
              WidgetsUtil.verticalSpace8,
              SizedBox(
                height: 20,
                child: Row(
                  children: [
                    Text(bufferedSeconds.inSeconds.toString()),
                    const Spacer(),
                    Text(_audioDuration.inSeconds.toString()),
                  ],
                ),
              )

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     CurrentDurationContainer(audioPlayer: _audioPlayer),
              //     Spacer(),
              //     _buildPlayAudioContainer(),
              //     Spacer(),
              //     Container(
              //       alignment: Alignment.centerRight,
              //       //decoration: BoxDecoration(border: Border.all()),
              //       width: MediaQuery.of(context).size.width * (0.1),
              //       child: Text(
              //         "${_audioDuration.inSeconds}s",
              //         style: TextStyle(
              //           color: Constants.white,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // Stack(
              //   children: [
              //     Align(
              //       alignment: AlignmentDirectional.centerStart,
              //       child: BufferedDurationContainer(audioPlayer: _audioPlayer),
              //     ),
              //     Align(
              //       alignment: AlignmentDirectional.centerStart,
              //       child: SizedBox(
              //         width: MediaQuery.of(context).size.width,
              //         height: 100,
              //         // child: CurrentDurationSliderContainer(
              //         //   audioPlayer: _audioPlayer,
              //         //   duration: _audioDuration,

              //         // child:
              //     )
              //   ],
              // ),
              // SizedBox(
              //   height: widget.constraints.minHeight * (0.025),
              // ),
            ],
          ),
        ),

        SizedBox(
          height: widget.constraints.maxHeight * (0.04),
        ),

        Column(
          children: question.answerOptions!.map((option) {
            return NewOptionContainer(
              quizType: QuizTypes.audioQuestions,
              submittedAnswerId: question.submittedAnswerId,
              showAnswerCorrectness: widget.showAnswerCorrectness,
              showAudiencePoll: false,
              hasSubmittedAnswerForCurrentQuestion:
                  widget.hasSubmittedAnswerForCurrentQuestion,
              constraints: widget.constraints,
              answerOption: option,
              correctOptionId: AnswerEncryption.decryptCorrectAnswer(
                  rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
                  correctAnswer: question.correctAnswer!),
              submitAnswer: widget.submitAnswer,
            );
          }).toList(),
        )
        // _showOption
        //     ?
        //     : Column(
        //         children: question.answerOptions!
        //             .map((e) => Container(
        //                   child: Center(
        //                     child: Text(
        //                       "-",
        //                       style: TextStyle(color: Constants.black1),
        //                     ),
        //                   ),
        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(20),
        //                     color: Constants.white,
        //                   ),
        //                   margin: EdgeInsets.only(
        //                       top: widget.constraints.maxHeight * (0.015)),
        //                   height: widget.constraints.maxHeight * (0.105),
        //                   width: widget.constraints.maxWidth * (0.95),
        //                 ))
        //             .toList(),
        //       ),

        //
      ],
    ));
  }

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
}

class CurrentDurationSliderContainer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Duration duration;

  CurrentDurationSliderContainer(
      {Key? key, required this.audioPlayer, required this.duration})
      : super(key: key);

  @override
  _CurrentDurationSliderContainerState createState() =>
      _CurrentDurationSliderContainerState();
}

class _CurrentDurationSliderContainerState
    extends State<CurrentDurationSliderContainer> {
  double currentValue = 0.0;

  late StreamSubscription<Duration> streamSubscription;
  @override
  void initState() {
    streamSubscription =
        widget.audioPlayer.positionStream.listen(currentDurationListener);

    super.initState();
  }

  void currentDurationListener(Duration duration) {
    currentValue = duration.inSeconds.toDouble();
    setState(() {});
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: Theme.of(context).sliderTheme.copyWith(
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
            trackHeight: 5,
            trackShape: CustomTrackShape(),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 6.5,
            ),
          ),
      child: Column(
        children: [
          SizedBox(
            height: 5.0,
            width: MediaQuery.of(context).size.width,
            child: Slider(
                min: 0.0,
                max: widget.duration.inSeconds.toDouble(),
                activeColor: Theme.of(context).primaryColor.withOpacity(0.6),
                inactiveColor: Theme.of(context).primaryColor.withOpacity(0.3),
                value: currentValue,
                thumbColor: Theme.of(context).colorScheme.secondary,
                onChanged: (value) {
                  setState(() {
                    currentValue = value;
                  });
                  widget.audioPlayer.seek(Duration(seconds: value.toInt()));
                }),
          ),
        ],
      ),
    );
  }
}

class BufferedDurationContainer extends StatefulWidget {
  final AudioPlayer audioPlayer;

  BufferedDurationContainer({Key? key, required this.audioPlayer})
      : super(key: key);

  @override
  _BufferedDurationContainerState createState() =>
      _BufferedDurationContainerState();
}

class _BufferedDurationContainerState extends State<BufferedDurationContainer> {
  late double bufferedPercentage = 0.0;

  late StreamSubscription<Duration> streamSubscription;

  @override
  void initState() {
    streamSubscription = widget.audioPlayer.bufferedPositionStream
        .listen(bufferedDurationListener);
    super.initState();
  }

  void bufferedDurationListener(Duration duration) {
    var audioDuration = widget.audioPlayer.duration ?? Duration.zero;
    bufferedPercentage = audioDuration.inSeconds == 0
        ? 0.0
        : (duration.inSeconds / audioDuration.inSeconds);
    setState(() {});
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.5),
        color: Theme.of(context).primaryColor.withOpacity(0.6),
      ),
      width: MediaQuery.of(context).size.width * bufferedPercentage,
      height: 5.0,
    );
  }
}

class CurrentDurationContainer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  CurrentDurationContainer({Key? key, required this.audioPlayer})
      : super(key: key);

  @override
  _CurrentDurationContainerState createState() =>
      _CurrentDurationContainerState();
}

class _CurrentDurationContainerState extends State<CurrentDurationContainer> {
  late StreamSubscription<Duration> currentAudioDurationStreamSubscription;
  late Duration currentDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    currentAudioDurationStreamSubscription =
        widget.audioPlayer.positionStream.listen(currentDurationListener);
  }

  void currentDurationListener(Duration duration) {
    setState(() {
      currentDuration = duration;
    });
  }

  @override
  void dispose() {
    currentAudioDurationStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      //decoration: BoxDecoration(border: Border.all()),
      width: MediaQuery.of(context).size.width * (0.1),
      child: Column(
        children: [
          Text(
            "${currentDuration.inSeconds}",
            style: TextStyle(
              color: Constants.white,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
    double additionalActiveTrackHeight = 0,
  }) {
    return Offset(offset.dx, offset.dy) &
        Size(parentBox.size.width, sliderTheme.trackHeight!);
  } //
}
