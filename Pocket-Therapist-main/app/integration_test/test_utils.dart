import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/provider/settings.dart' as settings;
import 'package:app/main.dart' as app;

/// [startApp] starts the application in preparation for testing.
/// Should be called first and only once.
Future<void> startApp(WidgetTester tester) async {
  app.main();
  defaultSettings();
  do{
    await tester.pump();
  }while(!settings.isInitialized());
}

/// [startAppBare] will start the application with all settings wiped.
/// as though the application was just stared. Typically paired with
Future<void> startAppBare(WidgetTester tester) async {
  await settings.reset(true);
  app.main();
  do{
    await tester.pump();
  }while(!settings.isInitialized());
}

/// []
Future<void> startAppWithSettings(WidgetTester tester, Map<String, Object> settingsMap) async {
  await settings.reset(true);
  settings.setMockValues(settingsMap);
  await settings.save();
  app.main();
  do{
    await tester.pump();
  }while(!settings.isInitialized());
}

/// [startSkipFrontScreen] this starts the app by calling [startApp] and automatically
/// moves the test into the actual app, leaving the tester on the dashboard.
Future<void> startSkipFrontScreen(WidgetTester tester) async {
  await startApp(tester);
  // Enter the app
  Finder startButton = find.byKey(const Key("Start_Button"));
  await pumpUntilFound(tester, startButton);
  await tap(tester, startButton);
}

/// [skipToEntriesPage] will skip throug the app from the login screen to the
/// entries page
Future<void> skipToEntriesPage(WidgetTester tester, [bool settle = false]) async {
  await startSkipFrontScreen(tester);
  await pumpUntilFound(tester, find.text("Entries"), settle);
  await tap(tester, find.text("Entries"), settle);
}

/// [skipToPlansPage] will skip throug the app from the login screen to the
/// entries page
Future<void> skipToPlansPage(WidgetTester tester, [bool settle = false]) async {
  await startSkipFrontScreen(tester);
  await pumpUntilFound(tester, find.text("Plans"), settle);
  await tap(tester, find.text("Plans"), settle);
}

/// [skipToCalendarPage] will skip throug the app from the login screen to the
/// entries page
Future<void> skipToCalendarPage(WidgetTester tester, [bool settle = false]) async {
  await startSkipFrontScreen(tester);
  await pumpUntilFound(tester, find.byKey(const Key("navCalendar")), settle);
  await tap(tester, find.byKey(const Key("navCalendar")), settle);
}

/// [defaultSettings] configures the default settings for testing which includes
/// no encryption and the application already being configured so that the init
/// methods can be skipped during testing.
void defaultSettings() {
  settings.setMockValues({
    settings.configuredKey: true,
    settings.encryptionToggleKey: false,
  });
}

/// [pumpUntilFound] repeatedly calls [WidgetTester.pump()] until
/// the [found] parameter is found or it times out. (5 min)
/// use [settle] = true, to make it pumpAndSettle
Future<void> pumpUntilFound(WidgetTester tester, Finder found, [bool settle = false, Duration? duration]) async {
  if(settle){
    while(found.evaluate().isEmpty){
      if (duration != null) {
        await tester.pumpAndSettle(duration);
      } else {
        await tester.pumpAndSettle();
      }
    }
  } else {
    while(found.evaluate().isEmpty){
      await tester.pump(duration);
    }
  }
}

/// [tap] can be used to tap on a widget with the Finder [found]
/// This automatically pumps the widget tree after tapping.
/// use [settle] = true, to make it pumpAndSettle
Future<void> tap(WidgetTester tester, Finder found, [bool settle = false, Duration? duration]) async {
  await tester.tap(found);
  if(settle) {
    if (duration != null) {
      await tester.pumpAndSettle(duration);
    } else {
      await tester.pumpAndSettle();
    }
  } else {
    await tester.pump(duration);
  }
}

/// [doubleTap] can be used to simulate a double tap on a widget with the Finder [found]
/// This automatically pumps the widget tree after tapping.
/// use [settle] = true, to make it pumpAndSettle
Future<void> doubleTap(WidgetTester tester, Finder found) async {
  await tester.tap(found);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(found);
  await tester.pump();
}