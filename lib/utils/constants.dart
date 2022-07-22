import 'package:flutter/material.dart';
import 'package:flutterquiz/features/wallet/models/payoutMethod.dart';

const String appName = "Elite Quiz";
const String packageName = "com.wss.quizsigns";

//supporated language codes
//Add language code in this list
//visit this to find languageCode for your respective language
//https://developers.google.com/admin-sdk/directory/v1/languages
final List<String> supporatedLocales = ['en', 'hi', 'ur'];
//
const String defaultLanguageCode = 'en';

//Enter 2 Letter ISO Code of country
//It will be use for phone auth.
const String initialSelectedCountryCode = 'IN';

//Hive all boxes name
const String authBox = "auth";
const String settingsBox = "settings";
const String bookmarkBox = "bookmark";
const String guessTheWordBookmarkBox = "guessTheWordBookmarkBox";
const String audioBookmarkBox = "audioBookmarkBox";
const String userdetailsBox = "userdetails";
const String examBox = "exam";

//examBox keys
//
//

//authBox keys
const String isLoginKey = "isLogin";
const String jwtTokenKey = "jwtToken";
const String firebaseIdBoxKey = "firebaseId";
const String authTypeKey = "authType";
const String isNewUserKey = "isNewUser";

//userBox keys
const String nameBoxKey = "name";
const String userUIdBoxKey = "userUID";
const String emailBoxKey = "email";
const String mobileNumberBoxKey = "mobile";
const String rankBoxKey = "rank";
const String coinsBoxKey = "coins";
const String scoreBoxKey = "score";
const String profileUrlBoxKey = "profileUrl";
const String statusBoxKey = "status";
const String referCodeBoxKey = "referCode";

//settings box keys
const String showIntroSliderKey = "showIntroSlider";
const String vibrationKey = "vibration";
const String backgroundMusicKey = "backgroundMusic";
const String soundKey = "sound";
const String languageCodeKey = "language";
const String fontSizeKey = "fontSize";
const String rewardEarnedKey = "rewardEarned";
const String fcmTokenBoxKey = "fcmToken";
const String settingsThemeKey = "theme";

//Database related constants

//Add your database url
//make sure do not add '/' at the end of url

const String databaseUrl = "https://elitequiz.wrteam.in";
// const String databaseUrl = "https://cricketmobileapp.com/api";

const String baseUrl = '$databaseUrl/Api/';

const String accessValue = "8525";
// Please check this change on qui app in constant.dart
// const String databaseUrl = "https://cricketmobileapp.com/api";
// //
// const String baseUrl = '$databaseUrl/Api/';
// //
// const String jwtKey = 'M}L&e6RYs7zB~?y';
//
//
// const String accessValue = "8525";

//lifelines
const String fiftyFifty = "fiftyFifty";
const String audiencePoll = "audiencePoll";
const String skip = "skip";
const String resetTime = "resetTime";

//firestore collection names
const String battleRoomCollection = "battleRoom"; //  testBattleRoom
const String multiUserBattleRoomCollection =
    "multiUserBattleRoom"; //testMultiUserBattleRoom
const String messagesCollection = "messages"; // testMessages
const String tournamentsCollection = "tournaments"; //testTournaments

//api end points
const String addUserUrl = "${baseUrl}user_signup";

const String getQuestionForOneToOneBattle = "${baseUrl}get_random_questions";
const String getQuestionForMultiUserBattle =
    "${baseUrl}get_question_by_room_id";
const String createMultiUserBattleRoom = "${baseUrl}create_room";
const String deleteMultiUserBattleRoom = "${baseUrl}destroy_room_by_room_id";

const String getBookmarkUrl = "${baseUrl}get_bookmark";
const String updateBookmarkUrl = "${baseUrl}set_bookmark";

const String getNotificationUrl = "${baseUrl}get_notifications";

const String getUserDetailsByIdUrl = "${baseUrl}get_user_by_id";
const String checkUserExistUrl = "${baseUrl}check_user_exists";

const String uploadProfileUrl = "${baseUrl}upload_profile_image";
const String updateUserCoinsAndScoreUrl = "${baseUrl}set_user_coin_score";
const String updateProfileUrl = "${baseUrl}update_profile";

const String getCategoryUrl = "${baseUrl}get_categories";
const String getQuestionsByLevelUrl = "${baseUrl}get_questions_by_level";
const String getQuestionForDailyQuizUrl = "${baseUrl}get_daily_quiz";
const String getLevelUrl = "${baseUrl}get_level_data";
const String getSubCategoryUrl = "${baseUrl}get_subcategory_by_maincategory";
const String getQuestionForSelfChallengeUrl =
    "${baseUrl}get_questions_for_self_challenge";
const String updateLevelUrl = "${baseUrl}set_level_data";
const String getMonthlyLeaderboardUrl = "${baseUrl}get_monthly_leaderboard";
const String getDailyLeaderboardUrl = "${baseUrl}get_daily_leaderboard";
const String getAllTimeLeaderboardUrl = "${baseUrl}get_globle_leaderboard";
const String getQuestionByTypeUrl = "${baseUrl}get_questions_by_type";
const String getQuestionContestUrl = "${baseUrl}get_questions_by_contest";
const String setContestLeaderboardUrl = "${baseUrl}set_contest_leaderboard";
const String getContestLeaderboardUrl = "${baseUrl}get_contest_leaderboard";

const String getFunAndLearnUrl = "${baseUrl}get_fun_n_learn";
const String getFunAndLearnQuestionsUrl = "${baseUrl}get_fun_n_learn_questions";

const String getStatisticUrl = "${baseUrl}get_users_statistics";
const String updateStatisticUrl = "${baseUrl}set_users_statistics";

const String getContestUrl = "${baseUrl}get_contest";
const String getSystemConfigUrl = "${baseUrl}get_system_configurations";

const String getSupportedQuestionLanguageUrl = "${baseUrl}get_languages";
const String getGuessTheWordQuestionUrl = "${baseUrl}get_guess_the_word";
const String getAppSettingsUrl = "${baseUrl}get_settings";
const String reportQuestionUrl = "${baseUrl}report_question";
const String getQuestionsByCategoryOrSubcategory = "${baseUrl}get_questions";
const String updateFcmIdUrl = "${baseUrl}update_fcm_id";
const String getAudioQuestionUrl = "${baseUrl}get_audio_questions"; //
const String getUserBadgesUrl = "${baseUrl}get_user_badges";
const String setUserBadgesUrl = "${baseUrl}set_badges";
const String setBattleStatisticsUrl = "${baseUrl}set_battle_statistics";
const String getBattleStatisticsUrl = "${baseUrl}get_battle_statistics";

const String getExamModuleUrl = "${baseUrl}get_exam_module";
const String getExamModuleQuestionsUrl = "${baseUrl}get_exam_module_questions";
const String setExamModuleResultUrl = "${baseUrl}set_exam_module_result";
const String deleteUserAccountUrl = "${baseUrl}delete_user_account";
const String getCoinHistoryUrl = "${baseUrl}get_tracker_data";
const String makePaymentRequestUrl = "${baseUrl}set_payment_request";
const String getTransactionsUrl = "${baseUrl}get_payment_request";
const String getLatexQuestionUrl = "${baseUrl}get_maths_questions";

//This will be in use to mark x category or y sub category played , and fun n learn para
const String setQuizCategoryPlayedUrl = "${baseUrl}set_quiz_categories";

//quesiton or quiz time duration
const int questionDurationInSeconds = 15;
const int selfChallengeMaxMinutes = 30;
const int guessTheWordQuestionDurationInSeconds = 45;

//Math/Chemistry type of question
//It is recommended to give more time in this type of quesiton
//beacuse rendering time of webview will take some intial load time
const int latexQuestionDurationInSeconds = 60;

const int inBetweenQuestionTimeInSeconds = 1;
//
//it is the waiting time for finding opponent. Once user has waited for
//given seconds it will show opponent not found
const int waitForOpponentDurationInSeconds = 10;
//time to read paragraph
const int comprehensionParagraphReadingTimeInSeconds = 60;

//answer correctness track name
const String correctAnswerSoundTrack = "assets/sounds/right.mp3";
const String wrongAnswerSoundTrack = "assets/sounds/wrong.mp3";
//this will be in use while playing self challengle
const String clickEventSoundTrack = "assets/sounds/click.mp3";

//coins and answer points and win percentage
const int lifeLineDeductCoins = 5;
const int numberOfHintsPerGuessTheWordQuestion = 2;
const int correctAnswerPoints = 4;
const int wrongAnswerDeductPoints = 2;
//points for correct answer in battle
const int correctAnswerPointsForBattle = 4;

const int guessTheWordCorrectAnswerPoints = 6;
const int guessTheWordWrongAnswerDeductPoints = 3;
const double winPercentageBreakPoint = 30.0; // more than 30% declare winner
const double maxCoinsWinningPercentage =
    80.0; //it is highest percentage to earn maxCoins
const int maxWinningCoins = 4;
const int guessTheWordMaxWinningCoins = 6;
//Coins to give winner of battle (1 vs 1)
const int battleWinnerCoins = 5;
const int randomBattleEntryCoins = 5;

//if user give the answer of battle with in 1 or 2 seconds
const int extraPointForQuickestAnswer = 2;
//if user give the answer of battle with in 3 or 4 seconds
const int extraPointForSecondQuickestAnswer = 1;
//minimum coins for creating group battle
const int minCoinsForGroupBattleCreation = 5;
const int maxCoinsForGroupBattleCreation = 50;

//Coins to deduct for seeing Review answers
const int reviewAnswersDeductCoins = 10;

//other constants
const String defaultQuestionLanguageId = "";

//Group battle invite message
const String groupBattleInviteMessage =
    "Hello, Join a group battle in $appName app. Go to group battle in the app and join using the code : ";

const String initialCountryCode = "IN"; // change your initialCountry Code

//Currency in which admin want to give money to user
const String payoutRequestCurrency = '\$';

//predefined messages for battle
final List<String> predefinedMessages = [
  "Hello..!!",
  "How are you..?",
  "Fine..!!",
  "Have a nice day..",
  "Well played",
  "What a performance..!!",
  "Thanks..",
  "Welcome..",
  "Merry Christmas",
  "Happy new year",
  "Happy Diwali",
  "Good night",
  "Hurry Up",
  "Dudeeee"
];

//constants for badges and rewards
const int minimumQuestionsForBadges = 5;

//
final List<String> badgeTypes = [
  "dashing_debut",
  "combat_winner",
  "clash_winner",
  "most_wanted_winner",
  "ultimate_player",
  "quiz_warrior",
  "super_sonic",
  "flashback",
  "brainiac",
  "big_thing",
  "elite",
  "thirsty",
  "power_elite",
  "sharing_caring",
  "streak"
];

//
const String roomCodeGenerateCharacters = "1234567890"; //Numeric
//to make roomCode alpha numeric use below string in roomCodeGenerateCharacters
//AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890

///
///Add your exam rules here
///
const List<String> examRules = [
  "I will not copy and give this exam with honesty",
  "If you lock your phone then exam will complete automatically",
  "If you minimize application or open other application and don't come back to application with in 5 seconds then exam will complete automatically",
  "Screen recording is prohibited",
  "In Android screenshot capturing is prohibited",
  "In ios, if you take screenshot then rules will violate and it will inform to examinator"
];

//
//Add notes for wallet request
//

const List<String> walletRequestNotes = ["Payout will take 3 - 5 working days"];

//To add more payout methods here
final List<PayoutMethod> payoutMethods = [
  //Paypal
  PayoutMethod(

      //Specify the input parameters label here
      inputDetailsFromUser: [
        "Enter paypal id",
      ], image: "assets/images/paypal.svg", type: "Paypal"),

  //Paytm
  PayoutMethod(

      //Specify the input parameters label here
      inputDetailsFromUser: ["Enter mobile number"],
      image: "assets/images/paytm.svg",
      type: "Paytm"),

  //UPI
  PayoutMethod(

      //Specify the input parameters label here
      inputDetailsFromUser: [
        "Enter upi id",
      ], image: "assets/images/upi.svg", type: "UPI"),

  /*
  //Sample payment method
  //Bank Transfer - Payment method name
  PayoutMethod(
      //Specify the input parameters label here
      //What are the details user need to give for this payment method
      //
      inputDetailsFromUser: [
        "Enter bank name",
        "Enter account number ",
        "Enter bank ifsc code",
      ], image: "assets/images/paytm.svg",
      type: "Bank Transfer"),
  */
];

//
//Please do not change this if you do torunament will not work as expected.
//This ensure that torunament will start only if 8 users are ready to play
//
const int numberOfPlayerForTournament = 8;

const int maxUsersInGroupBatle = 4;

const String appName1 = 'Queezy';

class Constants {
  static Color primaryColor = const Color(0xff6A5AE0);
  static Color secondaryColor = const Color(0xff9087E5);
  static Color bluecolor = Color(0xff5144B6);
  static Color pink = const Color(0xffFF8FA2);
  static Color lightPink = const Color(0xffffa5b5);
  static Color accent1 = const Color(0xffFFD6DD);
  static Color accent2 = const Color(0xffC4D0FB);
  static Color accent3 = const Color(0xffC9F2E9);
  static Color secondaryAccent = const Color(0xffFFCCD5);
  static Color accent4 = const Color(0xA9ADF3);
  static Color indigoWithOpacity02 = Colors.indigo.withOpacity(0.2);

  static Color tulip = const Color(0xff88E2CE);
  static Color lightGreen = const Color(0xff53DF83);
  static Color wrongAnswer = const Color(0xffFF6666);

  static Color black1 = const Color(0xff49465F);
  static Color black2 = const Color(0xff0C092A);
  static Color grey1 = const Color(0xff49465F);
  static Color grey2 = const Color(0xff858494);
  static Color grey3 = const Color(0xffCCCCCC);
  static Color grey4 = const Color(0xffE6E6E6);
  static Color grey5 = const Color.fromRGBO(239, 238, 252, 1);
  static Color backgroundColor = const Color(0xffEFEEFC);
  static Color facebookColor = const Color(0xff0056B2);
  static Color white = Colors.white;
  static Color lightwhite = Colors.white54;
  static Color secondaryTextColor = const Color(0xff660012);
  static Color orange = Colors.orange;
  static Color orange1 = Color(0xffFFB380);
  static Color darkorange = Color(0xffFF9B57);

  static double heading1 = 32;
  static double heading2 = 28;
  static double heading3 = 23;
  static double bodyXLarge = 20;
  static double bodyLarge = 18;
  static double bodyNormal = 16;
  static double bodySmall = 14;
  static double bodyXSmall = 12;

  static double cardsRadius = 20.0;
}
