import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/comprehensionCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';

import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/default_layout.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class FunAndLearnTitleScreen extends StatefulWidget {
  final String type;
  final String typeId;
  final String? categoryTitle;

  const FunAndLearnTitleScreen(
      {Key? key, required this.type, required this.typeId, this.categoryTitle})
      : super(key: key);
  @override
  _FunAndLearnTitleScreen createState() => _FunAndLearnTitleScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
        builder: (_) => FunAndLearnTitleScreen(
              type: arguments['type'],
              typeId: arguments['typeId'],
              categoryTitle: arguments['categoryTitle'],
            ));
  }
}

class _FunAndLearnTitleScreen extends State<FunAndLearnTitleScreen> {
  @override
  void initState() {
    super.initState();
    getComprehension();
  }

  void getComprehension() {
    Future.delayed(Duration.zero, () {
      context.read<ComprehensionCubit>().getComprehension(
            userId: context.read<UserDetailsCubit>().getUserId(),
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: widget.type,
            typeId: widget.typeId,
          );
    });
  }

  Widget _buildBackButton() {
    return Row(
      children: [
        Align(
          alignment: AlignmentDirectional.topStart,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 15.0, start: 20),
            child: CustomBackButton(
              iconColor: Constants.white,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: TitleText(
            text: widget.categoryTitle ?? "Examsss",
            textColor: Constants.white,
            // align: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Align(
      alignment: Alignment.topCenter,
      child: BlocConsumer<ComprehensionCubit, ComprehensionState>(
          bloc: context.read<ComprehensionCubit>(),
          listener: (context, state) {
            if (state is ComprehensionFailure) {
              if (state.errorMessage == unauthorizedAccessCode) {
                //
                UiUtils.showAlreadyLoggedInDialog(
                  context: context,
                );
              }
            }
          },
          builder: (context, state) {
            if (state is ComprehensionProgress ||
                state is ComprehensionInitial) {
              return Center(
                child: CircularProgressIndicator(
                  color: Constants.white,
                ),
              );
            }
            if (state is ComprehensionFailure) {
              return ErrorContainer(
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(state.errorMessage)),
                onTapRetry: () {
                  getComprehension();
                },
                showErrorImage: true,
                errorMessageColor: Theme.of(context).primaryColor,
              );
            }
            final comprehensions =
                (state as ComprehensionSuccess).getComprehension;
            return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 15.0),
                itemCount: comprehensions.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      print("Played : ${comprehensions[index].isPlayed}");
                      Navigator.of(context).pushNamed(Routes.funAndLearn,
                          arguments: {
                            "comprehension": comprehensions[index],
                            "quizType": QuizTypes.funAndLearn
                          });
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      color: Constants.secondaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Text(
                            comprehensions[index].title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Constants.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            height: 90,
                            width: 100,
                            padding: const EdgeInsets.all(5),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Center(
                                  child: Text(
                                "${comprehensions[index].noOfQue}\n${AppLocalization.of(context)!.getTranslatedValues("questionLbl")!}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Constants.primaryColor, height: 1.0),
                              )),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        showBackButton: true,
        title: widget.categoryTitle ?? "",
        titleColor: Constants.white,
        backgroundColor: Constants.primaryColor,
        child: Stack(
          children: [
            // const PageBackgroundGradientContainer(),
            // _buildBackButton(),
            _buildTitle(),
            Align(
                alignment: Alignment.bottomCenter, child: BannerAdContainer()),
          ],
        ));
  }
}
