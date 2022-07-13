import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/audioQuestionBookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guessTheWordBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/deleteAccountCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/uploadProfileCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/statistic/cubits/statisticsCubit.dart';
import 'package:flutterquiz/features/statistic/models/statisticModel.dart';
import 'package:flutterquiz/features/statistic/statisticRepository.dart';
import 'package:flutterquiz/ui/widgets/custom_card.dart';
import 'package:flutterquiz/ui/widgets/custom_donut_chart.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<DeleteAccountCubit>(
              create: (_) => DeleteAccountCubit(ProfileManagementRepository())),
          BlocProvider<UploadProfileCubit>(
            create: (context) => UploadProfileCubit(
              ProfileManagementRepository(),
            ),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (context) => UpdateUserDetailCubit(
              ProfileManagementRepository(),
            ),
          ),
          BlocProvider<StatisticCubit>(
            create: (_) => StatisticCubit(
              StatisticRepository(),
            ),
          ),
        ],
        child: Profile(),
      ),
    );
  }

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context
          .read<StatisticCubit>()
          .getStatisticWithBattle(context.read<UserDetailsCubit>().getUserId());

      setState(() {});
    });
  }

  int selectedIndex = 1;

  List<String> statsFilter = [
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  String selectedStat = 'Weekly';

  List<String> tabsTitle = [
    'Badges',
    'Stats',
    'Details',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      showBackButton: false,
      title: '',
      action: IconButton(
        icon: Icon(
          Icons.settings,
          color: Constants.white,
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues("logoutDialogLbl")!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();

                            context
                                .read<BadgesCubit>()
                                .updateState(BadgesInitial());
                            context
                                .read<BookmarkCubit>()
                                .updateState(BookmarkInitial());
                            context
                                .read<GuessTheWordBookmarkCubit>()
                                .updateState(GuessTheWordBookmarkInitial());

                            context
                                .read<AudioQuestionBookmarkCubit>()
                                .updateState(AudioQuestionBookmarkInitial());

                            context.read<AuthCubit>().signOut();
                            Navigator.of(context)
                                .pushReplacementNamed(Routes.loginScreen);
                          },
                          child: Text(
                            AppLocalization.of(context)!
                                .getTranslatedValues("yesBtn")!,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          )),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            AppLocalization.of(context)!
                                .getTranslatedValues("noBtn")!,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          )),
                    ],
                  ));

          log('Settings');
        },
      ),
      titleColor: Constants.white,
      backgroundColor: Constants.primaryColor,
      child: BlocConsumer<UploadProfileCubit, UploadProfileState>(
        listener: (context, state) {
          if (state is UploadProfileFailure) {
            UiUtils.setSnackbar(
                AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(state.errorMessage))!,
                context,
                false);
          } else if (state is UploadProfileSuccess) {
            context
                .read<UserDetailsCubit>()
                .updateUserProfileUrl(state.imageUrl);
          }
        },
        builder: (context, state) {
          return BlocBuilder<UserDetailsCubit, UserDetailsState>(
            bloc: context.read<UserDetailsCubit>(),
            builder: (BuildContext context, UserDetailsState state) {
              if (state is UserDetailsFetchSuccess) {
                return _body(state);
              }
              return const SizedBox();
            },
          );
        },
      ),
    );
  }

  Widget _body(state) {
    return Stack(
      children: [
        CustomCard(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            top: 70,
            bottom: 16,
          ),
          child: SizedBox(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  WidgetsUtil.verticalSpace24,
                  WidgetsUtil.verticalSpace24,
                  TitleText(
                    text: state.userProfile.name!.isEmpty
                        ? ""
                        : state.userProfile.name!,
                    size: Constants.heading3,
                    weight: FontWeight.w500,
                    textColor: Constants.black1,
                  ),
                  WidgetsUtil.verticalSpace24,
                  _statsCard(state),
                  WidgetsUtil.verticalSpace16,
                  _tabs(state.userProfile.profileUrl!),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          child: Center(
            child: _avatar(state.userProfile.profileUrl!),
          ),
        ),
      ],
    );
  }

  Widget _tabItem(String profile) {
    switch (selectedIndex) {
      case 0:
        return _badgesTabItem();
      case 1:
        return _statsTabBloc();
      case 2:
        return _detailsTab(profile);
    }
    return const SizedBox();
  }

  Widget _detailsTab(String profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Constants.indigoWithOpacity02,
              ),
              child: Column(
                children: [
                  WidgetsUtil.verticalSpace16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TitleText(
                        text: "Recent matches",
                        size: Constants.bodyXLarge,
                        weight: FontWeight.w500,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Constants.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          height: 34,
                          alignment: Alignment.center,
                          child: DropdownButton<String>(
                            icon: const Icon(
                              CupertinoIcons.chevron_down,
                            ),
                            value: selectedStat,
                            items: statsFilter.map((item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: TitleText(
                                  text: item,
                                  size: Constants.bodyXSmall,
                                  weight: FontWeight.w500,
                                  textColor: Constants.black1,
                                ),
                              );
                            }).toList(),
                            underline: const SizedBox(),
                            onChanged: (String? value) {
                              log('OnChanged: $value');
                              setState(() {
                                selectedStat = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  WidgetsUtil.verticalSpace32,
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            position:
                                BadgePosition.topStart(start: 15, top: -20),
                            badgeColor: Colors.transparent,
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.transparent,
                              backgroundImage: NetworkImage(profile),
                            ),
                          ),
                        ),
                        TitleText(
                          text: "VS",
                          size: Constants.bodyXLarge,
                          weight: FontWeight.w500,
                        ),
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.transparent,
                          backgroundImage: svg.Svg(Assets.man4),
                        ),
                        Container(
                          width: 100,
                          height: 50,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Constants.lightGreen,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: TitleText(
                            text: "+100 QP",
                            size: Constants.bodyXLarge,
                            weight: FontWeight.w500,
                            textColor: Constants.white,
                          ),
                        )
                      ]),
                  WidgetsUtil.verticalSpace24,
                  Divider(
                    color: Constants.grey3,
                    thickness: 2,
                  ),
                  WidgetsUtil.verticalSpace32,
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            position:
                                BadgePosition.topStart(start: 15, top: -20),
                            badgeColor: Colors.transparent,
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.transparent,
                              backgroundImage: NetworkImage(profile),
                            ),
                          ),
                        ),
                        TitleText(
                          text: "VS",
                          size: Constants.bodyXLarge,
                          weight: FontWeight.w500,
                        ),
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.transparent,
                          backgroundImage: svg.Svg(Assets.man5),
                        ),
                        Container(
                          width: 100,
                          height: 50,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Constants.lightGreen,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: TitleText(
                            text: "+100 QP",
                            size: Constants.bodyXLarge,
                            weight: FontWeight.w500,
                            textColor: Constants.white,
                          ),
                        )
                      ]),
                ],
              )),
        )
      ],
    );
  }

  Widget _statsTabBloc() {
    return BlocConsumer<StatisticCubit, StatisticState>(
        listener: (context, state) {
      if (state is StatisticFetchFailure) {
        if (state.errorMessageCode == unauthorizedAccessCode) {
          UiUtils.showAlreadyLoggedInDialog(context: context);
        }
      }
    }, builder: (context, state) {
      if (state is StatisticFetchSuccess) {
        return _statsTabItem();
      }
      if (state is StatisticFetchInProgress) {
        return SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            color: Constants.primaryColor,
          ),
        );
      }
      return SizedBox();
    });
  }

  Column _statsTabItem() {
    StatisticModel model =
        context.read<StatisticCubit>().getStatisticsDetails();
    return Column(
      children: [
        Container(
          width: SizeConfig.screenWidth,
          margin: const EdgeInsets.only(
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              Constants.cardsRadius,
            ),
            image: DecorationImage(
              image: AssetImage(
                Assets.swivels1,
              ),
              alignment: Alignment.topLeft,
            ),
            color: const Color(0xffE8E5FA),
          ),
          child: Column(
            children: [
              WidgetsUtil.verticalSpace16,
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Constants.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(
                    right: 16,
                  ),
                  height: 34,
                  width: 100,
                  alignment: Alignment.center,
                  child: DropdownButton<String>(
                    icon: const Icon(
                      CupertinoIcons.chevron_down,
                    ),
                    value: selectedStat,
                    items: statsFilter.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: TitleText(
                          text: item,
                          size: Constants.bodyXSmall,
                          weight: FontWeight.w500,
                          textColor: Constants.black1,
                        ),
                      );
                    }).toList(),
                    underline: const SizedBox(),
                    onChanged: (String? value) {
                      log('OnChanged: $value');
                      setState(() {
                        selectedStat = value!;
                      });
                    },
                  ),
                ),
              ),
              WidgetsUtil.verticalSpace24,
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                child: TitleText(
                  text: 'You have played a total 24 quizzes this month!',
                  textColor: Constants.black1,
                  align: TextAlign.center,
                  size: Constants.bodyXLarge,
                  weight: FontWeight.w500,
                ),
              ),
              WidgetsUtil.verticalSpace16,
              _customDonutchartBloc(),
              WidgetsUtil.verticalSpace16,
            ],
          ),
        ),
        WidgetsUtil.verticalSpace32,
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Constants.primaryColor,
            ),
            height: 500,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TitleText(
                          text: "Top performance by category",
                          size: Constants.bodyXLarge,
                          textColor: Constants.white,
                          weight: FontWeight.w500,
                        ),
                      ),
                      Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Constants.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(Assets.leaderBoardOutlined)),
                    ],
                  ),
                  WidgetsUtil.verticalSpace16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: Constants.accent1,
                            ),
                            WidgetsUtil.horizontalSpace8,
                            TitleText(
                              text: 'Math',
                              weight: FontWeight.w500,
                              textColor: Constants.white,
                              align: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: Constants.accent2,
                            ),
                            WidgetsUtil.horizontalSpace8,
                            TitleText(
                              text: 'Sports',
                              weight: FontWeight.w500,
                              textColor: Constants.white,
                              align: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: Constants.secondaryColor,
                            ),
                            WidgetsUtil.horizontalSpace8,
                            TitleText(
                              text: 'Music',
                              weight: FontWeight.w500,
                              textColor: Constants.white,
                              align: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  WidgetsUtil.verticalSpace16,
                  _customBarchartBloc(),
                  WidgetsUtil.verticalSpace16,
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              TitleText(
                                text:
                                    '${model.correctAnswers} / ${model.answeredQuestions}',
                                weight: FontWeight.w500,
                                textColor: Constants.white,
                              ),
                              SizedBox(
                                width: 100,
                                child: TitleText(
                                  text: 'Questions Answered',
                                  align: TextAlign.center,
                                  textColor: Constants.white,
                                  size: Constants.bodyXSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              TitleText(
                                text: '8/10',
                                weight: FontWeight.w500,
                                textColor: Constants.white,
                              ),
                              SizedBox(
                                width: 100,
                                child: TitleText(
                                  text: 'Questions Answered',
                                  align: TextAlign.center,
                                  size: Constants.bodyXSmall,
                                  textColor: Constants.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              TitleText(
                                text: '6/10',
                                weight: FontWeight.w500,
                                textColor: Constants.white,
                              ),
                              SizedBox(
                                width: 100,
                                child: TitleText(
                                  text: 'Questions Answered',
                                  align: TextAlign.center,
                                  size: Constants.bodyXSmall,
                                  textColor: Constants.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _customDonutchartBloc() {
    return BlocConsumer<StatisticCubit, StatisticState>(
        listener: (context, state) {
      if (state is StatisticFetchFailure) {
        if (state.errorMessageCode == unauthorizedAccessCode) {
          UiUtils.showAlreadyLoggedInDialog(context: context);
        }
      }
    }, builder: (context, state) {
      if (state is StatisticFetchSuccess) {
        return _customDonutchart();
      }
      if (state is StatisticFetchInProgress) {
        return SizedBox(
          height: 50,
          width: 50,
          child: Center(
            child: CircularProgressIndicator(
              color: Constants.primaryColor,
            ),
          ),
        );
      }
      return SizedBox();
    });
  }

  double getValue1(StatisticModel model) {
    log('Values are ${model.answeredQuestions} and ${model.correctAnswers}');
    int totalQuestions = int.parse(model.answeredQuestions);
    int correctAnswers = int.parse(model.correctAnswers);
    double percentage = (correctAnswers / totalQuestions) * 100;
    return percentage;
  }

  double getValue2(StatisticModel model) {
    int totalQuestions = int.parse(model.answeredQuestions);
    int correctAnswers = int.parse(model.correctAnswers);
    double percentage =
        ((totalQuestions - correctAnswers) / totalQuestions) * 100;

    return percentage;
  }

  Widget _customBarchartBloc() {
    return BlocConsumer<StatisticCubit, StatisticState>(
        listener: (context, state) {
      if (state is StatisticFetchFailure) {
        if (state.errorMessageCode == unauthorizedAccessCode) {
          UiUtils.showAlreadyLoggedInDialog(context: context);
        }
      }
    }, builder: (context, state) {
      if (state is StatisticFetchSuccess) {
        return _customBarChart();
      }
      if (state is StatisticFetchInProgress) {
        return SizedBox(
          height: 50,
          width: 50,
          child: Center(
            child: CircularProgressIndicator(
              color: Constants.primaryColor,
            ),
          ),
        );
      }
      return SizedBox();
    });
  }

  Widget _customDonutchart() {
    StatisticModel statisticModel =
        context.read<StatisticCubit>().getStatisticsDetails();

    return CustomDonutChart(
      height: 148,
      radius: 10,
      value1: getValue1(statisticModel),
      value2: getValue2(statisticModel),
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TitleText(
                text: statisticModel.correctAnswers,
                size: Constants.heading1,
                weight: FontWeight.w700,
                textColor: Constants.black1,
              ),
              TitleText(
                text: '/${statisticModel.answeredQuestions}',
                size: Constants.bodyNormal,
                weight: FontWeight.w500,
                textColor: Constants.grey2,
              ),
            ],
          ),
          TitleText(
            text: 'Q\'s Attempted',
            weight: FontWeight.w500,
            size: 11,
            textColor: Constants.grey2,
          ),
        ],
      ),
    );
  }

  Widget _customBarChart() {
    StatisticModel model =
        context.read<StatisticCubit>().getStatisticsDetails();
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
            barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Constants.white,
            )),
            baselineY: 0.1,
            minY: 0,
            maxY: 100,
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    reservedSize: 50,
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return TitleText(
                        text: "${(value.toInt())}%",
                        textColor: Constants.white,
                        align: TextAlign.left,
                      );
                    }),
              ),
              rightTitles: AxisTitles(),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                left: BorderSide.none,
                right: BorderSide.none,
                top: BorderSide.none,
              ),
            ),
            gridData: FlGridData(
                horizontalInterval: 20,
                drawVerticalLine: false,
                drawHorizontalLine: true,
                getDrawingHorizontalLine: (_) {
                  return FlLine(color: Constants.white, dashArray: [8]);
                }),
            barGroups: [
              BarChartGroupData(x: 0, barsSpace: 50, barRods: [
                BarChartRodData(
                    toY: getValue1(model).toInt().toDouble(),
                    fromY: 0,
                    width: 35,
                    borderRadius: BorderRadius.circular(8),
                    color: Constants.accent1),
                BarChartRodData(
                    toY: 80,
                    fromY: 0,
                    width: 36,
                    borderRadius: BorderRadius.circular(8),
                    color: Constants.accent2),
                BarChartRodData(
                    toY: 54,
                    fromY: 0,
                    width: 36,
                    borderRadius: BorderRadius.circular(8),
                    color: Constants.secondaryColor),
              ]),
            ]),
      ),
    );
  }

  SizedBox _badgesTabItem() {
    return SizedBox(
      height: 300,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        children: List.generate(
          Assets.badges.length,
          (index) {
            return Image.asset(
              Assets.badges[index],
            );
          },
        ),
      ),
    );
  }

  Widget _tabs(profile) {
    return Column(
      children: [
        //tabs
        Row(
          children: List.generate(
            3,
            (index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Column(
                    children: [
                      TitleText(
                        text: tabsTitle[index],
                        size: Constants.bodySmall,
                        textColor: selectedIndex == index
                            ? Constants.primaryColor
                            : Constants.grey2,
                        weight: selectedIndex == index
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                      WidgetsUtil.verticalSpace8,
                      AnimatedContainer(
                        width: 6,
                        height: 6,
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedIndex == index
                              ? Constants.primaryColor
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        //tabItems
        WidgetsUtil.verticalSpace16,
        _tabItem(profile),
      ],
    );
  }

  Container _statsCard(state) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Constants.primaryColor,
        borderRadius: BorderRadius.circular(
          Constants.cardsRadius,
        ),
      ),
      height: 100,
      width: SizeConfig.screenWidth,
      child: Row(
        children: [
          Expanded(
            child: rowItem(
              Assets.star,
              'POINTS',
              state.userProfile.allTimeScore,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: rowItem(
              Assets.world,
              'WORLD RANK',
              '#${state.userProfile.allTimeRank}',
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: rowItem(
              Assets.local,
              'LOCAL RANK',
              '#${state.userProfile.status}',
            ),
          ),
        ],
      ),
    );
  }

  Column rowItem(String asset, String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          asset,
          width: 24,
          height: 24,
        ),
        Container(
          margin: const EdgeInsets.only(top: 6),
          child: TitleText(
            text: title,
            size: Constants.bodyXSmall,
            weight: FontWeight.w500,
            textColor: Constants.white.withOpacity(0.5),
          ),
        ),
        TitleText(
          text: value,
          size: Constants.bodyNormal,
          weight: FontWeight.w700,
          textColor: Constants.white,
        ),
      ],
    );
  }

  Padding _verticalDivider() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 16,
      ),
      child: VerticalDivider(
        color: Constants.white,
      ),
    );
  }

  Widget _avatar(String imageUrl) {
    return Badge(
      badgeContent: Image.asset(
        Assets.turkey,
        width: 30,
        height: 28,
      ),
      position: BadgePosition.bottomEnd(),
      elevation: 0,
      badgeColor: Colors.transparent,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 96,
        height: 96,
      ),
    );
  }
}
