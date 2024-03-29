import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/tournament/cubits/tournamentDetailsCubit.dart';
import 'package:flutterquiz/features/tournament/model/tournamentDetails.dart';
import 'package:flutterquiz/features/tournament/tournamentRepository.dart';

import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';

class TournamentDetailsScreen extends StatefulWidget {
  TournamentDetailsScreen({Key? key}) : super(key: key);

  @override
  _TournamentDetailsScreenState createState() =>
      _TournamentDetailsScreenState();

  static Route<TournamentDetailsScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          //
          BlocProvider(
              create: (_) => TournamentDetailsCubit(TournamentRepository())),
        ],
        child: TournamentDetailsScreen(),
      ),
    );
  }
}

class _TournamentDetailsScreenState extends State<TournamentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    getTournaments();
  }

  void getTournaments() {
    Future.delayed(Duration.zero, () {
      context.read<TournamentDetailsCubit>().getTournaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.of(context).pushNamed(Routes.tournament,
            arguments: TournamentDetails(
                createdAt: "",
                entryFee: 5,
                winAmount: 40,
                id: "1",
                title: "Quiz Cup",
                questionDuration: const Duration(seconds: 10)));
      }),
      body: Stack(
        children: [
          const PageBackgroundGradientContainer(),
        ],
      ),
    );
  }
}
