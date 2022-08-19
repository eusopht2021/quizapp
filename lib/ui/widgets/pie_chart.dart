import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/title_text.dart';

import '../../utils/constants.dart';

class CustomPieChart extends StatelessWidget {
  final double value1, value2, radius;
  final String? text;
  final Color? mainColor;

  const CustomPieChart({
    Key? key,
    required this.value1,
    required this.value2,
    required this.radius,
    this.text,
    this.mainColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PieChart(
          PieChartData(
            centerSpaceRadius: 0.0,
            sectionsSpace: 0.0,
            startDegreeOffset: 270,
            sections: [
              PieChartSectionData(
                value: value1,
                showTitle: false,
                color: mainColor ?? Constants.pink,
                radius: radius,
              ),
              PieChartSectionData(
                value: value2,
                showTitle: false,
                color: Constants.lightGreen.withOpacity(0.3),
                radius: radius,
              ),
            ],
          ),
        ),
        Center(
          child: TitleText(
            text: text ?? '${value1.toInt()}%',
            size: Constants.bodySmall,
            weight: FontWeight.w500,
            textColor: Constants.white,
          ),
        ),
      ],
    );
  }
}
