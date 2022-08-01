import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/rewardedAdCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/contestCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/customDialog.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/roomDialog.dart';
import 'package:flutterquiz/ui/widgets/custom_button.dart';
import 'package:flutterquiz/ui/widgets/social_button.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/ui/widgets/watchRewardAdDialog.dart';
import 'package:flutterquiz/utils/constants.dart';

import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class RandomOrPlayFrdDialog extends StatefulWidget {
  RandomOrPlayFrdDialog({Key? key}) : super(key: key);

  @override
  _RandomOrPlayFrdDialogState createState() => _RandomOrPlayFrdDialogState();
}

class _RandomOrPlayFrdDialogState extends State<RandomOrPlayFrdDialog> {
  static String _defaultSelectedCategoryValue = selectCategoryKey;
  String? selectedCategory = _defaultSelectedCategoryValue;
  String? selectedCategoryId = "";
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context.read<RewardedAdCubit>().createRewardedAd(context,
          onFbRewardAdCompleted: _addCoinsAfterRewardAd);
      if (context.read<SystemConfigCubit>().getIsCategoryEnableForBattle() ==
          "1") {
        context.read<QuizCategoryCubit>().getQuizCategory(
              languageId: UiUtils.getCurrentQuestionLanguageId(context),
              type: UiUtils.getCategoryTypeNumberFromQuizType(QuizTypes.battle),
              userId: context.read<UserDetailsCubit>().getUserId(),
            );
      }
    });
    super.initState();
  }

  // TextStyle _buildTextStyle() {
  //   return TextStyle(
  //     color: Theme.of(context).backgroundColor,
  //     fontSize: 16.0,
  //   );
  // }

  Widget topLabelDesign(BoxConstraints constraints) {
    return Container(
      height: constraints.maxHeight * (0.2),
      decoration: BoxDecoration(
          color: Constants.primaryColor,
          borderRadius: const BorderRadius.only(
              topRight: const Radius.circular(20),
              topLeft: const Radius.circular(20))),
      alignment: Alignment.center,
      child: TitleText(
        text: AppLocalization.of(context)!.getTranslatedValues("randomLbl")!,
        size: Constants.bodyXLarge,
        textColor: Constants.white,
        weight: FontWeight.w500,
      ),
    );
  }

  //using for category
  Widget _buildDropdown({
    required List<Map<String, String?>>
        values, //keys of value will be name and id
    required String keyValue, // need to have this keyValues for fade animation
  }) {
    return DropdownButton<String>(
        key: Key(keyValue),
        borderRadius: BorderRadius.circular(20),
        dropdownColor: Theme.of(context).canvasColor,
        // dropdownColor: Constants.primaryColor,
        // //same as background of dropdown color
        style: TextStyle(color: Constants.white, fontSize: 16.0),
        isExpanded: true,
        iconEnabledColor: Theme.of(context).primaryColor,
        // iconEnabledColor: Constants.primaryColor,
        onChanged: (value) {
          setState(() {
            selectedCategory = value!;
            selectedCategoryId = values
                .where((element) => element['name']! == value)
                .toList()
                .first['id'];
          });
        },
        underline: const SizedBox(),
        //values is map of name and id. only passing name to dropdown
        items: values.map((e) => e['name']).toList().map((name) {
          return DropdownMenuItem(
            value: name,
            child: name! == selectCategoryKey
                ? TitleText(
                    text:
                        AppLocalization.of(context)!.getTranslatedValues(name)!,
                    size: Constants.bodyXLarge,
                    textColor: Constants.white,
                    weight: FontWeight.w500,
                  )
                : TitleText(
                    text: name,
                    size: Constants.bodyXLarge,
                    textColor: Constants.white,
                    weight: FontWeight.w500,
                  ),
          );
        }).toList(),
        value: selectedCategory);
  }

  Widget _buildDropDownContainer(BoxConstraints constraints) {
    return context.read<SystemConfigCubit>().getIsCategoryEnableForBattle() ==
            "1"
        ? Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            margin:
                EdgeInsets.symmetric(horizontal: constraints.maxWidth * (0.05)),
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                // color: Constants.primaryColor,
                borderRadius: BorderRadius.circular(25.0)),
            height: constraints.maxHeight * (0.115),
            child: BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
                bloc: context.read<QuizCategoryCubit>(),
                listener: (context, state) {
                  if (state is QuizCategorySuccess) {
                    setState(() {
                      selectedCategory = state.categories.first.categoryName;
                      selectedCategoryId = state.categories.first.id;
                    });
                  }

                  if (state is QuizCategoryFailure) {
                    if (state.errorMessage == unauthorizedAccessCode) {
                      //
                      UiUtils.showAlreadyLoggedInDialog(
                        context: context,
                      );
                      return;
                    }
                    showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                    //context.read<QuizCategoryCubit>().getQuizCategory(UiUtils.getCurrentQuestionLanguageId(context), "");
                                  },
                                  child: Text(
                                    AppLocalization.of(context)!
                                        .getTranslatedValues(retryLbl)!,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              ],
                              content: Text(AppLocalization.of(context)!
                                  .getTranslatedValues(
                                      convertErrorCodeToLanguageKey(
                                          state.errorMessage))!),
                            )).then((value) {
                      if (value != null && value) {
                        context.read<QuizCategoryCubit>().getQuizCategory(
                              languageId:
                                  UiUtils.getCurrentQuestionLanguageId(context),
                              type: UiUtils.getCategoryTypeNumberFromQuizType(
                                  QuizTypes.battle),
                              userId:
                                  context.read<UserDetailsCubit>().getUserId(),
                            );
                      }
                    });
                  }
                },
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: state is QuizCategorySuccess
                        ? _buildDropdown(
                            values: state.categories
                                .map(
                                    (e) => {"name": e.categoryName, "id": e.id})
                                .toList(),
                            keyValue: "selectCategorySuccess")
                        : Opacity(
                            opacity: 0.65,
                            child: _buildDropdown(values: [
                              {"name": selectCategoryKey, "id": "0"}
                            ], keyValue: "selectCategory"),
                          ),
                  );
                }),
          )
        : Container();
  }

  Widget entryFee() {
    return Container(
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary, fontSize: 18),
            children: <TextSpan>[
              TextSpan(
                  text: AppLocalization.of(context)!
                      .getTranslatedValues("entryFeesLbl")!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary)),
              TextSpan(
                  text: ' $randomBattleEntryCoins ',
                  style: TextStyle(
                      color: Constants.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              TextSpan(
                  text: AppLocalization.of(context)!
                      .getTranslatedValues("coinsLbl")!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary)),
            ],
          ),
        ));
  }

  Widget currentCoin(BoxConstraints constraints) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth * (0.1)),
      decoration: BoxDecoration(
          color: Constants.primaryColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25.0)),
      height: constraints.maxHeight * (0.135),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${AppLocalization.of(context)!.getTranslatedValues(currentCoinsKey)!}:  ",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.75),
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          BlocBuilder<UserDetailsCubit, UserDetailsState>(
            bloc: context.read<UserDetailsCubit>(),
            builder: (context, state) {
              if (state is UserDetailsFetchSuccess) {
                return Text(
                  context.read<UserDetailsCubit>().getCoins()!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }

              return Container();
            },
          ),
        ],
      ),
    );
  }

  void _addCoinsAfterRewardAd() {
    //ad rewards here
    //once user sees ad then add coins to user wallet
    context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: lifeLineDeductCoins,
        );

    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
        context.read<UserDetailsCubit>().getUserId(),
        lifeLineDeductCoins,
        true,
        watchedRewardAdKey);
  }

  Widget letsGoButton(BoxConstraints boxConstraints) {
    return Container(
      alignment: Alignment.center,
      child: CustomButton(
        onPressed: () {
          UserProfile userProfile =
              context.read<UserDetailsCubit>().getUserProfile();
          if (int.parse(userProfile.coins!) < randomBattleEntryCoins) {
            //if ad not loaded than show not enough coins
            if (context.read<RewardedAdCubit>().state is! RewardedAdLoaded) {
              UiUtils.errorMessageDialog(
                  context,
                  AppLocalization.of(context)!.getTranslatedValues(
                      convertErrorCodeToLanguageKey(notEnoughCoinsCode))!);
              return;
            }

            showDialog(
                context: context,
                builder: (_) => WatchRewardAdDialog(onTapYesButton: () {
                      //showAd
                      context.read<RewardedAdCubit>().showAd(
                          context: context,
                          onAdDismissedCallback: _addCoinsAfterRewardAd);
                    }));
            return;
          }
          if (selectedCategory == _defaultSelectedCategoryValue &&
              context
                      .read<SystemConfigCubit>()
                      .getIsCategoryEnableForBattle() ==
                  "1") {
            UiUtils.errorMessageDialog(
                context,
                AppLocalization.of(context)!
                    .getTranslatedValues(pleaseSelectCategoryKey)!);
            return;
          }

          Navigator.of(context).pushReplacementNamed(
              Routes.battleRoomFindOpponent,
              arguments: selectedCategoryId);
        },
        text: AppLocalization.of(context)!.getTranslatedValues("letsPlay")!,
        // style: _buildTextStyle(),
      ),
    );
  }

  Widget playWithFrdBtn(BoxConstraints constraints) {
    return Container(
      alignment: Alignment.center,
      child: SocialButton(
        showBorder: true,
        textColor: Constants.white,
        onTap: () async {
          Navigator.of(context).pop();

          showDialog(
            context: context,
            builder: (context) => MultiBlocProvider(providers: [
              BlocProvider<QuizCategoryCubit>(
                  create: (_) => QuizCategoryCubit(QuizRepository())),
              BlocProvider<UpdateScoreAndCoinsCubit>(
                  create: (_) =>
                      UpdateScoreAndCoinsCubit(ProfileManagementRepository())),
            ], child: RoomDialog(quizType: QuizTypes.battle)),
          );
        },
        text:
            AppLocalization.of(context)!.getTranslatedValues("playWithFrdLbl")!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      showbackButton: true,
      topPadding: MediaQuery.of(context).size.height * (0.15),
      height: MediaQuery.of(context).size.height * (0.6),
      child: BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
        listener: (context, state) {
          if (state is UpdateScoreAndCoinsFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              UiUtils.showAlreadyLoggedInDialog(context: context);
            }
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Constants.cardsRadius),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                color: Constants.primaryColor,
                child: Column(
                  children: [
                    CustomPaint(
                      painter: CurvePainter(
                          color: Theme.of(context).backgroundColor),
                      child: Container(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight * (0.74),
                        child: LayoutBuilder(builder: (context, constraints) {
                          return Column(
                            children: [
                              topLabelDesign(constraints),
                              SizedBox(
                                height: constraints.maxHeight * (0.075),
                              ),
                              _buildDropDownContainer(constraints),
                              SizedBox(
                                height: constraints.maxHeight * (0.075),
                              ),
                              entryFee(),
                              SizedBox(
                                height: constraints.maxHeight * (0.075),
                              ),
                              currentCoin(constraints),
                              SizedBox(
                                height: constraints.maxHeight * (0.075),
                              ),
                              letsGoButton(constraints),
                            ],
                          );
                        }),
                      ),
                    ),
                    const Spacer(),
                    playWithFrdBtn(constraints),
                    SizedBox(
                      height: constraints.maxHeight * (0.025),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final Color color;
  CurvePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill; // Change this to fill
    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.quadraticBezierTo(
        size.width * (0.5), size.height * (1.25), 0, size.height);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
