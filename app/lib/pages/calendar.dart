import 'package:app/provider/entry.dart';
import 'package:app/uiwidgets/calendar.dart';
import 'package:app/uiwidgets/decorations.dart';
import 'package:app/uiwidgets/emotion_chart.dart';
import 'package:flutter/material.dart';

/// [CalendarPage] is the page that displays tthe calendar and related mood
/// tracking information for the user.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
	List<NavigationDestination> destinations = const [
		NavigationDestination(
				key: Key("navDashboard"),
				icon: Icon(Icons.dashboard),
				label: "Dashboard"),
		NavigationDestination(
				key: Key("navEntries"), icon: Icon(Icons.feed), label: "Entries"),
		NavigationDestination(
				key: Key("navNewEntry"), icon: Icon(Icons.add), label: "NewEntry"),
		NavigationDestination(
				key: Key("navCalendar"),
				icon: Icon(Icons.calendar_month),
				label: "Calendar"),
		NavigationDestination(
				key: Key("navPlans"), icon: Icon(Icons.event_note), label: "Plans"),
		NavigationDestination(
				key: Key("navSettings"), icon: Icon(Icons.settings), label: "Settings"),
	];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
				body: SafeArea(
				child: Column(
					children: [
						const Text('Calendar'),
						// ignore: prefer_const_constructors
						Padding(
							// ignore: prefer_const_constructors
						  padding: EdgeInsets.all(8.0),
							// ignore: prefer_const_constructors
						  child: Calendar(),
						),
						EmotionGraph(),
					],
				),
			),
			bottomNavigationBar: CustomNavigationBar(
				selectedIndex: 3,
				destinations: destinations,
				onDestinationSelected: (index) {
					switch (index) {
						case 2:
							makeNewEntry(context);
							setState(() {});
							return;
						case 5:
							Navigator.of(context).pushNamed(destinations[index].label).then((value) => setState((){}));
							return;
						case _:
							Navigator.of(context).pushReplacementNamed(destinations[index].label);
							break;
					}
				},
			),
		);
  }
}
