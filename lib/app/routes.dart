import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/navigation/navigation.dart';
import 'package:flutterquiz/ui/screens/aboutAppScreen.dart';
import 'package:flutterquiz/ui/screens/auth/new_login_screen.dart';
import 'package:flutterquiz/ui/screens/auth/otpScreen.dart';
import 'package:flutterquiz/ui/screens/auth/reset_password_screen.dart';
import 'package:flutterquiz/ui/screens/badgesScreen.dart';
import 'package:flutterquiz/ui/screens/battle/battleRoomFindOpponentScreen.dart';
import 'package:flutterquiz/ui/screens/battle/battleRoomQuizScreen.dart';
import 'package:flutterquiz/ui/screens/battle/multiUserBattleRoomQuizScreen.dart';
import 'package:flutterquiz/ui/screens/battle/multiUserBattleRoomResultScreen.dart';
import 'package:flutterquiz/ui/screens/bookmarkScreen.dart';
import 'package:flutterquiz/ui/screens/coinHistoryScreen.dart';
import 'package:flutterquiz/ui/screens/coinStoreScreen.dart';
import 'package:flutterquiz/ui/screens/exam/examScreen.dart';
import 'package:flutterquiz/ui/screens/exam/examsScreen.dart';
import 'package:flutterquiz/ui/screens/introSliderScreen.dart';
import 'package:flutterquiz/ui/screens/new_leaderBoard.dart';
import 'package:flutterquiz/ui/screens/new_settings/new_settings_screen.dart';
import 'package:flutterquiz/ui/screens/notificationScreen.dart';
import 'package:flutterquiz/ui/screens/profile/profile.dart';
import 'package:flutterquiz/ui/screens/profile/selectProfilePictureScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/bookmarkQuizScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/categoryScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/contestLeaderboardScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/contestScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/funAndLearnScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/funAndLearnTitleScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/guessTheWordQuizScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/levelsScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/new_levels_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/new_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/new_result_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/reviewAnswersScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/selfChallengeQuestionsScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/selfChallengeScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/subCategoryAndLevelScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/subCategoryScreen.dart';
import 'package:flutterquiz/ui/screens/referAndEarnScreen.dart';
import 'package:flutterquiz/ui/screens/rewards/rewardsScreen.dart';
import 'package:flutterquiz/ui/screens/statisticsScreen.dart';
import 'package:flutterquiz/ui/screens/tournament/tournamentDetailsScreen.dart';
import 'package:flutterquiz/ui/screens/tournament/tournamentScreen.dart';
import 'package:flutterquiz/ui/screens/wallet/walletScreen.dart';

import '../ui/screens/auth/new_sign_up_screen.dart';
import '../ui/screens/auth/onBoardingScreen.dart';
import '../ui/screens/auth/sign_up_options.dart';
import '../ui/screens/auth/sign_up_process.dart';
import '../ui/screens/new_splash.dart';

class Routes {
  static const home = "/";
  static const onBoardingScreen = "onBoardingScreen";
  static const signupoptions = "signupoptions";
  static const resetpswdScreen = "resetPswdScreen";

  static const loginScreen = "login";
  static const signupScreen = "signupScreen";
  static const signupprocess = "signupprocess";
  static const create = "createScreen";

  // static const login = "login";
  static const splash = 'splash';
  static const discover = 'discover';
  static const leaderboard = 'leaderboard';
  // static const signUp = "signUp";
  static const introSlider = "introSlider";
  static const selectProfile = "selectProfile";
  static const quiz = "/quiz";
  static const subcategoryAndLevel = "/subcategoryAndLevel";
  static const subCategory = "/subCategory";
  static const newLevelsScreen = "/new_levels_screen";

  static const referAndEarn = "/referAndEarn";
  static const notification = "/notification";
  static const bookmark = "/bookmark";
  static const bookmarkQuiz = "/bookmarkQuiz";
  static const coinStore = "/coinStore";
  static const rewards = "/rewards";
  static const result = "/result";
  static const selectRoom = "/selectRoom";
  static const category = "/category";
  static const profile = "/profile";
  static const editProfile = "/editProfile";
  static const leaderBoard = "/leaderBoard";
  static const reviewAnswers = "/reviewAnswers";
  static const selfChallenge = "/selfChallenge";
  static const selfChallengeQuestions = "/selfChallengeQuestions";
  static const battleRoomQuiz = "/battleRoomQuiz";
  static const battleRoomFindOpponent = "/battleRoomFindOpponent";

  static const logOut = "/logOut";
  static const trueFalse = "/trueFalse";
  static const multiUserBattleRoomQuiz = "/multiUserBattleRoomQuiz";
  static const multiUserBattleRoomQuizResult = "/multiUserBattleRoomQuizResult";

  static const contest = "/contest";
  static const contestLeaderboard = "/contestLeaderboard";
  static const funAndLearnTitle = "/funAndLearnTitle";
  static const funAndLearn = "funAndLearn";
  static const guessTheWord = "/guessTheWord";
  static const appSettings = "/appSettings";
  static const levels = "/levels";
  static const aboutApp = "/aboutApp";
  static const badges = "/badges";
  static const exams = "/exams";
  static const exam = "/exam";
  static const tournament = "/tournament";
  static const tournamentDetails = "/tournamentDetails";
  static const otpScreen = "/otpScreen";
  static const statistics = "/statistics";
  static const coinHistory = "/coinHistory";
  static const wallet = "/wallet";

  static String currentRoute = splash;

  static Route<dynamic> onGenerateRouted(RouteSettings routeSettings) {
    //to track current route
    //this will only track pushed route on top of previous route
    currentRoute = routeSettings.name ?? "";
    log("Current Route is $currentRoute");
    switch (routeSettings.name) {
      case splash:
        return CupertinoPageRoute(builder: (context) => Splash());
      case home:
        return CupertinoPageRoute(builder: (context) => Navigation());
      case introSlider:
        return CupertinoPageRoute(builder: (context) => IntroSliderScreen());
      case onBoardingScreen:
        return CupertinoPageRoute(builder: (context) => OnBoarding());
      case resetpswdScreen:
        return CupertinoPageRoute(builder: (context) => ResetPassword());

      case loginScreen:
        // case login:
        // return CupertinoPageRoute(builder: (context) => SignInScreen());
        return CupertinoPageRoute(builder: (context) => Login());

      case signupoptions:
        return CupertinoPageRoute(builder: (context) => const SignUpOptions());
      //  case signupoptions:
      // return CupertinoPageRoute(builder: (context) => CreateScreen());
      case signupScreen:
        return CupertinoPageRoute(builder: (context) => const SignUp());
      case signupprocess:
        return CupertinoPageRoute(builder: (context) => SignUpProcess());

      // case signUp:
      //   return CupertinoPageRoute(builder: (context) => SignUpScreen());
      case otpScreen:
        return OtpScreen.route(routeSettings);
      case subcategoryAndLevel:
        return SubCategoryAndLevelScreen.route(routeSettings);
      case selectProfile:
        return SelectProfilePictureScreen.route(routeSettings);
      case quiz:
        // return QuizScreen.route(routeSettings);
        return NewQuizScreen.route(routeSettings);

      case wallet:
        return WalletScreen.route(routeSettings);

      case coinStore:
        return CoinStoreScreen.route(routeSettings);
      case rewards:
        return RewardsScreen.route(routeSettings);

      case referAndEarn:
        return CupertinoPageRoute(builder: (_) => ReferAndEarnScreen());
      case result:
        // return ResultScreen.route(routeSettings);
        return NewResultScreen.route(routeSettings);
      case profile:
        log('Profile.route() called');
        return Profile.route(routeSettings);
      // return StatisticsScreen.route(routeSettings);
      // return ProfileScreen.route(routeSettings);
      case reviewAnswers:
        return ReviewAnswersScreen.route(routeSettings);
      case selfChallenge:
        return SelfChallengeScreen.route(routeSettings);
      case selfChallengeQuestions:
        return SelfChallengeQuestionsScreen.route(routeSettings);
      case category:
        return CategoryScreen.route(routeSettings);
      case leaderBoard:
        return NewLeaderBoardScreen.route(routeSettings);

      case bookmark:
        return CupertinoPageRoute(builder: (context) => const BookmarkScreen());
      case bookmarkQuiz:
        return BookmarkQuizScreen.route(routeSettings);
      case battleRoomQuiz:
        return BattleRoomQuizScreen.route(routeSettings);

      case notification:
        return NotificationScreen.route(routeSettings);

      case funAndLearnTitle:
        return FunAndLearnTitleScreen.route(routeSettings);
      case funAndLearn:
        return FunAndLearnScreen.route(routeSettings);
      case multiUserBattleRoomQuiz:
        return MultiUserBattleRoomQuizScreen.route(routeSettings);
      case contest:
        return ContestScreen.route(routeSettings);

      case guessTheWord:
        return GuessTheWordQuizScreen.route(routeSettings);

      case multiUserBattleRoomQuizResult:
        return MultiUserBattleRoomResultScreen.route(routeSettings);

      case contestLeaderboard:
        return ContestLeaderBoardScreen.route(routeSettings);

      case battleRoomFindOpponent:
        return BattleRoomFindOpponentScreen.route(routeSettings);

      // case appSettings:
      //   return AppSettingsScreen.route(routeSettings);
      case appSettings:
        return NewSettingsScreen.route(routeSettings);

      case levels:
        return LevelsScreen.route(routeSettings);

      case coinHistory:
        return CoinHistoryScreen.route(routeSettings);

      case aboutApp:
        return CupertinoPageRoute(builder: (context) => const AboutAppScreen());

      case subCategory:
        return SubCategoryScreen.route(routeSettings);

      case newLevelsScreen:
        return NewLevelsScreen.route(routeSettings);

      case badges:
        return BadgesScreen.route(routeSettings);

      case exams:
        return ExamsScreen.route(routeSettings);

      case exam:
        return ExamScreen.route(routeSettings);

      case tournament:
        return TournamentScreen.route(routeSettings);

      case tournamentDetails:
        return TournamentDetailsScreen.route(routeSettings);

      case statistics:
        return StatisticsScreen.route(routeSettings);

      default:
        return CupertinoPageRoute(builder: (context) => const Scaffold());
    }
  }
}
