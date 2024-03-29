import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/utils/constants.dart';

class QuestionContainer extends StatelessWidget {
  final Question? question;
  final Color? questionColor;
  final int? questionNumber;
  final bool isMathQuestion;

  const QuestionContainer({
    Key? key,
    this.question,
    required this.isMathQuestion,
    this.questionColor,
    this.questionNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(isMathQuestion);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                alignment: Alignment.centerLeft,
                child: isMathQuestion
                    ? TeXView(
                        child: TeXViewDocument(
                          question!.question!,
                        ),
                        style: TeXViewStyle(
                            contentColor: questionColor ?? Constants.black1,
                            backgroundColor: Colors.transparent,
                            sizeUnit: TeXViewSizeUnit.pixels,
                            textAlign: TeXViewTextAlign.center,
                            fontStyle: TeXViewFontStyle(
                              fontSize: Constants.bodyXLarge.toInt(),
                              fontWeight: TeXViewFontWeight.w500,
                            )),
                      )
                    : Text(
                        questionNumber == null
                            ? "${question!.question}"
                            : "$questionNumber. " + "${question!.question}",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                            color: questionColor ?? Constants.black1),
                      ),
              ),
            ),
            question!.marks!.isEmpty
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Text(
                      "[${question!.marks}]",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                          color:
                              questionColor ?? Theme.of(context).primaryColor),
                    ),
                  ),
          ],
        ),
        const SizedBox(
          height: 15.0,
        ),
        question!.imageUrl == null
            ? Container()
            : question!.imageUrl!.isEmpty
                ? Container()
                : Container(
                    width: MediaQuery.of(context).size.width * (0.8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0)),
                    height: MediaQuery.of(context).size.height * (0.225),
                    child: CachedNetworkImage(
                      errorWidget: (context, image, _) => Center(
                        child: Icon(
                          Icons.error,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        );
                      },
                      imageUrl: question!.imageUrl!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: Constants.primaryColor,
                      )),
                    ),
                  ),
        question!.imageUrl == null
            ? Container()
            : const SizedBox(
                height: 5.0,
              ),
      ],
    );
  }
}
