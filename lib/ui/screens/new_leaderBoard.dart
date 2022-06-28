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
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
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
import 'package:hive/hive.dart';

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
  ScrollController controllerM = ScrollController();
  ScrollController controllerA = ScrollController();
  ScrollController controllerD = ScrollController();
  @override
  void initState() {
    controllerM.addListener(scrollListenerM);
    controllerA.addListener(scrollListenerA);
    controllerD.addListener(scrollListenerD);
    Future.delayed(Duration.zero, () {
      context
          .read<LeaderBoardDailyCubit>()
          .fetchLeaderBoard("20", context.read<UserDetailsCubit>().getUserId());
    });
    Future.delayed(Duration.zero, () {
      context
          .read<LeaderBoardMonthlyCubit>()
          .fetchLeaderBoard("20", context.read<UserDetailsCubit>().getUserId());
    });
    Future.delayed(Duration.zero, () {
      context
          .read<LeaderBoardAllTimeCubit>()
          .fetchLeaderBoard("20", context.read<UserDetailsCubit>().getUserId());
    });

    super.initState();
  }

  @override
  void dispose() {
    controllerM.removeListener(scrollListenerM);
    controllerA.removeListener(scrollListenerA);
    controllerD.removeListener(scrollListenerD);
    super.dispose();
  }

  scrollListenerM() {
    if (controllerM.position.maxScrollExtent == controllerM.offset) {
      if (context.read<LeaderBoardMonthlyCubit>().hasMoreData()) {
        context.read<LeaderBoardMonthlyCubit>().fetchMoreLeaderBoardData(
            "20", context.read<UserDetailsCubit>().getUserId());
      }
    }
  }

  scrollListenerA() {
    if (controllerA.position.maxScrollExtent == controllerA.offset) {
      if (context.read<LeaderBoardAllTimeCubit>().hasMoreData()) {
        context.read<LeaderBoardAllTimeCubit>().fetchMoreLeaderBoardData(
            "20", context.read<UserDetailsCubit>().getUserId());
      }
    }
  }

  scrollListenerD() {
    if (controllerD.position.maxScrollExtent == controllerD.offset) {
      if (context.read<LeaderBoardDailyCubit>().hasMoreData()) {
        context.read<LeaderBoardDailyCubit>().fetchMoreLeaderBoardData(
            "20", context.read<UserDetailsCubit>().getUserId());
      }
    }
  }

  int selectTab = 0;
  List<String> tabItems = ['Daily', 'Monthly', 'All Time'];
  bool? isCollapse;
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Constants.primaryColor, body: topDesign());
  }

  Widget topDesign() {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.backgroundCircle),
          ),
        ),
        child: Column(
          children: [
            PreferredSize(
              preferredSize: const Size.fromWidth(10),
              child: CustomAppBar(
                title: "Leaderboard",
                onBackTapped: () {
                  Navigator.pop(context);
                },
              ),
            ),
            WidgetsUtil.verticalSpace24,
            Container(
                width: SizeConfig.screenWidth,
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Constants.black1.withOpacity(0.3),
                ),
                child: _tabBar()),
            _tabItem(),
          ],
        ),
      ),
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
              child: Expanded(
                child: Container(
                  padding: EdgeInsets.only(
                    top: 8,
                    bottom: 8,
                  ),
                  child: Center(
                    child: TitleText(
                      text: tabItems[index],
                      textColor: Constants.white,
                      weight: FontWeight.w500,
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: selectTab == index
                          ? Constants.secondaryColor
                          : Colors.transparent),
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
              child: CircularProgressContainer(
                useWhiteLoader: false,
              ),
            );
          }
          if (state is LeaderBoardMonthlyFailure) {
            return ErrorContainer(
              showBackButton: false,
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage))!,
              onTapRetry: () {
                context
                    .read<LeaderBoardMonthlyCubit>()
                    .fetchMoreLeaderBoardData(
                        "20", context.read<UserDetailsCubit>().getUserId());
              },
              showErrorImage: true,
              errorMessageColor: Theme.of(context).primaryColor,
            );
          }
          final monthlyList =
              (state as LeaderBoardMonthlySuccess).leaderBoardDetails;
          final hasMore = state.hasMore;
          return Column(
            children: [
              WidgetsUtil.verticalSpace16,
              SizedBox(
                  height: SizeConfig.screenHeight,
                  child: Stack(children: [
                    Positioned(
                      top: 50,
                      left: 145,
                      child: Column(
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
                              badgeContent: SvgPicture.asset(
                                Assets.crown,
                                height: 30,
                              ),
                              position: BadgePosition.topEnd(end: 5, top: -20),
                              badgeColor: Colors.transparent,
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.transparent,
                                backgroundImage: CachedNetworkImageProvider(
                                  monthlyList[1]['profile'],
                                ),
                              ),
                            ),
                          ),
                          WidgetsUtil.verticalSpace20,
                          SizedBox(
                            width: 100,
                            child: TitleText(
                              text: monthlyList[1]['name']!.isNotEmpty
                                  ? monthlyList[1]['name']!
                                  : "...",
                              textColor: Constants.white,
                              size: Constants.bodySmall,
                              align: TextAlign.center,
                            ),
                          ),
                          WidgetsUtil.verticalSpace4,
                          _QPContainer(
                            Center(
                              child: TitleText(
                                text: monthlyList[1]['score']!.isNotEmpty
                                    ? monthlyList[1]['score']!
                                    : "...",
                                size: Constants.bodyXSmall,
                                textColor: Constants.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 60,
                      left: 40,
                      child: Column(
                        children: [
                          Badge(
                            showBadge: true,
                            badgeColor: Colors.transparent,
                            position: BadgePosition.bottomEnd(),
                            elevation: 0,
                            badgeContent: Image.asset(Assets.france),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              backgroundImage: CachedNetworkImageProvider(
                                monthlyList[2]['profile'],
                              ),
                            ),
                          ),
                          WidgetsUtil.verticalSpace20,
                          SizedBox(
                            width: 100,
                            child: TitleText(
                              text: monthlyList[2]['name']!.isNotEmpty
                                  ? monthlyList[2]['name']!
                                  : "...",
                              textColor: Constants.white,
                              size: Constants.bodySmall,
                              align: TextAlign.center,
                            ),
                          ),
                          WidgetsUtil.verticalSpace4,
                          _QPContainer(
                            Center(
                              child: TitleText(
                                text: monthlyList[2]['score']!.isNotEmpty
                                    ? monthlyList[2]['score']!
                                    : "...",
                                size: Constants.bodyXSmall,
                                textColor: Constants.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 110,
                      right: 40,
                      child: Column(
                        children: [
                          Badge(
                            showBadge: true,
                            badgeColor: Colors.transparent,
                            position: BadgePosition.bottomEnd(),
                            elevation: 0,
                            badgeContent: Image.asset(Assets.portugal),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              backgroundImage: CachedNetworkImageProvider(
                                monthlyList[3]['profile'],
                              ),
                            ),
                          ),
                          WidgetsUtil.verticalSpace20,
                          SizedBox(
                            width: 100,
                            child: TitleText(
                              text: monthlyList[3]['name']!.isNotEmpty
                                  ? monthlyList[3]['name']!
                                  : "...",
                              textColor: Constants.white,
                              size: Constants.bodySmall,
                              align: TextAlign.center,
                            ),
                          ),
                          WidgetsUtil.verticalSpace4,
                          _QPContainer(
                            Center(
                              child: TitleText(
                                text: monthlyList[3]['score']!.isNotEmpty
                                    ? monthlyList[3]['score']!
                                    : "...",
                                size: Constants.bodyXSmall,
                                textColor: Constants.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 180,
                      right: 133,
                      left: 132,
                      child: Image.asset(Assets.rank1),
                    ),
                    Positioned(
                      top: 210,
                      right: 243,
                      left: 28,
                      child: Image.asset(Assets.rank2),
                    ),
                    Positioned(
                      top: 260,
                      right: 28,
                      left: 242,
                      child: Image.asset(Assets.rank3),
                    ),
                    leaderBoardList(monthlyList, hasMore),
                  ])),
            ],
          );
        });
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
          final dailyList =
              (state as LeaderBoardDailySuccess).leaderBoardDetails;
          final hasMore = state.hasMore;
          return Column(
            children: [
              WidgetsUtil.verticalSpace24,
              SizedBox(
                height: SizeConfig.screenHeight,
                child: Stack(children: [
                  Positioned(
                    right: 25,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: 34,
                      width: 140,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Constants.bluecolor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(Assets.schedule),
                          WidgetsUtil.horizontalSpace8,
                          Expanded(
                            child: TitleText(
                              text: "06d 23h 00m",
                              weight: FontWeight.w500,
                              size: 12,
                              textColor: Constants.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 145,
                    child: Column(
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
                            badgeContent: SvgPicture.asset(
                              Assets.crown,
                              height: 30,
                            ),
                            position: BadgePosition.topEnd(end: 5, top: -20),
                            badgeColor: Colors.transparent,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              backgroundImage: CachedNetworkImageProvider(
                                dailyList[1]['profile'],
                              ),
                            ),
                          ),
                        ),
                        WidgetsUtil.verticalSpace20,
                        SizedBox(
                          width: 100,
                          child: TitleText(
                            text: dailyList[1]['name']!.isNotEmpty
                                ? dailyList[1]['name']!
                                : "...",
                            textColor: Constants.white,
                            size: Constants.bodySmall,
                            align: TextAlign.center,
                          ),
                        ),
                        WidgetsUtil.verticalSpace4,
                        _QPContainer(
                          Center(
                            child: TitleText(
                              text: dailyList[1]['score']!.isNotEmpty
                                  ? dailyList[1]['score']!
                                  : "...",
                              size: Constants.bodyXSmall,
                              textColor: Constants.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 60,
                    left: 40,
                    child: Column(
                      children: [
                        Badge(
                          showBadge: true,
                          badgeColor: Colors.transparent,
                          position: BadgePosition.bottomEnd(),
                          elevation: 0,
                          badgeContent: Image.asset(Assets.france),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.transparent,
                            backgroundImage: CachedNetworkImageProvider(
                              dailyList[2]['profile'],
                            ),
                          ),
                        ),
                        WidgetsUtil.verticalSpace20,
                        SizedBox(
                          width: 100,
                          child: TitleText(
                            text: dailyList[2]['name']!.isNotEmpty
                                ? dailyList[2]['name']!
                                : "...",
                            textColor: Constants.white,
                            size: Constants.bodySmall,
                            align: TextAlign.center,
                          ),
                        ),
                        WidgetsUtil.verticalSpace4,
                        _QPContainer(
                          Center(
                            child: TitleText(
                              text: dailyList[2]['score']!.isNotEmpty
                                  ? dailyList[2]['score']!
                                  : "...",
                              size: Constants.bodyXSmall,
                              textColor: Constants.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 110,
                    right: 40,
                    child: Column(
                      children: [
                        Badge(
                          showBadge: true,
                          badgeColor: Colors.transparent,
                          position: BadgePosition.bottomEnd(),
                          elevation: 0,
                          badgeContent: Image.asset(Assets.portugal),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.transparent,
                            backgroundImage: CachedNetworkImageProvider(
                              dailyList[3]['profile'],
                            ),
                          ),
                        ),
                        WidgetsUtil.verticalSpace20,
                        SizedBox(
                          width: 100,
                          child: TitleText(
                            text: dailyList[3]['name']!.isNotEmpty
                                ? dailyList[3]['name']!
                                : "...",
                            textColor: Constants.white,
                            size: Constants.bodySmall,
                            align: TextAlign.center,
                          ),
                        ),
                        WidgetsUtil.verticalSpace4,
                        _QPContainer(
                          Center(
                            child: TitleText(
                              text: dailyList[3]['score']!.isNotEmpty
                                  ? dailyList[3]['score']!
                                  : "...",
                              size: Constants.bodyXSmall,
                              textColor: Constants.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 180,
                    right: 133,
                    left: 132,
                    child: Image.asset(Assets.rank1),
                  ),
                  Positioned(
                    top: 210,
                    right: 243,
                    left: 28,
                    child: Image.asset(Assets.rank2),
                  ),
                  Positioned(
                    top: 260,
                    right: 28,
                    left: 242,
                    child: Image.asset(Assets.rank3),
                  ),
                  leaderBoardList(dailyList, hasMore),
                ]),
              ),
            ],
          );
        });
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
                context
                    .read<LeaderBoardAllTimeCubit>()
                    .fetchMoreLeaderBoardData(
                        "20", context.read<UserDetailsCubit>().getUserId());
              },
              showErrorImage: true,
              errorMessageColor: Theme.of(context).primaryColor,
            );
          }
          final allTimeList =
              (state as LeaderBoardAllTimeSuccess).leaderBoardDetails;
          final hasMore = state.hasMore;
          return Column(
            children: [
              WidgetsUtil.verticalSpace24,
              SizedBox(
                height: SizeConfig.screenHeight,
                child: Stack(children: [
                  Positioned(
                    top: 40,
                    left: 145,
                    child: Column(
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
                            badgeContent: SvgPicture.asset(
                              Assets.crown,
                              height: 30,
                            ),
                            position: BadgePosition.topEnd(end: 5, top: -20),
                            badgeColor: Colors.transparent,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              backgroundImage: CachedNetworkImageProvider(
                                allTimeList[1]['profile'],
                              ),
                            ),
                          ),
                        ),
                        WidgetsUtil.verticalSpace20,
                        SizedBox(
                          width: 100,
                          height: 40,
                          child: TitleText(
                            text: allTimeList[1]['name']!.isNotEmpty
                                ? allTimeList[1]['name']!
                                : "...",
                            textColor: Constants.white,
                            size: Constants.bodySmall,
                            align: TextAlign.center,
                          ),
                        ),
                        WidgetsUtil.verticalSpace4,
                        _QPContainer(
                          Center(
                            child: TitleText(
                              text: allTimeList[1]['score']!.isNotEmpty
                                  ? allTimeList[1]['score']!
                                  : "...",
                              size: Constants.bodyXSmall,
                              textColor: Constants.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 60,
                    left: 40,
                    child: Column(
                      children: [
                        Badge(
                          showBadge: true,
                          badgeColor: Colors.transparent,
                          position: BadgePosition.bottomEnd(),
                          elevation: 0,
                          badgeContent: Image.asset(Assets.france),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.transparent,
                            backgroundImage: CachedNetworkImageProvider(
                              allTimeList[2]['profile'],
                            ),
                          ),
                        ),
                        WidgetsUtil.verticalSpace20,
                        SizedBox(
                          width: 100,
                          child: TitleText(
                            text: allTimeList[2]['name']!.isNotEmpty
                                ? allTimeList[2]['name']!
                                : "...",
                            textColor: Constants.white,
                            size: Constants.bodySmall,
                            align: TextAlign.center,
                          ),
                        ),
                        WidgetsUtil.verticalSpace4,
                        _QPContainer(
                          Center(
                            child: TitleText(
                              text: allTimeList[2]['score']!.isNotEmpty
                                  ? allTimeList[2]['score']!
                                  : "...",
                              size: Constants.bodyXSmall,
                              textColor: Constants.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 110,
                    right: 40,
                    child: Column(
                      children: [
                        Badge(
                          showBadge: true,
                          badgeColor: Colors.transparent,
                          position: BadgePosition.bottomEnd(),
                          elevation: 0,
                          badgeContent: Image.asset(Assets.portugal),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.transparent,
                            backgroundImage: CachedNetworkImageProvider(
                              allTimeList[3]['profile'],
                            ),
                          ),
                        ),
                        WidgetsUtil.verticalSpace20,
                        SizedBox(
                          width: 100,
                          child: TitleText(
                            text: allTimeList[3]['name']!.isNotEmpty
                                ? allTimeList[3]['name']!
                                : "...",
                            textColor: Constants.white,
                            size: Constants.bodySmall,
                            align: TextAlign.center,
                          ),
                        ),
                        WidgetsUtil.verticalSpace4,
                        _QPContainer(
                          Center(
                            child: TitleText(
                              text: allTimeList[3]['score']!.isNotEmpty
                                  ? allTimeList[3]['score']!
                                  : "...",
                              size: Constants.bodyXSmall,
                              textColor: Constants.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 180,
                    right: 133,
                    left: 132,
                    child: Image.asset(Assets.rank1),
                  ),
                  Positioned(
                    top: 210,
                    right: 243,
                    left: 28,
                    child: Image.asset(Assets.rank2),
                  ),
                  Positioned(
                    top: 260,
                    right: 28,
                    left: 242,
                    child: Image.asset(Assets.rank3),
                  ),
                  leaderBoardList(allTimeList, hasMore),
                ]),
              ),
            ],
          );
        });
  }

  Widget leaderBoardList(List leaderBoardList, hasMore) {
    return DraggableScrollableSheet(
        snap: true,
        expand: true,
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: ((context, scrollController) {
          return NotchedCard(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                  color: Constants.grey5,
                  borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                    children: List.generate(leaderBoardList.length, (index) {
                  if (index <= 3) {
                    return SizedBox();
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        height: 100,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16, left: 16),
                            child: Row(children: [
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
                                      text: index.toString(),
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
                                        leaderBoardList[index]['profile'] ??
                                            ""),
                                  ),
                                  title: TitleText(
                                    text: leaderBoardList[index]['name'] ?? "",
                                  ),
                                  subtitle: TitleText(
                                    text:
                                        '${leaderBoardList[index]['score'] ?? "0"}' +
                                            ' points',
                                  ),
                                ),
                              )
                            ]),
                          ),
                        ),
                      ),
                    );
                  }
                })),
              ),
            ),
          );
        }));
  }

  Widget _QPContainer(child) {
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
