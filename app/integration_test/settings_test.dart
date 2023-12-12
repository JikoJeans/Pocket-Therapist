import 'package:app/provider/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/provider/settings.dart' as settings;

import 'test_utils.dart';

void main() {
  group("Overall Settings Test", () {
    tearDown(() async => await settings.reset());

    testWidgets("Settings works...", (tester) async {
      const String password = "password123@";
      settings.setFontScale(1.5);
      settings.setTheme(ThemeOption.dark);
      settings.setAccentColor(Colors.blueAccent);
      await startAppWithSettings(tester, {
        settings.fontScaleKey: 1.5,
        settings.themeKey: ThemeOption.dark.index,
        settings.accentColorKey: Colors.blueAccent.value,
      });
      await settings.setPassword(password);

      expect(settings.getCurrentTheme().brightness,
          ThemeSettings.darkTheme.brightness);
      expect(settings.getFontScale(), 1.5);
      expect(settings.getAccentColor().value, Colors.blueAccent.value);
      expect(settings.getOtherSetting(settings.preferencesPrefix), null);
      expect(settings.getOtherSetting(settings.fontScaleKey), 1.5);
    });

    testWidgets("Theme changes with different selections",
        (widgetTester) async {
      await startApp(widgetTester);
      await pumpUntilFound(
          widgetTester, find.byKey(const Key("Settings_Button")));
      await tap(widgetTester, find.byKey(const Key("Settings_Button")));

      Finder dropdown = find.byKey(const ValueKey('StyleDropDown'));
      await pumpUntilFound(widgetTester, dropdown);
      await tap(widgetTester, dropdown);

      // Find the dark option
      final darkDropDown = find.text('Dark').last;

      // Select the drop down and expect to be replaced with dark
      await tap(widgetTester, darkDropDown);
      expect(find.text('Dark'), findsOneWidget);

      //Find the provider & give me the state
      MaterialApp appState = widgetTester.widget(find.byType(MaterialApp));
      // Test if the Theme is dark
      expect(Brightness.dark, appState.theme?.brightness);
      expect(ThemeSettings.darkTheme.brightness, appState.theme?.brightness);
      // Tap the drop down again

      await tap(widgetTester, dropdown, true);

      // Find the light option
      final lightDropDown = find.text('Light').first;

      // Select the drop down and expect to be replaced with light

      await tap(widgetTester, lightDropDown, true);

      // Find the light option
      expect(find.text('Light'), findsOneWidget);

      appState = widgetTester.widget(find.byType(MaterialApp));
      // Test if the Theme is light
      expect(Brightness.light, appState.theme?.brightness);
      expect(ThemeSettings.lightTheme.brightness, appState.theme?.brightness);

      await tap(widgetTester, find.text('Edit Tag List'), true);

      await widgetTester.pageBack();
      await widgetTester.pump();

      await tap(widgetTester, find.text('Edit Emotion List'), true);
      await tap(widgetTester,
          find.byKey(const Key('Enable/Disable Encryption')), true);
      await tap(widgetTester, find.byKey(const Key('Erase_Button')), true);
      await tap(widgetTester, find.text('Open Vault File'), true);
    });
  });

  group("Editing Tags Tests", () {
    const String filter = 'test';

    //Initial test used to make sure that no create tag button is displayed
    testWidgets("Tag List Tests", (widgetTester) async {
      //traverse to tag settings -------------------------------------------------
      await startAppBare(widgetTester);

      Finder settingsButton = find.byKey(const Key("Settings_Button"));
      await pumpUntilFound(widgetTester, settingsButton);
      await tap(widgetTester, settingsButton);

      Finder tagList = find.text("Edit Tag List");
      await pumpUntilFound(widgetTester, tagList);
      await tap(widgetTester, tagList, true);

      Finder target = find.byKey(const Key('Create Tag'));
      expect(target, findsNothing);

      //check a tag that we know doesnt exist ------------------------------------
      target = find.byKey(const Key('Tag Search Bar'));
      await widgetTester.enterText(target, filter);
      await widgetTester.pump();

      target = find.byKey(const Key('Create Tag'));
      await tap(widgetTester, target, true);

      //Enter a new tag name
      target = find.byKey(const Key('Tag Name Field'));
      await widgetTester.enterText(target, filter);

      //Confirm new tag
      target = find.byKey(const Key('Save New Tag Button'));
      await tap(widgetTester, target, true);

      //Empty tag search bar
      target = find.byKey(const Key('Tag Search Bar'));
      await widgetTester.enterText(target, "");
      await widgetTester.pump();

      //try to delete tag
      await widgetTester.enterText(target, filter);
      await widgetTester.pump();
      target = find.byKey(const Key('Delete $filter Button'));
      await tap(widgetTester, target, true);

      //expect no delete button and create tag button again
      target = find.byKey(const Key('Tag Search Bar'));
      await widgetTester.enterText(target, filter);
      await widgetTester.pump();
      target = find.byKey(const Key('Delete $filter Button'));
      expect(target, findsNothing);

      //Recreate tag
      target = find.byKey(const Key('Create Tag'));
      await tap(widgetTester, target);

      //Enter a new tag name
      target = find.byKey(const Key('Tag Name Field'));
      await widgetTester.enterText(target, filter);

      //Confirm new tag
      target = find.byKey(const Key('Save New Tag Button'));
      await tap(widgetTester, target, true);
      target = find.text(filter);
      expect(target, findsOneWidget);

      //check field submission with text and without -----------------------------
      //try empty text field
      target = find.byKey(const Key('Tag Search Bar'));
      await widgetTester.enterText(target, '');
      //await widgetTester.testTextInput.receiveAction(TextInputAction.done);
      await widgetTester.pump();
      target = find.byKey(const Key('Create Tag'));
      expect(target, findsNothing);
      //try with known good tag
      target = find.byKey(const Key('Tag Search Bar'));
      await widgetTester.enterText(target, filter);
      //obtain edge case where search is set to nothing
      widgetTester.testTextInput.enterText('');
      widgetTester.testTextInput.enterText(filter);
      await widgetTester.testTextInput.receiveAction(TextInputAction.done);
      await widgetTester.pump();
      //cancel new tag creation
      target = find.byKey(const Key('Cancel New Tag Button'));
      await pumpUntilFound(widgetTester, target);
      await tap(widgetTester, target, true);
      target = find.byKey(const Key('Create Tag'));
      expect(target, findsNothing);
    });
  });
}
