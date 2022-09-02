import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/exam/models/examResult.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class ExamResultBottomSheetContainer extends StatelessWidget {
  final ExamResult examResult;
  const ExamResultBottomSheetContainer({Key? key, required this.examResult})
      : super(key: key);

  Widget _buildExamDetailsContainer(
      {required String title,
      required String examData,
      required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            width: MediaQuery.of(context).size.width * (0.4),
            height: 45,
            child: Text(
              "$title :",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Constants.primaryColor,
                fontSize: 17.0,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Constants.secondaryColor,
              borderRadius: BorderRadius.circular(25.0),
            ),
            height: 45,
            width: MediaQuery.of(context).size.width * (0.4),
            child: Text(
              examData,
              style: TextStyle(
                color: Constants.white,
                fontSize: 16.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuestionStatistic(
      {required String title,
      required BuildContext context,
      required int totalQuestion,
      required int correct,
      required int incorrect}) {
    return Container(
      height: MediaQuery.of(context).size.height * (0.2),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 10.0,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                color: Constants.primaryColor,
                fontSize: 20.0,
              ),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, boxConstraints) {
              final textStyle = TextStyle(
                color: Constants.primaryColor.withOpacity(0.7),
                height: 1.3,
              );
              return Container(
                decoration: BoxDecoration(
                  color: badgeLockedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Expanded(
                        child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width: boxConstraints.maxWidth * (0.32),
                            child: Text(
                              "${AppLocalization.of(context)!.getTranslatedValues(totalKey)!} \n ${AppLocalization.of(context)!.getTranslatedValues(questionsKey)!}",
                              style: textStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                left: BorderSide(
                                  width: 2,
                                  color:
                                      Constants.primaryColor.withOpacity(0.7),
                                ),
                                right: BorderSide(
                                  width: 2,
                                  color:
                                      Constants.primaryColor.withOpacity(0.7),
                                ),
                              )),
                              alignment: Alignment.center,
                              child: Text(
                                "${AppLocalization.of(context)!.getTranslatedValues(correctKey)!} \n ${AppLocalization.of(context)!.getTranslatedValues(questionsKey)!}",
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: boxConstraints.maxWidth * (0.36),
                            child: Text(
                              "${AppLocalization.of(context)!.getTranslatedValues(incorrectKey)!} \n ${AppLocalization.of(context)!.getTranslatedValues(questionsKey)!}",
                              style: textStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )),
                    SizedBox(
                      height: boxConstraints.maxHeight * (0.3),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Constants.primaryColor,
                              ),
                              width: boxConstraints.maxWidth * (0.32),
                              child: Text(
                                "$totalQuestion",
                                style: TextStyle(
                                    fontSize: 17.5, color: Constants.white),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.9)),
                              width: boxConstraints.maxWidth * (0.32),
                              child: Text(
                                "$correct",
                                style: TextStyle(
                                  fontSize: 17.5,
                                  color: Constants.white,
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.9)),
                              width: boxConstraints.maxWidth * (0.36),
                              child: Text(
                                "$incorrect",
                                style: TextStyle(
                                  color: Theme.of(context).backgroundColor,
                                  fontSize: 17.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * (0.85)),
      decoration: BoxDecoration(
        color: Constants.white,
        borderRadius: UiUtils.getBottomSheetRadius(),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * (0.075),
                  decoration: BoxDecoration(
                      color: Constants.primaryColor,
                      borderRadius: UiUtils.getBottomSheetRadius()),
                  child: Text(
                    AppLocalization.of(context)!
                        .getTranslatedValues(examResultKey)!,
                    style: TextStyle(color: Constants.white, fontSize: 20.0),
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                _buildExamDetailsContainer(
                    title: AppLocalization.of(context)!
                        .getTranslatedValues(obtainedMarksKey)!,
                    examData:
                        "${examResult.obtainedMarks()}/${examResult.totalMarks}",
                    context: context),
                const SizedBox(
                  height: 10.0,
                ),
                _buildExamDetailsContainer(
                    title: AppLocalization.of(context)!
                        .getTranslatedValues(examDurationKey)!,
                    examData: UiUtils.convertMinuteIntoHHMM(
                        int.parse(examResult.duration)),
                    context: context),
                const SizedBox(
                  height: 10.0,
                ),
                _buildExamDetailsContainer(
                    title: AppLocalization.of(context)!
                        .getTranslatedValues(completedInKey)!,
                    examData: UiUtils.convertMinuteIntoHHMM(
                        examResult.totalDuration.isNotEmpty
                            ? int.parse(examResult.totalDuration)
                            : 0),
                    context: context),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Divider(
                    thickness: 1.5,
                  ),
                ),
                _buildQuestionStatistic(
                    title: AppLocalization.of(context)!
                        .getTranslatedValues(totalQuestionsKey)!,
                    context: context,
                    totalQuestion: examResult.totalQuestions(),
                    correct: examResult.totalCorrectAnswers(),
                    incorrect: examResult.totalInCorrectAnswers()),
                ...examResult.getUniqueMarksOfQuestion().map((mark) {
                  return _buildQuestionStatistic(
                    context: context,
                    correct: examResult.totalCorrectAnswersByMark(mark),
                    totalQuestion: examResult.totalQuestionsByMark(mark),
                    incorrect: examResult.totalInCorrectAnswersByMark(mark),
                    title:
                        "$mark ${AppLocalization.of(context)!.getTranslatedValues(markKey)!} ${AppLocalization.of(context)!.getTranslatedValues(questionsKey)!}",
                  );
                }).toList(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.05),
                ),
              ],
            ),
          ),
          Positioned(
              top: -60.0,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: IconButton(
                      onPressed: () {
                        print("Something");
                        //Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close,
                        size: 40.0,
                        color: Theme.of(context).backgroundColor,
                      )))),
        ],
      ),
    );
  }
}
