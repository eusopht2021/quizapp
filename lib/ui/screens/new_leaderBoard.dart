import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/leaderBoard/cubit/leaderBoardAllTimeCubit.dart';
import 'package:flutterquiz/features/leaderBoard/cubit/leaderBoardDailyCubit.dart';
import 'package:flutterquiz/features/leaderBoard/cubit/leaderBoardMonthlyCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/custom_appbar.dart';

class NewLeaderBoardScreen extends StatefulWidget {
  const NewLeaderBoardScreen({Key? key}) : super(key: key);

  @override
  State<NewLeaderBoardScreen> createState() => _NewLeaderBoardScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (context) => MultiBlocProvider(providers: [
              BlocProvider<LeaderBoardMonthlyCubit>(
                  create: (context) => LeaderBoardMonthlyCubit()),
              BlocProvider<LeaderBoardDailyCubit>(
                  create: (context) => LeaderBoardDailyCubit()),
              BlocProvider<LeaderBoardAllTimeCubit>(
                  create: (context) => LeaderBoardAllTimeCubit(
                      // LeaderBoardRepository(),
                      )),
            ], child: NewLeaderBoardScreen()));
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            child: CustomAppBar(
              title: "Leaderboard",
              onBackTapped: () {
                Navigator.pop(context);
              },
            ),
            preferredSize: Size.fromWidth(10),
          ),
        ),
      ),
    );
  }
}
