import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app/helper/dates_and_times.dart';
import 'package:app/provider/entry.dart';
import 'package:app/provider/settings.dart' as settings;


/// Graph Types
/// An enum for each graph type an [EmotionGraph] can be displayed as
enum GraphTypes {
  time,
  frequency;

  @override
  String toString() => name.split('.').last;
}

/// [EmotionGraph] is a panel that grabs all entries withing a given date range and displys
/// either a line plot of the intesity of that emotion over the range, or the relative
/// intensities of each emotion in a radial chart
class EmotionGraph extends StatefulWidget {
  final GraphTypes type;

  EmotionGraph(
      {super.key, type})
      : type = type ?? settings.getEmotionGraphType();

  @override
  State<EmotionGraph> createState() => _EmotionGraphState();
}

class _EmotionGraphState extends State<EmotionGraph> {
	DateTime startDate = DateTime.utc(DateTime.now().year, DateTime.now().month, 1); 
	DateTime endDate = DateTime.utc(DateTime.now().year, DateTime.now().month, 1).add(Duration(days: DateTime.now().getDaysInMonth()-1)); 

  static const maxStrength = 60.0;

  Map<String, List<FlSpot>> _emotionData = {};
	Map<String, bool> _chartedEmotions = {};

  //X is the number of days from the start entry
  double getX(JournalEntry entry) =>
      entry.creationDate.difference(startDate).inDays.floorToDouble();
  double getXFromDay(DateTime day) =>
      day.difference(startDate).inDays.toDouble().floorToDouble();

  Widget _getTimeChart() {
    final gridColor = settings.getCurrentTheme().colorScheme.onBackground;

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          //Only show time at bottom
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: _getTimeTitles,
            ),
          ),
        ),

        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipBgColor: settings.getCurrentTheme().colorScheme.background,
            tooltipBorder: BorderSide(color: gridColor),
            getTooltipItems: (spots) => spots.map((spot) {
              final emotion = _emotionData.keys.elementAt(spot.barIndex);
              final value =
                  ((spot.bar.spots[spot.spotIndex].y / maxStrength) * 100)
                      .round();

              return LineTooltipItem("$emotion: ",
                  settings.getCurrentTheme().textTheme.displayMedium!,
                  //Print value in emotion's color
                  children: [
                    TextSpan(
                      text: "$value%",
                      style: settings
                          .getCurrentTheme()
                          .textTheme
                          .displayMedium!
                          .copyWith(color: emotionList[emotion]),
                    )
                  ]);
            }).toList(),
          ),
        ),

        minX: 0.0, maxX: getXFromDay(endDate),
        minY: 0.0, maxY: maxStrength,
        gridData: FlGridData(
          drawHorizontalLine: false,
          drawVerticalLine: true,
          verticalInterval: 1,
          getDrawingVerticalLine: (_) => FlLine(
            dashArray: [1, 0],
            strokeWidth: 0.8,
            color: gridColor,
          ),
        ),

        borderData: FlBorderData(border: Border.all(color: gridColor)),

        //Create a line for each emotion
        lineBarsData: _emotionData.entries
            .map((entry) => LineChartBarData(
                  show: _chartedEmotions[entry.key] == true,
                  spots: entry.value,
                  color: emotionList[entry.key],
                  dotData: const FlDotData(
                    show: false,
                  ),
                  isCurved: true,
                  curveSmoothness: 0.5,
                  barWidth: 4.5,
                  preventCurveOverShooting: true,
                  preventCurveOvershootingThreshold: 2,
                ))
            .toList(),
      ),
    );
  }

  Widget _getFrequencyChart() {
    final gridColor = settings.getCurrentTheme().colorScheme.onBackground;

    //Summ up the strength of all entreis
    final emotionValues = _emotionData.entries.map((entry) {
      final sum = entry.value.fold(0.0, (sum, strength) => sum += strength.y);
      return RadarEntry(
          value: sum / (maxStrength * getXFromDay(endDate)));
    }).toList();

    //Find the strongest emotion based on calculated radial values
    var max = 0.0;
    var index = emotionValues.lastIndexWhere((emotion) {
      if (emotion.value > max) {
        max = emotion.value;
        return true;
      } else {
        return false;
      }
    });
    Color strongestEmotion = index == -1
        ? Colors.transparent
        : emotionList[_emotionData.keys.elementAt(index)] as Color;

    return Container(
      padding: const EdgeInsets.only(
        top: 14,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 24,
      ),
      decoration: ShapeDecoration(
        color: settings.getCurrentTheme().colorScheme.background,
        shape: settings.getCurrentTheme().cardTheme.shape!,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: RadarChart(
          RadarChartData(
            radarShape: RadarShape.polygon,
            borderData: FlBorderData(show: true),
            //titlePositionPercentageOffset: 0.068,
            getTitle: (index, angel) =>
                RadarChartTitle(text: _emotionData.keys.elementAt(index)),
            //Hide value ticker
            ticksTextStyle:
                const TextStyle(color: Colors.transparent, fontSize: 10),
            tickBorderData: const BorderSide(color: Colors.transparent),
            radarBorderData: BorderSide(color: gridColor),
            gridBorderData: BorderSide(color: gridColor, width: 2),
            dataSets: [
              RadarDataSet(
                entryRadius: 0.0,
                borderColor: strongestEmotion,
                fillColor: strongestEmotion.withOpacity(0.5),
                dataEntries: emotionValues,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTimeTitles(double value, TitleMeta meta) {
    final day = startDate.add(Duration(days: value.toInt())).day;

    final startOfWeek =
        startDate.add(Duration(days: value.floor())).weekday ==
            startDate.weekday;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      //Dont label last line if it's not the end of the week
      child: Text(
          (startOfWeek || getXFromDay(endDate) <= 7.0)
              ? "${startDate.month}/$day"
              : "",
          style: settings.getCurrentTheme().textTheme.labelMedium),
    );
  }

  @override
  Widget build(BuildContext context) {
    _chartedEmotions = Map.fromIterable(emotionList.keys, value: (entry) => false);
    _emotionData = Map.fromIterable(emotionList.keys, value: (i) {
			return List<FlSpot>.generate(
				getXFromDay(endDate).floor() + 1,
				(day) => FlSpot(day.toDouble(), 0)
			);
		});

    //Calculate sum strength for each emotion
    for (var entry in entriesInDateRange(startDate, endDate, entries)) {
      for (var emotion in entry.emotions) {
        final dayIndex = getX(entry).floor();

				_chartedEmotions[emotion.name] = true;

        //Set the y position has the highest intensity of the day
        if (dayIndex < _emotionData[emotion.name]!.length) {
          _emotionData[emotion.name]![dayIndex] = FlSpot(
						getX(entry),
						math.max(_emotionData[emotion.name]![dayIndex].y, emotion.strength.toDouble())
					);
        } else {
          _emotionData[emotion.name]![dayIndex] =
						FlSpot(getX(entry), emotion.strength.toDouble());
        }
      }
    }

    return Expanded(
      child: Card(
        //aspectRatio: 1.75,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
							Row(
								children: [
									IconButton(
										key: const Key("Graph_Previous"),
										icon: const Icon( Icons.navigate_before, ),
										onPressed: ()=> setState(() {
											endDate = startDate.subtract(const Duration(days: 1));
											startDate = DateTime.utc(endDate.year, endDate.month, 1);
										}),
									),
									Expanded(
										child: Text(
											"${startDate.formatDate().month} ${startDate.formatDate().day} - ${endDate.formatDate().day}",
											style: settings.getCurrentTheme().textTheme.titleLarge,
											textAlign: TextAlign.center,
										),
									),
									IconButton(
										key: const Key("Graph_Next"),
										icon: const Icon( Icons.navigate_next, ),
										onPressed: ()=> setState(() {
											startDate = endDate.add(const Duration(days: 1));
											endDate = DateTime.utc(startDate.year, startDate.month + 1, 1).subtract(const Duration(days: 1));
										}),
									),
								]
							),
              Expanded(
                  child: switch (widget.type) {
                GraphTypes.time => _getTimeChart(),
                GraphTypes.frequency => _getFrequencyChart()
              }),
            ],
          ),
        ),
      ),
    );
  }
}
