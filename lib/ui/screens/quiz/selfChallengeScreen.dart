import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';

import 'dart:math' as math;

import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/roundedAppbar.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class SelfChallengeScreen extends StatefulWidget {
  SelfChallengeScreen({Key? key}) : super(key: key);

  @override
  _SelfChallengeScreenState createState() => _SelfChallengeScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => SelfChallengeScreen());
  }
}

class _SelfChallengeScreenState extends State<SelfChallengeScreen> {
  static String _defaultSelectedCategoryValue = selectCategoryKey;
  static String _defaultSelectedSubcategoryValue = selectSubCategoryKey;

  //to display category and suncategory
  String? selectedCategory = _defaultSelectedCategoryValue;
  String? selectedSubcategory = _defaultSelectedSubcategoryValue;

  //id to pass for selfChallengeQuestionsScreen
  String? selectedCategoryId = "";
  String? selectedSubcategoryId = "";

  //minutes for self challenge
  int? selectedMinutes;

  //nunber of questions
  int? selectedNumberOfQuestions;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      context.read<QuizCategoryCubit>().getQuizCategory(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: UiUtils.getCategoryTypeNumberFromQuizType(
                QuizTypes.selfChallenge),
            userId: context.read<UserDetailsCubit>().getUserId(),
          );
    });
  }

  void startSelfChallenge() {
    //
    if (context.read<SubCategoryCubit>().state is SubCategoryFetchFailure) {
      //If there is not any sub category then fetch the all quesitons from given category
      if ((context.read<SubCategoryCubit>().state as SubCategoryFetchFailure)
              .errorMessage ==
          "102") {
        //

        if (selectedCategory != _defaultSelectedCategoryValue &&
            selectedMinutes != null &&
            selectedNumberOfQuestions != null) {
          //to see what keys to pass in arguments see static function route of SelfChallengeQuesitonsScreen

          print("Get questions");
          Navigator.of(context)
              .pushNamed(Routes.selfChallengeQuestions, arguments: {
            "numberOfQuestions": selectedNumberOfQuestions.toString(),
            "categoryId": selectedCategoryId, //
            "minutes": selectedMinutes,
            "subcategoryId": "",
          });
          return;
        } else {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          UiUtils.setSnackbar(
              AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(selectAllValuesCode))!,
              context,
              false);
          return;
        }
      }
    }

    if (selectedCategory != _defaultSelectedCategoryValue &&
        selectedSubcategory != _defaultSelectedSubcategoryValue &&
        selectedMinutes != null &&
        selectedNumberOfQuestions != null) {
      //to see what keys to pass in arguments see static function route of SelfChallengeQuesitonsScreen

      print("Get questions");
      Navigator.of(context)
          .pushNamed(Routes.selfChallengeQuestions, arguments: {
        "numberOfQuestions": selectedNumberOfQuestions.toString(),
        "categoryId": "", //catetoryId
        "minutes": selectedMinutes,
        "subcategoryId": selectedSubcategoryId,
      });
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      UiUtils.setSnackbar(
          AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(selectAllValuesCode))!,
          context,
          false);
    }
  }

  Widget _buildDropdownIcon() {
    return Transform.rotate(
      angle: math.pi / 2,
      child: Icon(
        Icons.arrow_forward_ios,
        size: 20,
        color: Constants.white,
      ),
    );
  }

  //using for category and subcategory
  Widget _buildDropdown({
    required bool forCategory,
    required List<Map<String, String?>>
        values, //keys of value will be name and id
    required String keyValue, // need to have this keyValues for fade animation
  }) {
    return DropdownButton<String>(
        key: Key(keyValue),
        dropdownColor:
            Theme.of(context).primaryColor, //same as background of dropdown color
        style: TextStyle(color: Constants.white, fontSize: 16.0),
        isExpanded: true,
        onChanged: (value) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          if (!forCategory) {
            // if it's for subcategory

            //if no subcategory selected then do nothing
            if (value != _defaultSelectedSubcategoryValue) {
              int index =
                  values.indexWhere((element) => element['name'] == value);
              setState(() {
                selectedSubcategory = value;
                selectedSubcategoryId = values[index]['id'];
              });
            }
          } else {
            //if no category selected then do nothing
            if (value != _defaultSelectedCategoryValue) {
              int index =
                  values.indexWhere((element) => element['name'] == value);
              setState(() {
                selectedCategory = value;
                selectedCategoryId = values[index]['id'];
                selectedSubcategory = _defaultSelectedSubcategoryValue; //
              });

              context.read<SubCategoryCubit>().fetchSubCategory(
                    selectedCategoryId!,
                    context.read<UserDetailsCubit>().getUserId(),
                  );
            } else {
              context.read<QuizCategoryCubit>().getQuizCategory(
                    languageId: UiUtils.getCurrentQuestionLanguageId(context),
                    type: UiUtils.getCategoryTypeNumberFromQuizType(
                        QuizTypes.selfChallenge),
                    userId: context.read<UserDetailsCubit>().getUserId(),
                  );
            }
          }
        },
        icon: _buildDropdownIcon(),
        underline: const SizedBox(),
        //values is map of name and id. only passing name to dropdown
        items: values.map((e) => e['name']).toList().map((name) {
          return DropdownMenuItem(
            value: name,
            child: name! == selectCategoryKey || name == selectSubCategoryKey
                ? Text(AppLocalization.of(context)!.getTranslatedValues(name)!)
                : Text(name),
          );
        }).toList(),
        value: forCategory ? selectedCategory : selectedSubcategory);
  }

  //dropdown container with border
  Widget _buildDropdownContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * (0.8),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10.0)),
      child: child,
    );
  }

  //for selecting time and question
  Widget _buildSelectTimeAndQuestionContainer(
      {bool? forSelectQuestion,
      int? value,
      Color? textColor,
      Color? backgroundColor,
      required Color borderColor}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (forSelectQuestion!) {
            selectedNumberOfQuestions = value;
          } else {
            selectedMinutes = value;
          }
        });
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 10.0),
        height: 30.0,
        width: 45.0,
        child: Text(
          "$value",
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.w500, fontSize: 18),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Widget _buildTitleContainer(String title) {
    return Container(
      width: MediaQuery.of(context).size.width * (0.8),
      alignment: Alignment.centerLeft,
      child: Text(
        "$title",
        style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            color: Constants.white),
      ),
    );
  }

  Widget _buildAppbar() {
    return Align(
      alignment: Alignment.topCenter,
      child: RoundedAppbar(
        appBarColor: Theme.of(context).primaryColor,
        appTextAndIconColor: Constants.white,
        removeSnackBars: true,
        title:
            AppLocalization.of(context)!.getTranslatedValues("selfChallenge")!,
      ),
    );
  }

  Widget _buildSubCategoryDropdownContainer(SubCategoryState state) {
    if (state is SubCategoryFetchSuccess) {
      return _buildDropdown(
          forCategory: false,
          values: state.subcategoryList
              .map((e) => {"name": e.subcategoryName, "id": e.id})
              .toList(),
          keyValue: "selectSubcategorySuccess${state.categoryId}");
    }

    return Opacity(
      opacity: 0.75,
      child: _buildDropdown(
          forCategory: false,
          values: [
            {"name": _defaultSelectedSubcategoryValue}
          ],
          keyValue: "selectSubcategory"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        //await Future.delayed(Duration.zero);
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Constants.white,
        body: Stack(
          children: [
            // const PageBackgroundGradientContainer(),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * (0.15)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 35.0, bottom: 25.0),
                  child: Column(
                    children: [
                      //to build category dropdown
                      BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
                        bloc: context.read<QuizCategoryCubit>(),
                        listener: (context, state) {
                          if (state is QuizCategorySuccess) {
                            setState(() {
                              selectedCategory =
                                  state.categories.first.categoryName;
                              selectedCategoryId = state.categories.first.id;
                            });
                            context.read<SubCategoryCubit>().fetchSubCategory(
                                  state.categories.first.id!,
                                  context.read<UserDetailsCubit>().getUserId(),
                                );
                          }
                          if (state is QuizCategoryFailure) {
                            if (state.errorMessage == unauthorizedAccessCode) {
                              //
                              UiUtils.showAlreadyLoggedInDialog(
                                context: context,
                              );
                              return;
                            }

                            UiUtils.setSnackbar(
                                AppLocalization.of(context)!
                                    .getTranslatedValues(
                                        convertErrorCodeToLanguageKey(
                                            state.errorMessage))!,
                                context,
                                true,
                                duration: const Duration(days: 365),
                                onPressedAction: () {
                              //to get categories
                              context.read<QuizCategoryCubit>().getQuizCategory(
                                    languageId:
                                        UiUtils.getCurrentQuestionLanguageId(
                                            context),
                                    type: UiUtils
                                        .getCategoryTypeNumberFromQuizType(
                                            QuizTypes.selfChallenge),
                                    userId: context
                                        .read<UserDetailsCubit>()
                                        .getUserId(),
                                  );
                            });
                          }
                        },
                        builder: (context, state) {
                          return _buildDropdownContainer(AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: state is QuizCategorySuccess
                                ? _buildDropdown(
                                    forCategory: true,
                                    values: state.categories
                                        .map((e) => {
                                              "name": e.categoryName,
                                              "id": e.id
                                            })
                                        .toList(),
                                    keyValue: "selectCategorySuccess")
                                : Opacity(
                                    opacity: 0.75,
                                    child: _buildDropdown(
                                        forCategory: true,
                                        values: [
                                          {
                                            "name":
                                                _defaultSelectedCategoryValue,
                                            "id": "0"
                                          }
                                        ],
                                        keyValue: "selectCategory"),
                                  ),
                          ));
                        },
                      ),

                      //to build sub category dropdown
                      BlocConsumer<SubCategoryCubit, SubCategoryState>(
                        bloc: context.read<SubCategoryCubit>(),
                        listener: (context, state) {
                          if (state is SubCategoryFetchSuccess) {
                            setState(() {
                              selectedSubcategory =
                                  state.subcategoryList.first.subcategoryName;
                              selectedSubcategoryId =
                                  state.subcategoryList.first.id;
                            });
                          } else if (state is SubCategoryFetchFailure) {
                            if (state.errorMessage == unauthorizedAccessCode) {
                              //
                              UiUtils.showAlreadyLoggedInDialog(
                                context: context,
                              );
                              return;
                            }
                            if (state.errorMessage == "102") {
                              //
                              return;
                            }

                            UiUtils.setSnackbar(
                                AppLocalization.of(context)!
                                    .getTranslatedValues(
                                        convertErrorCodeToLanguageKey(
                                            state.errorMessage))!,
                                context,
                                true,
                                duration: const Duration(days: 365),
                                onPressedAction: () {
                              //load subcategory again
                              context.read<SubCategoryCubit>().fetchSubCategory(
                                    selectedCategoryId!,
                                    context
                                        .read<UserDetailsCubit>()
                                        .getUserId(),
                                  );
                            });
                          }
                        },
                        builder: (context, state) {
                          if (state is SubCategoryFetchFailure) {
                            //if there is no subcategory then show empty sized box
                            if (state.errorMessage == "102") {
                              return const SizedBox();
                            }
                          }
                          return Column(
                            children: [
                              const SizedBox(
                                height: 25,
                              ),
                              _buildDropdownContainer(AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child:
                                    _buildSubCategoryDropdownContainer(state),
                              )),
                            ],
                          );
                        },
                      ),

                      const SizedBox(
                        height: 25.0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Theme.of(context).primaryColor,
                        ),
                        padding: const EdgeInsets.all(10.0),
                        width: MediaQuery.of(context).size.width * (0.8),
                        child: Column(
                          children: [
                            _buildTitleContainer(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("selectNoQusLbl")!,
                            ),
                            const SizedBox(
                              height: 25.0,
                            ),
                            SizedBox(
                              height: 50,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: List.generate(
                                        10, (index) => (index + 1) * 5)
                                    .map((e) =>
                                        _buildSelectTimeAndQuestionContainer(
                                          forSelectQuestion: true,
                                          value: e,
                                          borderColor:
                                              selectedNumberOfQuestions == e
                                                  ? Theme.of(context).primaryColor
                                                  : Constants.white,
                                          backgroundColor:
                                              selectedNumberOfQuestions == e
                                                  ? Constants.white
                                                  : Constants.secondaryColor,
                                          textColor:
                                              selectedNumberOfQuestions == e
                                                  ? Theme.of(context).primaryColor
                                                  : Constants.white,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 25.0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Theme.of(context).primaryColor,
                        ),
                        padding: const EdgeInsets.all(10.0),
                        width: MediaQuery.of(context).size.width * (0.8),
                        child: Column(
                          children: [
                            _buildTitleContainer(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("selectTimeLbl")!,
                            ),
                            const SizedBox(
                              height: 25.0,
                            ),
                            SizedBox(
                              height: 50,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: List.generate(
                                        selfChallengeMaxMinutes ~/ 3,
                                        (index) => (index + 1) * 3)
                                    .map((e) =>
                                        _buildSelectTimeAndQuestionContainer(
                                            forSelectQuestion: false,
                                            value: e,
                                            backgroundColor:
                                                selectedMinutes == e
                                                    ? Constants.white
                                                    : Constants.secondaryColor,
                                            textColor: selectedMinutes == e
                                                ? Theme.of(context).primaryColor
                                                : Constants.white,
                                            borderColor: selectedMinutes == e
                                                ? Theme.of(context).primaryColor
                                                : Constants.white))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      CustomRoundedButton(
                        elevation: 5.0,
                        borderColor: Theme.of(context).primaryColor,
                        widthPercentage: 0.3,
                        backgroundColor: Theme.of(context).primaryColor,
                        buttonTitle: AppLocalization.of(context)!
                            .getTranslatedValues("startLbl")!
                            .toUpperCase(),
                        fontWeight: FontWeight.bold,
                        radius: 5.0,
                        onTap: () {
                          startSelfChallenge();
                        },
                        showBorder: false,
                        titleColor: Constants.white,
                        shadowColor: Theme.of(context).primaryColor,
                        height: 40,
                      )
                    ],
                  ),
                ),
              ),
            ),
            _buildAppbar()
          ],
        ),
      ),
    );
  }
}
