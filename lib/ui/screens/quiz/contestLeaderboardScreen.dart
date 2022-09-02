import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/getContestLeaderboardCubit.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/notched_card.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:recase/recase.dart';
import 'package:flutterquiz/utils/widgets_util.dart';

class ContestLeaderBoardScreen extends StatefulWidget {
  final String? contestId;
  const ContestLeaderBoardScreen({Key? key, this.contestId}) : super(key: key);
  @override
  _ContestLeaderBoardScreen createState() => _ContestLeaderBoardScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<GetContestLeaderboardCubit>(
              create: (_) => GetContestLeaderboardCubit(QuizRepository()),
              child:
                  ContestLeaderBoardScreen(contestId: arguments!['contestId']),
            ));
  }
}

class _ContestLeaderBoardScreen extends State<ContestLeaderBoardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GetContestLeaderboardCubit>().getContestLeaderboard(
        userId: context.read<UserDetailsCubit>().getUserId(),
        contestId: widget.contestId);
  }

  int selectTab = 0;
  bool isExpand = false;
  double _topPosition(index) {
    double position = 0;
    index == 0
        ? position = SizeConfig.screenHeight * (0.012)
        : index == 1
            ? position = SizeConfig.screenHeight * (0.045)
            : index == 2
                ? position = SizeConfig.screenHeight * (0.07)
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
                ? position = SizeConfig.screenHeight * (0.045)
                : null;
    return position;
  }

  Color? _dotColor;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.primaryColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          leading: CustomBackButton(
            iconColor: Constants.white,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalization.of(context)!
                    .getTranslatedValues("contestLeaderBoardLbl")!,
                style: TextStyle(color: Constants.white),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.backgroundCircle),
            ),
          ),
          child: Stack(
            children: [
              leaderBoard(),
            ],
          ),
        ));
  }

  Widget leaderBoard() {
    return BlocConsumer<GetContestLeaderboardCubit, GetContestLeaderboardState>(
      bloc: context.read<GetContestLeaderboardCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        if (state is GetContestLeaderboardProgress ||
            state is GetContestLeaderboardInitial) {
          return Center(
            child: CircularProgressIndicator(
              color: Constants.white,
            ),
          );
        }
        if (state is GetContestLeaderboardFailure) {
          return ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                context
                    .read<GetContestLeaderboardCubit>()
                    .getContestLeaderboard(
                        userId: context.read<UserDetailsCubit>().getUserId(),
                        contestId: widget.contestId);
              },
              showErrorImage: true);
        }
        final getContestLeaderboardList =
            (state as GetContestLeaderboardSuccess).getContestLeaderboardList;

        log("getContestLeaderboardList  inedex 0 : ${getContestLeaderboardList[0].name}");

        // final podiumList = [];
        // /for (int i = 0; i < getContestLeaderboardList.length; i++) {
        //   if (i == 0) {
        //     continue;
        //   } else {
        //     podiumList.add(getContestLeaderboardList[i]);
        //   }
        // }

        return SizedBox(
          height: SizeConfig.screenHeight,
          child: Stack(
            children: [
              ...List.generate(getContestLeaderboardList.length, (index) {
                return Positioned(
                  top: _topPosition(index),
                  left: _leftPosition(index),
                  right: _rightPosition(index),
                  child: index < 3
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
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
                                  badgeContent: index == 0
                                      ? SvgPicture.asset(
                                          Assets.crown,
                                          height: 30,
                                        )
                                      : const SizedBox(),
                                  position:
                                      BadgePosition.topEnd(end: 5, top: -20),
                                  badgeColor: Colors.transparent,
                                  child: ClipOval(
                                    clipBehavior: Clip.antiAlias,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      radius: 25,
                                      child: CachedNetworkImage(
                                        imageUrl: index == 0
                                            ? getContestLeaderboardList[0]
                                                .profile!
                                            : index == 1
                                                ? getContestLeaderboardList[1]
                                                    .profile!
                                                : index == 2
                                                    ? getContestLeaderboardList[
                                                            2]
                                                        .profile!
                                                    : "",
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
                              ),
                              WidgetsUtil.verticalSpace16,
                              SizedBox(
                                width: 100,
                                height: 20,
                                child: TitleText(
                                  text: (index == 0
                                          ? getContestLeaderboardList[0].name!
                                          : index == 1
                                              ? getContestLeaderboardList[1]
                                                  .name!
                                              : index == 2
                                                  ? getContestLeaderboardList[2]
                                                      .name!
                                                  : "")
                                      .titleCase,
                                  textColor: Constants.white,
                                  size: Constants.bodySmall,
                                  align: TextAlign.center,
                                  maxlines: 1,
                                ),
                              ),
                              WidgetsUtil.verticalSpace8,
                              index < 3
                                  ? _qpContainer(
                                      Center(
                                        child: TitleText(
                                          // ignore: prefer_interpolation_to_compose_strings
                                          text: (index == 0
                                                  ? getContestLeaderboardList[0]
                                                      .score!
                                                  : index == 1
                                                      ? getContestLeaderboardList[
                                                              1]
                                                          .score!
                                                      : index == 2
                                                          ? getContestLeaderboardList[
                                                                  2]
                                                              .score!
                                                          : "") +
                                              " PTS",
                                          size: Constants.bodyXSmall,
                                          textColor: Constants.white,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        )
                      : const SizedBox(),
                );
              }),
              Positioned(
                top: SizeConfig.screenHeight * 0.156,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: SizeConfig.screenWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // const Expanded(
                          //   flex: 1,
                          //   child: SizedBox(),
                          // ),
                          Expanded(
                            flex: 5,
                            child: Image.asset(
                              Assets.rank2,
                              fit: BoxFit.fill,
                              width: SizeConfig.screenWidth * 0.15,
                              height: SizeConfig.screenHeight * 0.29,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Image.asset(
                              Assets.rank1,
                              fit: BoxFit.fill,
                              width: SizeConfig.screenWidth * 0.2,
                              height: SizeConfig.screenHeight * 0.37,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 80),
                              child: Image.asset(
                                Assets.rank3,
                                fit: BoxFit.fill,
                                width: SizeConfig.screenWidth * 0.15,
                                height: SizeConfig.screenHeight * 0.35,
                              ),
                            ),
                          ),
                          // const Expanded(
                          //   flex: 1,
                          //   child: SizedBox(),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              leaderBoardList(getContestLeaderboardList),
            ],
          ),
        );
      },
    );
  }

//////////////
  Widget leaderBoardList(List leaderBoardList) {
    List startsFromThree = [];
    List startsFromZero = [];
    List users = [];
    // print("getContestLeaderboardList  inedex 0 : ${startsFromThree[0].name}");

    // log("getContestLeaderboardList  inedex 0 : ${users[0].name}");
    int counterIndex = 0;
    // log(draggable[""].toString());
    // log('Draggable: ${draggable.length}   leaderboard : ${leaderBoardList.length}   ');
    return NotificationListener(
      onNotification: (DraggableScrollableNotification dSnotification) {
        double extent = dSnotification.extent;
        String temp = extent.toStringAsFixed(2);
        extent = double.parse(temp);

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
        initialChildSize: 0.45,
        minChildSize: 0.45,
        maxChildSize: 1.0,
        builder: (context, controller) {
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
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: ListView(
                controller: controller,
                shrinkWrap: true,
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
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        // counterIndex++;
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
                                              ? ((index + 1).toString())
                                              : (index + 3).toString(),
                                        ),
                                      ),
                                    ),
                                  ),

                                  //),
                                  Expanded(
                                    flex: 9,
                                    child: ListTile(
                                        leading: ClipOval(
                                          clipBehavior: Clip.antiAlias,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            radius: 25,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  users[index].profile! ?? "",
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
                                        title: TitleText(
                                          text:
                                              "${users[index].name ?? "Player"}",
                                        ),
                                        subtitle: TitleText(
                                          text:
                                              '${users[index].score ?? "0"} PTS',
                                        ),
                                        trailing: isExpand
                                            ? index == 0
                                                ? SvgPicture.asset(Assets.crown)
                                                : index == 1
                                                    ? SvgPicture.asset(
                                                        Assets.silverCrown)
                                                    : index == 2
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
//////////////////////////////////////////////////////////////
/////////////////////////
///////////////////////////////////////////
//           return Container(
//             height: MediaQuery.of(context).size.height,
//             child: Column(children: [
//               Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.height * .28,
//                   child: LayoutBuilder(builder: (context, constraints) {
//                     double profileRadiusPercentage = 0.0;
//                     if (constraints.maxHeight <
//                         UiUtils.profileHeightBreakPointResultScreen) {
//                       profileRadiusPercentage = 0.175;
//                     } else {
//                       profileRadiusPercentage = 0.2;
//                     }
//                     return Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         getContestLeaderboardList.length > 1
//                             ? Container(
//                                 padding: EdgeInsetsDirectional.only(
//                                     top: MediaQuery.of(context).size.height *
//                                         .07),
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       height:
//                                           MediaQuery.of(context).size.height *
//                                               .115,
//                                       width: MediaQuery.of(context).size.width *
//                                           .22,
//                                       child: Stack(
//                                         children: [
//                                           Container(
//                                               height: MediaQuery.of(context)
//                                                       .size
//                                                       .height *
//                                                   .1,
//                                               width: MediaQuery.of(context)
//                                                       .size
//                                                       .width *
//                                                   .22,
//                                               decoration: BoxDecoration(
//                                                   shape: BoxShape.circle,
//                                                   border: Border.all(
//                                                       width: 1.0,
//                                                       color: Theme.of(context)
//                                                           .backgroundColor)),
//                                               child: CircleAvatar(
//                                                   radius: constraints
//                                                           .maxHeight *
//                                                       (profileRadiusPercentage -
//                                                           0.0535),
//                                                   backgroundImage:
//                                                       CachedNetworkImageProvider(
//                                                     getContestLeaderboardList[1]
//                                                         .profile!,
//                                                   ))),
//                                           Positioned(
//                                             left: MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 .06,
//                                             top: MediaQuery.of(context)
//                                                     .size
//                                                     .height *
//                                                 .07,
//                                             child: CircleAvatar(
//                                                 radius: 15,
//                                                 backgroundColor:
//                                                     Theme.of(context)
//                                                         .primaryColor,
//                                                 child: Text(
//                                                   "2\u207f\u1d48",
//                                                   style: TextStyle(
//                                                       color: Theme.of(context)
//                                                           .backgroundColor),
//                                                 )),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Container(
//                                       width: MediaQuery.of(context).size.width *
//                                           .2,
//                                       child: Center(
//                                         child: Text(
//                                           getContestLeaderboardList[1].name ??
//                                               "...",
//                                           overflow: TextOverflow.ellipsis,
//                                           maxLines: 2,
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                               color: Theme.of(context)
//                                                   .primaryColor),
//                                         ),
//                                       ),
//                                     ),
//                                     Container(
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 .2,
//                                         child: Center(
//                                           child: Text(
//                                             getContestLeaderboardList[1]
//                                                     .score ??
//                                                 "...",
//                                             overflow: TextOverflow.ellipsis,
//                                             maxLines: 1,
//                                             textAlign: TextAlign.center,
//                                             style: TextStyle(
//                                                 color: Theme.of(context)
//                                                     .primaryColor),
//                                           ),
//                                         )),
//                                   ],
//                                 ),
//                               )
//                             : Container(
//                                 height: MediaQuery.of(context).size.height * .1,
//                                 width: MediaQuery.of(context).size.width * .22,
//                               ),
//                         Container(
//                           child: Column(
//                             children: [
//                               SvgPicture.asset(
//                                   UiUtils.getImagePath("Rankone_icon.svg"),
//                                   height:
//                                       MediaQuery.of(context).size.height * .025,
//                                   color: primaryColor,
//                                   width:
//                                       MediaQuery.of(context).size.width * .02),
//                               Container(
//                                 decoration:
//                                     const BoxDecoration(shape: BoxShape.circle),
//                                 height:
//                                     MediaQuery.of(context).size.height * .16,
//                                 width: MediaQuery.of(context).size.width * .26,
//                                 child: Stack(
//                                   children: [
//                                     Container(
//                                       height:
//                                           MediaQuery.of(context).size.height *
//                                               .14,
//                                       width: MediaQuery.of(context).size.width *
//                                           .26,
//                                       decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           border: Border.all(
//                                               width: 3.0,
//                                               color: Theme.of(context)
//                                                   .primaryColor)),
//                                       child: Card(
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(100),
//                                         ),
//                                         child: CircleAvatar(
//                                             radius: constraints.maxHeight *
//                                                 (profileRadiusPercentage -
//                                                     0.0535),
//                                             backgroundImage:
//                                                 CachedNetworkImageProvider(
//                                               getContestLeaderboardList[0]
//                                                   .profile!,
//                                             )),
//                                       ),
//                                     ),
//                                     Positioned(
//                                       left: MediaQuery.of(context).size.width *
//                                           .08,
//                                       top: MediaQuery.of(context).size.height *
//                                           .11,
//                                       child: CircleAvatar(
//                                           radius: 17,
//                                           backgroundColor:
//                                               Theme.of(context).primaryColor,
//                                           child: Text(
//                                             "1\u02e2\u1d57",
//                                             style: TextStyle(
//                                                 color: Theme.of(context)
//                                                     .backgroundColor),
//                                           )),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Container(
//                                   width: MediaQuery.of(context).size.width * .2,
//                                   child: Center(
//                                     child: Text(
//                                       getContestLeaderboardList[0].name ??
//                                           "...",
//                                       overflow: TextOverflow.ellipsis,
//                                       textAlign: TextAlign.center,
//                                       maxLines: 2,
//                                       style: TextStyle(
//                                           color:
//                                               Theme.of(context).primaryColor),
//                                     ),
//                                   )),
//                               Container(
//                                   width: MediaQuery.of(context).size.width * .2,
//                                   child: Center(
//                                     child: Text(
//                                       getContestLeaderboardList[0].score ??
//                                           "...",
//                                       overflow: TextOverflow.ellipsis,
//                                       textAlign: TextAlign.center,
//                                       maxLines: 1,
//                                       style: TextStyle(
//                                           color:
//                                               Theme.of(context).primaryColor),
//                                     ),
//                                   ))
//                             ],
//                           ),
//                         ),
//                         getContestLeaderboardList.length > 2
//                             ? Container(
//                                 padding: EdgeInsetsDirectional.only(
//                                     top: MediaQuery.of(context).size.height *
//                                         .07),
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       height:
//                                           MediaQuery.of(context).size.height *
//                                               .115,
//                                       width: MediaQuery.of(context).size.width *
//                                           .22,
//                                       child: Stack(
//                                         children: [
//                                           Container(
//                                               height: MediaQuery.of(context)
//                                                       .size
//                                                       .height *
//                                                   .1,
//                                               width: MediaQuery.of(context)
//                                                       .size
//                                                       .width *
//                                                   .22,
//                                               decoration: BoxDecoration(
//                                                   shape: BoxShape.circle,
//                                                   border: Border.all(
//                                                       width: 1.0,
//                                                       color: Theme.of(context)
//                                                           .backgroundColor)),
//                                               child: CircleAvatar(
//                                                   radius: constraints
//                                                           .maxHeight *
//                                                       (profileRadiusPercentage -
//                                                           0.0535),
//                                                   backgroundImage:
//                                                       CachedNetworkImageProvider(
//                                                     getContestLeaderboardList[2]
//                                                             .profile ??
//                                                         "",
//                                                   ))),
//                                           Positioned(
//                                               left: MediaQuery.of(context)
//                                                       .size
//                                                       .width *
//                                                   .06,
//                                               top: MediaQuery.of(context)
//                                                       .size
//                                                       .height *
//                                                   .07,
//                                               child: CircleAvatar(
//                                                   radius: 15,
//                                                   backgroundColor:
//                                                       Theme.of(context)
//                                                           .primaryColor,
//                                                   child: Text(
//                                                     "3\u02b3\u1d48",
//                                                     style: TextStyle(
//                                                         color: Theme.of(context)
//                                                             .backgroundColor),
//                                                   ))),
//                                         ],
//                                       ),
//                                     ),
//                                     Container(
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 .2,
//                                         child: Center(
//                                           child: Text(
//                                             getContestLeaderboardList[2].name ??
//                                                 "...",
//                                             overflow: TextOverflow.ellipsis,
//                                             maxLines: 2,
//                                             textAlign: TextAlign.center,
//                                             style: TextStyle(
//                                                 color: Theme.of(context)
//                                                     .primaryColor),
//                                           ),
//                                         )),
//                                     Container(
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 .2,
//                                         child: Center(
//                                           child: Text(
//                                             getContestLeaderboardList[2]
//                                                     .score ??
//                                                 "...",
//                                             overflow: TextOverflow.ellipsis,
//                                             textAlign: TextAlign.center,
//                                             maxLines: 1,
//                                             style: TextStyle(
//                                                 color: Theme.of(context)
//                                                     .primaryColor),
//                                           ),
//                                         )),
//                                   ],
//                                 ),
//                               )
//                             : Container(
//                                 height: MediaQuery.of(context).size.height * .1,
//                                 width: MediaQuery.of(context).size.width * .22,
//                               )
//                       ],
//                     );
//                   })),
//               Container(
//                 height: MediaQuery.of(context).size.height * .51,
//                 padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   itemCount: getContestLeaderboardList.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     int i = index + 1;
//                     return index > 2
//                         ? Row(
//                             children: [
//                               Expanded(
//                                 flex: 1,
//                                 child: Padding(
//                                   padding: EdgeInsetsDirectional.only(
//                                       top: MediaQuery.of(context).size.height *
//                                           .01,
//                                       start: 10),
//                                   child: Column(children: <Widget>[
//                                     Text(
//                                       "$i",
//                                       style: const TextStyle(fontSize: 18),
//                                     ),
//                                     Icon(Icons.arrow_drop_up,
//                                         color: Theme.of(context).primaryColor)
//                                   ]),
//                                 ),
//                               ),
//                               Expanded(
//                                 flex: 9,
//                                 child: Card(
//                                   color: Theme.of(context)
//                                       .primaryColor
//                                       .withOpacity(0.1),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(35.0),
//                                   ),
//                                   child: ListTile(
//                                     dense: true,
//                                     contentPadding: const EdgeInsets.only(
//                                         left: 0, right: 20),
//                                     title: Text(
//                                       getContestLeaderboardList[index].name!,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     leading: Container(
//                                       width: MediaQuery.of(context).size.width *
//                                           .12,
//                                       height:
//                                           MediaQuery.of(context).size.height *
//                                               .3,
//                                       decoration: BoxDecoration(
//                                         color: Theme.of(context)
//                                             .primaryColor
//                                             .withOpacity(0.5),
//                                         shape: BoxShape.circle,
//                                         image: DecorationImage(
//                                             image: NetworkImage(
//                                                 getContestLeaderboardList[index]
//                                                     .profile!),
//                                             fit: BoxFit.cover),
//                                       ),
//                                     ),
//                                     trailing: Container(
//                                       width: MediaQuery.of(context).size.width *
//                                           .1,
//                                       child: Text(
//                                         UiUtils.formatNumber(int.parse(
//                                             getContestLeaderboardList[index]
//                                                     .score ??
//                                                 "0")),
//                                         maxLines: 1,
//                                         softWrap: false,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : Container();
//                   },
//                 ),
//               ),
              // Container(
              //   decoration: BoxDecoration(
              //       color: Theme.of(context).colorScheme.secondary,
              //       borderRadius: const BorderRadius.only(
              //           topLeft: const Radius.circular(20),
              //           topRight: const Radius.circular(20))),
              //   child: ListTile(
              //       title: Text(
              //         "My Rank",
              //         overflow: TextOverflow.ellipsis,
              //         style: TextStyle(color: backgroundColor),
              //       ),
              //       leading: Wrap(children: [
              //         Container(
              //           width: MediaQuery.of(context).size.width * .08,
              //           padding: EdgeInsets.only(
              //               top: MediaQuery.of(context).size.height * .02),
              //           child: Text(
              //             QuizRemoteDataSource.rank,
              //             overflow: TextOverflow.ellipsis,
              //             maxLines: 1,
              //             style: TextStyle(color: backgroundColor),
              //           ),
              //         ),
              //         Container(
              //             height: MediaQuery.of(context).size.height * .06,
              //             width: MediaQuery.of(context).size.width * .13,
              //             decoration: BoxDecoration(
              //                 shape: BoxShape.circle,
              //                 border: Border.all(
              //                     width: 1.0,
              //                     color: Theme.of(context).backgroundColor),
              //                 image: new DecorationImage(
              //                     fit: BoxFit.fill,
              //                     image: NetworkImage(
              //                         QuizRemoteDataSource.profile)))),
              //       ]),
              //       trailing: Container(
              //         height: MediaQuery.of(context).size.height * .06,
              //         width: MediaQuery.of(context).size.width * .25,
              //         decoration: BoxDecoration(
              //           color: Theme.of(context).primaryColor,
              //           borderRadius: const BorderRadius.only(
              //               bottomLeft: const Radius.circular(50.0),
              //               topLeft: const Radius.circular(50.0),
              //               bottomRight: const Radius.circular(20.0),
              //               topRight: const Radius.circular(20.0)),
              //         ),
              //         child: Center(
              //             child: Text(
              //           QuizRemoteDataSource.score,
              //           style:
              //               TextStyle(color: Theme.of(context).backgroundColor),
              //         )),
              //       )),
              // ),
//             ]),
//           );
//         });
//   }
// }
