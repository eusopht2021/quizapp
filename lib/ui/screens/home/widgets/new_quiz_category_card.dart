import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
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
        top: 0,
        left: horizontalMargin ?? 0,
        right: horizontalMargin ?? 0,
        bottom: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          width: 2,
          color: Constants.grey5,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.only(
          left: 8,
          right: 16,
          top: 4,
          bottom: 4,
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              border: Border.all(
                width: 3,
                color: Constants.accent2,
              ),
              borderRadius: BorderRadius.circular(
                15,
              ),
              // color: Constants.black1,
            ),
            height: 60,
            width: 55,
            child: CachedNetworkImage(
              imageUrl: asset,
              // height: 25,
              // width: 25,
              fit: BoxFit.scaleDown,
              placeholder: (_, __) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Constants.primaryColor,
                  ),
                );
              },
              errorWidget: ((context, error, stackTrace) {
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
