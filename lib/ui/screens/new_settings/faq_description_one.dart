import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/notched_card.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/custom_appbar.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/widgets_util.dart';
import 'package:video_player/video_player.dart';

class FaqDescriptionOne extends StatefulWidget {
  const FaqDescriptionOne({Key? key}) : super(key: key);

  @override
  State<FaqDescriptionOne> createState() => _FaqDescriptionOneState();
}

class _FaqDescriptionOneState extends State<FaqDescriptionOne> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.grey5,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: "Help and Support",
          showBackButton: true,
          textColor: Constants.black1,
          iconColor: Constants.black1,
          onBackTapped: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
          top: 24,
        ),
        child: NotchedCard(
          dotColor: Constants.grey5,
          circleColor: Constants.white,
          child: Container(
            padding: const EdgeInsets.only(
              right: 16,
              left: 16,
              top: 40,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Constants.white),
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText(
                  text: "Intro to Queezy apps",
                  weight: FontWeight.w500,
                  textColor: Constants.black1,
                  size: Constants.bodyLarge,
                ),
                WidgetsUtil.verticalSpace10,
                TitleText(
                  text: "Updated  • 1 month ago",
                  weight: FontWeight.w400,
                  textColor: Constants.grey2,
                  size: Constants.bodyXSmall,
                ),
                WidgetsUtil.verticalSpace16,
                TitleText(
                  text:
                      "Queezy apps offer gamified quizzes with many different topics to test out your knowledge.",
                  weight: FontWeight.w400,
                  textColor: Constants.grey1,
                  size: Constants.bodyNormal,
                ),
                WidgetsUtil.verticalSpace16,
                TitleText(
                  text:
                      "With Queezy you can also take part in challenges with friends or against others.",
                  weight: FontWeight.w400,
                  textColor: Constants.grey1,
                  size: Constants.bodyNormal,
                ),
                WidgetsUtil.verticalSpace20,
                Stack(
                  children: [
                    Container(
                      // height: SizeConfig.screenHeight / 3,
                      width: SizeConfig.screenWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _controller.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            )
                          : Container(),
                    ),
                    // Container(
                    //   color: Colors.black.withOpacity(0.7),
                    // ),
                    // Container(
                    //   alignment: Alignment.center,
                    //   child: Center(
                    //     child: Container(
                    //       height: 20,
                    //       width: 30,
                    //       color: Constants.primaryColor,
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    //   alignment: Alignment.center,
                    //   child: Center(
                    //     child: Icon(
                    //       Icons.smart_display,
                    //       color: Constants.white,
                    //       size: 30,
                    //     ),
                    //   ),
                    // ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: const Color(0xffF2F7FD),
                          ),
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                          child: Container(
                            width: SizeConfig.screenWidth / 3,
                            child: Row(
                              children: [
                                TitleText(
                                  text: "Watch on",
                                  weight: FontWeight.w400,
                                  textColor: Constants.black1,
                                  size: Constants.bodyXSmall,
                                ),
                                Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.red,
                                ),
                                TitleText(
                                  text: "Youtube",
                                  weight: FontWeight.w400,
                                  textColor: Constants.black1,
                                  size: Constants.bodyXSmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
