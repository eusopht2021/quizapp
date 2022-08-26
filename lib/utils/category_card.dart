import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/style_properties.dart';

import 'package:flutterquiz/utils/widgets_util.dart';

class CategoryCard extends StatelessWidget {
  bool? showAsSubCategories;
  int? quizzes;
  final String categoryName;
  final String icon;
  final Color backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final double? iconShadowOpacity;
  CategoryCard({
    Key? key,
    required this.categoryName,
    required this.showAsSubCategories,
    required this.backgroundColor,
    required this.icon,
    this.quizzes,
    this.iconColor,
    this.iconShadowOpacity,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: StyleProperties.cardsRadius,
        color: backgroundColor,
      ),
      padding: StyleProperties.insets18,
      child: Column(
        children: [
          _iconBox(),
          WidgetsUtil.verticalSpace10,
          TitleText(
            text: categoryName,
            textColor: textColor ?? Constants.white,
            size: Constants.bodyNormal,
            weight: FontWeight.w500,
          ),
          WidgetsUtil.verticalSpace8,
          TitleText(
            text: showAsSubCategories!
                ? quizzes! <= 1
                    ? "$quizzes Subcategory"
                    : "$quizzes Subcategories"
                : quizzes! <= 1
                    ? "$quizzes Quiz"
                    : "$quizzes Quizzes",
            textColor: textColor ?? Constants.white,
            size: Constants.bodyXSmall,
            weight: FontWeight.w400,
          )
        ],
      ),
    );
  }

  Widget _iconBox() => Container(
        decoration: BoxDecoration(
            color: Constants.white.withOpacity(iconShadowOpacity ?? 0.2),
            borderRadius: StyleProperties.cardsRadius),
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(10),
        child: icon.contains('.svg')
            ? SvgPicture.asset(
                icon,
                height: 38,
                color: iconColor ?? Constants.white,
              )
            : icon.contains('.png')
                ? Image.asset(
                    icon,
                    height: 38,
                    color: iconColor ?? Constants.white,
                  )
                : Icon(
                    Icons.error,
                    color: iconColor,
                  ),
      );
}
