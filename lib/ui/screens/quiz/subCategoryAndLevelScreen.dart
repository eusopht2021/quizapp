import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlockedLevelCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/models/subcategory.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';

import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';

import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/style_properties.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class SubCategoryAndLevelScreen extends StatefulWidget {
  final String? category;
  final String? categoryName;
  const SubCategoryAndLevelScreen(
      {Key? key, this.category, required this.categoryName})
      : super(key: key);
  @override
  _SubCategoryAndLevelScreen createState() => _SubCategoryAndLevelScreen();
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
              child: SubCategoryAndLevelScreen(
                category: arguments['category'],
                categoryName: arguments['categoryName'],
              ),
            ));
  }
}

class _SubCategoryAndLevelScreen extends State<SubCategoryAndLevelScreen> {
  int currentIndex = 0;
  bool isExpanded = false;
  int? selected;
  // Widget icon = Icon(Icons.arrow_forward_ios_rounded);

  final expansionBox = [];
  @override
  void initState() {
    context.read<SubCategoryCubit>().fetchSubCategory(
          widget.category!,
          context.read<UserDetailsCubit>().getUserId(),
        );

    _controller = ExpandedTileController(isExpanded: true);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildBackAndLanguageButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 50, start: 20, end: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(
                15,
              ),
              child: Image.asset(
                Assets.backIcon,
                color: Constants.white,
              ),
            ),
          )
        ],
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

    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisExtent: 80,
          crossAxisCount: 4,
          mainAxisSpacing: 6,
          crossAxisSpacing: 5,
        ),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: int.parse(subcategoryList[currentIndex].maxLevel!),
        itemBuilder: (context, index) {
          int unlockedLevel =
              (state as UnlockedLevelFetchSuccess).unlockedLevel;
          // return GestureDetector(
          //   onTap: () {
          //     //index start with 0 so we comparing (index + 1)
          //     if ((index + 1) <= unlockedLevel) {
          //       //replacing this page
          //       Navigator.of(context)
          //           .pushReplacementNamed(Routes.quiz, arguments: {
          //         "numberOfPlayer": 1,
          //         "quizType": QuizTypes.quizZone,
          //         "categoryId": "",
          //         "subcategoryId": subcategoryList[currentIndex].id,
          //         "level": (index + 1).toString(),
          //         "subcategoryMaxLevel": subcategoryList[currentIndex].maxLevel,
          //         "unlockedLevel": unlockedLevel,
          //         "contestId": "",
          //         "comprehensionId": "",
          //         "quizName": "Quiz Zone"
          //       });
          //     } else {
          //       UiUtils.setSnackbar(
          //           AppLocalization.of(context)!.getTranslatedValues(
          //               convertErrorCodeToLanguageKey(levelLockedCode))!,
          //           context,
          //           false);
          //     }
          //   },
          //   child:
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // borderRadius: BorderRadius.circular(20.0),
                    color: Constants.secondaryColor,
                  ),
                  alignment: Alignment.center,
                  // height: 60.0,
                  // margin: const EdgeInsets.symmetric(
                  //   horizontal: 20.0,
                  //   vertical: 10.0,
                  // ),
                  child: TitleText(
                    text: "${index + 1}",
                    textColor: Constants.white,
                    size: 30,
                  ),
                  // child: ListTile(
                  //   onTap: () {
                  //     //index start with 0 so we comparing (index + 1)
                  //     if ((index + 1) <= unlockedLevel) {
                  //       //replacing this page
                  //       Navigator.of(context)
                  //           .pushReplacementNamed(Routes.quiz, arguments: {
                  //         "numberOfPlayer": 1,
                  //         "quizType": QuizTypes.quizZone,
                  //         "categoryId": "",
                  //         "subcategoryId": subcategoryList[currentIndex].id,
                  //         "level": (index + 1).toString(),
                  //         "subcategoryMaxLevel":
                  //             subcategoryList[currentIndex].maxLevel,
                  //         "unlockedLevel": unlockedLevel,
                  //         "contestId": "",
                  //         "comprehensionId": "",
                  //         "quizName": "Quiz Zone"
                  //       });
                  //     } else {
                  //       UiUtils.setSnackbar(
                  //           AppLocalization.of(context)!.getTranslatedValues(
                  //               convertErrorCodeToLanguageKey(levelLockedCode))!,
                  //           context,
                  //           false);
                  //     }
                  //   },
                  //   leading: TitleText(
                  //       text:
                  //           "${AppLocalization.of(context)!.getTranslatedValues("levelLbl")!} ${index + 1}",
                  //       size: 20,
                  //       weight: FontWeight.bold,
                  //       textColor: Constants.white),
                  //   // title:
                  //   //     TitleText(text: "${subcategoryList[currentIndex].maxLevel}"),
                  //   trailing: Icon(
                  //     Icons.arrow_forward_ios_rounded,
                  //     color: Constants.white,
                  //   ),
                  // ),

                  //  TitleText(
                  //   text:
                  //       "${AppLocalization.of(context)!.getTranslatedValues("levelLbl")!} ${index + 1}",
                  //   size: 20,
                  //   weight: FontWeight.bold,
                  //   textColor: Constants.white,
                  // ),
                ),
              ),
              // ),
            ),
          );
        });
  }

  heightContainer(List items) {
    double itemContainerHeight = 75.0;
    double mainExtentheight = 200.0;
    double containerHeight = (itemContainerHeight * items.length).toDouble();
    double kContainerHeight = (containerHeight + mainExtentheight);
    return kContainerHeight;
  }

  double? height;

  // double itemContainerHeight = 75;
  // double mainExtentheight = 200;
  // // double containerHeight =

  // double? height = null;

  // heightContainer(List items) {
  //   return (itemContainerHeight * items.length);
  // }

  // (containerHeight + mainExtentheight);

  ExpandedTileController? _controller;
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: Constants.primaryColor,
      title: widget.categoryName ?? "",
      showBackButton: true,
      titleColor: Constants.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // _buildBackAndLanguageButton(),
            // const SizedBox(
            //   height: 35.0,
            // ),
            levelBoxes(),

            //     Column(
            //       children: <Widget>[
            //         _buildBackAndLanguageButton(),
            //         const SizedBox(
            //           height: 35.0,
            //         ),
            //         Flexible(
            //           child: BlocConsumer<SubCategoryCubit, SubCategoryState>(
            //               bloc: context.read<SubCategoryCubit>(),
            //               listener: (context, state) {
            //                 if (state is SubCategoryFetchSuccess) {
            //                   if (currentIndex == 0) {
            //                     context.read<UnlockedLevelCubit>().fetchUnlockLevel(
            //                         context.read<UserDetailsCubit>().getUserId(),
            //                         widget.category,
            //                         state.subcategoryList.first.id);
            //                   }
            //                 } else if (state is SubCategoryFetchFailure) {
            //                   if (state.errorMessage == unauthorizedAccessCode) {
            //                     //
            //                     UiUtils.showAlreadyLoggedInDialog(
            //                       context: context,
            //                     );
            //                   }
            //                 }
            //               },
            //               builder: (context, state) {
            //                 if (state is SubCategoryFetchInProgress ||
            //                     state is SubCategoryInitial) {
            //                   return Center(
            //                       child: CircularProgressIndicator(
            //                     color: Constants.white,
            //                   ));
            //                 }
            //                 if (state is SubCategoryFetchFailure) {
            //                   return ErrorContainer(
            //                     errorMessageColor: Constants.primaryColor,
            //                     errorMessage: AppLocalization.of(context)!
            //                         .getTranslatedValues(
            //                             convertErrorCodeToLanguageKey(
            //                                 state.errorMessage)),
            //                     showErrorImage: true,
            //                     onTapRetry: () {
            //                       context.read<SubCategoryCubit>().fetchSubCategory(
            //                             widget.category!,
            //                             context.read<UserDetailsCubit>().getUserId(),
            //                           );
            //                     },
            //                   );
            //                 }
            //                 final subCategoryList =
            //                     (state as SubCategoryFetchSuccess).subcategoryList;

            //                 return Column(
            //                   children: [
            //                     SizedBox(
            //                       height: MediaQuery.of(context).size.height * (0.2),
            //                       child: PageView.builder(
            //                           itemCount: subCategoryList.length,
            //                           onPageChanged: (index) {
            //                             setState(() {
            //                               currentIndex = index;
            //                             });
            //                             //fetch unlocked level for current selected subcategory
            //                             context
            //                                 .read<UnlockedLevelCubit>()
            //                                 .fetchUnlockLevel(
            //                                     context
            //                                         .read<UserDetailsCubit>()
            //                                         .getUserId(),
            //                                     widget.category,
            //                                     subCategoryList[index].id);
            //                           },
            //                           controller: pageController,
            //                           itemBuilder: (context, index) {
            //                             return SubcategoryContainer(
            //                               subcategory: subCategoryList[index],
            //                               currentIndex: currentIndex,
            //                               index: index,
            //                             );
            //                           }),
            //                     ),
            //                     const SizedBox(
            //                       height: 25.0,
            //                     ),
            //                     Flexible(
            //                         child: ClipRRect(
            //                       borderRadius: BorderRadius.circular(25.0),
            //                       child: BlocConsumer<UnlockedLevelCubit,
            //                           UnlockedLevelState>(
            //                         listener: (context, state) {
            //                           if (state is UnlockedLevelFetchFailure) {
            //                             if (state.errorMessage ==
            //                                 unauthorizedAccessCode) {
            //                               //
            //                               UiUtils.showAlreadyLoggedInDialog(
            //                                 context: context,
            //                               );
            //                             }
            //                           }
            //                         },
            //                         builder: (context, state) {
            //                           return AnimatedSwitcher(
            //                             duration: const Duration(milliseconds: 500),
            //                             child: _buildLevels(state, subCategoryList),
            //                           );
            //                         },
            //                       ),
            //                     )),
            //                   ],
            //                 );
            //               }),
            //         ),
            //       ],
            //     ),

            Align(
              alignment: Alignment.bottomCenter,
              child: BannerAdContainer(),
            )
          ],
        ),
      ),
    );

//   }}
// class SubcategoryContainer extends StatefulWidget {
//   final int index;
//   final int currentIndex;
//   final Subcategory subcategory;
//   SubcategoryContainer(
//       {Key? key,
//       required this.currentIndex,
//       required this.index,
//       required this.subcategory})
//       : super(key: key);

//   @override
//   _SubcategoryContainerState createState() => _SubcategoryContainerState();
// }

// class _SubcategoryContainerState extends State<SubcategoryContainer>
//     with SingleTickerProviderStateMixin {
//   late AnimationController animationController;
//   late Animation<double> scaleAnimation;

//   @override
//   void initState() {
//     animationController = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 500));

//     scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
//         CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
//     if (widget.index == widget.currentIndex) {
//       animationController.forward();
//     }
//     super.initState();
//   }

//   @override
//   void dispose() {
//     animationController.dispose();
//     super.dispose();
//   }

//   @override
//   void didUpdateWidget(covariant SubcategoryContainer oldWidget) {
//     if (widget.currentIndex == widget.index) {
//       animationController.forward();
//     } else {
//       animationController.reverse();
//     }

//     super.didUpdateWidget(oldWidget);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: scaleAnimation,
//       builder: (_, child) {
//         return Transform.scale(
//           scale: scaleAnimation.value,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Constants.secondaryColor,
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//             alignment: Alignment.center,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TitleText(
//                   align: TextAlign.center,
//                   text: widget.subcategory.subcategoryName!,
//                   textColor: Constants.white,
//                   size: 22.0,
//                 ),
//                 WidgetsUtil.verticalSpace4,
//                 TitleText(
//                   text:
//                       "${.of(context)!.getTranslatedValues(questionsKey)!} : ${widget.subcategory.noOfQue!}",
//                   textColor: Constants.white,
//                   size: 18,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
  }

  Widget levelBoxes() {
    return BlocConsumer<SubCategoryCubit, SubCategoryState>(
        bloc: context.read<SubCategoryCubit>(),
        listener: (context, state) {
          if (state is SubCategoryFetchSuccess) {
            context.read<UnlockedLevelCubit>().fetchUnlockLevel(
                context.read<UserDetailsCubit>().getUserId(),
                widget.category,
                state.subcategoryList.first.id);
          } else if (state is SubCategoryFetchFailure) {
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
            ));
          }
          if (state is SubCategoryFetchFailure) {
            return ErrorContainer(
              errorMessageColor: Constants.primaryColor,
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage)),
              showErrorImage: true,
              onTapRetry: () {
                context.read<SubCategoryCubit>().fetchSubCategory(
                      widget.category!,
                      context.read<UserDetailsCubit>().getUserId(),
                    );
              },
            );
          }

          final subCategoryList =
              (state as SubCategoryFetchSuccess).subcategoryList;
          return ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(height: 5);
            },
            padding: const EdgeInsets.all(5),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: subCategoryList.length,
            itemBuilder: (context, index) {
              ExpandedTileController _controllers = ExpandedTileController();
              return Container(
                decoration: BoxDecoration(
                  borderRadius: StyleProperties.cardsRadius,
                  color: Constants.grey5,
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpandedTile(
                      onTap: () {
                        currentIndex = index;
                      },
                      theme: const ExpandedTileThemeData(
                        headerRadius: 24.0,
                        headerPadding: EdgeInsets.all(24.0),
                        contentPadding: EdgeInsets.all(24.0),
                        contentRadius: 12.0,
                      ),
                      title: TitleText(
                        text: subCategoryList[index].subcategoryName!,
                      ),
                      controller: _controllers,
                      content:
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
                          return _buildLevels(state, subCategoryList);
                        },
                      )),
                  //  ExpansionTile(
                  // contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  //  onTap     : () {
                  //         currentIndex = index;

                  //         // context.read<UnlockedLevelCubit>().fetchUnlockLevel(
                  //         //     context.read<UserDetailsCubit>().getUserId(),
                  //         //     widget.category,
                  //         //     subCategoryList[index].id);

                  //         // Navigator.pushNamed(context, Routes.newLevelsScreen,
                  //         //     arguments: {
                  //         //       "categoryName":
                  //         //           subCategoryList[currentIndex].subcategoryName,
                  //         //       "category": widget.category,
                  //         //       "levels": subCategoryList[index].maxLevel,
                  //         //       "subcategory": subCategoryList,
                  //         //       "index": index,
                  //         //     });
                  //       },
                  // key: Key(index.toString()),
                  // title: TitleText(
                  //   text: subCategoryList[index].subcategoryName!,
                  //   textColor: Constants.primaryColor,
                  //   weight: FontWeight.w500,
                  //   size: Constants.bodyLarge,
                  // ),
                  // // childrenPadding: const EdgeInsets.all(10),
                  // subtitle: TitleText(
                  //   text:
                  //       "${AppLocalization.of(context)!.getTranslatedValues(questionsKey)!} : ${subCategoryList[index].noOfQue}",
                  //   textColor: Constants.primaryColor,
                  //   size: Constants.bodyNormal,
                  //   weight: FontWeight.w400,
                  // ),

                  // trailing: AnimatedRotation(
                  //   turns: 0.25,
                  //   child: const Icon(
                  //     Icons.arrow_forward_ios_rounded,
                  //     size: 30,
                  //   ),
                  //   duration: Duration(milliseconds: 500),
                  // ),
                  // trailing: expansionBox.contains(index)
                  //     ? const Icon(
                  //         Icons.keyboard_arrow_up_rounded,
                  //         size: 40,
                  //       )
                  //     : const Icon(
                  //         Icons.arrow_forward_ios_rounded,
                  //       ),

                  // initiallyExpanded: index == selected,
                  // iconColor: Constants.primaryColor,
                  //   collapsedIconColor: Constants.primaryColor,
                  //   onExpansionChanged: (bool value) {
                  //     currentIndex = index;

                  //     context.read<UnlockedLevelCubit>().fetchUnlockLevel(
                  //         context.read<UserDetailsCubit>().getUserId(),
                  //         widget.category,
                  //         subCategoryList[index].id);

                  //     if (expansionBox.contains(index)) {
                  //       expansionBox.remove(index);
                  //     } else {
                  //       expansionBox.add(index);
                  //     }
                  //     // isExpanded = value;

                  //     log("$isExpanded  + $index");
                  //     setState(() {});
                  //   },
                  //   children: [
                  //     BlocConsumer<UnlockedLevelCubit, UnlockedLevelState>(
                  //       listener: (context, state) {
                  //         if (state is UnlockedLevelFetchFailure) {
                  //           if (state.errorMessage == unauthorizedAccessCode) {
                  //             //
                  //             UiUtils.showAlreadyLoggedInDialog(
                  //               context: context,
                  //             );
                  //           }
                  //         }
                  //       },
                  //       builder: (context, state) {
                  //         return _buildLevels(state, subCategoryList);
                  //       },
                  //     ),
                  //   ],
                  // ),
                ),
              );

              //  fetch unlocked level for current selected subcategory

              // return Container(
              //     decoration: BoxDecoration(
              //       borderRadius: StyleProperties.cardsRadius,
              //       color: Constants.grey5,
              //     ),
              //     padding: StyleProperties.insets10,
              //     child: SingleChildScrollView(
              //         child: Column(children: [
              //       SubcategoryContainer(
              //         levels:
              //             BlocConsumer<UnlockedLevelCubit, UnlockedLevelState>(
              //           listener: (context, state) {
              //             if (state is UnlockedLevelFetchFailure) {
              //               if (state.errorMessage == unauthorizedAccessCode) {
              //                 //
              //                 UiUtils.showAlreadyLoggedInDialog(
              //                   context: context,
              //                 );
              //               }
              //             }
              //           },
              //           builder: (context, state) {
              //             return _buildLevels(state, subCategoryList);
              //           },
              //         ),
              //         subcategory: subCategoryList[index],
              //         currentIndex: currentIndex,
              //         index: index,
              //         category: widget.category,
              //         subCategoryList: subCategoryList[index].id,
              //       ),
              //       const Divider()
              //     ])));
              // Row(
              //   children: [
              //     TitleText(
              //       text: "Levels",
              //       textColor: Constants.primaryColor,
              //     ),
              //     const Spacer(),
              //     IconButton(
              //       icon: isExpanded
              //           ? Icon(Icons.arrow_drop_up)
              //           : Icon(Icons.arrow_drop_down),
              //       onPressed: () {
              //         setState(() {
              //           isExpanded = !isExpanded;
              //         });
              //       },
              //     ),
              //   ],
              // ),
              // const Divider(),
              // isExpanded
              //     ? BlocConsumer<UnlockedLevelCubit,
              //         UnlockedLevelState>(
              //         listener: (context, state) {
              //           if (state is UnlockedLevelFetchFailure) {
              //             if (state.errorMessage ==
              //                 unauthorizedAccessCode) {
              //               //
              //               UiUtils.showAlreadyLoggedInDialog(
              //                 context: context,
              //               );
              //             }
              //           }
              //         },
              //         builder: (context, state) {
              //           return _buildLevels(state, subCategoryList);
              //         },
              //       )
              //     : SizedBox(),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
            },
          );
        });
  }
}
