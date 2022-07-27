import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/notched_card.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/size_config.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class CustomDraggableBottomSheet extends StatelessWidget {
  final List leaderBoardList;
  bool hasMore;

  CustomDraggableBottomSheet({
    Key? key,
    required this.leaderBoardList,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 1,
      builder: (context, scrollController) {
        return Column(
          children: List.generate(leaderBoardList.length, (index) {
            if (index < 3) {
              return SizedBox();
            } else {
              return Card(
                child: Row(children: [
                  CircleAvatar(
                    child: TitleText(
                        text: UiUtils.formatNumber(
                      int.parse(index.toString()),
                    )),
                  ),
                  ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            leaderBoardList[index]['profile'] ?? ""),
                      ),
                      title: TitleText(
                        text: leaderBoardList[index]['name'] ?? "",
                      ),
                      subtitle: TitleText(
                        text: UiUtils.formatNumber(
                          int.parse(leaderBoardList[index]['score'] ?? "0"),
                        ),
                      )),
                ]),
              );
            }
          }),
        );
      },
    );
  }
}

// Expanded(
//             child: Container(
//               color: Colors.white,
//               child: NotchedCard(
//                   child: SizedBox(
//                 width: SizeConfig.screenWidth,
//                 height: SizeConfig.screenHeight * 0.4,
//                 child: ListView.builder(
//                   controller: scrollController,
//                   itemCount: leaderBoardList.length,
//                   shrinkWrap: true,
//                   itemBuilder: ((context, index) {
//                     return index > 3
//                         ? (hasMore && index == (leaderBoardList.length - 1))
//                             ? Center(
//                                 child: CircularProgressIndicator(
//                                 color: Constants.white,
//                               ))
//                             : Card(
//                                 color: Constants.white,
//                                 child: Row(
//                                   children: [
//                                     CircleAvatar(
//                                       child: TitleText(
//                                           text: UiUtils.formatNumber(
//                                         int.parse(index.toString()),
//                                       )),
//                                     ),
//                                     ListTile(
//                                       leading: CircleAvatar(
//                                         backgroundImage: NetworkImage(
//                                             leaderBoardList[index]['profile'] ??
//                                                 ""),
//                                       ),
//                                       title: TitleText(
//                                         text: leaderBoardList[index]['name'] ??
//                                             "",
//                                       ),
//                                       subtitle: TitleText(
//                                         text: UiUtils.formatNumber(
//                                           int.parse(leaderBoardList[index]
//                                                   ['score'] ??
//                                               "0"),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                         : Container();
//                   }),
//                 ),
//               )),
//             ),
//           );
