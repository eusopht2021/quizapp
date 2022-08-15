import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/screens/home/widgets/new_quiz_category_card.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/category_card.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class CategoryScreen extends StatefulWidget {
  final QuizTypes quizType;
  final String? categoryTitle;

  const CategoryScreen({required this.quizType, this.categoryTitle});

  @override
  _CategoryScreen createState() => _CategoryScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => CategoryScreen(
        quizType: arguments['quizType'] as QuizTypes,
        categoryTitle: arguments['categoryTitle'] as String,
      ),
    );
  }
}

class _CategoryScreen extends State<CategoryScreen> {
  final ScrollController scrollController = ScrollController();
  int? selectedIndex;
  int? currentIndex;
  @override
  void initState() {
    context.read<QuizCategoryCubit>().getQuizCategory(
          languageId: UiUtils.getCurrentQuestionLanguageId(context),
          type: UiUtils.getCategoryTypeNumberFromQuizType(widget.quizType),
          userId: context.read<UserDetailsCubit>().getUserId(),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: Constants.primaryColor,
      title: widget.categoryTitle ?? "",
      titleColor: Constants.white,
      child: Stack(
        children: <Widget>[
          Column(children: <Widget>[
            Expanded(flex: 15, child: showCategory()),
          ]),
          Align(
            alignment: Alignment.bottomCenter,
            child: BannerAdContainer(),
          ),
        ],
      ),
    );
  }

  Widget back() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30, start: 20, end: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomBackButton(
            iconColor: Constants.white,
          )
        ],
      ),
    );
  }

  Widget showCategory() {
    return BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
        bloc: context.read<QuizCategoryCubit>(),
        listener: (context, state) {
          if (state is QuizCategoryFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              //
              log(state.errorMessage);
              UiUtils.showAlreadyLoggedInDialog(context: context);
            }
          }
        },
        builder: (context, state) {
          if (state is QuizCategoryProgress || state is QuizCategoryInitial) {
            return Center(
              child: CircularProgressIndicator(
                color: Constants.white,
              ),
            );
          }
          if (state is QuizCategoryFailure) {
            return ErrorContainer(
              showBackButton: false,
              errorMessageColor: Constants.white,
              showErrorImage: true,
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessage),
              ),
              onTapRetry: () {
                context.read<QuizCategoryCubit>().getQuizCategory(
                      languageId: UiUtils.getCurrentQuestionLanguageId(context),
                      type: UiUtils.getCategoryTypeNumberFromQuizType(
                          widget.quizType),
                      userId: context.read<UserDetailsCubit>().getUserId(),
                    );
              },
            );
          }
          final categoryList = (state as QuizCategorySuccess).categories;

          // return GridView.builder(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   itemCount: categoryList.length,
          //   shrinkWrap: true,
          //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisSpacing: 16,
          //     mainAxisSpacing: 16,
          //     crossAxisCount: 2,
          //   ),
          //   itemBuilder: ((context, index) {
          //     log(categoryList.length.toString() + " lists");
          //     bool checked = index == selectedIndex;

          //     return GestureDetector(
          //       onTap: () {
          //         setState(() {
          //           selectedIndex = index;
          //           if (widget.quizType == QuizTypes.quizZone) {
          //             //noOf means how many subcategory it has
          //             //if subcategory is 0 then check for level

          //             if (categoryList[index].noOf == "0") {
          //               //means this category does not have level
          //               if (categoryList[index].maxLevel == "0") {
          //                 //direct move to quiz screen pass level as 0
          //                 Navigator.of(context)
          //                     .pushNamed(Routes.quiz, arguments: {
          //                   "numberOfPlayer": 1,
          //                   "quizType": QuizTypes.quizZone,
          //                   "categoryId": categoryList[index].id,
          //                   "subcategoryId": "",
          //                   "level": "0",
          //                   "subcategoryMaxLevel": "0",
          //                   "unlockedLevel": 0,
          //                   "contestId": "",
          //                   "comprehensionId": "",
          //                   "quizName": "Quiz Zone"
          //                 });
          //               } else {
          //                 //navigate to level screen
          //                 Navigator.of(context)
          //                     .pushNamed(Routes.levels, arguments: {
          //                   "maxLevel": categoryList[index].maxLevel,
          //                   "categoryId": categoryList[index].id,
          //                 });
          //               }
          //             } else {
          //               Navigator.of(context).pushNamed(
          //                   Routes.subcategoryAndLevel,
          //                   arguments: categoryList[index].id);
          //             }
          //           } else if (widget.quizType == QuizTypes.audioQuestions) {
          //             //noOf means how many subcategory it has

          //             if (categoryList[index].noOf == "0") {
          //               //
          //               Navigator.of(context)
          //                   .pushNamed(Routes.quiz, arguments: {
          //                 "numberOfPlayer": 1,
          //                 "quizType": QuizTypes.audioQuestions,
          //                 "categoryId": categoryList[index].id,
          //                 "isPlayed": categoryList[index].isPlayed,
          //               });
          //             } else {
          //               //
          //               Navigator.of(context)
          //                   .pushNamed(Routes.subCategory, arguments: {
          //                 "categoryId": categoryList[index].id,
          //                 "quizType": widget.quizType,
          //               });
          //             }
          //           } else if (widget.quizType == QuizTypes.guessTheWord) {
          //             //if therse is noo subcategory then get questions by category
          //             if (categoryList[index].noOf == "0") {
          //               Navigator.of(context)
          //                   .pushNamed(Routes.guessTheWord, arguments: {
          //                 "type": "category",
          //                 "typeId": categoryList[index].id,
          //                 "isPlayed": categoryList[index].isPlayed,
          //               });
          //             } else {
          //               Navigator.of(context)
          //                   .pushNamed(Routes.subCategory, arguments: {
          //                 "categoryId": categoryList[index].id,
          //                 "quizType": widget.quizType,
          //               });
          //             }
          //           } else if (widget.quizType == QuizTypes.funAndLearn) {
          //             //if therse is no subcategory then get questions by category
          //             if (categoryList[index].noOf == "0") {
          //               Navigator.of(context)
          //                   .pushNamed(Routes.funAndLearnTitle, arguments: {
          //                 "type": "category",
          //                 "typeId": categoryList[index].id,
          //               });
          //             } else {
          //               Navigator.of(context)
          //                   .pushNamed(Routes.subCategory, arguments: {
          //                 "categoryId": categoryList[index].id,
          //                 "quizType": widget.quizType,
          //               });
          //             }
          //           } else if (widget.quizType == QuizTypes.mathMania) {
          //             //if therse is noo subcategory then get questions by category
          //             if (categoryList[index].noOf == "0") {
          //               Navigator.of(context)
          //                   .pushNamed(Routes.quiz, arguments: {
          //                 "numberOfPlayer": 1,
          //                 "quizType": QuizTypes.mathMania,
          //                 "categoryId": categoryList[index].id,
          //                 "isPlayed": categoryList[index].isPlayed,
          //               });
          //             } else {
          //               Navigator.of(context)
          //                   .pushNamed(Routes.subCategory, arguments: {
          //                 "categoryId": categoryList[index].id,
          //                 "quizType": widget.quizType,
          //               });
          //             }
          //           }
          //         });
          //       },
          //       child: CategoryCard(
          //         iconColor: checked ? Constants.white : Constants.primaryColor,
          //         iconShadowOpacity: checked ? 0.2 : 1,
          //         showAsSubCategories: true,
          //         icon: categoryList[index].image!,
          //         backgroundColor: checked ? Constants.pink : Constants.grey5,
          //         quizzes: int.parse(categoryList[index].noOf!),
          //         categoryName: categoryList[index].categoryName!,
          //         textColor: checked ? Constants.white : Constants.primaryColor,
          //       ),
          //     );
          //   }),
          // );

          return ListView.builder(
              padding: const EdgeInsets.only(
                bottom: 50,
              ),
              controller: scrollController,
              shrinkWrap: true,
              itemCount: categoryList.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                // bool checked = index == selectedIndex;

                return QuizCategoryCard(
                  horizontalMargin: 8,
                  category: "",
                  asset: Assets.quizCategories[index].asset,
                  name: categoryList[index].categoryName!,
                  onTap: () {
                    if (widget.quizType == QuizTypes.quizZone) {
                      //noOf means how many subcategory it has
                      //if subcategory is 0 then check for level
                      log("${categoryList} lists");

                      if (categoryList[index].noOf == "0") {
                        //means this category does not have level
                        if (categoryList[index].maxLevel == "0") {
                          //direct move to quiz screen pass level as 0
                          Navigator.of(context)
                              .pushNamed(Routes.quiz, arguments: {
                            "numberOfPlayer": 1,
                            "quizType": QuizTypes.quizZone,
                            "categoryId": categoryList[index].id,
                            "subcategoryId": "",
                            "level": "0",
                            "subcategoryMaxLevel": "0",
                            "unlockedLevel": 0,
                            "contestId": "",
                            "comprehensionId": "",
                            "quizName": "Quiz Zone"
                          });
                        } else {
                          //navigate to level screen
                          Navigator.of(context)
                              .pushNamed(Routes.levels, arguments: {
                            "maxLevel": categoryList[index].maxLevel,
                            "categoryId": categoryList[index].id,
                            "categoryName": categoryList[index].categoryName,
                          });
                        }
                      } else {
                        Navigator.of(context)
                            .pushNamed(Routes.subcategoryAndLevel, arguments: {
                          "category": categoryList[index].id,
                          "categoryName": categoryList[index].categoryName,
                        });
                      }
                    } else if (widget.quizType == QuizTypes.audioQuestions) {
                      //noOf means how many subcategory it has

                      if (categoryList[index].noOf == "0") {
                        //
                        Navigator.of(context)
                            .pushNamed(Routes.quiz, arguments: {
                          "numberOfPlayer": 1,
                          "quizType": QuizTypes.audioQuestions,
                          "categoryId": categoryList[index].id,
                          "isPlayed": categoryList[index].isPlayed,
                        });
                      } else {
                        //
                        Navigator.of(context)
                            .pushNamed(Routes.subCategory, arguments: {
                          "categoryId": categoryList[index].id,
                          "quizType": widget.quizType,
                        });
                      }
                    } else if (widget.quizType == QuizTypes.guessTheWord) {
                      //if therse is noo subcategory then get questions by category
                      if (categoryList[index].noOf == "0") {
                        Navigator.of(context)
                            .pushNamed(Routes.guessTheWord, arguments: {
                          "type": "category",
                          "typeId": categoryList[index].id,
                          "isPlayed": categoryList[index].isPlayed,
                        });
                      } else {
                        Navigator.of(context)
                            .pushNamed(Routes.subCategory, arguments: {
                          "categoryId": categoryList[index].id,
                          "quizType": widget.quizType,
                        });
                      }
                    } else if (widget.quizType == QuizTypes.funAndLearn) {
                      //if therse is no subcategory then get questions by category
                      if (categoryList[index].noOf == "0") {
                        Navigator.of(context)
                            .pushNamed(Routes.funAndLearnTitle, arguments: {
                          "type": "category",
                          "typeId": categoryList[index].id,
                        });
                      } else {
                        Navigator.of(context)
                            .pushNamed(Routes.subCategory, arguments: {
                          "categoryId": categoryList[index].id,
                          "quizType": widget.quizType,
                        });
                      }
                    } else if (widget.quizType == QuizTypes.mathMania) {
                      //if therse is noo subcategory then get questions by category
                      if (categoryList[index].noOf == "0") {
                        Navigator.of(context)
                            .pushNamed(Routes.quiz, arguments: {
                          "numberOfPlayer": 1,
                          "quizType": QuizTypes.mathMania,
                          "categoryId": categoryList[index].id,
                          "isPlayed": categoryList[index].isPlayed,
                        });
                      } else {
                        Navigator.of(context)
                            .pushNamed(Routes.subCategory, arguments: {
                          "categoryId": categoryList[index].id,
                          "quizType": widget.quizType,
                        });
                      }
                    }
                  },
                );
              }
              // return GestureDetector(
              // onTap: () {
              //   if (widget.quizType == QuizTypes.quizZone) {
              //     //noOf means how many subcategory it has
              //     //if subcategory is 0 then check for level
              //     log("${categoryList} lists");

              //     if (categoryList[index].noOf == "0") {
              //       //means this category does not have level
              //       if (categoryList[index].maxLevel == "0") {
              //         //direct move to quiz screen pass level as 0
              //         Navigator.of(context)
              //             .pushNamed(Routes.quiz, arguments: {
              //           "numberOfPlayer": 1,
              //           "quizType": QuizTypes.quizZone,
              //           "categoryId": categoryList[index].id,
              //           "subcategoryId": "",
              //           "level": "0",
              //           "subcategoryMaxLevel": "0",
              //           "unlockedLevel": 0,
              //           "contestId": "",
              //           "comprehensionId": "",
              //           "quizName": "Quiz Zone"
              //         });
              //       } else {
              //         //navigate to level screen
              //         Navigator.of(context)
              //             .pushNamed(Routes.levels, arguments: {
              //           "maxLevel": categoryList[index].maxLevel,
              //           "categoryId": categoryList[index].id,
              //         });
              //       }
              //     } else {
              //       Navigator.of(context).pushNamed(
              //           Routes.subcategoryAndLevel,
              //           arguments: categoryList[index].id);
              //     }
              //   } else if (widget.quizType == QuizTypes.audioQuestions) {
              //     //noOf means how many subcategory it has

              //     if (categoryList[index].noOf == "0") {
              //       //
              //       Navigator.of(context).pushNamed(Routes.quiz, arguments: {
              //         "numberOfPlayer": 1,
              //         "quizType": QuizTypes.audioQuestions,
              //         "categoryId": categoryList[index].id,
              //         "isPlayed": categoryList[index].isPlayed,
              //       });
              //     } else {
              //       //
              //       Navigator.of(context)
              //           .pushNamed(Routes.subCategory, arguments: {
              //         "categoryId": categoryList[index].id,
              //         "quizType": widget.quizType,
              //       });
              //     }
              //   } else if (widget.quizType == QuizTypes.guessTheWord) {
              //     //if therse is noo subcategory then get questions by category
              //     if (categoryList[index].noOf == "0") {
              //       Navigator.of(context)
              //           .pushNamed(Routes.guessTheWord, arguments: {
              //         "type": "category",
              //         "typeId": categoryList[index].id,
              //         "isPlayed": categoryList[index].isPlayed,
              //       });
              //     } else {
              //       Navigator.of(context)
              //           .pushNamed(Routes.subCategory, arguments: {
              //         "categoryId": categoryList[index].id,
              //         "quizType": widget.quizType,
              //       });
              //     }
              //   } else if (widget.quizType == QuizTypes.funAndLearn) {
              //     //if therse is no subcategory then get questions by category
              //     if (categoryList[index].noOf == "0") {
              //       Navigator.of(context)
              //           .pushNamed(Routes.funAndLearnTitle, arguments: {
              //         "type": "category",
              //         "typeId": categoryList[index].id,
              //       });
              //     } else {
              //       Navigator.of(context)
              //           .pushNamed(Routes.subCategory, arguments: {
              //         "categoryId": categoryList[index].id,
              //         "quizType": widget.quizType,
              //       });
              //     }
              //   } else if (widget.quizType == QuizTypes.mathMania) {
              //     //if therse is noo subcategory then get questions by category
              //     if (categoryList[index].noOf == "0") {
              //       Navigator.of(context).pushNamed(Routes.quiz, arguments: {
              //         "numberOfPlayer": 1,
              //         "quizType": QuizTypes.mathMania,
              //         "categoryId": categoryList[index].id,
              //         "isPlayed": categoryList[index].isPlayed,
              //       });
              //     } else {
              //       Navigator.of(context)
              //           .pushNamed(Routes.subCategory, arguments: {
              //         "categoryId": categoryList[index].id,
              //         "quizType": widget.quizType,
              //       });
              //     }
              //   }
              // },
              //   child: Container(
              //       height: 90,
              //       alignment: Alignment.center,
              //       margin: const EdgeInsets.all(15),
              //       decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(20.0),
              //           color: Constants.secondaryColor),
              //       child: ListTile(
              //         leading: CachedNetworkImage(
              //           placeholder: (context, _) => const SizedBox(),
              //           imageUrl: categoryList[index].image!,
              //           color: Constants.white,
              //           errorWidget: (context, imageUrl, _) => Icon(
              //             Icons.error,
              //             color: Theme.of(context).backgroundColor,
              //           ),
              //         ),
              //         trailing: Icon(Icons.navigate_next_outlined,
              //             size: 40, color: Constants.white),
              //         title: Text(
              //           categoryList[index].categoryName!,
              //           style: TextStyle(color: Constants.white),
              //         ),
              //       )),
              // );
              // },
              );
        });
  }
}
