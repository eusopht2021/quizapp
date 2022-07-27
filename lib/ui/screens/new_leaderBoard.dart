import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/leaderBoard/cubit/leaderBoardAllTimeCubit.dart';
import 'package:flutterquiz/features/leaderBoard/cubit/leaderBoardDailyCubit.dart';
import 'package:flutterquiz/features/leaderBoard/cubit/leaderBoardMonthlyCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/navigation/navbarcubit.dart';
import 'package:flutterquiz/ui/navigation/navbaritems.dart';
import 'package:flutterquiz/ui/navigation/navigation.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/notched_card.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/custom_appbar.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

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
        child: NewLeaderBoardScreen(),
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

  Navigation navBar = Navigation();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        BlocProvider.of<NavigationCubit>(context)
            .getNavBarItem(NavbarItems.newhome);
        Navigator.pushNamed(context, Routes.home, arguments: {
          "index": 0,
        });

        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: CustomAppBar(
            title: "Leaderboard",
            showBackButton: false,
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
          margin: EdgeInsets.symmetric(horizontal: 24),
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
                milliseconds: 300,
              ),
              height: 40,
              width: 100,
              child: Container(
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                ),
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
        ? position = 30.0
        : index == 1
            ? position = 60.0
            : index == 2
                ? position = 100.0
                : null;

    return position;
  }

  double? _leftPosition(index) {
    double? position = 0;
    index == 0
        ? position = 0
        : index == 1
            ? position = 30
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
        : index == 2
            ? position = 40
            : index == 1
                ? position = null
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
            errorMessageColor: Theme.of(context).primaryColor,
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
                                elevation: 0,
                                showBadge: true,
                                badgeContent: Image.asset(Assets.portugal),
                                badgeColor: Colors.transparent,
                                position: BadgePosition.bottomEnd(),
                                child: Badge(
                                    elevation: 0,
                                    showBadge: true,
                                    badgeContent: index == 0
                                        ? SvgPicture.asset(
                                            Assets.crown,
                                            height: 30,
                                          )
                                        : SizedBox(),
                                    position:
                                        BadgePosition.topEnd(end: 5, top: -20),
                                    badgeColor: Colors.transparent,
                                    child: CircleAvatar(
                                      radius: 25,
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
                              WidgetsUtil.verticalSpace20,
                              SizedBox(
                                width: 100,
                                height: 20,
                                child: TitleText(
                                  text: index == 0
                                      ? podiumList[0]['name']!.isNotEmpty
                                          ? podiumList[0]['name']!
                                          : ""
                                      : index == 1
                                          ? podiumList[1]['name']!.isNotEmpty
                                              ? podiumList[1]['name']!
                                              : ""
                                          : index == 2
                                              ? podiumList[2]['name']!
                                                      .isNotEmpty
                                                  ? podiumList[2]['name']!
                                                  : ""
                                              : "",
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
                                          text: index == 0
                                              ? podiumList[0]['score']!
                                                      .isNotEmpty
                                                  ? podiumList[0]['score']!
                                                  : ""
                                              : index == 1
                                                  ? podiumList[1]['score']!
                                                          .isNotEmpty
                                                      ? podiumList[1]['score']!
                                                      : ""
                                                  : index == 2
                                                      ? podiumList[2]['score']!
                                                              .isNotEmpty
                                                          ? podiumList[2]
                                                              ['score']!
                                                          : ""
                                                      : "",
                                          size: Constants.bodyXSmall,
                                          textColor: Constants.white,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          )
                        : SizedBox(),
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
                        Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            Assets.rank2,
                            fit: BoxFit.fill,
                            height: SizeConfig.screenHeight * 0.29,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            Assets.rank1,
                            fit: BoxFit.fill,
                            height: SizeConfig.screenHeight * 0.35,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: Image.asset(
                              Assets.rank3,
                              fit: BoxFit.fill,
                              height: SizeConfig.screenHeight * 0.3,
                            ),
                          ),
                        ),
                        Expanded(
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
            errorMessageColor: Theme.of(context).primaryColor,
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
                            elevation: 0,
                            showBadge: true,
                            badgeContent: Image.asset(Assets.portugal),
                            badgeColor: Colors.transparent,
                            position: BadgePosition.bottomEnd(),
                            child: Badge(
                                elevation: 0,
                                showBadge: true,
                                badgeContent: index == 0
                                    ? SvgPicture.asset(
                                        Assets.crown,
                                        height: 30,
                                      )
                                    : SizedBox(),
                                position:
                                    BadgePosition.topEnd(end: 5, top: -20),
                                badgeColor: Colors.transparent,
                                child: CircleAvatar(
                                  radius: 25,
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
                          WidgetsUtil.verticalSpace20,
                          SizedBox(
                            width: 100,
                            height: 20,
                            child: TitleText(
                              text: index == 0
                                  ? podiumList[0]['name']!.isNotEmpty
                                      ? podiumList[0]['name']!
                                      : ""
                                  : index == 1
                                      ? podiumList[1]['name']!.isNotEmpty
                                          ? podiumList[1]['name']!
                                          : ""
                                      : index == 2
                                          ? podiumList[2]['name']!.isNotEmpty
                                              ? podiumList[2]['name']!
                                              : ""
                                          : "",
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
                                      text: index == 0
                                          ? podiumList[0]['score']!.isNotEmpty
                                              ? podiumList[0]['score']!
                                              : ""
                                          : index == 1
                                              ? podiumList[1]['score']!
                                                      .isNotEmpty
                                                  ? podiumList[1]['score']!
                                                  : ""
                                              : index == 2
                                                  ? podiumList[2]['score']!
                                                          .isNotEmpty
                                                      ? podiumList[2]['score']!
                                                      : ""
                                                  : "",
                                      size: Constants.bodyXSmall,
                                      textColor: Constants.white,
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ])
                      : SizedBox(),
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
                        Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            Assets.rank2,
                            fit: BoxFit.fill,
                            height: SizeConfig.screenHeight * 0.29,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            Assets.rank1,
                            fit: BoxFit.fill,
                            height: SizeConfig.screenHeight * 0.35,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: Image.asset(
                              Assets.rank3,
                              fit: BoxFit.fill,
                              height: SizeConfig.screenHeight * 0.3,
                            ),
                          ),
                        ),
                        Expanded(
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
            errorMessageColor: Theme.of(context).primaryColor,
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
                              elevation: 0,
                              showBadge: true,
                              badgeContent: Image.asset(Assets.portugal),
                              badgeColor: Colors.transparent,
                              position: BadgePosition.bottomEnd(),
                              child: Badge(
                                  elevation: 0,
                                  showBadge: true,
                                  badgeContent: index == 0
                                      ? SvgPicture.asset(
                                          Assets.crown,
                                          height: 30,
                                        )
                                      : SizedBox(),
                                  position:
                                      BadgePosition.topEnd(end: 5, top: -20),
                                  badgeColor: Colors.transparent,
                                  child: CircleAvatar(
                                    radius: 25,
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
                            WidgetsUtil.verticalSpace20,
                            SizedBox(
                              width: 100,
                              height: 20,
                              child: TitleText(
                                text: index == 0
                                    ? podiumList[0]['name']!.isNotEmpty
                                        ? podiumList[0]['name']!
                                        : ""
                                    : index == 1
                                        ? podiumList[1]['name']!.isNotEmpty
                                            ? podiumList[1]['name']!
                                            : ""
                                        : index == 2
                                            ? podiumList[2]['name']!.isNotEmpty
                                                ? podiumList[2]['name']!
                                                : ""
                                            : "",
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
                                        text: index == 0
                                            ? podiumList[0]['score']!.isNotEmpty
                                                ? podiumList[0]['score']!
                                                : ""
                                            : index == 1
                                                ? podiumList[1]['score']!
                                                        .isNotEmpty
                                                    ? podiumList[1]['score']!
                                                    : ""
                                                : index == 2
                                                    ? podiumList[2]['score']!
                                                            .isNotEmpty
                                                        ? podiumList[2]
                                                            ['score']!
                                                        : ""
                                                    : "",
                                        size: Constants.bodyXSmall,
                                        textColor: Constants.white,
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        )
                      : SizedBox(),
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
                        Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            Assets.rank2,
                            fit: BoxFit.fill,
                            height: SizeConfig.screenHeight * 0.29,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            Assets.rank1,
                            fit: BoxFit.fill,
                            height: SizeConfig.screenHeight * 0.35,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: Image.asset(
                              Assets.rank3,
                              fit: BoxFit.fill,
                              height: SizeConfig.screenHeight * 0.3,
                            ),
                          ),
                        ),
                        Expanded(
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

  Widget leaderBoardList(List leaderBoardList, bool hasMore, {state}) {
    List startsFromThree = [];
    List startsFromZero = [];
    List users = [];

    for (int i = 0; i < leaderBoardList.length; i++) {
      startsFromZero.add(leaderBoardList[i]);

      if (i > 2) {
        startsFromThree.add(leaderBoardList[i]);
      }
    }

    if (isExpand) {
      users = startsFromZero;
    } else {
      users = startsFromThree;
    }
    log(startsFromThree.length.toString());
    int counterIndex = 0;
    // log(draggable[""].toString());
    // log('Draggable: ${draggable.length}   leaderboard : ${leaderBoardList.length}   ');
    return NotificationListener(
      onNotification: (DraggableScrollableNotification dSnotification) {
        if (dSnotification.extent >= 1.0) {
          setState(() {
            isExpand = true;
            log('IsExpand false running');
          });
        } else if (dSnotification.extent <= 0.45) {
          setState(
            () {
              isExpand = false;
              log('IsExpand true running');
            },
          );
        }
        return false;
      },
      child: DraggableScrollableSheet(
        snap: true,
        initialChildSize: 0.45,
        minChildSize: 0.45,
        maxChildSize: 1.0,
        builder: (context, controller) {
          controller.addListener(() {
            scrollListener(controller);
          });
          return NotchedCard(
            circleColor: Constants.grey5,
            child: Container(
              height: SizeConfig.screenHeight,
              padding: EdgeInsets.only(top: 10, right: 16, left: 16),
              decoration: BoxDecoration(
                color: Constants.grey5,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView(
                controller: controller,
                shrinkWrap: true,
                children: [
                  if (users.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: Icon(
                          Icons.group_add_outlined,
                          size: 150,
                          color: Constants.grey1.withOpacity(0.2),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
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
                          return SizedBox();
                        }
                        counterIndex++;
                        return SizedBox(
                          height: 100,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 16,
                                left: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: CircleAvatar(
                                      backgroundColor: Constants.black1,
                                      radius: 60,
                                      child: CircleAvatar(
                                        radius: 40,
                                        foregroundColor: Constants.grey2,
                                        backgroundColor: Constants.white,
                                        child: TitleText(
                                          text: isExpand
                                              ? ((counterIndex).toString())
                                              : (counterIndex + 3).toString(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 9,
                                    child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: NetworkImage(
                                              users[index]['profile'] ?? ""),
                                        ),
                                        title: TitleText(
                                          text:
                                              users[index]['name'] ?? "Player",
                                        ),
                                        subtitle: TitleText(
                                          text:
                                              '${users[index]['score'] ?? "0"}  points',
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
                                                        : SizedBox()
                                            : SizedBox()),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
