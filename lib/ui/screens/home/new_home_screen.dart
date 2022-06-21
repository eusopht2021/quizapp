import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutterquiz/features/ads/interstitialAdCubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementLocalDataSource.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/home/widgets/appUnderMaintenanceDialog.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/ui/screens/home/widgets/new_quiz_category_card.dart';
import 'package:flutterquiz/ui/screens/profile/widgets/editProfileFieldBottomSheetContainer.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/quizTypes.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:path_provider/path_provider.dart';

import '../../../features/auth/authRepository.dart';
import '../../../features/auth/cubits/referAndEarnCubit.dart';
import '../../../features/profileManagement/cubits/userDetailsCubit.dart';
import '../../../features/quiz/models/quizType.dart';
import '../../../utils/assets.dart';
import '../../../utils/constants.dart';
import '../../../utils/style_properties.dart';
import '../../../utils/widgets_util.dart';
import '../../widgets/pie_chart.dart';
import '../../widgets/social_button.dart';
import '../../widgets/title_text.dart';

class NewHomeScreen extends StatefulWidget {
  NewHomeScreen({Key? key}) : super(key: key);

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<ReferAndEarnCubit>(
                  create: (_) => ReferAndEarnCubit(AuthRepository()),
                ),
                BlocProvider<UpdateUserDetailCubit>(
                  create: (context) =>
                      UpdateUserDetailCubit(ProfileManagementRepository()),
                ),
              ],
              child: NewHomeScreen(),
            ));
  }
}

class _NewHomeScreenState extends State<NewHomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final double quizTypeWidthPercentage = 0.4;
  late double quizTypeTopMargin = 0.0;
  final double quizTypeHorizontalMarginPercentage = 0.08;
  final List<int> maxHeightQuizTypeIndexes = [0, 3, 4, 7, 8];

  final double quizTypeBetweenVerticalSpacing = 0.02;

  late List<QuizType> _quizTypes = quizTypes;

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

    profileAnimationController.dispose();
    selfChallengeAnimationController.dispose();
    firstAnimationController.dispose();
    secondAnimationController.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Constants.primaryColor,
      child: BlocConsumer<UserDetailsCubit, UserDetailsState>(
        bloc: context.read<UserDetailsCubit>(),
        builder: (context, state) {
          if (state is UserDetailsFetchInProgress ||
              state is UserDetailsInitial) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is UserDetailsFetchFailure) {
            return Text('Error something is wrong!');
          }
          UserProfile userProfile =
              (state as UserDetailsFetchSuccess).userProfile;
          if (userProfile.status == "0") {
            return Text('Error something is wrong!');
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
                        Expanded(
                          child: TitleText(
                            text: 'Good Morning',
                            textColor: Constants.accent1,
                            size: Constants.bodyXSmall,
                            weight: FontWeight.w500,
                          ),
                        ),
                        TitleText(
                          text: state.userProfile.name!,
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
                        Navigator.of(context).pushNamed(Routes.profile);
                      }),
                      child: CircleAvatar(
                        backgroundColor: Constants.pink,
                        backgroundImage: CachedNetworkImageProvider(
                            state.userProfile.profileUrl!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //body

            Expanded(
                child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Expanded(
                  child: Container(
                    height: 84,
                    width: SizeConfig.screenWidth,
                    margin: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          Assets.swivels,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: Constants.secondaryAccent,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 10,
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                WidgetsUtil.verticalSpace16,
                                TitleText(
                                  text: 'Recent Quiz'.toUpperCase(),
                                  size: Constants.bodySmall,
                                  weight: FontWeight.w500,
                                  textColor: Constants.secondaryTextColor,
                                ),
                                WidgetsUtil.verticalSpace8,
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        flex: 0,
                                        child: Icon(
                                          Icons.headphones,
                                          color: Constants.secondaryTextColor,
                                        ),
                                      ),
                                      WidgetsUtil.horizontalSpace8,
                                      Expanded(
                                        flex: 14,
                                        child: TitleText(
                                          text: 'A Basic Music Quiz',
                                          size: Constants.bodyLarge,
                                          weight: FontWeight.w500,
                                          textColor:
                                              Constants.secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: CustomPieChart(
                            value1: 88,
                            value2: 12,
                            radius: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                WidgetsUtil.verticalSpace24,
                Container(
                  margin: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Constants.grey3.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(Assets.cardCircles),
                    ),
                  ),
                  child: Column(
                    children: [
                      WidgetsUtil.verticalSpace16,
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 2,
                            child: SvgPicture.asset(
                              Assets.man5,
                              height: 48,
                              width: 48,
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: TitleText(
                                text: 'Featured'.toUpperCase(),
                                size: Constants.bodySmall,
                                textColor: Constants.white,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: SizedBox(),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 40,
                          right: 40,
                        ),
                        child: TitleText(
                          text:
                              'Take part in challenges with friends or other players',
                          size: Constants.bodyLarge,
                          align: TextAlign.center,
                          weight: FontWeight.w500,
                          textColor: Constants.white,
                        ),
                      ),
                      WidgetsUtil.verticalSpace16,
                      SizedBox(
                        width: SizeConfig.screenWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Expanded(
                              flex: 15,
                              child: SocialButton(
                                textColor: Constants.primaryColor,
                                iconColor: Constants.primaryColor,
                                background: Constants.white,
                                icon: Assets.search,
                                itemSpace: 12,
                                onTap: () => log('Find Friends'),
                                height: 44,
                                text: 'Find Friends',
                                showBorder: true,
                              ),
                            ),
                            const Spacer(),
                            SvgPicture.asset(
                              Assets.woman2,
                              height: 48,
                              width: 48,
                            ),
                            WidgetsUtil.horizontalSpace16,
                          ],
                        ),
                      ),
                      WidgetsUtil.verticalSpace16,
                    ],
                  ),
                ),
                WidgetsUtil.verticalSpace24,
                Container(
                  decoration: StyleProperties.sheetBorder,
                  padding: StyleProperties.insetsBottom80Hzt20,
                  child: Column(
                    children: [
                      WidgetsUtil.verticalSpace24,
                      Row(
                        children: [
                          TitleText(
                            text: 'Live Quizzes',
                            size: Constants.bodyXLarge,
                            textColor: Constants.black1,
                            weight: FontWeight.w500,
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () => log('See All'),
                            child: TitleText(
                              text: 'See All',
                              textColor: Constants.primaryColor,
                              size: Constants.bodySmall,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      WidgetsUtil.verticalSpace16,
                      ...List.generate(3, (index) {
                        return QuizCategoryCard(
                          name: 'Statistics Math Quiz',
                          asset: Assets.quizTypes[index],
                          category: 'Math',
                          quizNumber: index * 2,
                        );
                      }),
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

  void initAnimations() {
    //
    profileAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 85));
    selfChallengeAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 85));

    profileSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -0.0415)).animate(
            CurvedAnimation(
                parent: profileAnimationController, curve: Curves.easeIn));

    selfChallengeSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -0.0415)).animate(
            CurvedAnimation(
                parent: selfChallengeAnimationController,
                curve: Curves.easeIn));

    firstAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    firstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: firstAnimationController, curve: Curves.easeInOut));
    secondAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    secondAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: secondAnimationController, curve: Curves.easeInOut));
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
            context: context, builder: (_) => AppUnderMaintenanceDialog());
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
      if (!systemCubit.getIsAudioQuestionAvailable()) {
        _quizTypes.removeWhere(
            (element) => element.quizTypeEnum == QuizTypes.audioQuestions);
      }
      if (systemCubit.getIsFunNLearnAvailable() == "0") {
        _quizTypes.removeWhere(
            (element) => element.quizTypeEnum == QuizTypes.funAndLearn);
      }
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
      print("Notification arrives : $message");
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
    print(" The Url is $url");
    final http.Response response = await http.get(Uri.parse(url));
    print("The Response is $response");
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  // notification on foreground
  Future<void> generateSimpleNotification(
      String title, String body, String payloads) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
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
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        )),
        context: context,
        builder: (context) {
          return EditProfileFieldBottomSheetContainer(
              canCloseBottomSheet: false,
              fieldTitle: nameLbl,
              fieldValue: context.read<UserDetailsCubit>().getUserName(),
              numericKeyboardEnable: false,
              updateUserDetailCubit: updateUserDetailCubit);
        });
  }
}
