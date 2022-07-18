import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleText extends StatelessWidget {
  final String text;
  final Color? textColor;
  final TextAlign? align;
  final FontWeight? weight;
  final String? fontFamily;
  final double? size;
  final double? lineHeight;
  final int? maxlines;

  const TitleText(
      {Key? key,
      required this.text,
      this.textColor,
      this.align,
      this.weight,
      this.fontFamily,
      this.size,
      this.maxlines,
      this.lineHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxlines,
      textAlign: align,
      style: GoogleFonts.getFont(fontFamily ?? 'Rubik',
          fontSize: size,
          fontWeight: weight,
          color: textColor,
          height: lineHeight),
    );
  }
}
