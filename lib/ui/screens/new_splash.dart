import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/authLocalDataSource.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/widgets/default_background.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/assets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/size_config.dart';

class Splash extends StatefulWidget {
  Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool isUserLoggedIn = AuthLocalDataSource.checkIsAuth();
  @override
  void initState() {
    Future.delayed(
      const Duration(seconds: 10),
      () {
        debugPrint('Splash');
        if (!isUserLoggedIn) {
          Navigator.pushReplacementNamed(context, Routes.onBoardingScreen);
        } else
          context
              .read<UserDetailsCubit>()
              .fetchUserDetails(context.read<AuthCubit>().getUserFirebaseId());
        Navigator.pushReplacementNamed(context, Routes.home);
        // navigateToNextScreen();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(SizeConfig.screenWidth);
    return DefaultBackground(
      child: SizedBox(
        width: SizeConfig.screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset(
                Assets.lightIcon,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TitleText(
              text: 'Queezy',
              textColor: Constants.white,
              size: 36,
              fontFamily: 'Nunito',
              weight: FontWeight.w800,
            ),
          ],
        ),
      ),
    );
  }
}
