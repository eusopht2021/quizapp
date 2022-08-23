import 'package:flutter/material.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/ui/widgets/pie_chart.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class HorizontalTimerContainer extends StatelessWidget {
  final QuizTypes quizTypes;
  final AnimationController timerAnimationController;
  int? duration;

  HorizontalTimerContainer({
    Key? key,
    required this.timerAnimationController,
    required this.quizTypes,
    this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Container(
        //   decoration: BoxDecoration(
        //     color: Theme.of(context).primaryColor,
        //     borderRadius: BorderRadius.all(
        //       Radius.circular(
        //         10,
        //       ),
        //     ),
        //   ),
        //   alignment: Alignment.topRight,
        //   height: 10.0,
        //   width: MediaQuery.of(context).size.width *
        //       (UiUtils.quesitonContainerWidthPercentage - 0.1),
        // ),
        AnimatedBuilder(
          animation: timerAnimationController,
          builder: (context, child) {
            return SizedBox(
              height: 64,
              width: 64,
              child: CustomPieChart(
                text: getRemainingTime(),
                value1: 100 - (timerAnimationController.value * 100),
                value2: timerAnimationController.value * 100,
                radius: 35,
                mainColor: timerAnimationController.value >= 0.8
                    ? Colors.red
                    : Constants.lightGreen,
              ),
            );
            // return Container(
            //   decoration: BoxDecoration(
            //       color: timerAnimationController.value >= 0.8
            //           ? hurryUpTimerColor
            //           : Theme.of(context).colorScheme.secondary,
            //       borderRadius: const BorderRadius.all(Radius.circular(10))),
            //   alignment: Alignment.topRight,
            //   height: 10.0,
            //   width: MediaQuery.of(context).size.width *
            //       (UiUtils.quesitonContainerWidthPercentage - 0.1) *
            //       (1.0 - timerAnimationController.value),
            // );
          },
        ),
      ],
    );
  }

  String getRemainingTime() {
    double percentRemaining = timerAnimationController.value;
    const int questionDurationInSeconds = 15;
    const int guessTheWordQuestionDurationInSeconds = 45;
    const int latexQuestionDurationInSeconds = 60;
    int totalSeconds = 0;
    if (quizTypes == QuizTypes.mathMania) {
      totalSeconds = latexQuestionDurationInSeconds;
    } else if (quizTypes == QuizTypes.guessTheWord) {
      totalSeconds = guessTheWordQuestionDurationInSeconds;
    } else {
      totalSeconds = questionDurationInSeconds;
    }
    totalSeconds = totalSeconds - (totalSeconds * percentRemaining).toInt();
    return totalSeconds.toString();
  }
}
