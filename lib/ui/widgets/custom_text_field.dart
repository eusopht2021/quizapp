import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final String? suffixIcon, label;
  final dynamic prefixIcon;
  final Function()? onSuffixTap;
  final Function()? onTap;
  final String? Function(String?)? onSaved;
  final Color? fillColor;
  final TextInputType? keyboardtype;
  final Color? iconTextColor;
  final Color? borderColor;
  final bool showBorder;
  final FocusNode? node;
  final int? maxLines;
  final double? textSize;
  final FontWeight? titleWeight;
  final MainAxisAlignment? mainAxisAlignment;
  final double? horizontalMargin;
  bool isDark = false;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;
  final bool? hidetext;
  final String? obscuringCharacter;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;

  CustomTextField({
    Key? key,
    this.label,
    this.obscuringCharacter,
    this.hidetext,
    this.controller,
    required this.hint,
    this.keyboardtype,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.fillColor = Colors.white,
    this.iconTextColor,
    this.showBorder = false,
    this.onTap,
    this.onSaved,
    this.node,
    this.textSize,
    this.titleWeight,
    this.borderColor,
    this.maxLines,
    this.textInputType,
    this.validator,
    this.mainAxisAlignment,
    this.horizontalMargin,
    this.onFieldSubmitted,
    this.textInputAction,
  }) : super(key: key);

  bool isColorDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  @override
  Widget build(BuildContext context) {
    isDark = isColorDark(fillColor!);
    return Column(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      children: [
        if (label != null)
          Container(
            margin: EdgeInsets.only(
              left: horizontalMargin ?? 24,
            ),
            alignment: Alignment.centerLeft,
            child: TitleText(
              text: label!,
              weight: titleWeight ?? FontWeight.w400,
              textColor: iconTextColor ?? Constants.black2,
              size: textSize ?? Constants.bodySmall,
            ),
          ),
        Container(
          margin: EdgeInsets.only(
            left: horizontalMargin ?? 24,
            right: horizontalMargin ?? 24,
            top: 8,
          ),
          padding: const EdgeInsets.all(0.0),
          child: TextFormField(
            style: TextStyle(color: iconTextColor),
            controller: controller,
            validator: validator,
            maxLines: maxLines ?? 1,
            focusNode: node,
            onTap: onTap,
            onSaved: onSaved,
            obscureText: hidetext ?? false,
            obscuringCharacter: obscuringCharacter ?? "*",
            onFieldSubmitted: onFieldSubmitted,
            textInputAction: textInputAction,
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor ?? Constants.white,
              border: _border(),
              focusedBorder: _border(),
              enabledBorder: _border(),
              prefixIconConstraints: const BoxConstraints(
                maxWidth: 72,
                maxHeight: 24,
              ),
              prefixIcon: getPrefixIcon(),
              suffixIconConstraints: const BoxConstraints(
                maxWidth: 72,
                maxHeight: 24,
              ),
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: onSuffixTap,
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                        ),
                        child: suffixIcon!.contains('.svg')
                            ? SvgPicture.asset(
                                suffixIcon!,
                                fit: BoxFit.contain,
                                color: isDark ? Constants.white : null,
                              )
                            : Image.asset(
                                suffixIcon!,
                                fit: BoxFit.contain,
                                color: isDark ? Constants.white : null,
                              ),
                      ),
                    )
                  : null,
              hintText: hint,
              hintStyle: GoogleFonts.rubik(
                fontWeight: FontWeight.w400,
                fontSize: Constants.bodyNormal,
                color: isDark ? Constants.white : Constants.grey2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: showBorder
            ? BorderSide(
                color: borderColor ?? Constants.primaryColor,
                width: 2,
              )
            : BorderSide.none,
      );

  Widget? getPrefixIcon() {
    if (prefixIcon == null) {
      return null;
    } else if (prefixIcon.runtimeType == String) {
      return Container(
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        child: prefixIcon!.contains('.svg')
            ? SvgPicture.asset(
                prefixIcon!,
                // fit: BoxFit.contain,
                color: isDark ? Constants.white : null,
              )
            : Image.asset(
                prefixIcon!,
                // fit: BoxFit.contain,
                color: isDark ? Constants.white : null,
              ),
      );
    } else {
      return prefixIcon;
    }
  }
}
