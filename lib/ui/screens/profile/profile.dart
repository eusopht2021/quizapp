import 'dart:developer';
import 'package:badges/badges.dart' as bdgs;
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/ui/navigation/navbarcubit.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutterquiz/ui/navigation/navbaritems.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/ui/widgets/badgesIconContainer.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/deleteAccountCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/uploadProfileCubit.dart';
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
import 'package:recase/recase.dart';

class Profile extends StatefulWidget {
  final bool routefromHomeScreen;

  const Profile({
    Key? key,
    required this.routefromHomeScreen,
  }) : super(key: key);

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, bool>;
    log(arguments.toString());
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
        child: Profile(
          routefromHomeScreen: arguments['routefromHomeScreen']!,
        ),
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

  int selectedIndex = 0;

  List<String> statsFilter = [
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  String selectedStat = 'Weekly';

  List<String> tabsTitle = [
    'Badges',
    'Stats',
    'Settings'
    // 'Details',
  ];
  final statisticsDetailsContainerHeightPercentage = 0.145;

  String countryFlag = '';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() async {
        BlocProvider.of<NavigationCubit>(context)
            .getNavBarItem(NavbarItems.newhome);

        if (widget.routefromHomeScreen) {
          return true;
        } else {
          return false;
        }
      }),
      child: DefaultLayout(
        expandBodyBehindAppBar: true,
        showBackButton: widget.routefromHomeScreen,
        title: '',
        action: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
              icon: Icon(
                Icons.settings,
                color: Constants.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, Routes.appSettings,
                    arguments: "newsettingssceeen");
              }),
        ),
        titleColor: Constants.white,
        backgroundColor: Constants.primaryColor,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                Assets.rightCircle,
              ),
            ),
            Positioned(
              top: 83,
              right: 100,
              child: Image.asset(
                Assets.smallDot,
              ),
            ),
            Positioned(
              top: 80,
              left: 0,
              child: Image.asset(
                Assets.leftCircle,
              ),
            ),
            Positioned(
              top: 90,
              left: 80,
              child: Image.asset(
                Assets.smallDot,
              ),
            ),
            Positioned(
              top: 80,
              right: 2,
              left: 2,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(state) {
    return Stack(
      children: [
        SizedBox(
          width: SizeConfig.screenWidth,
          height: SizeConfig.screenHeight - 80,
          child: CustomCard(
            // borderRadius: BorderRadius.all(Radius.circular(20)),
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              top: 70,
              bottom: 8,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  WidgetsUtil.verticalSpace24,
                  WidgetsUtil.verticalSpace24,
                  TitleText(
                    text:
                        "${state.userProfile.name!.isEmpty ? "" : state.userProfile.name!}"
                            .titleCase,
                    size: Constants.heading3,
                    weight: FontWeight.w500,
                    textColor: Constants.black1,
                  ),
                  WidgetsUtil.verticalSpace24,
                  _statsCard(state),
                  WidgetsUtil.verticalSpace16,
                  _tabs(state.userProfile.profileUrl!),
                  // WidgetsUtil.verticalSpace32,
                  // WidgetsUtil.verticalSpace32,
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
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.selectProfile,
                  arguments: false,
                );
              },
              child: bdgs.Badge(
                  toAnimate: false,
                  badgeColor: Constants.white,
                  elevation: 0,
                  position: bdgs.BadgePosition.bottomStart(
                    start: 0,
                  ),
                  badgeContent: Icon(
                    Icons.add_a_photo_outlined,
                    color: Constants.primaryColor,
                  ),
                  child: _avatar(state.userProfile.profileUrl!)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabItem(String profile) {
    switch (selectedIndex) {
      case 0:
        return _buildBadges(context);
      case 1:
        return _statsTabBloc(profile);
      // case 2:
      // return _battle(profile);
      case 2:
        return const SizedBox();
    }
    return const SizedBox();
  }

  List<Badge> _organizedBadges(List<Badge> badges) {
    List<Badge> lockedBadges =
        badges.where((element) => element.status == "0").toList();
    List<Badge> unlockedBadges = badges
        .where((element) => element.status == "1" || element.status == "2")
        .toList();
    unlockedBadges.addAll(lockedBadges);
    return unlockedBadges;
  }

  Widget _buildBadges(BuildContext context) {
    return BlocConsumer<BadgesCubit, BadgesState>(
      listener: (context, state) {
        if (state is BadgesFetchFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      bloc: context.read<BadgesCubit>(),
      builder: (context, state) {
        if (state is BadgesFetchInProgress || state is BadgesInitial) {
          return Center(
            child: CircularProgressIndicator(
              color: Constants.primaryColor,
            ),
          );
        }
        if (state is BadgesFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage)),
              onTapRetry: () {
                context.read<BadgesCubit>().getBadges(
                    userId: context.read<UserDetailsCubit>().getUserId(),
                    refreshBadges: true);
              },
              showErrorImage: true,
            ),
          );
        }
        final List<Badge> badges =
            _organizedBadges((state as BadgesFetchSuccess).badges);
        return GridView.builder(
            clipBehavior: Clip.none,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 0),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 30,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onTap: () {
                      showBadgeDetails(context, badges[index]);
                    },
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // BadgesIconContainer(
                          //   badge: badges[index],
                          //   constraints: constraints,
                          //   addTopPadding: true,
                          // ),
                          Positioned(
                            top: 0,
                            right: 10,
                            left: 10,
                            // bottom: 20,
                            child: Image.asset(
                              badges[index].status == "0"
                                  ? Assets.badgeLocked
                                  : Assets.badges[index],
                              fit: BoxFit.fill,
                            ),
                          ),

                          Positioned(
                            top: SizeConfig.screenWidth * 0.26,
                            // bottom: 0,
                            left: 4,
                            right: 4,
                            child: TitleText(
                              text: badges[index].badgeLabel,
                              align: TextAlign.center,
                              maxlines: 3,
                              textColor: badges[index].status == "0"
                                  ? badgeLockedColor
                                  : Constants.black1, //
                              size: Constants.bodySmall,
                              // height: 1.25,

                              weight: FontWeight.w500,
                            ),
                          ),

                          // badges[index].status == "0"
                          //     ? Positioned(
                          //         top: 50,
                          //         left: 30,
                          //         child: Image.asset(
                          //           Assets.password,
                          //           color: Constants.black1,
                          //           height: 60,
                          //           width: 60,
                          //         ),
                          //       )
                          //     : const SizedBox(),
                        ],
                      ),
                    ),
                  );
                },
              );
            });
      },
    );
  }

  void showBadgeDetails(BuildContext context, Badge badge) {
    showModalBottomSheet(
        elevation: 5.0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        )),
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              color: Constants.secondaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height * (0.25),
                    width: MediaQuery.of(context).size.width * (0.3),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return BadgesIconContainer(
                        badge: badge,
                        constraints: constraints,
                        addTopPadding: true,
                      );
                    })),
                Transform.translate(
                  offset:
                      Offset(0, MediaQuery.of(context).size.height * (-0.05)),
                  child: Column(
                    children: [
                      Text(
                        "${badge.badgeLabel}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: badge.status == "0"
                              ? Constants.white
                              : Constants.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22.5,
                        ),
                      ),
                      const SizedBox(
                        height: 2.5,
                      ),
                      Text(
                        "${badge.badgeNote}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Constants.white,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(
                        height: 2.5,
                      ),
                      //
                      badge.type == "big_thing" && badge.status == "0"
                          ? BlocBuilder<StatisticCubit, StatisticState>(
                              bloc: context.read<StatisticCubit>(),
                              builder: (context, state) {
                                if (state is StatisticInitial ||
                                    state is StatisticFetchInProgress) {
                                  return Center(
                                    child: SizedBox(
                                      height: 15.0,
                                      width: 15.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Constants.white,
                                      ),
                                    ),
                                  );
                                }
                                if (state is StatisticFetchFailure) {
                                  return Container();
                                }
                                final statisticDetails =
                                    (state as StatisticFetchSuccess)
                                        .statisticModel;
                                final answerToGo = int.parse(
                                        badge.badgeCounter) -
                                    int.parse(statisticDetails.correctAnswers);
                                return Column(
                                  children: [
                                    Text(
                                      "${AppLocalization.of(context)!.getTranslatedValues(needMoreKey)!} $answerToGo ${AppLocalization.of(context)!.getTranslatedValues(correctAnswerToUnlockKey)!}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Constants.white,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5.0,
                                    ),
                                  ],
                                );
                              },
                            )
                          : Container(),

                      Text(
                        "${AppLocalization.of(context)!.getTranslatedValues(getKey)!} ${badge.badgeReward} ${AppLocalization.of(context)!.getTranslatedValues(coinsUnlockingByBadgeKey)!}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Constants.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  // Widget _detailsTab(String profile) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         child: Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 16),
  //             width: double.infinity,
  //             height: SizeConfig.screenWidth * 0.8,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(20),
  //               color: Constants.indigoWithOpacity02,
  //             ),
  //             child: Column(
  //               children: [
  //                 WidgetsUtil.verticalSpace16,
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     TitleText(
  //                       text: "Recent matches",
  //                       size: Constants.bodyXLarge,
  //                       weight: FontWeight.w500,
  //                     ),
  //                   ],
  //                 ),
  //                 WidgetsUtil.verticalSpace32,
  //                 Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       bdgs.Badge(
  //                         toAnimate: false,
  //                         elevation: 0,
  //                         showBadge: true,
  //                         badgeContent: Image.asset(Assets.portugal),
  //                         badgeColor: Colors.transparent,
  //                         position: bdgs.BadgePosition.bottomEnd(),
  //                         child: bdgs.Badge(
  //                           toAnimate: false,
  //                           elevation: 0,
  //                           showBadge: true,
  //                           badgeContent: SvgPicture.asset(
  //                             Assets.crown,
  //                             height: 30,
  //                           ),
  //                           position: bdgs.BadgePosition.topStart(
  //                               start: 15, top: -20),
  //                           badgeColor: Colors.transparent,
  //                           child: CircleAvatar(
  //                             radius: 35,
  //                             backgroundColor: Colors.transparent,
  //                             child: CachedNetworkImage(
  //                               imageUrl: profile,
  //                               width: 100,
  //                               height: 100,
  //                               fit: BoxFit.fill,
  //                               placeholder: (_, __) {
  //                                 return CircularProgressIndicator(
  //                                   color: Constants.primaryColor,
  //                                 );
  //                               },
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       TitleText(
  //                         text: "VS",
  //                         size: Constants.bodyXLarge,
  //                         weight: FontWeight.w500,
  //                       ),
  //                       CircleAvatar(
  //                         radius: 35,
  //                         backgroundColor: Colors.transparent,
  //                         backgroundImage: svg.Svg(Assets.man4),
  //                       ),
  //                       Container(
  //                         width: 100,
  //                         height: 50,
  //                         padding: const EdgeInsets.symmetric(
  //                             vertical: 12, horizontal: 12),
  //                         decoration: BoxDecoration(
  //                           color: Constants.lightGreen,
  //                           borderRadius: BorderRadius.circular(9),
  //                         ),
  //                         child: TitleText(
  //                           text: "+100 QP",
  //                           size: Constants.bodyXLarge,
  //                           weight: FontWeight.w500,
  //                           textColor: Constants.white,
  //                         ),
  //                       )
  //                     ]),
  //                 WidgetsUtil.verticalSpace24,
  //                 Divider(
  //                   color: Constants.grey3,
  //                   thickness: 2,
  //                 ),
  //                 WidgetsUtil.verticalSpace32,
  //                 Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       bdgs.Badge(
  //                         toAnimate: false,
  //                         elevation: 0,
  //                         showBadge: true,
  //                         badgeContent: Image.asset(Assets.portugal),
  //                         badgeColor: Colors.transparent,
  //                         position: bdgs.BadgePosition.bottomEnd(),
  //                         child: bdgs.Badge(
  //                           toAnimate: false,
  //                           elevation: 0,
  //                           showBadge: true,
  //                           badgeContent: SvgPicture.asset(
  //                             Assets.crown,
  //                             height: 30,
  //                           ),
  //                           position: bdgs.BadgePosition.topStart(
  //                               start: 15, top: -20),
  //                           badgeColor: Colors.transparent,
  //                           child: CircleAvatar(
  //                             radius: 35,
  //                             backgroundColor: Colors.transparent,
  //                             backgroundImage: NetworkImage(profile),
  //                           ),
  //                         ),
  //                       ),
  //                       TitleText(
  //                         text: "VS",
  //                         size: Constants.bodyXLarge,
  //                         weight: FontWeight.w500,
  //                       ),
  //                       CircleAvatar(
  //                         radius: 35,
  //                         backgroundColor: Colors.transparent,
  //                         backgroundImage: svg.Svg(Assets.man5),
  //                       ),
  //                       Container(
  //                         width: 100,
  //                         height: 50,
  //                         padding: const EdgeInsets.symmetric(
  //                             vertical: 12, horizontal: 12),
  //                         decoration: BoxDecoration(
  //                           color: Constants.lightGreen,
  //                           borderRadius: BorderRadius.circular(9),
  //                         ),
  //                         child: TitleText(
  //                           text: "+100 QP",
  //                           size: Constants.bodyXLarge,
  //                           weight: FontWeight.w500,
  //                           textColor: Constants.white,
  //                         ),
  //                       )
  //                     ]),
  //               ],
  //             )),
  //       ),
  //     ],
  //   );
  // }

  Widget _statsTabBloc(profile) {
    return BlocConsumer<StatisticCubit, StatisticState>(
        listener: (context, state) {
      if (state is StatisticFetchFailure) {
        if (state.errorMessageCode == unauthorizedAccessCode) {
          UiUtils.showAlreadyLoggedInDialog(context: context);
        }
      }
    }, builder: (context, state) {
      if (state is StatisticFetchSuccess) {
        return _statsTabItem(state, profile);
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
      return const SizedBox();
    });
  }

  Widget _statsTabItem(state, profile) {
    StatisticModel model =
        context.read<StatisticCubit>().getStatisticsDetails();
    return SingleChildScrollView(
      child: Column(
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
                // WidgetsUtil.verticalSpace16,
                WidgetsUtil.verticalSpace24,
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: TitleText(
                    text:
                        '${AppLocalization.of(context)!.getTranslatedValues("youHaveAnswered")!} ${_totalAnswers(model.answeredQuestions)} ${AppLocalization.of(context)!.getTranslatedValues("questions")!}!',
                    textColor: Constants.black1,
                    align: TextAlign.center,
                    size: Constants.bodyXLarge,
                    weight: FontWeight.w500,
                  ),
                ),
                WidgetsUtil.verticalSpace16,
                _customDonutchartBloc(),
                WidgetsUtil.verticalSpace16,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _battleContainer(
                            badge: Assets.battle,
                            color: Constants.white,
                            count: model.calculatePlayedBattles().toString(),
                            title: AppLocalization.of(context)!
                                .getTranslatedValues(playedKey)!,
                            badgeColor: Constants.black1,
                          ),
                          WidgetsUtil.horizontalSpace10,
                          // const Spacer(),
                          _battleContainer(
                            badge: Assets.medal,
                            color: Constants.primaryColor,
                            count: model.battleVictories,
                            title: AppLocalization.of(context)!
                                .getTranslatedValues(wonKey)!,
                            badgeColor: Constants.white,
                          ),
                        ],
                      ),
                      WidgetsUtil.verticalSpace10,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _battleContainer(
                            badge: Assets.lost,
                            color: Constants.primaryColor,
                            count: model.battleLoose,
                            title: AppLocalization.of(context)!
                                .getTranslatedValues(lostKey)!,
                            badgeColor: Constants.white,
                          ),
                          WidgetsUtil.horizontalSpace10,
                          // const Spacer(),
                          _battleContainer(
                            badge: Assets.drawn,
                            color: Constants.white,
                            count: model.battleDrawn,
                            title: AppLocalization.of(context)!
                                .getTranslatedValues(drawLbl)!,
                            badgeColor: Constants.black1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                WidgetsUtil.verticalSpace16,
              ],
            ),
          ),
          WidgetsUtil.verticalSpace16,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                height: SizeConfig.screenWidth * 0.8,
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
                      ],
                    ),
                    WidgetsUtil.verticalSpace32,
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          bdgs.Badge(
                            toAnimate: false,
                            elevation: 0,
                            showBadge: true,
                            badgeContent: Image.asset(Assets.portugal),
                            badgeColor: Colors.transparent,
                            position: bdgs.BadgePosition.bottomEnd(),
                            child: bdgs.Badge(
                              toAnimate: false,
                              elevation: 0,
                              showBadge: true,
                              badgeContent: SvgPicture.asset(
                                Assets.crown,
                                height: 30,
                              ),
                              position: bdgs.BadgePosition.topStart(
                                  start: 15, top: -20),
                              badgeColor: Colors.transparent,
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.transparent,
                                // child: CachedNetworkImage(
                                //   imageUrl: profile,
                                //   width: 100,
                                //   height: 100,
                                //   fit: BoxFit.fill,
                                //   placeholder: (_, __) {
                                //     return CircularProgressIndicator(
                                //       color: Constants.primaryColor,
                                //     );
                                //   },
                                // ),
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
                            padding: const EdgeInsets.symmetric(
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
                          bdgs.Badge(
                            toAnimate: false,
                            elevation: 0,
                            showBadge: true,
                            badgeContent: Image.asset(Assets.portugal),
                            badgeColor: Colors.transparent,
                            position: bdgs.BadgePosition.bottomEnd(),
                            child: bdgs.Badge(
                              toAnimate: false,
                              elevation: 0,
                              showBadge: true,
                              badgeContent: SvgPicture.asset(
                                Assets.crown,
                                height: 30,
                              ),
                              position: bdgs.BadgePosition.topStart(
                                  start: 15, top: -20),
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
                            padding: const EdgeInsets.symmetric(
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
          ),
          WidgetsUtil.verticalSpace32,
          // Padding(
          //   padding: EdgeInsets.only(
          //     left: 16,
          //     right: 16,
          //     bottom: widget.routefromHomeScreen
          //         ? kBottomNavigationBarHeight
          //         : kBottomNavigationBarHeight * 2,
          //   ),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(20),
          //       color: Constants.primaryColor,
          //     ),
          //     height: 500,
          //     child: Padding(
          //       padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Row(
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             children: [
          //               Expanded(
          //                 child: TitleText(
          //                   text: "TOP PERFORMANCE",
          //                   size: Constants.bodyXLarge,
          //                   textColor: Constants.white,
          //                   weight: FontWeight.w500,
          //                 ),
          //               ),
          //               Container(
          //                   height: 40,
          //                   width: 40,
          //                   decoration: BoxDecoration(
          //                     color: Constants.white.withOpacity(0.2),
          //                     borderRadius: BorderRadius.circular(12),
          //                   ),
          //                   child: Image.asset(Assets.leaderBoardOutlined)),
          //             ],
          //           ),
          //           WidgetsUtil.verticalSpace16,
          //           // Row(
          //           //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           //   children: [
          //           //     Row(
          //           //       children: [
          //           //         CircleAvatar(
          //           //           radius: 5,
          //           //           backgroundColor: Constants.accent1,
          //           //         ),
          //           //         WidgetsUtil.horizontalSpace8,
          //           //         TitleText(
          //           //           text: 'Math',
          //           //           weight: FontWeight.w500,
          //           //           textColor: Constants.white,
          //           //           align: TextAlign.left,
          //           //         ),
          //           //       ],
          //           //     ),
          //           //     Row(
          //           //       children: [
          //           //         CircleAvatar(
          //           //           radius: 5,
          //           //           backgroundColor: Constants.accent2,
          //           //         ),
          //           //         WidgetsUtil.horizontalSpace8,
          //           //         TitleText(
          //           //           text: 'Sports',
          //           //           weight: FontWeight.w500,
          //           //           textColor: Constants.white,
          //           //           align: TextAlign.left,
          //           //         ),
          //           //       ],
          //           //     ),
          //           //     Row(
          //           //       children: [
          //           //         CircleAvatar(
          //           //           radius: 5,
          //           //           backgroundColor: Constants.secondaryColor,
          //           //         ),
          //           //         WidgetsUtil.horizontalSpace8,
          //           //         TitleText(
          //           //           text: 'Music',
          //           //           weight: FontWeight.w500,
          //           //           textColor: Constants.white,
          //           //           align: TextAlign.left,
          //           //         ),
          //           //       ],
          //           //     ),
          //           //     const SizedBox(
          //           //       width: 20,
          //           //     ),
          //           //   ],
          //           // ),

          //           WidgetsUtil.verticalSpace16,
          //           _customBarchartBloc(),
          //           WidgetsUtil.verticalSpace16,
          //           Expanded(
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 const SizedBox(
          //                   width: 50,
          //                 ),
          //                 Expanded(
          //                   child: Column(
          //                     children: [
          //                       TitleText(
          //                         text:
          //                             '${model.correctAnswers} / ${model.answeredQuestions}',
          //                         weight: FontWeight.w500,
          //                         textColor: Constants.white,
          //                       ),
          //                       SizedBox(
          //                         width: 100,
          //                         child: TitleText(
          //                           text: 'Questions Answered',
          //                           align: TextAlign.center,
          //                           textColor: Constants.white,
          //                           size: Constants.bodyXSmall,
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          // Expanded(
          //   child: Column(
          //     children: [
          //       TitleText(
          //         text: '8/10',
          //         weight: FontWeight.w500,
          //         textColor: Constants.white,
          //       ),
          //       SizedBox(
          //         width: 100,
          //         child: TitleText(
          //           text: 'Questions Answered',
          //           align: TextAlign.center,
          //           size: Constants.bodyXSmall,
          //           textColor: Constants.white,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Expanded(
          //   child: Column(
          //     children: [
          //       TitleText(
          //         text: '6/10',
          //         weight: FontWeight.w500,
          //         textColor: Constants.white,
          //       ),
          //       SizedBox(
          //         width: 100,
          //         child: TitleText(
          //           text: 'Questions Answered',
          //           align: TextAlign.center,
          //           size: Constants.bodyXSmall,
          //           textColor: Constants.white,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          //   ],
          // ),
          //     )
          //   ],
          // ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _battleContainer({
    String? count,
    String? title,
    Color? color,
    String? badge,
    Color? badgeColor,
  }) {
    return bdgs.Badge(
      toAnimate: false,
      elevation: 0,
      badgeColor: Colors.transparent,
      position: bdgs.BadgePosition.topEnd(end: 10, top: 10),
      badgeContent: FittedBox(
        child: Image.asset(
          badge!,
          height: 30,
          width: 30,
          color: badgeColor,
        ),
      ),
      child: Container(
        height: SizeConfig.screenHeight * 0.13,
        width: SizeConfig.screenWidth * 0.38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color!,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            right: 16, left: 16, bottom: 16, top: 16,
            // top: 12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TitleText(
                    text: count!,
                    size: Constants.heading1,
                    weight: FontWeight.w700,
                    textColor: badgeColor),
              ),
              // WidgetsUtil.verticalSpace16,
              Expanded(
                child: TitleText(
                  text: title!,
                  size: Constants.bodySmall,
                  weight: FontWeight.w400,
                  textColor: badgeColor,
                ),
              ),
            ],
          ),
        ),
      ),
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
      return const SizedBox();
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
      return const SizedBox();
    });
  }

  String _correctAnswers(String correctanswers) {
    final numberFormat = NumberFormat.compactCurrency(
      decimalDigits: 0,
      symbol: '',
    );
    String correctanswer =
        numberFormat.format(num.parse(correctanswers).toInt());

    return correctanswer;
  }

  String _totalAnswers(String totalAnswers) {
    final numberFormat = NumberFormat.compactCurrency(
      decimalDigits: 0,
      symbol: '',
    );
    String answeredQuestion =
        numberFormat.format(num.parse(totalAnswers).toInt());

    return answeredQuestion;
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
                text: _correctAnswers(statisticModel.correctAnswers),
                size: Constants.bodyXLarge,
                weight: FontWeight.w700,
                textColor: Constants.black1,
              ),
              TitleText(
                text: "/${_totalAnswers(statisticModel.answeredQuestions)}",
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
                // BarChartRodData(
                //     toY: 80,
                //     fromY: 0,
                //     width: 36,
                //     borderRadius: BorderRadius.circular(8),
                //     color: Constants.accent2),
                // BarChartRodData(
                //     toY: 54,
                //     fromY: 0,
                //     width: 36,
                //     borderRadius: BorderRadius.circular(8),
                //     color: Constants.secondaryColor),
              ]),
            ]),
      ),
    );
  }

  // _badgesTabItem() {
  //   return BlocBuilder<BadgesCubit, BadgesState>(
  //       bloc: context.read<BadgesCubit>(),
  //       builder: (context, state) {
  //         final child = state is BadgesFetchSuccess
  //             ? context.read<BadgesCubit>().getUnlockedBadges().isEmpty
  //                 ? Container()
  //                 : SizedBox(
  //                     height: 300,
  //                     child: GridView.count(
  //                       padding: EdgeInsets.zero,
  //                       crossAxisCount: 3,
  //                       children: (context
  //                               .read<BadgesCubit>()
  //                               .getUnlockedBadges()
  //                               .map((badge) => BadgesIconContainer(
  //                                     badge: badge,
  //                                     constraints: const BoxConstraints(
  //                                         maxHeight: 160, maxWidth: 100),
  //                                     addTopPadding: false,
  //                                   ))
  //                               .toList()
  //                           // children: List.generate(
  //                           //   Assets.badges.length,
  //                           //   (index) {
  //                           //     return Image.asset(
  //                           //       Assets.badges[index],
  //                           //     );
  //                           ),
  //                     ),
  //                   )
  //             : const SizedBox();
  //         return SizedBox(
  //           child: child,
  //         );
  //       });
  // }

  Widget _tabs(profile) {
    return Column(
      children: [
        //tabs
        Row(
          children: List.generate(
            tabsTitle.length,
            (index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (index == 2) {
                      Navigator.pushNamed(
                        context,
                        Routes.appSettings,
                        arguments: "newsettingssceeen",
                      );
                    } else {
                      setState(() {
                        selectedIndex = index;
                      });
                    }
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
        // WidgetsUtil.verticalSpace32,
        WidgetsUtil.verticalSpace16,
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
              asset: Assets.star,
              title: AppLocalization.of(context)!
                  .getTranslatedValues("points")!
                  .toUpperCase(),
              value: state.userProfile.allTimeScore,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: rowItem(
              asset: Assets.world,
              title: AppLocalization.of(context)!
                  .getTranslatedValues("rankLbl")!
                  .toUpperCase(),
              value: '#${state.userProfile.allTimeRank}',
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: rowItem(
              asset: Assets.coinIcon, //local
              title: AppLocalization.of(context)!
                  .getTranslatedValues("coinsLbl")!
                  .toUpperCase(),
              value: '${state.userProfile.coins}',
            ),
          ),
        ],
      ),
    );
  }

  Column rowItem({String? asset, String? title, String? value, String? icon}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        asset!.contains('png')
            ? Image.asset(
                asset,
                width: 24,
                height: 24,
                color: Constants.white,
              )
            : SvgPicture.asset(asset),
        Container(
          margin: const EdgeInsets.only(top: 6),
          child: TitleText(
            text: title!,
            size: Constants.bodyXSmall,
            weight: FontWeight.w500,
            textColor: Constants.white.withOpacity(0.5),
          ),
        ),
        TitleText(
          text: value!,
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
    final box = Hive.box(userdetailsBox);
    // box.add(countryFlag);
    if (box.containsKey('user_flag')) {
      countryFlag = box.get('user_flag');
    }
    return GestureDetector(
      onTap: () {
        showCountryPicker(
            context: context,
            onSelect: (country) {
              countryFlag = country.flagEmoji;
              box.put('user_flag', countryFlag);
              setState(() {});
            });
      },
      child: bdgs.Badge(
        toAnimate: false,
        badgeContent: countryFlag.isNotEmpty
            ? CircleAvatar(
                backgroundColor: Constants.white,
                radius: 16,
                child: Text(
                  countryFlag,
                  style: const TextStyle(fontSize: 20),
                ),
              )
            : Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Constants.primaryColor.withOpacity(0.5),
                  ),
                  color: Constants.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  Icons.flag_circle,
                  color: Constants.white,
                ),
              ),
        position: bdgs.BadgePosition.bottomEnd(end: 0, bottom: -12),
        elevation: 0,
        badgeColor: Colors.transparent,
        child: ClipOval(
          clipBehavior: Clip.antiAlias,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.transparent,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.fill,
              placeholder: (_, __) {
                return CircularProgressIndicator(
                  color: Constants.primaryColor,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
