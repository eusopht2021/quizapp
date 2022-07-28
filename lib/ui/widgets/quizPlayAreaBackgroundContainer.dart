import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/constants.dart';

class QuizPlayAreaBackgroundContainer extends StatelessWidget {
  final double? heightPercentage;
  QuizPlayAreaBackgroundContainer({Key? key, this.heightPercentage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * (heightPercentage ?? 0.885),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Constants.primaryColor,
        borderRadius: const BorderRadiusDirectional.only(
            bottomEnd: const Radius.circular(100)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
    );
  }
}
