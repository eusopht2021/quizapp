import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlockedLevelCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/models/subcategory.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class NewLevelsScreen extends StatefulWidget {
  final String? category;
  const NewLevelsScreen({Key? key, this.category}) : super(key: key);

  @override
  State<NewLevelsScreen> createState() => _NewLevelsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<SubCategoryCubit>(
                  create: (_) => SubCategoryCubit(QuizRepository()),
                ),
                BlocProvider<UnlockedLevelCubit>(
                  create: (_) => UnlockedLevelCubit(QuizRepository()),
                ),
              ],
              child:
                  NewLevelsScreen(category: routeSettings.arguments as String?),
            ));
  }
}

class _NewLevelsScreenState extends State<NewLevelsScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }


  //  BlocConsumer<UnlockedLevelCubit,
  //                               UnlockedLevelState>(
  //                             listener: (context, state) {
  //                               if (state is UnlockedLevelFetchFailure) {
  //                                 if (state.errorMessage ==
  //                                     unauthorizedAccessCode) {
  //                                   //
  //                                   UiUtils.showAlreadyLoggedInDialog(
  //                                     context: context,
  //                                   );
  //                                 }
  //                               }
  //                             },
  //                             builder: (context, state) {
  //                               return AnimatedSwitcher(
  //                                 duration: const Duration(milliseconds: 500),
  //                                 child: _buildLevels(state, subCategoryList),
  //                               );
  //                             },





  Widget _buildLevels(
      UnlockedLevelState state, List<Subcategory> subcategoryList) {
    if (state is UnlockedLevelInitial) {
      return Container();
    }
    if (state is UnlockedLevelFetchInProgress) {
      return Center(
          child: CircularProgressIndicator(
        color: Constants.white,
      ));
    }
    if (state is UnlockedLevelFetchFailure) {
      return Center(
        child: ErrorContainer(
          errorMessage: AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(state.errorMessage)),
          topMargin: 0.0,
          onTapRetry: () {
            //fetch unlocked level for current selected subcategory
            context.read<UnlockedLevelCubit>().fetchUnlockLevel(
                context.read<UserDetailsCubit>().getUserId(),
                widget.category,
                subcategoryList[currentIndex].id);
          },
          showErrorImage: false,
        ),
      ); //
    }
    int unlockedLevel = (state as UnlockedLevelFetchSuccess).unlockedLevel;

    return ListView.builder(
        padding: const EdgeInsets.only(bottom: 50.0),
        itemCount: int.parse(subcategoryList[currentIndex].maxLevel!),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              //index start with 0 so we comparing (index + 1)
              if ((index + 1) <= unlockedLevel) {
                //replacing this page
                Navigator.of(context)
                    .pushReplacementNamed(Routes.quiz, arguments: {
                  "numberOfPlayer": 1,
                  "quizType": QuizTypes.quizZone,
                  "categoryId": "",
                  "subcategoryId": subcategoryList[currentIndex].id,
                  "level": (index + 1).toString(),
                  "subcategoryMaxLevel": subcategoryList[currentIndex].maxLevel,
                  "unlockedLevel": unlockedLevel,
                  "contestId": "",
                  "comprehensionId": "",
                  "quizName": "Quiz Zone"
                });
              } else {
                UiUtils.setSnackbar(
                    AppLocalization.of(context)!.getTranslatedValues(
                        convertErrorCodeToLanguageKey(levelLockedCode))!,
                    context,
                    false);
              }
            },
            child: Opacity(
              opacity: (index + 1) <= unlockedLevel ? 1.0 : 0.55,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Constants.secondaryColor,
                ),
                alignment: Alignment.center,
                height: 75.0,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: TitleText(
                  text:
                      "${AppLocalization.of(context)!.getTranslatedValues("levelLbl")!} ${index + 1}",
                  size: 20,
                  weight: FontWeight.bold,
                  textColor: Constants.white,
                ),
              ),
            ),
          );
        });
  }
}
