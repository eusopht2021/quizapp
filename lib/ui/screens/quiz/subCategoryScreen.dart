import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/screens/home/widgets/new_quiz_category_card.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/custom_card.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class SubCategoryScreen extends StatefulWidget {
  final String categoryId;
  final QuizTypes quizType;
  final String? subcategoryTitle;
  const SubCategoryScreen(
      {Key? key,
      required this.categoryId,
      required this.quizType,
      this.subcategoryTitle})
      : super(key: key);

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => SubCategoryScreen(
              categoryId: arguments['categoryId'],
              quizType: arguments['quizType'],
              subcategoryTitle: arguments['subcategoryTitle'],
            ));
  }
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  void getSubCategory() {
    Future.delayed(Duration.zero, () {
      context.read<SubCategoryCubit>().fetchSubCategory(
            widget.categoryId,
            context.read<UserDetailsCubit>().getUserId(),
          );
    });
  }

  @override
  void initState() {
    super.initState();
    getSubCategory();
  }

  Widget _buildBackButton() {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 15.0, start: 20),
        child: CustomBackButton(
          iconColor: Constants.white,
        ),
      ),
    );
  }

  Widget _buildSubCategory() {
    return BlocConsumer<SubCategoryCubit, SubCategoryState>(
        bloc: context.read<SubCategoryCubit>(),
        listener: (context, state) {
          if (state is SubCategoryFetchFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              //
              UiUtils.showAlreadyLoggedInDialog(
                context: context,
              );
            }
          }
        },
        builder: (context, state) {
          if (state is SubCategoryFetchInProgress ||
              state is SubCategoryInitial) {
            return Center(
              child: CircularProgressIndicator(
                color: Constants.white,
              ),
            );
          }
          if (state is SubCategoryFetchFailure) {
            return Center(
              child: ErrorContainer(
                showBackButton: false,
                errorMessageColor: Theme.of(context).primaryColor,
                showErrorImage: true,
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage),
                ),
                onTapRetry: () {
                  getSubCategory();
                },
              ),
            );
          }
          final subCategoryList =
              (state as SubCategoryFetchSuccess).subcategoryList;
          return Align(
            alignment: Alignment.topCenter,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                bottom: 50,
              ),
              shrinkWrap: true,
              itemCount: subCategoryList.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return QuizCategoryCard(
                  asset: "",
                  horizontalMargin: 8,
                  name: subCategoryList[index].subcategoryName!,
                  category: "",
                  onTap: () {
                    if (widget.quizType == QuizTypes.guessTheWord) {
                      Navigator.of(context)
                          .pushNamed(Routes.guessTheWord, arguments: {
                        "type": "subcategory",
                        "typeId": subCategoryList[index].id,
                        "isPlayed": subCategoryList[index].isPlayed,
                      });
                    } else if (widget.quizType == QuizTypes.funAndLearn) {
                      Navigator.of(context)
                          .pushNamed(Routes.funAndLearnTitle, arguments: {
                        "type": "subcategory",
                        "typeId": subCategoryList[index].id,
                      });
                    } else if (widget.quizType == QuizTypes.audioQuestions) {
                      //
                      Navigator.of(context).pushNamed(Routes.quiz, arguments: {
                        "numberOfPlayer": 1,
                        "quizType": QuizTypes.audioQuestions,
                        "subcategoryId": subCategoryList[index].id,
                        "isPlayed": subCategoryList[index].isPlayed,
                      });
                    } else if (widget.quizType == QuizTypes.mathMania) {
                      //
                      Navigator.of(context).pushNamed(Routes.quiz, arguments: {
                        "numberOfPlayer": 1,
                        "quizType": QuizTypes.mathMania,
                        "subcategoryId": subCategoryList[index].id,
                        "isPlayed": subCategoryList[index].isPlayed,
                      });
                    }
                  },
                );

                // Container(
                //     height: 90,
                //     alignment: Alignment.center,
                //     margin: const EdgeInsets.all(15),
                //     decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(20.0),
                //         color: Constants.secondaryColor),
                //     child: ListTile(
                //       onTap: () {
                //         if (widget.quizType == QuizTypes.guessTheWord) {
                //           Navigator.of(context)
                //               .pushNamed(Routes.guessTheWord, arguments: {
                //             "type": "subcategory",
                //             "typeId": subCategoryList[index].id,
                //             "isPlayed": subCategoryList[index].isPlayed,
                //           });
                //         } else if (widget.quizType == QuizTypes.funAndLearn) {
                //           Navigator.of(context)
                //               .pushNamed(Routes.funAndLearnTitle, arguments: {
                //             "type": "subcategory",
                //             "typeId": subCategoryList[index].id,
                //           });
                //         } else if (widget.quizType ==
                //             QuizTypes.audioQuestions) {
                //           //
                //           Navigator.of(context)
                //               .pushNamed(Routes.quiz, arguments: {
                //             "numberOfPlayer": 1,
                //             "quizType": QuizTypes.audioQuestions,
                //             "subcategoryId": subCategoryList[index].id,
                //             "isPlayed": subCategoryList[index].isPlayed,
                //           });
                //         } else if (widget.quizType == QuizTypes.mathMania) {
                //           //
                //           Navigator.of(context)
                //               .pushNamed(Routes.quiz, arguments: {
                //             "numberOfPlayer": 1,
                //             "quizType": QuizTypes.mathMania,
                //             "subcategoryId": subCategoryList[index].id,
                //             "isPlayed": subCategoryList[index].isPlayed,
                //           });
                //         }
                //       },
                //       trailing: Icon(
                //         Icons.navigate_next_outlined,
                //         size: 40,
                //         color: Constants.white,
                //       ),
                //       title: Text(
                //         subCategoryList[index].subcategoryName!,
                //         style: TextStyle(
                //           color: Constants.white,
                //         ),
                //       ),
                //     ));
              },
            ),
          );
        });
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
      title: widget.subcategoryTitle ?? "",
      showBackButton: true,
      titleColor: Constants.white,
      backgroundColor: Constants.primaryColor,
      child: CustomCard(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
          ),
          child: Stack(
            children: [
              _buildSubCategory(),
              // _buildBackButton(),
              _buildBannerAd(),
            ],
          ),
        ),
      ),
    );
  }
}
