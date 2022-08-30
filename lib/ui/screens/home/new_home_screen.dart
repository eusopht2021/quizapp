import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/interstitialAdCubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementLocalDataSource.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/randomOrPlayFrdDialog.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/roomDialog.dart';
import 'package:flutterquiz/ui/screens/home/widgets/appUnderMaintenanceDialog.dart';
import 'package:flutterquiz/ui/screens/profile/widgets/editProfileFieldBottomSheetContainer.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/quizTypes.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:recase/recase.dart';

import '../../../features/auth/authRepository.dart';
import '../../../features/auth/cubits/referAndEarnCubit.dart';
import '../../../features/profileManagement/cubits/userDetailsCubit.dart';
import '../../../features/quiz/models/quizType.dart';
import '../../../utils/assets.dart';
import '../../../utils/constants.dart';
import '../../../utils/style_properties.dart';
import '../../../utils/widgets_util.dart';
import '../../widgets/title_text.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({Key? key}) : super(key: key);

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<ReferAndEarnCubit>(
            create: (_) => ReferAndEarnCubit(
              AuthRepository(),
            ),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (context) => UpdateUserDetailCubit(
              ProfileManagementRepository(),
            ),
          ),
        ],
        child: const NewHomeScreen(),
      ),
    );
  }
}

class _NewHomeScreenState extends State<NewHomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final double quizTypeWidthPercentage = 0.4;
  late double quizTypeTopMargin = 0.0;
  final double quizTypeHorizontalMarginPercentage = 0.08;
  final List<int> maxHeightQuizTypeIndexes = [0, 3, 4, 7, 8];

  final double quizTypeBetweenVerticalSpacing = 0.02;

  final List<QuizType> _quizTypes = quizTypes;

  late AnimationController profileAnimationController;
  late AnimationController selfChallengeAnimationController;

  late Animation<Offset> profileSlideAnimation;

  late Animation<Offset> selfChallengeSlideAnimation;

  late AnimationController firstAnimationController;
  late Animation<double> firstAnimation;
  late AnimationController secondAnimationController;
  late Animation<double> secondAnimation;

  bool? dragUP;
  int currentMenu = 1;
  bool routefromHomeScreen = false;
  int? selectedIndex;
  bool? showDescription = false;
  final descriptions = <int>[];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    initAnimations();
    showAppUnderMaintenanceDialog();
    setQuizMenu();
    _initLocalNotification();
    checkForUpdates();
    setupInteractedMessage();
    createAds();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    ProfileManagementLocalDataSource.updateReversedCoins(0);
    scrollController.dispose();
    profileAnimationController.dispose();
    selfChallengeAnimationController.dispose();
    firstAnimationController.dispose();
    secondAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ScrollController scrollController = ScrollController();
  int? index;
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).primaryColor,
      child: BlocConsumer<UserDetailsCubit, UserDetailsState>(
        bloc: context.read<UserDetailsCubit>(),
        builder: (context, state) {
          if (state is UserDetailsFetchInProgress ||
              state is UserDetailsInitial) {
            return Center(
                child: CircularProgressIndicator(
              color: Constants.white,
            ));
          }
          if (state is UserDetailsFetchFailure) {
            return Center(
              child: Container(
                  padding: const EdgeInsets.all(20),
                  width: SizeConfig.screenWidth,
                  color: Constants.secondaryColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50)),
                          child: Image.asset(
                            Assets.lightIcon,
                            color: Constants.grey4,
                            colorBlendMode: BlendMode.overlay,
                          ),
                        ),
                      ),
                      WidgetsUtil.verticalSpace20,
                      const Expanded(
                        flex: 2,
                        child: TitleText(
                          align: TextAlign.center,
                          text: 'Error !! something is wrong!',
                          size: 30,
                          textColor: Colors.white,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )),
            );
          }
          UserProfile userProfile =
              (state as UserDetailsFetchSuccess).userProfile;
          if (userProfile.status == "0") {
            return const Center(
              child: Text('Error something is wrong!'),
            );
          }
          return Column(children: [
            Container(
              margin: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 50,
                bottom: 10,
              ),
              height: kToolbarHeight,
              child: Row(
                children: [
                  Expanded(
                    flex: 9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(Assets.sunIcon),
                            WidgetsUtil.horizontalSpace8,
                            Expanded(
                              child: TitleText(
                                text: greetingMessage(),
                                textColor: Constants.accent1,
                                size: Constants.bodyXSmall,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        TitleText(
                          text: state.userProfile.name!.titleCase,
                          textColor: Constants.white,
                          size: Constants.heading3,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: (() {
                        log("message");
                        Navigator.of(context)
                            .pushNamed(Routes.profile, arguments: {
                          "routefromHomeScreen": true,
                        });
                      }),
                      child: CircleAvatar(
                        backgroundColor: Constants.pink,
                        backgroundImage: CachedNetworkImageProvider(
                          state.userProfile.profileUrl!,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //body

            Expanded(
                child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                // GestureDetector(
                //   onTap: () {},
                //   child: Container(
                //     height: 84,
                //     width: SizeConfig.screenWidth,
                //     margin: const EdgeInsets.only(
                //       left: 24,
                //       right: 24,
                //     ),
                //     clipBehavior: Clip.antiAlias,
                //     decoration: BoxDecoration(
                //       image: DecorationImage(
                //         image: AssetImage(
                //           Assets.swivels,
                //         ),
                //       ),
                //       borderRadius: BorderRadius.circular(20),
                //       color: Constants.secondaryAccent,
                //     ),
                //     child: Row(
                //       children: [
                //         Expanded(
                //           flex: 10,
                //           child: Container(
                //             margin: const EdgeInsets.only(
                //               left: 24,
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 WidgetsUtil.verticalSpace16,
                //                 TitleText(
                //                   text: 'Recent Quiz'.toUpperCase(),
                //                   size: Constants.bodySmall,
                //                   weight: FontWeight.w500,
                //                   textColor: Constants.secondaryTextColor,
                //                 ),
                //                 WidgetsUtil.verticalSpace8,
                //                 Expanded(
                //                   child: Row(
                //                     mainAxisAlignment:
                //                         MainAxisAlignment.spaceAround,
                //                     children: [
                //                       Expanded(
                //                         flex: 0,
                //                         child: Icon(
                //                           Icons.headphones,
                //                           color: Constants.secondaryTextColor,
                //                         ),
                //                       ),
                //                       WidgetsUtil.horizontalSpace8,
                //                       Expanded(
                //                         flex: 14,
                //                         child: TitleText(
                //                           text: 'A Basic Music Quiz',
                //                           size: Constants.bodyLarge,
                //                           weight: FontWeight.w500,
                //                           textColor:
                //                               Constants.secondaryTextColor,
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //         const Expanded(
                //           flex: 3,
                //           child: CustomPieChart(
                //             value1: 88,
                //             value2: 12,
                //             radius: 24,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                WidgetsUtil.verticalSpace8,
                _buildSelfChallenge(),

                // Container(
                //   margin: const EdgeInsets.only(
                //     left: 24,
                //     right: 24,
                //   ),
                //   decoration: BoxDecoration(
                //     color: Constants.grey3.withOpacity(0.4),
                //     borderRadius: BorderRadius.circular(20),
                //     image: DecorationImage(
                //       fit: BoxFit.fill,
                //       image: AssetImage(Assets.cardCircles),
                //     ),
                //   ),
                //   child:

                //   Column(
                //     // mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       // WidgetsUtil.verticalSpace16,
                //       // Row(s
                //       //   // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //       //   children: [
                //       //     Expanded(
                //       //       flex: 2,
                //       //       child: SvgPicture.asset(
                //       //         Assets.man9,
                //       //         height: 48,
                //       //         width: 48,
                //       //       ),
                //       //     ),
                //       //     Expanded(
                //       //       flex: 6,
                //       //       child: Center(
                //       //         child: TitleText(
                //       //           text: AppLocalization.of(context)!
                //       //               .getTranslatedValues("featured")!
                //       //               .toUpperCase(),
                //       //           size: Constants.bodySmall,
                //       //           textColor: Constants.white,
                //       //           weight: FontWeight.w500,
                //       //         ),
                //       //       ),
                //       //     ),
                //       //     const Expanded(
                //       //       flex: 2,
                //       //       child: SizedBox(),
                //       //     ),
                //       //   ],
                //       // ),
                //       // Padding(
                //       //   padding: const EdgeInsets.only(
                //       //     left: 40,
                //       //     right: 40,
                //       //   ),
                //       //   child: TitleText(
                //       //     text: AppLocalization.of(context)!
                //       //         .getTranslatedValues("takepartLbl")!,
                //       //     size: Constants.bodyLarge,
                //       //     align: TextAlign.center,
                //       //     weight: FontWeight.w500,
                //       //     textColor: Constants.white,
                //       //   ),
                //       // ),
                //       // WidgetsUtil.verticalSpace16,
                //       // SizedBox(
                //       //   // width: SizeConfig.screenWidth,
                //       //   child: Row(
                //       //     mainAxisAlignment: MainAxisAlignment.center,
                //       //     children: [
                //       //       const Spacer(),
                //       //       Expanded(
                //       //         flex: 3,
                //       //         child: SocialButton(
                //       //           horizontalMargin: 10,
                //       //           textColor: Theme.of(context).primaryColor,
                //       //           iconColor: Theme.of(context).primaryColor,
                //       //           background: Constants.white,
                //       //           icon: Assets.findFriendsIcon,
                //       //           itemSpace: 12,
                //       //           onTap: () {
                //       //             BlocProvider.of<NavigationCubit>(context)
                //       //                 .getNavBarItem(NavbarItems.discover);
                //       //           },
                //       //           height: 44,
                //       //           text: AppLocalization.of(context)!
                //       //               .getTranslatedValues("findFriendsLbs")!,
                //       //           showBorder: false,
                //       //         ),
                //       //       ),
                //       //       // const Spacer(),
                //       //       Expanded(
                //       //         child: SvgPicture.asset(
                //       //           Assets.womanWave,
                //       //           height: 48,
                //       //           width: 48,
                //       //         ),
                //       //       ),
                //       //       WidgetsUtil.horizontalSpace16,
                //       //     ],
                //       //   ),
                //       // ),
                //       // WidgetsUtil.verticalSpace16,

                //     ],
                //   ),
                // ),
                WidgetsUtil.verticalSpace16,
                Container(
                  margin: EdgeInsets.zero,
                  decoration: StyleProperties.sheetBorder,
                  padding: StyleProperties.insets18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // WidgetsUtil.verticalSpace8,
                      TitleText(
                        text: AppLocalization.of(context)!
                            .getTranslatedValues("liveQuizzes")!,
                        size: Constants.bodyXLarge,
                        textColor: Constants.black1,
                        weight: FontWeight.w500,
                      ),

                      // WidgetsUtil.verticalSpace16,

                      GridView.builder(
                        clipBehavior: Clip.none,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                            top: 16, right: 0, left: 0, bottom: kToolbarHeight),
                        itemCount: _quizTypes.length,
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          // childAspectRatio: 1,
                          mainAxisExtent: 115,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          crossAxisCount: 2,
                        ),
                        itemBuilder: ((context, index) {
                          // log(categoryList.length.toString() + " lists");
                          bool checked = index == selectedIndex;

                          return categoryCard(
                            mainIconColor: checked
                                ? Theme.of(context).primaryColor
                                : Constants.white,
                            showDesc: descriptions.contains(index),
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                                _navigateToQuizZone(index + 1);
                              });
                            },
                            onTapIcon: () {
                              if (descriptions.contains(index)) {
                                descriptions.remove(index);
                              } else {
                                descriptions.add(index);
                              }

                              setState(() {});
                            },
                            iconColor: checked
                                ? Constants.white
                                : Theme.of(context).primaryColor,
                            iconShadowOpacity: checked ? 0.2 : 1,
                            quizDescription: AppLocalization.of(context)!
                                .getTranslatedValues(
                                    _quizTypes[index].description),
                            icon: _quizTypes[index].image,
                            backgroundColor:
                                checked ? Constants.pink : Constants.grey5,
                            categoryName: _quizTypes[index].getTitle(context),
                            textColor: checked
                                ? Constants.white
                                : Theme.of(context).primaryColor,
                          );
                        }),
                      ),

                      // ...List.generate(_quizTypes.length, (index) {
                      //   return QuizCategoryCard(
                      //     name: _quizTypes[index].getTitle(context),
                      //     asset: _quizTypes[index].image,
                      //     category: AppLocalization.of(context)!
                      //         .getTranslatedValues(
                      //             _quizTypes[index].description)!,
                      //     onTap: () {
                      //       _navigateToQuizZone(index + 1);
                      //     },
                      //   );
                      // }),
                    ],
                  ),
                ),
              ],
            ))
          ]);
        },
        listener: (context, state) {
          if (state is UserDetailsFetchSuccess) {
            UiUtils.fetchBookmarkAndBadges(
                context: context, userId: state.userProfile.userId!);

            if (state.userProfile.name!.isEmpty) {
              showUpdateNameBottomSheet();
            } else if (state.userProfile.profileUrl!.isEmpty) {
              Navigator.of(context)
                  .pushNamed(Routes.selectProfile, arguments: false);
            }
          } else if (state is UserDetailsFetchFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              UiUtils.showAlreadyLoggedInDialog(context: context);
            }
          }
        },
      ),
    );
  }

  Widget _buildSelfChallenge() {
    return GestureDetector(
      onTap: () {
        context.read<QuizCategoryCubit>().updateState(QuizCategoryInitial());
        context.read<SubCategoryCubit>().updateState(SubCategoryInitial());
        Navigator.of(context).pushNamed(Routes.selfChallenge);
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: selfChallengeSlideAnimation,
          child: Container(
            margin: const EdgeInsets.only(
              top: 0,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,

              //gradient: UiUtils.buildLinerGradient([Theme.of(context).colorScheme.secondary, Theme.of(context).primaryColor], Alignment.centerLeft, Alignment.centerRight),

              borderRadius: BorderRadius.circular(20.0),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * (0.1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      margin: const EdgeInsetsDirectional.only(start: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TitleText(
                            text: AppLocalization.of(context)!
                                .getTranslatedValues(selfChallengeLbl)!,
                            size: Constants.bodyLarge,
                            weight: FontWeight.w500,
                            textColor: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(
                            height: 1.0,
                          ),
                          TitleText(
                            text: AppLocalization.of(context)!
                                .getTranslatedValues(challengeYourselfLbl)!,
                            size: 14.0,
                            textColor: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Transform.scale(
                        scale: 0.55,
                        child: SvgPicture.asset(
                          "assets/images/selfchallenge_icon.svg",
                          color: Theme.of(context).primaryColor,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _scrollController() {
    scrollController.animateTo(
      SizeConfig.screenHeight * 0.43,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void initAnimations() {
    //
    profileAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 85));
    selfChallengeAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 85));

    profileSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -0.0415))
            .animate(CurvedAnimation(
                parent: profileAnimationController, curve: Curves.easeIn));

    selfChallengeSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -0.0415))
            .animate(CurvedAnimation(
                parent: selfChallengeAnimationController,
                curve: Curves.easeIn));

    firstAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    firstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: firstAnimationController, curve: Curves.easeInOut));
    secondAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    secondAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: secondAnimationController, curve: Curves.easeIn));
  }

  void createAds() {
    Future.delayed(Duration.zero, () {
      context.read<InterstitialAdCubit>().createInterstitialAd(context);
    });
  }

  void showAppUnderMaintenanceDialog() {
    Future.delayed(Duration.zero, () {
      if (context.read<SystemConfigCubit>().appUnderMaintenance()) {
        showDialog(
            context: context,
            builder: (_) => const AppUnderMaintenanceDialog());
      }
    });
  }

  void _initLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payLoad) {
      print("For ios version <= 9 notification will be shown here");
    });

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onTapLocalNotification);
    _requestPermissionsForIos();
  }

  Future<void> _requestPermissionsForIos() async {
    if (Platform.isIOS) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions();
    }
  }

  void setQuizMenu() {
    Future.delayed(Duration.zero, () {
      final systemCubit = context.read<SystemConfigCubit>();
      quizTypeTopMargin = systemCubit.isSelfChallengeEnable() ? 0.425 : 0.29;
      if (systemCubit.getIsContestAvailable() == "0") {
        _quizTypes.removeWhere(
            (element) => element.quizTypeEnum == QuizTypes.contest);
      }
      if (systemCubit.getIsDailyQuizAvailable() == "0") {
        _quizTypes.removeWhere(
            (element) => element.quizTypeEnum == QuizTypes.dailyQuiz);
      }
      //remove (== "0") in default condition
      if (!systemCubit.getIsAudioQuestionAvailable()) {
        _quizTypes.removeWhere(
            (element) => element.quizTypeEnum == QuizTypes.audioQuestions);
      }
      if (systemCubit.getIsFunNLearnAvailable() == "0") {
        _quizTypes.removeWhere(
            (element) => element.quizTypeEnum == QuizTypes.funAndLearn);
      }
      //remove (== "0") in default condition
      if (!systemCubit.getIsGuessTheWordAvailable()) {
        _quizTypes.removeWhere(
            (element) => element.quizTypeEnum == QuizTypes.guessTheWord);
      }
      if (systemCubit.getIsExamAvailable() == "0") {
        _quizTypes
            .removeWhere((element) => element.quizTypeEnum == QuizTypes.exam);
      }
      setState(() {});
    });
  }

  late bool showUpdateContainer = false;

  void checkForUpdates() async {
    await Future.delayed(Duration.zero);
    if (context.read<SystemConfigCubit>().isForceUpdateEnable()) {
      try {
        bool forceUpdate = await UiUtils.forceUpdate(
            context.read<SystemConfigCubit>().getAppVersion());

        if (forceUpdate) {
          setState(() {
            showUpdateContainer = true;
          });
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  Future<void> setupInteractedMessage() async {
    //
    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .requestPermission(announcement: true, provisional: true);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    // handle background notification
    FirebaseMessaging.onBackgroundMessage(UiUtils.onBackgroundMessage);
    //handle foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // print("Notification arrives : $message");
      var data = message.data;

      var title = data['title'].toString();
      var body = data['body'].toString();
      var type = data['type'].toString();

      var image = data['image'];

      //if notification type is badges then update badges in cubit list
      if (type == "badges") {
        String badgeType = data['badge_type'];
        Future.delayed(Duration.zero, () {
          context.read<BadgesCubit>().unlockBadge(badgeType);
        });
      }

      if (type == "payment_request") {
        Future.delayed(Duration.zero, () {
          context.read<UserDetailsCubit>().updateCoins(
                addCoin: true,
                coins: int.parse(data['coins'].toString()),
              );
        });
      }

      //payload is some data you want to pass in local notification
      image != null
          ? generateImageNotification(title, body, image, type, type)
          : generateSimpleNotification(title, body, type);
    });
  }

  // notification type is category then move to category screen
  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      if (message.data['type'] == 'category') {
        Navigator.of(context).pushNamed(Routes.category,
            arguments: {"quizType": QuizTypes.quizZone});
      } else if (message.data['type'] == 'badges') {
        //if user open app by tapping
        UiUtils.updateBadgesLocally(context);
        Navigator.of(context).pushNamed(Routes.badges);
      } else if (message.data['type'] == "payment_request") {
        //UiUtils.needToUpdateCoinsLocally(context);
        Navigator.of(context).pushNamed(Routes.wallet);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _onTapLocalNotification(String? payload) async {
    //
    String type = payload ?? "";
    if (type == "badges") {
      Navigator.of(context).pushNamed(Routes.badges);
    } else if (type == "category") {
      Navigator.of(context).pushNamed(
        Routes.category,
      );
    } else if (type == "payment_request") {
      Navigator.of(context).pushNamed(Routes.wallet);
    }
  }

  Future<void> generateImageNotification(String title, String msg, String image,
      String payloads, String type) async {
    var largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    var bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: msg,
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.wrteam.flutterquiz', //channel id
      'flutterquiz', //channel name
      channelDescription: 'flutterquiz',
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation,
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, msg, platformChannelSpecifics, payload: payloads);
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    // print(" The Url is $url");

    final http.Response response = await http.get(Uri.parse(url));
    // print("The Response is $response");
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  // notification on foreground
  Future<void> generateSimpleNotification(
      String title, String body, String payloads) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'com.wrteam.flutterquiz', //channel id
        'flutterquiz', //channel name
        channelDescription: 'flutterquiz',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const IOSNotificationDetails iosNotificationDetails =
        IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: payloads);
  }

  void showUpdateNameBottomSheet() {
    final updateUserDetailCubit = context.read<UpdateUserDetailCubit>();

    final userDetailsCubit = context.read<UserDetailsCubit>();
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        elevation: 5.0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        )),
        context: context,
        builder: (context) {
          return EditProfileFieldBottomSheetContainer(
              canCloseBottomSheet: false,
              fieldTitle: nameLbl,
              password: false,
              fieldValue: context.read<UserDetailsCubit>().getUserName(),
              numericKeyboardEnable: false,
              userDetailCubit: userDetailsCubit,
              updateUserDetailCubit: updateUserDetailCubit);
        });
  }

//

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    //show you left the game
    if (state == AppLifecycleState.resumed) {
      UiUtils.needToUpdateCoinsLocally(context);
    } else {
      ProfileManagementLocalDataSource.updateReversedCoins(0);
    }
  }

  double _getTopMarginForQuizTypeContainer(int quizTypeIndex) {
    double topMarginPercentage = quizTypeTopMargin;
    int baseCondition = quizTypeIndex % 2 == 0 ? 0 : 1;
    for (int i = quizTypeIndex; i > baseCondition; i = i - 2) {
      //
      double topQuizTypeHeight = maxHeightQuizTypeIndexes.contains(i - 2)
          ? UiUtils.quizTypeMaxHeightPercentage
          : UiUtils.quizTypeMinHeightPercentage;

      topMarginPercentage = topMarginPercentage +
          quizTypeBetweenVerticalSpacing +
          topQuizTypeHeight;
    }
    return topMarginPercentage;
  }

  void _navigateToQuizZone(int containerNumber) {
    //container number will be [1,2,3,4] if self chellenge is enable
    //container number will be [1,2,3,4,5,6] if self chellenge is not enable

    log("current index $containerNumber");
    if (currentMenu == 1) {
      if (containerNumber == 1) {
        _onQuizTypeContainerTap(0);
      } else if (containerNumber == 2) {
        _onQuizTypeContainerTap(1);
      } else if (containerNumber == 3) {
        _onQuizTypeContainerTap(2);
      } else if (containerNumber == 4) {
        _onQuizTypeContainerTap(3);
      } else if (containerNumber == 5) {
        _onQuizTypeContainerTap(4);
      } else if (containerNumber == 6) {
        _onQuizTypeContainerTap(5);
      } else if (containerNumber == 7) {
        _onQuizTypeContainerTap(6);
      } else if (containerNumber == 8) {
        _onQuizTypeContainerTap(7);
      } else if (containerNumber == 9) {
        _onQuizTypeContainerTap(8);
      } else if (containerNumber == 10) {
        _onQuizTypeContainerTap(9);
      }

      //    else {
      //     if (context.read<SystemConfigCubit>().isSelfChallengeEnable()) {
      //       log("self challange is enabled");
      //       if (_quizTypes.length >= 4) {
      //         _onQuizTypeContainerTap(3);
      //       }
      //       return;
      //     }
      //     log("self challange is not enabled");

      //     if (containerNumber == 4) {
      //       if (_quizTypes.length >= 4) {
      //         _onQuizTypeContainerTap(3);
      //       }
      //     } else if (containerNumber == 5) {
      //       if (_quizTypes.length >= 5) {
      //         _onQuizTypeContainerTap(4);
      //       }
      //     } else if (containerNumber == 6) {
      //       if (_quizTypes.length >= 6) {
      //         _onQuizTypeContainerTap(5);
      //       }
      //     }
      //   }
      // } else if (currentMenu == 2) {
      //   //determine
      //   if (containerNumber == 1) {
      //     if (_quizTypes.length >= 5) {
      //       _onQuizTypeContainerTap(4);
      //     }
      //   } else if (containerNumber == 2) {
      //     if (_quizTypes.length >= 6) {
      //       _onQuizTypeContainerTap(5);
      //     }
      //   } else if (containerNumber == 3) {
      //     if (_quizTypes.length >= 7) {
      //       _onQuizTypeContainerTap(6);
      //     }
      //   } else {
      //     //if self challenge is enable
      //     if (context.read<SystemConfigCubit>().isSelfChallengeEnable()) {
      //       if (_quizTypes.length >= 8) {
      //         _onQuizTypeContainerTap(7);
      //         return;
      //       }
      //       return;
      //     }

      //     if (containerNumber == 4) {
      //       if (_quizTypes.length >= 8) {
      //         _onQuizTypeContainerTap(7);
      //       }
      //     } else if (containerNumber == 5) {
      //       if (_quizTypes.length >= 9) {
      //         _onQuizTypeContainerTap(8);
      //       }
      //     } else if (containerNumber == 6) {
      //       if (_quizTypes.length >= 10) {
      //         _onQuizTypeContainerTap(9);
      //       }
      //     }
      //   }
      // } else {
      //   //for menu 3
      //   if (containerNumber == 1) {
      //     if (_quizTypes.length >= 9) {
      //       _onQuizTypeContainerTap(8);
      //     }
      //   } else if (containerNumber == 2) {
      //     if (_quizTypes.length >= 10) {
      //       _onQuizTypeContainerTap(9);
      //     }
      //   } else if (containerNumber == 3) {
      //     if (_quizTypes.length >= 11) {
      //       _onQuizTypeContainerTap(10);
      //     }
      //   } else {
      //     if (_quizTypes.length == 12) {
      //       _onQuizTypeContainerTap(11);
      //     }
      //   }
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
      Navigator.of(context).pushNamed(Routes.category, arguments: {
        "quizType": QuizTypes.quizZone,
        "categoryTitle": _quizTypes[quizTypeIndex].getTitle(context)

        /// ??
      });
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
      Navigator.of(context).pushNamed(Routes.category, arguments: {
        "quizType": QuizTypes.funAndLearn,
        "categoryTitle": _quizTypes[quizTypeIndex].getTitle(context),
      });
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
      Navigator.of(context).pushNamed(Routes.category, arguments: {
        "quizType": QuizTypes.guessTheWord,
        "categoryTitle": _quizTypes[quizTypeIndex].getTitle(context)
      });
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum ==
        QuizTypes.audioQuestions) {
      Navigator.of(context).pushNamed(Routes.category, arguments: {
        "quizType": QuizTypes.audioQuestions,
        "categoryTitle": _quizTypes[quizTypeIndex].getTitle(context),
      });
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.exam) {
      //update exam status to exam initial
      context.read<ExamCubit>().updateState(ExamInitial());
      Navigator.of(context).pushNamed(Routes.exams, arguments: {
        "categoryTitle": _quizTypes[quizTypeIndex].getTitle(context),
      });
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.mathMania) {
      Navigator.of(context).pushNamed(Routes.category, arguments: {
        "quizType": QuizTypes.mathMania,
        "categoryTitle": _quizTypes[quizTypeIndex].getTitle(context)
      });
    }
  }

//Greetings Message
  String greetingMessage() {
    var timeNow = DateTime.now().hour;

    if ((timeNow >= 5) && (timeNow < 12)) {
      //05 : 00 am to 11:59am
      return 'GOOD MORNING';
    } else if ((timeNow >= 12) && (timeNow < 17)) {
      // 12:00 pm to 4:59pm
      return 'GOOD AFTERNOON';
    } else if ((timeNow >= 17) && (timeNow < 5)) {
      //5:00pm to 4:59am
      return 'GOOD EVENING';
    } else {
      return 'GOOD EVENING';
    }
  }

// categoryCard
  Widget categoryCard({
    final String? quizDescription,
    final String? categoryName,
    final String? icon,
    final Color? backgroundColor,
    final Color? iconColor,
    final Color? textColor,
    final double? iconShadowOpacity,
    final Color? mainIconColor,
    Function()? onTap,
    Function()? onTapIcon,
    bool? showDesc,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            // width: SizeConfig.screenWidth,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              borderRadius: StyleProperties.cardsRadius,
              color: backgroundColor,
            ),
            padding: StyleProperties.insets10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.fill,
                  child: SvgPicture.asset(
                    icon!,
                    color: iconColor,
                    height: 40,
                    width: 40,
                  ),
                ),
                WidgetsUtil.verticalSpace8,
                Align(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: TitleText(
                      text: categoryName!,
                      textColor: textColor ?? Constants.white,
                      size: Constants.bodyNormal,
                      weight: FontWeight.w500,
                      align: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(1.1, -1.1),
            child: Tooltip(
              message: quizDescription,
              triggerMode: TooltipTriggerMode.tap,
              child: Icon(
                Icons.info,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox({icon, iconShadowOpacity, iconColor}) => Container(
        decoration: BoxDecoration(
            color: Constants.white.withOpacity(iconShadowOpacity ?? 0.2),
            borderRadius: StyleProperties.cardsRadius),
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(10),
        child: icon.contains('.svg')
            ? SvgPicture.asset(
                icon,
                height: 38,
                color: iconColor ?? Constants.white,
              )
            : icon.contains('.png')
                ? Image.asset(
                    icon,
                    height: 38,
                    color: iconColor ?? Constants.white,
                  )
                : Icon(
                    Icons.error,
                    color: iconColor,
                  ),
      );
}
