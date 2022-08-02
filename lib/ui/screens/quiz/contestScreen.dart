import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/contestCubit.dart';
import 'package:flutterquiz/features/quiz/models/contest.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class ContestScreen extends StatefulWidget {
  @override
  _ContestScreen createState() => _ContestScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(providers: [
              BlocProvider<ContestCubit>(
                create: (_) => ContestCubit(QuizRepository()),
              ),
              BlocProvider<UpdateScoreAndCoinsCubit>(
                create: (_) =>
                    UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
              ),
            ], child: ContestScreen()));
  }
}

class _ContestScreen extends State<ContestScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context
        .read<ContestCubit>()
        .getContest(context.read<UserDetailsCubit>().getUserId());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Builder(builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Constants.primaryColor,
            appBar: AppBar(
                backgroundColor: Constants.primaryColor,
                leading: CustomBackButton(
                  iconColor: Constants.white,
                ),
                centerTitle: true,
                title: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TitleText(
                      text: AppLocalization.of(context)!
                          .getTranslatedValues("contestLbl")!,
                      align: TextAlign.center,
                      textColor: Constants.white,
                      weight: FontWeight.bold,
                      size: 22.0),
                ),
                bottom: TabBar(
                    labelPadding: EdgeInsetsDirectional.only(
                        top: MediaQuery.of(context).size.height * .03),
                    labelColor: Constants.white,
                    unselectedLabelColor: Constants.grey4.withOpacity(0.7),
                    labelStyle: Theme.of(context).textTheme.subtitle1,
                    indicatorColor: Constants.white,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 5,
                    tabs: [
                      Tab(
                          text: AppLocalization.of(context)!
                              .getTranslatedValues("pastLbl")),
                      Tab(
                          text: AppLocalization.of(context)!
                              .getTranslatedValues("liveLbl")),
                      Tab(
                          text: AppLocalization.of(context)!
                              .getTranslatedValues("upcomingLbl")),
                    ])),
            body: Stack(
              children: [
                BlocConsumer<ContestCubit, ContestState>(
                    bloc: context.read<ContestCubit>(),
                    listener: (context, state) {
                      if (state is ContestFailure) {
                        if (state.errorMessage == unauthorizedAccessCode) {
                          //
                          UiUtils.showAlreadyLoggedInDialog(
                            context: context,
                          );
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is ContestProgress || state is ContestInitial) {
                        return Center(
                            child: CircularProgressIndicator(
                          color: Constants.white,
                        ));
                      }
                      if (state is ContestFailure) {
                        print(state.errorMessage);
                        return ErrorContainer(
                          errorMessage: AppLocalization.of(context)!
                              .getTranslatedValues(
                                  convertErrorCodeToLanguageKey(
                                      state.errorMessage)),
                          onTapRetry: () {
                            context.read<ContestCubit>().getContest(
                                context.read<UserDetailsCubit>().getUserId());
                          },
                          showErrorImage: true,
                          errorMessageColor: Theme.of(context).primaryColor,
                        );
                      }
                      final contestList = (state as ContestSuccess).contestList;
                      return TabBarView(children: [
                        past(contestList.past),
                        live(contestList.live),
                        future(contestList.upcoming)
                      ]);
                    })
              ],
            ),
          );
        }));
  }

  Widget past(Contest data) {
    return data.errorMessage.isNotEmpty
        ? ErrorContainer(
            showBackButton: false,
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(data.errorMessage))!,
            errorMessageColor: Constants.white,
            onTapRetry: () {
              context
                  .read<ContestCubit>()
                  .getContest(context.read<UserDetailsCubit>().getUserId());
            },
            showErrorImage: true)
        : ListView.builder(
            shrinkWrap: false,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  height: data.contestDetails[index].showDescription == false
                      ? MediaQuery.of(context).size.height * .35
                      : MediaQuery.of(context).size.height * .4,
                  margin: const EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width * .9,
                  decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      boxShadow: [
                        UiUtils.buildBoxShadow(
                            offset: const Offset(5, 5), blurRadius: 10.0),
                      ],
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(20))),
                  child: contestDesign(data, index, 0));
            });
  }

  Widget live(Contest data) {
    return data.errorMessage.isNotEmpty
        ? ErrorContainer(
            showBackButton: false,
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(data.errorMessage))!,
            errorMessageColor: Constants.white,
            onTapRetry: () {
              context
                  .read<ContestCubit>()
                  .getContest(context.read<UserDetailsCubit>().getUserId());
            },
            showErrorImage: true)
        : ListView.builder(
            shrinkWrap: false,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  height: data.contestDetails[index].showDescription == false
                      ? MediaQuery.of(context).size.height * .3
                      : MediaQuery.of(context).size.height * .4,
                  margin: const EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width * .9,
                  decoration: BoxDecoration(
                      color: Constants.secondaryColor,
                      boxShadow: [
                        UiUtils.buildBoxShadow(
                            offset: const Offset(5, 5), blurRadius: 10.0),
                      ],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: contestDesign(data, index, 1));
            });
  }

  Widget future(Contest data) {
    return data.errorMessage.isNotEmpty
        ? ErrorContainer(
            showBackButton: false,
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(data.errorMessage))!,
            errorMessageColor: Constants.white,
            onTapRetry: () {
              context
                  .read<ContestCubit>()
                  .getContest(context.read<UserDetailsCubit>().getUserId());
            },
            showErrorImage: true)
        : ListView.builder(
            shrinkWrap: false,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: data.contestDetails[index].showDescription == false
                    ? MediaQuery.of(context).size.height * .3
                    : MediaQuery.of(context).size.height * .4,
                margin: const EdgeInsets.all(15),
                width: MediaQuery.of(context).size.width * .9,
                decoration: BoxDecoration(
                  color: Constants.white,
                  boxShadow: [
                    UiUtils.buildBoxShadow(
                        offset: const Offset(5, 5), blurRadius: 10.0),
                  ],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: contestDesign(data, index, 2),
              );
            },
          );
  }

  Widget contestDesign(dynamic data, int index, int type) {
    return Column(
      children: [
        Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: CachedNetworkImage(
                placeholder: (context, _) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Constants.white,
                    ),
                  );
                },
                imageBuilder: (context, imageProvider) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  );
                },
                errorWidget: (context, image, error) {
                  print(error.toString());
                  return Center(
                    child: Icon(
                      Icons.error,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
                fit: BoxFit.cover,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .15,
                imageUrl: data.contestDetails[index].image.toString(),
              ),
            )),
        Divider(
          color: Constants.primaryColor,
          height: 0.1,
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: Constants
                .white, //height: MediaQuery.of(context).size.height*.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: Text(
                    data.contestDetails[index].name.toString(),
                    style: TextStyle(
                        color: Constants.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        data.contestDetails[index].showDescription =
                            !data.contestDetails[index].showDescription!;
                      });
                    },
                    child: Icon(
                      data.contestDetails[index].showDescription!
                          ? Icons.keyboard_arrow_up_sharp
                          : Icons.keyboard_arrow_down_sharp,
                      color: Constants.primaryColor,
                      size: 40,
                    )),
              ],
            ),
          ),
        ),
        Divider(
          color: Constants.primaryColor,
          height: 0.1,
        ),
        data.contestDetails[index].showDescription!
            ? Container(
                padding: const EdgeInsets.only(left: 10),
                color: Constants.white,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                    //scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Text(
                      data.contestDetails[index].description!,
                      style: TextStyle(
                          color: Constants.primaryColor.withOpacity(0.6),
                          fontWeight: FontWeight.bold),
                    )))
            : Container(),
        Divider(
          color: Constants.primaryColor,
          height: 0.1,
        ),
        Expanded(
          flex: 4,
          child: Container(
            height: SizeConfig.screenHeight * 0.4,
            padding: const EdgeInsets.only(
              left: 10,
            ),
            decoration: BoxDecoration(
                color: Constants.white,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues("entryFeesLbl")!,
                        style: TextStyle(
                            color: Constants.primaryColor.withOpacity(0.6),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data.contestDetails[index].entry.toString(),
                        style: TextStyle(
                            color: Constants.primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues("endsOnLbl")!,
                        style: TextStyle(
                            color: Constants.primaryColor.withOpacity(0.6),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data.contestDetails[index].endDate.toString(),
                        style: TextStyle(
                            color: Constants.primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues("playersLbl")!,
                        style: TextStyle(
                            color: Constants.primaryColor.withOpacity(0.6),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data.contestDetails[index].participants.toString(),
                        style: TextStyle(
                            color: Constants.primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 5.0,
                    ),
                    type == 0
                        ? TextButton(
                            style: TextButton.styleFrom(
                              primary: Constants.white,
                              backgroundColor: Constants.primaryColor,
                              side: BorderSide(
                                  color: Constants.primaryColor, width: 1),
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * .1,
                                  MediaQuery.of(context).size.height * .05),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                  Routes.contestLeaderboard,
                                  arguments: {
                                    "contestId": data.contestDetails[index].id
                                  });
                            },
                            child: Text(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("leaderboardLbl")!,
                            ),
                          )
                        : type == 1
                            ? Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 10.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    onPrimary: Constants.white,
                                    primary: Constants.primaryColor,
                                    side: BorderSide(
                                        color: Constants.primaryColor,
                                        width: 1),
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width * .2,
                                        MediaQuery.of(context).size.height *
                                            .05),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (int.parse(context
                                            .read<UserDetailsCubit>()
                                            .getCoins()!) >=
                                        int.parse(data
                                            .contestDetails[index].entry!)) {
                                      context
                                          .read<UpdateScoreAndCoinsCubit>()
                                          .updateCoins(
                                            context
                                                .read<UserDetailsCubit>()
                                                .getUserId(),
                                            int.parse(data
                                                .contestDetails[index].entry!),
                                            false,
                                            AppLocalization.of(context)!
                                                    .getTranslatedValues(
                                                        playedContestKey) ??
                                                "-",
                                          );

                                      context
                                          .read<UserDetailsCubit>()
                                          .updateCoins(
                                              addCoin: false,
                                              coins: int.parse(data
                                                  .contestDetails[index]
                                                  .entry!));
                                      Navigator.of(context)
                                          .pushReplacementNamed(Routes.quiz,
                                              arguments: {
                                            "numberOfPlayer": 1,
                                            "quizType": QuizTypes.contest,
                                            "contestId":
                                                data.contestDetails[index].id,
                                            "quizName": "Contest"
                                          });
                                    } else {
                                      UiUtils.setSnackbar(
                                          AppLocalization.of(context)!
                                              .getTranslatedValues(
                                                  "noCoinsMsg")!,
                                          context,
                                          false);
                                    }
                                  },
                                  child: Text(
                                    AppLocalization.of(context)!
                                        .getTranslatedValues("playLbl")!,
                                    style: TextStyle(color: Constants.white),
                                  ),
                                ),
                              )
                            : Container()
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
