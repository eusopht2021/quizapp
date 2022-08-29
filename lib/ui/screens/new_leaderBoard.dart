import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/leaderBoard/cubit/leaderBoardAllTimeCubit.dart';
import 'package:flutterquiz/features/leaderBoard/cubit/leaderBoardDailyCubit.dart';
import 'package:flutterquiz/features/leaderBoard/cubit/leaderBoardMonthlyCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/navigation/navbarcubit.dart';
import 'package:flutterquiz/ui/navigation/navbaritems.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/notched_card.dart';
import 'package:scrollable_panel/scrollable_panel.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/custom_appbar.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutterquiz/utils/widgets_util.dart';
import 'package:recase/recase.dart';

class NewLeaderBoardScreen extends StatefulWidget {
  const NewLeaderBoardScreen({Key? key}) : super(key: key);

  @override
  State<NewLeaderBoardScreen> createState() => _NewLeaderBoardScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<LeaderBoardMonthlyCubit>(
              create: (context) => LeaderBoardMonthlyCubit()),
          BlocProvider<LeaderBoardDailyCubit>(
              create: (context) => LeaderBoardDailyCubit()),
          BlocProvider<LeaderBoardAllTimeCubit>(
            create: (context) => LeaderBoardAllTimeCubit(
                // LeaderBoardRepository(),
                ),
          ),
        ],
        child: const NewLeaderBoardScreen(),
      ),
    );
  }
}

class _NewLeaderBoardScreenState extends State<NewLeaderBoardScreen> {
  @override
  void initState() {
    log('Leaderboard');
    Future.delayed(
      Duration.zero,
      () {
        context.read<LeaderBoardDailyCubit>().fetchLeaderBoard(
              "20",
              context.read<UserDetailsCubit>().getUserId(),
            );
      },
    );
    Future.delayed(
      Duration.zero,
      () {
        context.read<LeaderBoardMonthlyCubit>().fetchLeaderBoard(
              "20",
              context.read<UserDetailsCubit>().getUserId(),
            );
      },
    );
    Future.delayed(
      Duration.zero,
      () {
        context.read<LeaderBoardAllTimeCubit>().fetchLeaderBoard(
              "20",
              context.read<UserDetailsCubit>().getUserId(),
            );
      },
    );
    super.initState();
  }

  scrollListenerM(ScrollController controller) {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<LeaderBoardMonthlyCubit>().hasMoreData()) {
        context.read<LeaderBoardMonthlyCubit>().fetchMoreLeaderBoardData(
            "20", context.read<UserDetailsCubit>().getUserId());
      }
    }
  }

  scrollListenerA(ScrollController controller) {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<LeaderBoardAllTimeCubit>().hasMoreData()) {
        log("Has more items - All Time");
        context.read<LeaderBoardAllTimeCubit>().fetchMoreLeaderBoardData(
            "20", context.read<UserDetailsCubit>().getUserId());
      }
    }
  }

  scrollListenerD(ScrollController controller) {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<LeaderBoardDailyCubit>().hasMoreData()) {
        context.read<LeaderBoardDailyCubit>().fetchMoreLeaderBoardData(
            "20", context.read<UserDetailsCubit>().getUserId());
      }
    }
  }

  int selectTab = 0;
  List<String> tabItems = ['Daily', 'Monthly', 'All Time'];
  bool isExpand = false;
  Color? _dotColor;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        BlocProvider.of<NavigationCubit>(context)
            .getNavBarItem(NavbarItems.newhome);

        return true;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: CustomAppBar(
            title: "Leaderboard",
            showBackButton: true,
            onBackTapped: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Constants.primaryColor,
        body: Container(
          // height: SizeConfig.screenHeight,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.backgroundCircle),
            ),
          ),
          child: topDesign(),
        ),
      ),
    );
  }

  Widget topDesign() {
    return Column(
      children: [
        // WidgetsUtil.verticalSpace24,
        Container(
          height: SizeConfig.screenHeight * 0.07,
          width: SizeConfig.screenWidth,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Constants.black1.withOpacity(0.3),
          ),
          child: _tabBar(),
        ),
        Expanded(
          child: _tabItem(),
        ),
      ],
    );
  }

  Widget _tabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        tabItems.length,
        (index) {
          return GestureDetector(
            onTap: (() {
              setState(() {
                selectTab = index;
              });
            }),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 200,
              ),
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: selectTab == index
                      ? Constants.secondaryColor
                      : Colors.transparent),
              child: Center(
                child: TitleText(
                  text: tabItems[index],
                  textColor: Constants.white,
                  weight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tabItem() {
    switch (selectTab) {
      case 0:
        return _dailyTab();
      case 1:
        return _monthlyTab();
      case 2:
        return _allTimeShow();
    }
    return const SizedBox();
  }

  double _topPosition(index) {
    double position = 0;
    index == 0
        ? position = SizeConfig.screenHeight * (0.030)
        : index == 1
            ? position = SizeConfig.screenHeight * (0.055)
            : index == 2
                ? position = SizeConfig.screenHeight * (0.100)
                : null;

    return position;
  }

  double? _leftPosition(index) {
    double? position = 0;
    index == 0
        ? position = 0
        : index == 1
            ? position = SizeConfig.screenHeight * (0.040)
            // : index == 2
            //     ? position = 60
            : index == 2
                ? position = null
                : null;
    return position;
  }

  double? _rightPosition(index) {
    double? position = 0;
    index == 0
        ? position = 0
        : index == 1
            ? position = null
            : index == 2
                ? position = SizeConfig.screenHeight * (0.050)
                : null;
    return position;
  }

  Widget _monthlyTab() {
    return BlocConsumer<LeaderBoardMonthlyCubit, LeaderBoardMonthlyState>(
      bloc: context.read<LeaderBoardMonthlyCubit>(),
      listener: (context, state) {
        if (state is LeaderBoardMonthlyFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            //
            UiUtils.showAlreadyLoggedInDialog(
              context: context,
            );
            return;
          }
        }
      },
      builder: (context, state) {
        if (state is LeaderBoardMonthlyProgress ||
            state is LeaderBoardAllTimeInitial) {
          return Center(
            child: CircularProgressIndicator(
              color: Constants.white,
            ),
          );
        }
        if (state is LeaderBoardMonthlyFailure) {
          return ErrorContainer(
            showBackButton: false,
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessage))!,
            onTapRetry: () {
              context.read<LeaderBoardMonthlyCubit>().fetchMoreLeaderBoardData(
                  "20", context.read<UserDetailsCubit>().getUserId());
            },
            showErrorImage: true,
            errorMessageColor: Constants.white,
          );
        }
        final monthlyList =
            (state as LeaderBoardMonthlySuccess).leaderBoardDetails;
        final hasMore = state.hasMore;
        final podiumList = [];
        for (int i = 0; i < monthlyList.length; i++) {
          if (i == 0) {
            continue;
          } else {
            podiumList.add(monthlyList[i]);
          }
        }
        return SizedBox(
          height: SizeConfig.screenHeight,
          child: Stack(
            children: [
              ...List.generate(
                podiumList.length,
                (index) {
                  return Positioned(
                    top: _topPosition(index),
                    left: _leftPosition(index),
                    right: _rightPosition(index),
                    child: index < 3
                        ? Column(
                            children: [
                              Badge(
                                toAnimate: false,
                                elevation: 0,
                                showBadge: true,
                                badgeContent: Image.asset(Assets.portugal),
                                badgeColor: Colors.transparent,
                                position: BadgePosition.bottomEnd(),
                                child: Badge(
                                    toAnimate: false,
                                    elevation: 0,
                                    showBadge: true,
                                    badgeContent: index == 0
                                        ? SvgPicture.asset(
                                            Assets.crown,
                                            height: 30,
                                          )
                                        : const SizedBox(),
                                    position:
                                        BadgePosition.topEnd(end: 15, top: -20),
                                    badgeColor: Colors.transparent,
                                    child: CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        index == 0
                                            ? podiumList[0]['profile']
                                            : index == 1
                                                ? podiumList[1]['profile']
                                                : index == 2
                                                    ? podiumList[2]['profile']
                                                    : "",
                                      ),
                                    )),
                              ),
                              WidgetsUtil.verticalSpace16,
                              SizedBox(
                                width: 100,
                                height: 20,
                                child: TitleText(
                                  text:
                                      "${index == 0 ? podiumList[0]['name']!.isNotEmpty ? podiumList[0]['name']! : "" : index == 1 ? podiumList[1]['name']!.isNotEmpty ? podiumList[1]['name']! : "" : index == 2 ? podiumList[2]['name']!.isNotEmpty ? podiumList[2]['name']! : "" : ""}"
                                          .titleCase,
                                  textColor: Constants.white,
                                  size: Constants.bodySmall,
                                  align: TextAlign.center,
                                  maxlines: 1,
                                ),
                              ),
                              WidgetsUtil.verticalSpace4,
                              index < 3
                                  ? _qpContainer(
                                      Center(
                                        child: TitleText(
                                          text:
                                              "${index == 0 ? podiumList[0]['score']!.isNotEmpty ? podiumList[0]['score']! : "" : index == 1 ? podiumList[1]['score']!.isNotEmpty ? podiumList[1]['score']! : "" : index == 2 ? podiumList[2]['score']!.isNotEmpty ? podiumList[2]['score']! : "" : ""} PTS",
                                          size: Constants.bodyXSmall,
                                          textColor: Constants.white,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          )
                        : const SizedBox(),
                  );
                },
              ),
              Positioned(
                top: SizeConfig.screenHeight * 0.2,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: SizeConfig.screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            Assets.rank2,
                            fit: BoxFit.cover,
                            height: SizeConfig.screenHeight * 0.29,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            Assets.rank1,
                            fit: BoxFit.cover,
                            height: SizeConfig.screenHeight * 0.35,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: Image.asset(
                              Assets.rank3,
                              fit: BoxFit.cover,
                              height: SizeConfig.screenHeight * 0.3,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              leaderBoardList(monthlyList, hasMore, state: state),
            ],
          ),
        );
      },
    );
  }

  Widget _dailyTab() {
    return BlocConsumer<LeaderBoardDailyCubit, LeaderBoardDailyState>(
      bloc: context.read<LeaderBoardDailyCubit>(),
      listener: (context, state) {
        if (state is LeaderBoardDailyFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            //
            UiUtils.showAlreadyLoggedInDialog(
              context: context,
            );
            return;
          }
        }
      },
      builder: (context, state) {
        if (state is LeaderBoardDailyProgress ||
            state is LeaderBoardDailyInitial) {
          return Center(
              child: CircularProgressIndicator(
            color: Constants.white,
          ));
        }
        if (state is LeaderBoardDailyFailure) {
          return ErrorContainer(
            showBackButton: false,
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessage))!,
            onTapRetry: () {
              context.read<LeaderBoardDailyCubit>().fetchMoreLeaderBoardData(
                  "20", context.read<UserDetailsCubit>().getUserId());
            },
            showErrorImage: true,
            errorMessageColor: Constants.white,
          );
        }
        final dailyList = (state as LeaderBoardDailySuccess).leaderBoardDetails;
        final hasMore = state.hasMore;
        final podiumList = [];
        for (int i = 0; i < dailyList.length; i++) {
          if (i == 0) {
            continue;
          } else {
            podiumList.add(dailyList[i]);
          }
        }
        return SizedBox(
          height: SizeConfig.screenHeight,
          child: Stack(
            children: [
              ...List.generate(podiumList.length, (index) {
                return Positioned(
                  top: _topPosition(index),
                  left: _leftPosition(index),
                  right: _rightPosition(index),
                  child: index < 3
                      ? Column(children: [
                          Badge(
                            toAnimate: false,
                            elevation: 0,
                            showBadge: true,
                            badgeContent: Image.asset(Assets.portugal),
                            badgeColor: Colors.transparent,
                            position: BadgePosition.bottomEnd(),
                            child: Badge(
                                toAnimate: false,
                                elevation: 0,
                                showBadge: true,
                                badgeContent: index == 0
                                    ? SvgPicture.asset(
                                        Assets.crown,
                                        height: 30,
                                      )
                                    : const SizedBox(),
                                position:
                                    BadgePosition.topEnd(end: 15, top: -20),
                                badgeColor: Colors.transparent,
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: CachedNetworkImageProvider(
                                    index == 0
                                        ? podiumList[0]['profile']
                                        : index == 1
                                            ? podiumList[1]['profile']
                                            : index == 2
                                                ? podiumList[2]['profile']
                                                : "",
                                  ),
                                )),
                          ),
                          WidgetsUtil.verticalSpace16,
                          SizedBox(
                            width: 100,
                            height: 20,
                            child: TitleText(
                              text:
                                  "${index == 0 ? podiumList[0]['name']!.isNotEmpty ? podiumList[0]['name']! : "" : index == 1 ? podiumList[1]['name']!.isNotEmpty ? podiumList[1]['name']! : "" : index == 2 ? podiumList[2]['name']!.isNotEmpty ? podiumList[2]['name']! : "" : ""}"
                                      .titleCase,
                              textColor: Constants.white,
                              size: Constants.bodySmall,
                              align: TextAlign.center,
                              maxlines: 1,
                            ),
                          ),
                          WidgetsUtil.verticalSpace4,
                          index < 3
                              ? _qpContainer(
                                  Center(
                                    child: TitleText(
                                      text:
                                          "${index == 0 ? podiumList[0]['score']!.isNotEmpty ? podiumList[0]['score']! : "" : index == 1 ? podiumList[1]['score']!.isNotEmpty ? podiumList[1]['score']! : "" : index == 2 ? podiumList[2]['score']!.isNotEmpty ? podiumList[2]['score']! : "" : ""} PTS",
                                      size: Constants.bodyXSmall,
                                      textColor: Constants.white,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ])
                      : const SizedBox(),
                );
              }),
              Positioned(
                top: SizeConfig.screenHeight * 0.2,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: SizeConfig.screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            Assets.rank2,
                            fit: BoxFit.cover,
                            height: SizeConfig.screenHeight * 0.29,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            Assets.rank1,
                            fit: BoxFit.cover,
                            height: SizeConfig.screenHeight * 0.35,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: Image.asset(
                              Assets.rank3,
                              fit: BoxFit.cover,
                              height: SizeConfig.screenHeight * 0.3,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              leaderBoardList(dailyList, hasMore, state: state),
            ],
          ),
        );
      },
    );
  }

  Widget _allTimeShow() {
    return BlocConsumer<LeaderBoardAllTimeCubit, LeaderBoardAllTimeState>(
      bloc: context.read<LeaderBoardAllTimeCubit>(),
      listener: (context, state) {
        if (state is LeaderBoardAllTimeFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            //
            UiUtils.showAlreadyLoggedInDialog(
              context: context,
            );
            return;
          }
        }
      },
      builder: (context, state) {
        if (state is LeaderBoardAllTimeProgress ||
            state is LeaderBoardAllTimeInitial) {
          return Center(
            child: CircularProgressIndicator(
              color: Constants.white,
            ),
          );
        }
        if (state is LeaderBoardAllTimeFailure) {
          return ErrorContainer(
            showBackButton: false,
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessage))!,
            onTapRetry: () {
              context.read<LeaderBoardAllTimeCubit>().fetchMoreLeaderBoardData(
                  "20", context.read<UserDetailsCubit>().getUserId());
            },
            showErrorImage: true,
            errorMessageColor: Constants.white,
          );
        }
        final allTimeList =
            (state as LeaderBoardAllTimeSuccess).leaderBoardDetails;
        final hasMore = state.hasMore;

        final podiumList = [];
        for (int i = 0; i < allTimeList.length; i++) {
          if (i == 0) {
            continue;
          } else {
            podiumList.add(allTimeList[i]);
          }
        }
        log(" podium ${podiumList.length}   all time : ${allTimeList.length}");

        return SizedBox(
          height: SizeConfig.screenHeight,
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              ...List.generate(podiumList.length, (index) {
                return Positioned(
                  top: _topPosition(index),
                  left: _leftPosition(index),
                  right: _rightPosition(index),
                  child: index < 3
                      ? Column(
                          children: [
                            Badge(
                              toAnimate: false,
                              elevation: 0,
                              showBadge: true,
                              badgeContent: Image.asset(Assets.portugal),
                              badgeColor: Colors.transparent,
                              position: BadgePosition.bottomEnd(),
                              child: Badge(
                                  toAnimate: false,
                                  elevation: 0,
                                  showBadge: true,
                                  badgeContent: index == 0
                                      ? SvgPicture.asset(
                                          Assets.crown,
                                          height: 30,
                                        )
                                      : const SizedBox(),
                                  position:
                                      BadgePosition.topEnd(end: 15, top: -20),
                                  badgeColor: Colors.transparent,
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: CachedNetworkImageProvider(
                                      index == 0
                                          ? podiumList[0]['profile']
                                          : index == 1
                                              ? podiumList[1]['profile']
                                              : index == 2
                                                  ? podiumList[2]['profile']
                                                  : "",
                                    ),
                                  )),
                            ),
                            WidgetsUtil.verticalSpace16,
                            SizedBox(
                              width: 100,
                              height: 20,
                              child: TitleText(
                                text:
                                    "${index == 0 ? podiumList[0]['name']!.isNotEmpty ? podiumList[0]['name']! : "" : index == 1 ? podiumList[1]['name']!.isNotEmpty ? podiumList[1]['name']! : "" : index == 2 ? podiumList[2]['name']!.isNotEmpty ? podiumList[2]['name']! : "" : ""}"
                                        .titleCase,
                                textColor: Constants.white,
                                size: Constants.bodySmall,
                                align: TextAlign.center,
                                maxlines: 1,
                              ),
                            ),
                            WidgetsUtil.verticalSpace4,
                            index < 3
                                ? _qpContainer(
                                    Center(
                                      child: TitleText(
                                        text:
                                            "${index == 0 ? podiumList[0]['score']!.isNotEmpty ? podiumList[0]['score']! : "" : index == 1 ? podiumList[1]['score']!.isNotEmpty ? podiumList[1]['score']! : "" : index == 2 ? podiumList[2]['score']!.isNotEmpty ? podiumList[2]['score']! : "" : ""} PTS",
                                        size: Constants.bodyXSmall,
                                        textColor: Constants.white,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        )
                      : const SizedBox(),
                );
              }),
              Positioned(
                top: SizeConfig.screenHeight * 0.2,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: SizeConfig.screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            Assets.rank2,
                            fit: BoxFit.cover,
                            height: SizeConfig.screenHeight * 0.29,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            Assets.rank1,
                            fit: BoxFit.cover,
                            height: SizeConfig.screenHeight * 0.35,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: Image.asset(
                              Assets.rank3,
                              fit: BoxFit.cover,
                              height: SizeConfig.screenHeight * 0.3,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              leaderBoardList(allTimeList, hasMore, state: state),
            ],
          ),
        );
      },
    );
  }

  final PanelController _panelController = PanelController();

  // Widget leaderBoardList(List leaderBoardList, bool hasMore, {state}) {
  //   List startsFromThree = [];
  //   List startsFromZero = [];
  //   List users = [];

  //   // int index = 0;
  //   int counterIndex = 0;

  //   for (int i = 0; i < leaderBoardList.length; i++) {
  //     startsFromZero.add(leaderBoardList[i]);

  //     if (i >= 3) {
  //       startsFromThree.add(leaderBoardList[i]);
  //     }
  //   }

  //   if (isExpand) {
  //     users = startsFromZero;
  //   } else {
  //     users = startsFromThree;
  //   }

  //   log(startsFromThree.length.toString());
  //   // print("${users[3]}");
  //   // log(draggable[""].toString());
  //   // log('Draggable: ${draggable.length}   leaderboard : ${leaderBoardList.length}   ');
  //   return ScrollablePanel(
  //     onExpand: () {
  //       setState(() {
  //         isExpand = true;
  //       });
  //       // _panelController
  //     },
  //     controller: _panelController,
  //     maxPanelSize: 0.5,
  //     defaultPanelSize: 0.45,
  //     minPanelSize: 0.45,
  //     builder: (context, controller) {
  //       controller.addListener(() {
  //         scrollListener(controller);
  //       });
  //       // return SingleChildScrollView(
  //       //   controller: controller,
  //       //   child: Container(
  //       //     color: Colors.pink,
  //       //     height: SizeConfig.screenHeight,
  //       //   ),
  //       // );
  //       return NotchedCard(
  //         circleColor: Constants.grey5,
  //         dotColor: isExpand
  //             ? _dotColor = Constants.primaryColor
  //             : Constants.primaryColor.withOpacity(0.3),
  //         child: Container(
  //           height: SizeConfig.screenHeight,
  //           padding: const EdgeInsets.only(top: 10, right: 16, left: 16),
  //           decoration: BoxDecoration(
  //             color: Constants.grey5,
  //             borderRadius: const BorderRadius.only(
  //               topLeft: Radius.circular(20),
  //               topRight: Radius.circular(20),
  //             ),
  //           ),
  //           child: SingleChildScrollView(
  //             controller: controller,
  //             // physics: NeverScrollableScrollPhysics(),
  //             child: Column(
  //               // controller: controller,
  //               // padding: EdgeInsets.zero,
  //               // shrinkWrap: true,
  //               children: [
  //                 if (users.length < 2)
  //                   Padding(
  //                     padding: const EdgeInsets.only(
  //                       top: 50,
  //                     ),
  //                     child: SizedBox(
  //                       width: double.infinity,
  //                       child: Center(
  //                         child: TitleText(
  //                           text: "No Users".toUpperCase(),
  //                           weight: FontWeight.w500,
  //                           size: Constants.heading2,
  //                           textColor: Constants.grey1.withOpacity(0.2),
  //                         ),
  //                       ),
  //                     ),
  //                   )
  //                 else
  //                   ...List.generate(users.length, (index) {
  //                     // (index % 21 == 0) ?   : index;
  //                     if (hasMore && index == (leaderBoardList.length - 1)) {
  //                       return Center(
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(15),
  //                           child: CircularProgressIndicator(
  //                             color: Constants.primaryColor,
  //                           ),
  //                         ),
  //                       );
  //                     }
  //                     // else if (!users[index].containsKey("name")) {
  //                     //   return SizedBox();
  //                     // }

  //                     else if (index % 21 == 0) {
  //                       // log(index.toString());

  //                       return const SizedBox();
  //                     }

  //                     log("$index  index");
  //                     return SizedBox(
  //                       height: 85,
  //                       child: Card(
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(20),
  //                         ),
  //                         elevation: 0,
  //                         child: Padding(
  //                           padding: const EdgeInsets.only(
  //                             right: 10,
  //                             left: 10,
  //                           ),
  //                           child: Row(
  //                             children: [
  //                               Expanded(
  //                                   child: Container(
  //                                 width: 25,
  //                                 height: 25,
  //                                 decoration: BoxDecoration(
  //                                     border:
  //                                         Border.all(color: Constants.grey4),
  //                                     shape: BoxShape.circle),
  //                                 child: Center(
  //                                   child: TitleText(
  //                                     text:
  //                                         isExpand ? "$index" : "${index + 3}",
  //                                     size: Constants.bodyXSmall,
  //                                     textColor: Constants.grey2,
  //                                   ),
  //                                 ),
  //                               )),
  //                               Expanded(
  //                                 flex: 8,
  //                                 child: ListTile(
  //                                     horizontalTitleGap: 16,
  //                                     minVerticalPadding: 4,
  //                                     leading: Badge(
  //                                       toAnimate: false,
  //                                       badgeContent: Image.asset(
  //                                         index % 3 == 0
  //                                             ? Assets.portugal
  //                                             : index % 2 == 0
  //                                                 ? Assets.turkey
  //                                                 : Assets.france,
  //                                         width: 20,
  //                                         height: 20,
  //                                       ),
  //                                       position: BadgePosition.bottomEnd(),
  //                                       badgeColor: Colors.transparent,
  //                                       elevation: 0,
  //                                       child: ClipOval(
  //                                         clipBehavior: Clip.antiAlias,
  //                                         child: CircleAvatar(
  //                                           backgroundColor: Colors.transparent,
  //                                           radius: 25,
  //                                           child: CachedNetworkImage(
  //                                             imageUrl:
  //                                                 users[index]['profile'] ?? "",
  //                                             placeholder: (url, string) {
  //                                               return CircularProgressIndicator(
  //                                                 color: Constants.primaryColor,
  //                                               );
  //                                             },
  //                                             errorWidget: (_, __, ___) {
  //                                               return Image.asset(
  //                                                 Assets.person,
  //                                                 width: 30,
  //                                                 height: 30,
  //                                               );
  //                                             },
  //                                             // placeholder: Image.asset(Assets.person),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     title: TitleText(
  //                                       maxlines: 1,
  //                                       text: users[index]['name'] ?? "Player",
  //                                       size: Constants.bodyNormal,
  //                                       align: TextAlign.left,
  //                                       weight: FontWeight.w500,
  //                                     ),
  //                                     subtitle: TitleText(
  //                                       text:
  //                                           '${users[index]['score'] ?? "0"} pts',
  //                                       // ${AppLocalization.of(context)!.getTranslatedValues("points")!}',
  //                                     ),
  //                                     trailing: isExpand
  //                                         ? index == 1
  //                                             ? SvgPicture.asset(Assets.crown)
  //                                             : index == 2
  //                                                 ? SvgPicture.asset(
  //                                                     Assets.silverCrown)
  //                                                 : index == 3
  //                                                     ? SvgPicture.asset(
  //                                                         Assets.bronzeCrown)
  //                                                     : const SizedBox()
  //                                         : const SizedBox()),
  //                               )
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     );
  //                   }),
  //                 // ListView.builder(
  //                 //   physics: const NeverScrollableScrollPhysics(),
  //                 //   shrinkWrap: true,
  //                 //   itemCount: users.length,
  //                 //   itemBuilder: (context, index) {

  //                 //   },
  //                 // ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget leaderBoardList(List leaderBoardList, bool hasMore, {state}) {
    List startsFromThree = [];
    List startsFromZero = [];
    List users = [];

    // int index = 0;
    int counterIndex = 0;

    // print("${users[3]}");
    // log(draggable[""].toString());
    // log('Draggable: ${draggable.length}   leaderboard : ${leaderBoardList.length}   ');
    return NotificationListener(
      onNotification: (DraggableScrollableNotification dSnotification) {
        double extent = dSnotification.extent;
        String temp = extent.toStringAsFixed(2);
        extent = double.parse(temp);
        log("counte======r :${extent} ${dSnotification.extent}");

        if (dSnotification.extent >= 0.95) {
          isExpand = true;
        } else if (dSnotification.extent <= 0.47) {
          isExpand = false;
        }
        // setState(() {});
        return true;
      },
      child: DraggableScrollableSheet(
        snap: true,
        initialChildSize: 0.46,
        minChildSize: 0.46,
        maxChildSize: 0.97,

        // controller: controller,
        builder: (context, controller) {
          controller.addListener(() {
            scrollListener(controller);
          });
          for (int i = 0; i < leaderBoardList.length; i++) {
            if (!startsFromZero.contains(leaderBoardList[i])) {
              startsFromZero.add(leaderBoardList[i]);
            }

            if (i >= 3 && !startsFromThree.contains(leaderBoardList[i])) {
              startsFromThree.add(leaderBoardList[i]);
            }
          }

          if (isExpand) {
            users = startsFromZero;
          } else {
            users = startsFromThree;
          }

          log(startsFromThree.length.toString());
          return NotchedCard(
            circleColor: Constants.grey5,
            dotColor: isExpand
                ? _dotColor = Constants.primaryColor
                : Constants.primaryColor.withOpacity(0.3),
            child: Container(
              height: SizeConfig.screenHeight,
              padding: const EdgeInsets.only(top: 10, right: 16, left: 16),
              decoration: BoxDecoration(
                color: Constants.grey5,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView(
                controller: controller,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                children: [
                  if (users.length < 2)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 50,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: TitleText(
                            text: "No Users".toUpperCase(),
                            weight: FontWeight.w500,
                            size: Constants.heading2,
                            textColor: Constants.grey1.withOpacity(0.2),
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(users.length, (index) {
                      // (index % 21 == 0) ?   : index;
                      if (hasMore && index == (leaderBoardList.length - 1)) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: CircularProgressIndicator(
                              color: Constants.primaryColor,
                            ),
                          ),
                        );
                      }
                      // else if (!users[index].containsKey("name")) {
                      //   return SizedBox();
                      // }

                      else if (index % 21 == 0) {
                        // log(index.toString());

                        return const SizedBox();
                      }

                      log("$index  index");
                      return SizedBox(
                        height: 85,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 10,
                              left: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Constants.grey4),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: TitleText(
                                      text:
                                          isExpand ? "$index" : "${index + 3}",
                                      size: Constants.bodyXSmall,
                                      textColor: Constants.grey2,
                                    ),
                                  ),
                                )),
                                Expanded(
                                  flex: 8,
                                  child: ListTile(
                                      horizontalTitleGap: 16,
                                      minVerticalPadding: 4,
                                      leading: Badge(
                                        toAnimate: false,
                                        badgeContent: Image.asset(
                                          index % 3 == 0
                                              ? Assets.portugal
                                              : index % 2 == 0
                                                  ? Assets.turkey
                                                  : Assets.france,
                                          width: 20,
                                          height: 20,
                                        ),
                                        position: BadgePosition.bottomEnd(),
                                        badgeColor: Colors.transparent,
                                        elevation: 0,
                                        child: ClipOval(
                                          clipBehavior: Clip.antiAlias,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            radius: 25,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  users[index]['profile'] ?? "",
                                              placeholder: (url, string) {
                                                return CircularProgressIndicator(
                                                  color: Constants.primaryColor,
                                                );
                                              },
                                              errorWidget: (_, __, ___) {
                                                return Image.asset(
                                                  Assets.person,
                                                  width: 30,
                                                  height: 30,
                                                );
                                              },
                                              // placeholder: Image.asset(Assets.person),
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: TitleText(
                                        maxlines: 1,
                                        text:
                                            "${users[index]['name'] ?? "Player"}"
                                                .titleCase,
                                        size: Constants.bodyNormal,
                                        align: TextAlign.left,
                                        weight: FontWeight.w500,
                                      ),
                                      subtitle: TitleText(
                                        text:
                                            '${users[index]['score'] ?? "0"} PTS',
                                        // ${AppLocalization.of(context)!.getTranslatedValues("points")!}',
                                      ),
                                      trailing: isExpand
                                          ? index == 1
                                              ? SvgPicture.asset(Assets.crown)
                                              : index == 2
                                                  ? SvgPicture.asset(
                                                      Assets.silverCrown)
                                                  : index == 3
                                                      ? SvgPicture.asset(
                                                          Assets.bronzeCrown)
                                                      : const SizedBox()
                                          : const SizedBox()),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  // ListView.builder(
                  //   physics: const NeverScrollableScrollPhysics(),
                  //   shrinkWrap: true,
                  //   itemCount: users.length,
                  //   itemBuilder: (context, index) {

                  //   },
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void scrollListener(ScrollController controller) {
    if (selectTab == 0) {
      scrollListenerD(controller);
    } else if (selectTab == 1) {
      scrollListenerM(controller);
    } else {
      scrollListenerA(controller);
    }
  }

  Widget _qpContainer(child) {
    return Container(
      height: 34,
      width: 74,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Constants.secondaryColor,
      ),
      child: child,
    );
  }
}
