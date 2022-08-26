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
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/style_properties.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class NewLevelsScreen extends StatefulWidget {
  final String? categoryName;
  final String? category;
  final String? levels;
  final int? index;
  final List<Subcategory>? subcategory;

  const NewLevelsScreen(
      {Key? key,
      this.categoryName,
      this.category,
      this.levels,
      this.index,
      this.subcategory})
      : super(key: key);

  @override
  State<NewLevelsScreen> createState() => _NewLevelsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
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
              child: NewLevelsScreen(
                categoryName: arguments['categoryName'],
                category: arguments['category'],
                levels: arguments['levels'],
                subcategory: arguments['subcategory'],
                index: arguments['index'],
              ),
            ));
  }
}

class _NewLevelsScreenState extends State<NewLevelsScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      titleColor: Constants.white,
      backgroundColor: Constants.primaryColor,
      title: widget.categoryName ?? "",
      child: BlocConsumer<UnlockedLevelCubit, UnlockedLevelState>(
          listener: (context, state) {
        if (state is UnlockedLevelFetchFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            //
            UiUtils.showAlreadyLoggedInDialog(
              context: context,
            );
          }
        }
      }, builder: (context, state) {
        return levelBoxes();
      }),
    );
  }

  Widget levelBoxes() {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: StyleProperties.cardsRadius,
            color: Constants.grey5,
          ),
          child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              childrenPadding: const EdgeInsets.all(8),
              iconColor: Constants.primaryColor,
              textColor: Constants.primaryColor,
              collapsedTextColor: Constants.primaryColor,
              collapsedIconColor: Constants.primaryColor,
              title: TitleText(
                text:
                    "${AppLocalization.of(context)!.getTranslatedValues("levelLbl")!} ",
                textColor: Constants.primaryColor,
                size: Constants.bodyXLarge,
                weight: FontWeight.w500,
              ),
              children: [
                BlocConsumer<UnlockedLevelCubit, UnlockedLevelState>(
                  listener: (context, state) {
                    if (state is UnlockedLevelFetchFailure) {
                      if (state.errorMessage == unauthorizedAccessCode) {
                        //
                        UiUtils.showAlreadyLoggedInDialog(
                          context: context,
                        );
                      }
                    }
                  },
                  builder: (context, state) {
                    return _buildLevels(state, widget.subcategory!);
                  },
                ),
              ],
              onExpansionChanged: (value) {
                context.read<UnlockedLevelCubit>().fetchUnlockLevel(
                    context.read<UserDetailsCubit>().getUserId(),
                    widget.category,
                    widget.subcategory![currentIndex].id);
              }),
        ),
      ),
    );
  }

  Widget _buildLevels(
      UnlockedLevelState state, List<Subcategory> subcategoryList) {
    if (state is UnlockedLevelInitial) {
      return Container();
    }
    if (state is UnlockedLevelFetchInProgress) {
      return Center(
          child: CircularProgressIndicator(
        color: Constants.primaryColor,
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

    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisExtent: 80,
          crossAxisCount: 4,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        shrinkWrap: true,
        padding: const EdgeInsets.all(10),
        itemCount: int.parse(widget.levels!),
        itemBuilder: (context, index) {
          currentIndex = widget.index!; //levels
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
              child: CircleAvatar(
                  backgroundColor: Constants.primaryColor,
                  child: Center(
                    child: TitleText(
                      text: "${index + 1}",
                      textColor: Constants.white,
                      size: 30,
                    ),
                  )),
              // ),
            ),
          );
        });
  }
}
