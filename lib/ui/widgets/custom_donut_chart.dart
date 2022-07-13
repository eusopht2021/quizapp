import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/constants.dart';

class CustomDonutChart extends StatelessWidget {
  final Widget center;
  final double height, radius, value1, value2;

  const CustomDonutChart({
    Key? key,
    required this.center,
    required this.height,
    required this.radius,
    required this.value1,
    required this.value2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: height,
          child: PieChart(
            PieChartData(
              startDegreeOffset: 270,
              centerSpaceRadius: 60,
              sectionsSpace: 0,
              sections: [
                PieChartSectionData(
                  value: value1,
                  showTitle: false,
                  color: Constants.primaryColor,
                  radius: radius,
                ),
                PieChartSectionData(
                  value: value2,
                  showTitle: false,
                  color: Constants.primaryColor.withOpacity(0.3),
                  radius: radius,
                ),
              ],
            ),
            swapAnimationDuration: const Duration(
              milliseconds: 150,
            ), // Optional
            swapAnimationCurve: Curves.bounceIn,
          ),
        ),
        SizedBox(
          height: height,
          child: Center(
            child: center,
          ),
        ),
      ],
    );
  }
}
