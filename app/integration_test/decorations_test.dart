import 'package:app/uiwidgets/decorations.dart' as decorations;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  group("Password Field Tests", () {
    late Widget myApp;
    const Key testKey = Key("FindMePassword");

    setUp(() => {
          myApp = MaterialApp(
              home: Scaffold(
                  body: SafeArea(
            child: decorations.ControlledTextField(
              key: testKey,
              hintText: "Password",
              validator: (textInField) =>
                  (textInField?.isEmpty ?? true) ? 'Field is required' : null,
            ),
          )))
        });

    testWidgets('Test Valid PasswordField', (tstr) async {
      await tstr.pumpWidget(myApp);
      await tstr.pump();

      expect(find.text("Password"), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      await tstr.enterText(find.byKey(testKey), "SuperSecretPassword");
      await tstr.pump();

      var finder = find.descendant(
          of: find.byKey(testKey), matching: find.byType(TextField));
      var field = tstr.firstWidget<TextField>(finder);

      expect(field.obscureText, true);
      finder = find.descendant(
          of: find.byKey(testKey), matching: find.byType(IconButton));
      await tap(tstr, finder, true);

      // You must  refind the TextField, it gets redrawn
      finder = find.descendant(
          of: find.byKey(testKey), matching: find.byType(TextField));
      field = tstr.firstWidget<TextField>(finder);

      expect(field.obscureText, false);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('Testing Invalid PasswordField', (tstr) async {
      Key testKey = const Key("FindMePassword");
      await tstr.pumpWidget(myApp);
      await tstr.enterText(find.byKey(testKey), "SomeThingIncorrect");
      await tstr.pump();
      //Lets make it empty!
      await tstr.enterText(find.byKey(testKey), "");
      await tstr.pump();
      //Check if the current validator would have errored on the input text
      expect(
          tstr.widget<TextFormField>(find.byType(TextFormField)).validator!(''),
          isNotNull);
    });
  });

  group("Quotes Tests", () {
    testWidgets("Ensuring new quote Appears when pressed",
        (widgetTester) async {
      //expected behavior, start button is present
      Widget myApp = MaterialApp(
          home: Scaffold(
              body: SafeArea(
        child: decorations.Quote(),
      )));
      await widgetTester.pumpWidget(myApp);
      await widgetTester.pump();

      Finder quoteButton = find.byKey(const Key("Quote"));
      String current = decorations.currentQuote;
      expect(find.text(current), findsOneWidget); // find the quote on screen

      await tap(widgetTester, quoteButton, true, const Duration(seconds: 5));

      String next = decorations.nextQuote;
      expect(find.text(current), findsNothing); // doesn't find old quote
      expect(find.text(next), findsOneWidget); // finds new quote
    });
  });

  group("Navigation Tests", () {
    testWidgets('Navagation between pages', (tester) async {
      await startSkipFrontScreen(tester);
      await pumpUntilFound(tester, find.text("Dashboard"));

      //Navigate to each page
      for (var page in [
        "Entries",
        "Calendar",
        "Plans",
        "Dashboard",
        "Settings"
      ]) {
        Finder pg = find.text(page);
        await tester.pumpAndSettle();
        await tap(tester, pg);
        await pumpUntilFound(tester, pg, true);
      }

      await tester.pump();
      //Back out of settings page
      await tester.pageBack();
      await tester.pump();
      expect(find.text("Dashboard"), findsWidgets);
    });
  });
  group("Animation Tests", () {
    testWidgets("Ensuring The Loading Animation Appears", (widgetTester) async {
      //expected behavior, start button is present
      Widget myApp = const MaterialApp(
          home: Scaffold(
              body: SafeArea(
        child: decorations.LoadingAnimation(),
      )));
      await widgetTester.pumpWidget(myApp);
      await widgetTester.pump();

      Finder animationWidget = find.byKey(const Key("Loading_Animation"));
      expect(animationWidget, findsOneWidget); // find the animation
    });
  });
}
