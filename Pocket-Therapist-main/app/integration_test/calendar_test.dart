import 'package:flutter_test/flutter_test.dart';
import 'test_utils.dart';

import 'package:flutter/material.dart';

import 'package:app/pages/calendar.dart';
import 'package:app/pages/entries.dart';
import 'package:app/uiwidgets/decorations.dart';

import 'package:app/provider/settings.dart' as settings;
import 'package:app/provider/entry.dart';

void main() {

  late Widget myApp;
  setUp(() => {
    myApp = const MaterialApp(
        home: CalendarPage(),
    )});


  testWidgets('Test calendar widget constructor', (WidgetTester tester) async {
		await tester.pumpWidget(myApp);

    final calendar = find.byKey(const Key("Calendar_Panel"));
		expect(calendar, findsOneWidget);

		final calendarGrid = find.byKey(const Key("Calendar_Grid"));
		expect(calendarGrid, findsOneWidget);

		final calendarDays = find.byKey(const Key("Calendar_Day"));
		expect(calendarDays, findsNWidgets(7*6));
  });

	testWidgets('Test forward date switching', (WidgetTester tester) async {
		await tester.pumpWidget(myApp);
		
    final nextButton = find.byKey(const Key("Date_Next"));
		expect(nextButton, findsOneWidget);

    //Test forward
		var date = DateTime.utc(DateTime.now().year, DateTime.now().month, 1);
		while( date.isBefore(DateTime.utc(DateTime.now().year + 4, DateTime.now().month, 1)) ){
			//Calculate date of next month
			if ( date.month < 12 ){
				date = DateTime( date.year, date.month + 1, 1);
			} else {
				date = DateTime( date.year + 1, 1, 1);
			}

			//Go to next month and test amount of days are correct
			await tap(tester, nextButton);
		
			final calendarDays = find.byKey(const Key("Calendar_Day"));
			expect(calendarDays, findsNWidgets(7*6));
		}
	});

	testWidgets('Test backwards date switching', (WidgetTester tester) async {
		await tester.pumpWidget(myApp);
		
    final previousButton = find.byKey(const Key("Date_Previous"));
		expect(previousButton, findsOneWidget);

    //Test backward
		var date = DateTime(DateTime.now().year, DateTime.now().month, 1);
		while( date.isAfter(DateTime(DateTime.now().year - 4, DateTime.now().month, 1)) ){
			//Calculate date of next month
			if ( date.month < 12 ){
				date = DateTime( date.year, date.month -1, 1);
			} else {
				date = DateTime( date.year -1, 12, 1);
			}

			await tap(tester, previousButton);

			final calendarDays = find.byKey(const Key("Calendar_Day"));
			expect(calendarDays, findsNWidgets(7*6));
		}
	});

  testWidgets('Calendar integration test', (WidgetTester tester) async {
		
		await startAppWithSettings(tester, {
			settings.configuredKey: true,
			settings.encryptionToggleKey: false,
		});

		final today = DateTime.now();
		emotionList = {
			'Happy': const Color(0xfffddd68),
		};
		entries = [
			JournalEntry(
				title: "Title!",
				entryText: "Journal!",
				dateOverride: today,
				emotions: [ 
					Emotion(
						name: "Happy", 
						color: const Color(0xfffddd68), 
						strength: 50
					),
				]
			),
		];
		await skipToCalendarPage(tester);

		//Open todays entries(s)
		final calendarDays = find.byKey(const Key("Calendar_Day"));
		await pumpUntilFound(tester, calendarDays);

		final firstOfTheMonth = DateTime(today.year, today.month, 1);
		final firstWeekPadding = firstOfTheMonth.weekday - 1;
		final todayItem = tester.widgetList(calendarDays).elementAt(firstWeekPadding + today.day - 1) as Container;

		//Today should be colored according to the entry we just made
		final todayColor = (todayItem.decoration as ShapeDecoration).color; 
		expect(todayColor, emotionList["Happy"]);

		// Check that entry is still visable
		find.byWidget(todayItem);
		await tap(tester, find.byWidget(todayItem));
		await pumpUntilFound(tester, find.byType(EntryPanelPage)); 

		// View new entry
		final card = find.byType(DisplayCard);

		for(var filter in ["Week", "Month", "Year"]) {
			final dropdownKey = find.byKey(const ValueKey("SortByDateDropDown"));
			await pumpUntilFound(tester, dropdownKey);
			// find the drop down and tap it
			await tap(tester, dropdownKey, true);

			// find the Year option and tap it
			final weekDropDown = find.text(filter).last;
			await pumpUntilFound(tester, weekDropDown);
			await tap(tester, weekDropDown, true);

			expect(card, findsWidgets);
		} 

		await tap(tester, card);
		expect(find.text("Title!"), findsOneWidget);
		expect(find.text("Journal!"), findsOneWidget);
  });

}
