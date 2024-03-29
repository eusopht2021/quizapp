import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlockedLevelCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class LevelsScreen extends StatefulWidget {
  final String maxLevel;
  final String categoryId;
  final String? categoryName;
  const LevelsScreen(
      {Key? key,
      required this.maxLevel,
      required this.categoryId,
      required this.categoryName})
      : super(key: key);

  @override
  _LevelsScreenState createState() => _LevelsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<UnlockedLevelCubit>(
              create: (_) => UnlockedLevelCubit(QuizRepository()),
              child: LevelsScreen(
                maxLevel: arguments['maxLevel'],
                categoryId: arguments['categoryId'],
                categoryName: arguments['categoryName'],
              ),
            ));
  }
}

class _LevelsScreenState extends State<LevelsScreen> {
  @override
  void initState() {
    super.initState();
    getUnlockedLevelData();
  }

  void getUnlockedLevelData() {
    Future.delayed(Duration.zero, () {
      context.read<UnlockedLevelCubit>().fetchUnlockLevel(
            context.read<UserDetailsCubit>().getUserId(),
            widget.categoryId,
            "0",
          );
    });
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30, start: 20, end: 20),
      child: CustomBackButton(
        iconColor: Constants.white,
      ),
    );
  }

  Widget _buildLevels() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocConsumer<UnlockedLevelCubit, UnlockedLevelState>(
          bloc: context.read<UnlockedLevelCubit>(),
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
            if (state is UnlockedLevelInitial ||
                state is UnlockedLevelFetchInProgress) {
              return Center(
                child: CircularProgressIndicator(
                  color: Constants.white,
                ),
              );
            }
            if (state is UnlockedLevelFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: AppLocalization.of(context)!
                      .getTranslatedValues(
                          convertErrorCodeToLanguageKey(state.errorMessage))!,
                  onTapRetry: () {
                    getUnlockedLevelData();
                  },
                  showErrorImage: true,
                ),
              );
            }
            int unlockedLevel =
                (state as UnlockedLevelFetchSuccess).unlockedLevel;
            return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: int.parse(widget.maxLevel),
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
                          "categoryId": widget.categoryId,
                          "subcategoryId": "0",
                          "level": (index + 1).toString(),
                          "subcategoryMaxLevel": widget.maxLevel,
                          "unlockedLevel": unlockedLevel,
                          "contestId": "",
                          "comprehensionId": "",
                          "quizName": "Quiz Zone"
                        });
                      } else {
                        UiUtils.setSnackbar(
                            AppLocalization.of(context)!.getTranslatedValues(
                                convertErrorCodeToLanguageKey(
                                    levelLockedCode))!,
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
                        margin: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          "${AppLocalization.of(context)!.getTranslatedValues("levelLbl")!} ${index + 1}",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Constants.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }

  Widget _buildBannerAd() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BannerAdContainer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: widget.categoryName ?? "",
      backgroundColor: Theme.of(context).primaryColor,
      titleColor: Constants.white,
      child: Stack(
        children: <Widget>[
          // _buildBackButton(),
          _buildLevels(),
          _buildBannerAd(),
        ],
      ),
    );
  }
}
