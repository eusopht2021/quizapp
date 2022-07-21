import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg_provider;
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/randomOrPlayFrdDialog.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/roomDialog.dart';
import 'package:flutterquiz/ui/screens/home/widgets/new_quiz_category_card.dart';
import 'package:flutterquiz/ui/widgets/friend_card.dart';
import 'package:flutterquiz/ui/widgets/notched_card.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/category_card.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/custom_appbar.dart';
import 'package:flutterquiz/utils/custom_text_field.dart';
import 'package:flutterquiz/utils/info_card.dart';
import 'package:flutterquiz/utils/quizTypes.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/style_properties.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class Discover extends StatefulWidget {
  // final controller = Get.put(DiscoverController());
  const Discover({Key? key}) : super(key: key);

  @override
  State<Discover> createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  @override
  void initState() {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        sheetOpen = false;
      }
    });
    super.initState();
  }

  bool sheetOpen = false;

  int selectedSearchTab = 0;
  int currentMenu = 1;

  FocusNode focusNode = FocusNode();
  final List<QuizType> _quizTypes = quizTypes;

  List<String> searchTabs = ['Top', 'Quiz', 'Categories', 'Friends'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.primaryColor,
      width: SizeConfig.screenWidth,
      height: SizeConfig.screenHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomAppBar(
            title: 'Discover',
            onBackTapped: () {
              setState(() {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                sheetOpen = false;
              });
            },
            showBackButton: sheetOpen ? true : false,
          ),
          WidgetsUtil.verticalSpace16,
          CustomTextField(
            node: focusNode,
            onTap: () {
              setState(() {
                sheetOpen = true;
              });
            },
            textcolor: Constants.white,
            hint: 'Quiz, categories, or friends',
            fillColor: Constants.black2.withOpacity(0.2),
            prefixIcon: Assets.search,
            showBorder: false,
          ),
          WidgetsUtil.verticalSpace24,
          sheetOpen
              ? Expanded(
                  child: _searchSheet(),
                )
              : Expanded(
                  child: CustomScrollView(
                    slivers: [
                      const SliverAppBar(
                        flexibleSpace: Center(
                          // TOP PICKS
                          child: InfoCard(
                            topPicksCard: true,
                            quizzesLength: 5,
                          ),
                        ),
                        collapsedHeight: 170,
                        elevation: 0.0,
                        backgroundColor: Colors.transparent,
                        leading: SizedBox(),
                      ),

                      // _sheet(),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            WidgetsUtil.verticalSpace24,
                            _sheet(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  _tabs() {
    log(quizTypes.length.toString());
    return Row(
      children: List.generate(searchTabs.length, (index) {
        return Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                selectedSearchTab = index;
              });
            },
            child: Column(
              children: [
                Center(
                  child: TitleText(
                    text: searchTabs[index],
                    weight: FontWeight.w500,
                    textColor: selectedSearchTab == index
                        ? Constants.primaryColor
                        : Constants.grey2,
                  ),
                ),
                WidgetsUtil.verticalSpace8,
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == selectedSearchTab
                        ? Constants.primaryColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _sheet() {
    return Container(
      decoration: StyleProperties.sheetBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WidgetsUtil.verticalSpace24,
          _heading("Top rank of the week"),
          WidgetsUtil.verticalSpace16,
          _ranker(
            rankerCard: true,
            rankerName: "Brandon Matrovs",
            points: 124,
          ),
          WidgetsUtil.verticalSpace24,
          _heading("Categories"),
          WidgetsUtil.verticalSpace16,
          GridView.count(
            shrinkWrap: true,
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: kBottomNavigationBarHeight,
            ),
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: List.generate(
              Assets.quizCategories.length,
              (index) {
                return CategoryCard(
                  backgroundColor: Assets.quizCategories[index].color,
                  icon: Assets.quizCategories[index].asset,
                  categoryName: Assets.quizCategories[index].name,
                  quizzes: 21,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String text) => Container(
        margin: const EdgeInsets.only(
          left: 24,
          right: 24,
        ),
        child: TitleText(
          text: text,
          size: Constants.heading3,
          weight: FontWeight.w500,
        ),
      );

  Widget _ranker({rankerCard, rankerName, points}) {
    return Badge(
      badgeContent: SvgPicture.asset(Assets.crown),
      badgeColor: Colors.transparent,
      position: BadgePosition.topEnd(top: -20, end: 40),
      elevation: 0,
      child: Container(
        margin: const EdgeInsets.only(
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: Constants.primaryColor,
          borderRadius: StyleProperties.cardsRadius,
          image: DecorationImage(
            // image: Svg.Svg(Assets.rankerCardBg),
            image: svg_provider.Svg(
              Assets.rankerCardBg,
            ),
            fit: BoxFit.cover,
          ),
        ),
        padding: StyleProperties.insets15,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Constants.white,
                ),
              ),
              padding: StyleProperties.insets10,
              margin: StyleProperties.rightInset15,
              child: TitleText(
                text: "1",
                size: Constants.bodyXSmall,
                textColor: Constants.white,
                weight: FontWeight.w500,
              ),
            ),
            SvgPicture.asset(
              Assets.man1,
              height: 70,
            ),
            WidgetsUtil.horizontalSpace16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleText(
                    text: "$rankerName",
                    textColor: Constants.white,
                    weight: FontWeight.w500,
                    size: Constants.bodyLarge,
                    // lineHeight: 2.0,
                    align: TextAlign.center,
                  ),
                  Padding(
                    padding: StyleProperties.topInset10,
                    child: TitleText(
                      text: "$points points",
                      textColor: Constants.white,
                      // weight: FontWeight.w500,
                      size: Constants.bodyNormal,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _searchSheet() {
    return NotchedCard(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Constants.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(
              Constants.cardsRadius,
            ),
            topLeft: Radius.circular(
              Constants.cardsRadius,
            ),
          ),
        ),
        child: Column(
          children: [
            WidgetsUtil.verticalSpace24,
            _tabs(),
            WidgetsUtil.verticalSpace24,
            _searchBottomItems(),
          ],
        ),
      ),
    );
  }

  Widget _searchBottomItems() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: kBottomNavigationBarHeight,
        ),
        child: Column(
          children: [
            Row(
              children: [
                WidgetsUtil.horizontalSpace24,
                TitleText(
                  text: 'Recent Searches',
                  size: Constants.bodyXLarge,
                  weight: FontWeight.w500,
                  textColor: Constants.black1,
                ),
                const Spacer(),
                TitleText(
                  text: 'Clear All',
                  textColor: Constants.primaryColor,
                  weight: FontWeight.w500,
                  size: Constants.bodySmall,
                ),
                WidgetsUtil.horizontalSpace24,
              ],
            ),
            ...List.generate(_quizTypes.length, (index) {
              return QuizCategoryCard(
                name: _quizTypes[index].getTitle(context),
                asset: _quizTypes[index].image,
                category: AppLocalization.of(context)!
                    .getTranslatedValues(_quizTypes[index].description)!,
                onTap: () {
                  _navigateToQuizZone(index + 1);
                },
              );
            }),
            WidgetsUtil.verticalSpace24,
            Container(
              margin: const EdgeInsets.only(
                left: 24,
              ),
              alignment: Alignment.centerLeft,
              child: TitleText(
                text: 'Friends',
                size: Constants.bodyXLarge,
                weight: FontWeight.w500,
                textColor: Constants.black1,
              ),
            ),
            WidgetsUtil.verticalSpace16,
            FriendCard(
              name: 'Maren Workman',
              points: 325,
              icon: Assets.woman2,
            ),
            WidgetsUtil.verticalSpace16,
            FriendCard(
              name: 'Brandon Matrovs',
              points: 124,
              icon: Assets.man3,
            ),
            WidgetsUtil.verticalSpace16,
            FriendCard(
              name: 'Manuela Lipshutz',
              points: 437,
              icon: Assets.woman1,
            ),
            WidgetsUtil.verticalSpace16,
          ],
        ),
      ),
    );
  }

  void _navigateToQuizZone(int containerNumber) {
    //container number will be [1,2,3,4] if self chellenge is enable
    //container number will be [1,2,3,4,5,6] if self chellenge is not enable

    if (currentMenu == 1) {
      if (containerNumber == 1) {
        _onQuizTypeContainerTap(0);
      } else if (containerNumber == 2) {
        _onQuizTypeContainerTap(1);
      } else if (containerNumber == 3) {
        _onQuizTypeContainerTap(2);
      } else {
        if (context.read<SystemConfigCubit>().isSelfChallengeEnable()) {
          if (_quizTypes.length >= 4) {
            _onQuizTypeContainerTap(3);
          }
          return;
        }

        if (containerNumber == 4) {
          if (_quizTypes.length >= 4) {
            _onQuizTypeContainerTap(3);
          }
        } else if (containerNumber == 5) {
          if (_quizTypes.length >= 5) {
            _onQuizTypeContainerTap(4);
          }
        } else if (containerNumber == 6) {
          if (_quizTypes.length >= 6) {
            _onQuizTypeContainerTap(5);
          }
        }
      }
    } else if (currentMenu == 2) {
      //determine
      if (containerNumber == 1) {
        if (_quizTypes.length >= 5) {
          _onQuizTypeContainerTap(4);
        }
      } else if (containerNumber == 2) {
        if (_quizTypes.length >= 6) {
          _onQuizTypeContainerTap(5);
        }
      } else if (containerNumber == 3) {
        if (_quizTypes.length >= 7) {
          _onQuizTypeContainerTap(6);
        }
      } else {
        //if self challenge is enable
        if (context.read<SystemConfigCubit>().isSelfChallengeEnable()) {
          if (_quizTypes.length >= 8) {
            _onQuizTypeContainerTap(7);
            return;
          }
          return;
        }

        if (containerNumber == 4) {
          if (_quizTypes.length >= 8) {
            _onQuizTypeContainerTap(7);
          }
        } else if (containerNumber == 5) {
          if (_quizTypes.length >= 9) {
            _onQuizTypeContainerTap(8);
          }
        } else if (containerNumber == 6) {
          if (_quizTypes.length >= 10) {
            _onQuizTypeContainerTap(9);
          }
        }
      }
    } else {
      //for menu 3
      if (containerNumber == 1) {
        if (_quizTypes.length >= 9) {
          _onQuizTypeContainerTap(8);
        }
      } else if (containerNumber == 2) {
        if (_quizTypes.length >= 10) {
          _onQuizTypeContainerTap(9);
        }
      } else if (containerNumber == 3) {
        if (_quizTypes.length >= 11) {
          _onQuizTypeContainerTap(10);
        }
      } else {
        if (_quizTypes.length == 12) {
          _onQuizTypeContainerTap(11);
        }
      }
    }
  }

  void _onQuizTypeContainerTap(int quizTypeIndex) {
    if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.dailyQuiz) {
      if (context.read<SystemConfigCubit>().getIsDailyQuizAvailable() == "1") {
        Navigator.of(context).pushNamed(Routes.quiz, arguments: {
          "quizType": QuizTypes.dailyQuiz,
          "numberOfPlayer": 1,
          "quizName": "Daily Quiz"
        });
      } else {
        UiUtils.setSnackbar(
            AppLocalization.of(context)!
                .getTranslatedValues(currentlyNotAvailableKey)!,
            context,
            false);
      }
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.quizZone) {
      Navigator.of(context).pushNamed(Routes.category,
          arguments: {"quizType": QuizTypes.quizZone});
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum ==
        QuizTypes.selfChallenge) {
      Navigator.of(context).pushNamed(Routes.selfChallenge);
    } //
    else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.battle) {
      //
      context.read<BattleRoomCubit>().updateState(BattleRoomInitial());
      context.read<QuizCategoryCubit>().updateState(QuizCategoryInitial());

      showDialog(
        context: context,
        builder: (context) => MultiBlocProvider(providers: [
          BlocProvider<UpdateScoreAndCoinsCubit>(
              create: (_) =>
                  UpdateScoreAndCoinsCubit(ProfileManagementRepository())),
        ], child: RandomOrPlayFrdDialog()),
      );
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum ==
        QuizTypes.trueAndFalse) {
      Navigator.of(context).pushNamed(Routes.quiz, arguments: {
        "quizType": QuizTypes.trueAndFalse,
        "numberOfPlayer": 1,
        "quizName": "True & False"
      });
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum ==
        QuizTypes.funAndLearn) {
      Navigator.of(context).pushNamed(Routes.category,
          arguments: {"quizType": QuizTypes.funAndLearn});
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.groupPlay) {
      context
          .read<MultiUserBattleRoomCubit>()
          .updateState(MultiUserBattleRoomInitial());

      context.read<QuizCategoryCubit>().updateState(QuizCategoryInitial());
      //
      showDialog(
          context: context,
          builder: (context) => MultiBlocProvider(providers: [
                BlocProvider<UpdateScoreAndCoinsCubit>(
                    create: (_) => UpdateScoreAndCoinsCubit(
                        ProfileManagementRepository())),
              ], child: RoomDialog(quizType: QuizTypes.groupPlay)));
      //
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.contest) {
      if (context.read<SystemConfigCubit>().getIsContestAvailable() == "1") {
        Navigator.of(context).pushNamed(Routes.contest);
      } else {
        UiUtils.setSnackbar(
            AppLocalization.of(context)!
                .getTranslatedValues(currentlyNotAvailableKey)!,
            context,
            false);
      }
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum ==
        QuizTypes.guessTheWord) {
      Navigator.of(context).pushNamed(Routes.category,
          arguments: {"quizType": QuizTypes.guessTheWord});
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum ==
        QuizTypes.audioQuestions) {
      Navigator.of(context).pushNamed(Routes.category,
          arguments: {"quizType": QuizTypes.audioQuestions});
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.exam) {
      //update exam status to exam initial
      context.read<ExamCubit>().updateState(ExamInitial());
      Navigator.of(context).pushNamed(Routes.exams);
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.mathMania) {
      Navigator.of(context).pushNamed(Routes.category,
          arguments: {"quizType": QuizTypes.mathMania});
    }
  }
}
