import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
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

  @override
  void initState() {
    context.read<SubCategoryCubit>().fetchSubCategory(
          widget.category!,
          context.read<UserDetailsCubit>().getUserId(),
        );
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
    int unlockedLevel = (state as UnlockedLevelFetchSuccess).unlockedLevel;

    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
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
                height: 40.0,
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

  bool isExpanded = false;

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

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: Constants.primaryColor,
      title: widget.categoryName ?? "",
      showBackButton: true,
      titleColor: Constants.white,
      child: Column(
        children: [
          // _buildBackAndLanguageButton(),
          const SizedBox(
            height: 35.0,
          ),
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
//                       "${AppLocalization.of(context)!.getTranslatedValues(questionsKey)!} : ${widget.subcategory.noOfQue!}",
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
          if (currentIndex == 0) {
            context.read<UnlockedLevelCubit>().fetchUnlockLevel(
                context.read<UserDetailsCubit>().getUserId(),
                widget.category,
                state.subcategoryList.first.id);
          }
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
            return const SizedBox(
              height: 16,
            );
          },
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //   crossAxisCount: 2,
          //   mainAxisSpacing: 16,
          //   mainAxisExtent: height,
          //   crossAxisSpacing: 16,
          // ),
          itemCount: subCategoryList.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: StyleProperties.cardsRadius,
                color: Constants.grey5,
              ),
              padding: StyleProperties.insets10,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SubcategoryContainer(
                      levels:
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
                      ),
                      subcategory: subCategoryList[index],
                      currentIndex: currentIndex,
                      index: index,
                      category: widget.category,
                      subCategoryList: subCategoryList[index].id,
                    ),

                    // const Divider(),
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SubcategoryContainer extends StatefulWidget {
  final int index;
  final int currentIndex;
  final Subcategory subcategory;
  final String? category;
  final Widget? levels;
  final String? subCategoryList;

  SubcategoryContainer(
      {Key? key,
      required this.currentIndex,
      required this.index,
      required this.category,
      required this.levels,
      required this.subCategoryList,
      required this.subcategory})
      : super(key: key);

  @override
  _SubcategoryContainerState createState() => _SubcategoryContainerState();
}

class _SubcategoryContainerState extends State<SubcategoryContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  final expansionBoxes = [];
  bool? isExpanded = false;
  int? index;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
      ),
      alignment: Alignment.center,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          childrenPadding: const EdgeInsets.all(10),
          subtitle: TitleText(
            text:
                "${AppLocalization.of(context)!.getTranslatedValues(questionsKey)!} : ${widget.subcategory.noOfQue!}",
            textColor: Constants.primaryColor,
            size: Constants.bodyNormal,
            weight: FontWeight.w400,
          ),
          title: TitleText(
            text: widget.subcategory.subcategoryName!,
            textColor: Constants.primaryColor,
            weight: FontWeight.w500,
            size: Constants.bodyLarge,
          ),
          trailing: isExpanded!
              ? const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 40,
                )
              : const Icon(
                  Icons.arrow_forward_ios_rounded,
                ),
          iconColor: Constants.primaryColor,
          collapsedIconColor: Constants.primaryColor,
          onExpansionChanged: ((value) {
            context.read<UnlockedLevelCubit>().fetchUnlockLevel(
                context.read<UserDetailsCubit>().getUserId(),
                widget.category,
                widget.subCategoryList);

            if (expansionBoxes.contains(widget.index)) {
              expansionBoxes.remove(widget.index);
            } else {
              expansionBoxes.add(widget.index);
            }
            isExpanded = !isExpanded!;
            setState(() {});

            // value
            //     ? height = heightContainer(subCategoryList)
            //     : height = null;
          }),
          children: [
            widget.levels!,
          ],
        ),
      ),

      // ListTile(
      //   title: TitleText(
      //     text: widget.subcategory.subcategoryName!,
      //     textColor: Constants.primaryColor,
      //     size: Constants.bodyXLarge,
      //     weight: FontWeight.w500,
      //   ),
      //   subtitle: TitleText(
      //     text:
      //         "${AppLocalization.of(context)!.getTranslatedValues(questionsKey)!} : ${widget.subcategory.noOfQue!}",
      //     textColor: Constants.primaryColor,
      //     size: Constants.bodyLarge,
      //     weight: FontWeight.w400,
      //   ),
      // ),
    );
  }
}
