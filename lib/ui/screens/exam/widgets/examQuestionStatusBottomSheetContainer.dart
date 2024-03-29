import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExamQuestionStatusBottomSheetContainer extends StatelessWidget {
  final PageController pageController;
  final Function navigateToResultScreen;
  const ExamQuestionStatusBottomSheetContainer(
      {Key? key,
      required this.pageController,
      required this.navigateToResultScreen})
      : super(key: key);

  Widget _buildQuestionAttemptedByMarksContainer(
      {required BuildContext context,
      required String questionMark,
      required List<Question> questions}) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (0.1)),
      child: Column(
        children: [
          Text(
            "$questionMark ${AppLocalization.of(context)!.getTranslatedValues(markKey)!} (${questions.length})",
            style: TextStyle(color: Constants.primaryColor, fontSize: 16.0),
          ),
          Divider(
            color: Constants.white,
          ),
          Wrap(
            children: List.generate(questions.length, (index) => index)
                .map((index) => hasQuestionAttemptedContainer(
                    attempted: questions[index].attempted,
                    context: context,
                    questionIndex: context
                        .read<ExamCubit>()
                        .getQuetionIndexById(questions[index].id!)))
                .toList(),
          ),
          Divider(
            color: Constants.primaryColor,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.02),
          ),
        ],
      ),
    );
  }

  Widget hasQuestionAttemptedContainer(
      {required int questionIndex,
      required bool attempted,
      required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        pageController.animateToPage(questionIndex,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut);
        Navigator.of(context).pop();
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        color: attempted ? Constants.primaryColor : Constants.secondaryColor,
        height: 30.0,
        width: 30.0,
        child: Text(
          "${questionIndex + 1}",
          style: TextStyle(color: Constants.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * (0.95),
      ),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          color: Constants.white),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Text(
                        "${AppLocalization.of(context)!.getTranslatedValues(totalQuestionsKey)!} : ${context.read<ExamCubit>().getQuestions().length}",
                        style: TextStyle(
                          color: Constants.primaryColor,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.close,
                          size: 28.0,
                          color: Constants.primaryColor,
                        )),
                  ),
                ),
              ],
            ),
            ...context
                .read<ExamCubit>()
                .getUniqueQuestionMark()
                .map((questionMark) {
              return _buildQuestionAttemptedByMarksContainer(
                context: context,
                questionMark: questionMark,
                questions:
                    context.read<ExamCubit>().getQuestionsByMark(questionMark),
              );
            }).toList(),
            Container(
              width: MediaQuery.of(context).size.width * (0.25),
              child: CustomRoundedButton(
                onTap: () {
                  navigateToResultScreen();
                },
                widthPercentage: MediaQuery.of(context).size.width,
                backgroundColor: Constants.primaryColor,
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
                    backgroundColor: Constants.primaryColor,
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
                        fontSize: 12.5, color: Constants.secondaryColor),
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
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.025),
            ),
          ],
        ),
      ),
    );
  }
}
