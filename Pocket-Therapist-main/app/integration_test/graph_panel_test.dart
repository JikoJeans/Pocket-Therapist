import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fl_chart/fl_chart.dart';

import 'package:app/uiwidgets/emotion_chart.dart';
import 'package:app/provider/entry.dart';
import 'package:app/helper/dates_and_times.dart';

import 'test_utils.dart';

void main() {

  testWidgets('Displaying emotion time chart', (tester) async {
		entries = [
			JournalEntry(
				title: "Title!",
				entryText: "Journal!",
				dateOverride: DateTime(DateTime.now().year, DateTime.now().month, (DateTime.now().getDaysInMonth()/2).round()),
				emotions: [ 
					Emotion(
						name: "Happy", 
						color: emotionList["Happy"]!, 
						strength: 50
					),
				]
			),
		];

    Map<String, Object> settingsMap = {
      "configured": true,
      "encryption": false,
      "emotionGraphType": GraphTypes.time.toString(),
      //load emotions for map
      "emotions": [
        "Happy",
        "Trust",
        "Fear",
        "Sad",
        "Disgust",
        "Anger",
        "Anticipation",
        "Surprise"
      ]
    };
    await startAppWithSettings(tester, settingsMap);

    //Navigate to graph page
    await skipToCalendarPage(tester, true);
    //Two graphs should exist
    expect(find.byType(EmotionGraph), findsOneWidget);

    //Check time chart
    final emotionGraph = find.byType(LineChart);
    expect(emotionGraph, findsOneWidget);

  });

  testWidgets('Displaying emotion frequency chart', (tester) async {
    //await startAppWithSettings(tester, {
    //  settings.configuredKey: true,
    //  settings.encryptionToggleKey: false,
    //  settings.emotionGraphTypeKey: GraphTypes.frequency.toString()
    //});
    Map<String, Object> settingsMap = {
      "configured": true,
      "encryption": false,
      "emotionGraphType": GraphTypes.frequency.toString(),
      //load emotions for map
      "emotions": [
        "Happy",
        "Trust",
        "Fear",
        "Sad",
        "Disgust",
        "Anger",
        "Anticipation",
        "Surprise"
      ]
    };
    await startAppWithSettings(tester, settingsMap);

    // Enter the app
    Finder startButton = find.byKey(const Key("Start_Button"));
    await pumpUntilFound(tester, startButton);
    await tap(tester, startButton);

    await pumpUntilFound(tester, find.byKey(const Key("navCalendar")), true);
    await tap(tester, find.byKey(const Key("navCalendar")), true);
    await tester.pumpAndSettle();
    //Two graphs should exist
    expect(find.byType(EmotionGraph), findsOneWidget);

    //Check time chart
    final emotionGraph = find.byType(RadarChart);
    expect(emotionGraph, findsOneWidget);
  });

	testWidgets('Test forward date switching', (WidgetTester tester) async {
		await skipToCalendarPage(tester, true);
		
    final nextButton = find.byKey(const Key("Graph_Next"));
		expect(nextButton, findsOneWidget);

    //Test forward
		var date = DateTime.utc(DateTime.now().year, DateTime.now().month, 1);
		while( date.isBefore(DateTime.utc(DateTime.now().year + 4, DateTime.now().month, 1)) ){
			//Calculate date of next month
			if ( date.month != DateTime.december ){
				date = DateTime.utc( date.year, date.month + 1, 1);
			} else {
				date = DateTime.utc( date.year + 1, 1, 1);
			}

			//Go to next month and test amount of days are correct
			await tap(tester, nextButton);
			await tester.pump();
		
			final endDate = DateTime.utc(date.year, date.month, date.getDaysInMonth());
			final dateRange = find.text("${date.formatDate().month} ${date.formatDate().day} - ${endDate.formatDate().day}");
			expect(dateRange, findsOneWidget);
		}
	});

	testWidgets('Test backwards date switching', (WidgetTester tester) async {
		await skipToCalendarPage(tester, true);
		
    final previousButton = find.byKey(const Key("Graph_Previous"));
		expect(previousButton, findsOneWidget);

    //Test backward
		var date = DateTime.utc(DateTime.now().year, DateTime.now().month, 1);
		while( date.isAfter(DateTime.utc(DateTime.now().year - 4, DateTime.now().month, 1)) ){
			//Calculate date of next month
			if ( date.month != DateTime.january ){
				date = DateTime.utc( date.year, date.month -1, 1);
			} else {
				date = DateTime.utc( date.year -1, 12, 1);
			}

			//Go to next month and test amount of days are correct
			await tap(tester, previousButton);
			await tester.pump();
		
			final endDate = DateTime.utc(date.year, date.month, date.getDaysInMonth());
			final dateRange = find.text("${date.formatDate().month} ${date.formatDate().day} - ${endDate.formatDate().day}");
			expect(dateRange, findsOneWidget);
		}
	});
}
