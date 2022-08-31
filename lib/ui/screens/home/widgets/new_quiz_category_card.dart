import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../utils/constants.dart';
import '../../../widgets/title_text.dart';

class QuizCategoryCard extends StatelessWidget {
  final String asset, name, category;
  final double? horizontalMargin;
  final Function()? onTap;
  const QuizCategoryCard({
    Key? key,
    required this.asset,
    required this.name,
    required this.category,
    this.onTap,
    this.horizontalMargin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        top: 6,
        left: horizontalMargin ?? 0,
        right: horizontalMargin ?? 0,
        bottom: 0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          width: 2,
          color: Constants.grey5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.only(
          left: 8,
          right: 16,
          top: 8,
          bottom: 8,
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Constants.accent2,
              ),
              borderRadius: BorderRadius.circular(
                20,
              ),
              // color: Constants.black1,
            ),
            height: 80,
            width: 50,
            child: asset.contains('.svg')
                ? SvgPicture.asset(
                    asset,
                    height: 25,
                    width: 25,
                    color: Constants.primaryColor,
                    placeholderBuilder: ((context) {
                      return const Icon(Icons.error);
                    }),
                  )
                : Image.asset(
                    asset,
                    height: 25,
                    width: 25,
                    errorBuilder: ((context, error, stackTrace) {
                      return const Icon(Icons.error);
                    }),
                  ),
          ),
        ),
        title: TitleText(
          text: name,
          size: Constants.bodyNormal,
          weight: FontWeight.w500,
          textColor: Constants.black1,
        ),
        subtitle: category.isEmpty
            ? null
            : TitleText(
                text: category,
                size: Constants.bodyXSmall,
                weight: FontWeight.w400,
              ),
        trailing: Icon(
          CupertinoIcons.forward,
          color: Constants.primaryColor,
          size: 24,
        ),
      ),
    );
  }
}
