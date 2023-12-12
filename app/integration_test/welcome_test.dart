import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() async {
  group("Create Account", () {
    testWidgets("Login to Account", (widgetTester) async {
      const String password = "password123@";
      const String badPassword = "password123";

      // This is a ripped hash from  an actual install so it should function the same everytime.
      Map<String, Object> settingsMap = {
        "configured": true,
        "theme": 0,
        "fontScale": 1.0,
        "encryption": true,
        "accent": 4289956095,
        "enc": {
          "data":
              "246172676f6e32696424763d3139246d3d3530303030302c743d382c703d34244b442b2b445075716463337855546b357066724a7777246b30684a376a753876563346492f56394373676c414f774343744e4c39554e3154685769616e783856646f2359486e32576a702f757166782b484a6d3a524a4a463252475a4565526b4e54455332794c6c664e6e4d522b54467876716d385832504b5639306448757143504c306c75634f752f334f6463373658366e6d236f4f787635776134424c3552762f32753a78346e5939396230374b65777133497636396f667149596759664743416e2f775479556a342b6b3575696c51726f42324571597938426e684b4d7469394b486623246172676f6e32696424763d3139246d3d3530303030302c743d382c703d3424514f65346654574346514c446e44376a6a7776374f7724346b41534432334d6e6576723268574b646b494c6530524f672b5070764d7857764338527261306f563155",
          "sig":
              "5e211073bf51a887aa407da84c4508d0baded525a46682fc4399bbcc4d6a07c85050d4735cd605d561590e8d2d8342be0f509d90b426a4bc8a6a6594fc8a5222"
        },
        "tags": [
          "Calm",
          "Centered",
          "Content",
          "Fulfilled",
          "Patient",
          "Peaceful",
          "Present",
          "Relaxed",
          "Serene",
          "Trusting"
        ]
      };

      await startAppWithSettings(widgetTester, settingsMap);
      await widgetTester.pump();

      Finder startbutton = find.byKey(const Key("Start_Button"));
      await tap(widgetTester, startbutton);

// First alert box - Enter password ---------------------------------------------[
      Finder passwordField = find.descendant(
          of: find.byKey(const Key("Login_Password_Field")),
          matching: find.byType(TextFormField));

// Enter password ---------------------------------------------------------------
      await widgetTester.enterText(passwordField, badPassword);
      await widgetTester.pump();

      /// Submit the first password ( stores it )
      Finder enterPasswordButton = find.byKey(const Key('Submit_Password'));
      await tap(widgetTester, enterPasswordButton);

      Finder confirmIncorrectButton =
          find.byKey(const Key("Incorrect_Password"));
      //wait until incorrect password is found
      await pumpUntilFound(widgetTester, confirmIncorrectButton);
      await tap(widgetTester, confirmIncorrectButton);

      await widgetTester.enterText(passwordField, password);
      await widgetTester.pump();

      Finder seePasswordButton = find.byType(IconButton);
      await tap(widgetTester, seePasswordButton);
      await tap(widgetTester, seePasswordButton);

      // await widgetTester.runAsync(() async {
      enterPasswordButton = find.byKey(const Key('Submit_Password'));
      await tap(widgetTester, enterPasswordButton, true);
      // });

      //Successful login, on dashboard
      await expectLater(find.text("Dashboard"), findsNWidgets(2));
    });

    testWidgets("No Password Account creation", (widgetTester) async {
      String password = "";
      await startAppBare(widgetTester);

      Finder startbutton = find.byKey(const Key("Start_Button"));
      await pumpUntilFound(widgetTester, startbutton);
      await tap(widgetTester, startbutton);
// First alert box - Enter password ---------------------------------------------[
      Finder passwordField = find.descendant(
          of: find.byKey(const Key('Enter_Password_Field')),
          matching: find.byType(TextFormField));

      await pumpUntilFound(widgetTester, passwordField);

// Enter password ---------------------------------------------------------------
      await widgetTester.enterText(passwordField, password);
      await widgetTester.pump();

      /// Submit the first password ( stores it )
      Finder enterPasswordButton = find.byKey(const Key('Create_Password'));

// Tap enter button to create password ----------------------------------------------
      await tap(widgetTester, enterPasswordButton);

// Find the confirm button ---------------------------------------------------------
      Finder confirmNoPasswordButton = find.text("Yes");
      await tap(widgetTester, confirmNoPasswordButton);
      //Successful login, on dashboard
      Finder dashboard = find.text("Dashboard");
      //wait until incorrect password is found
      await pumpUntilFound(widgetTester, dashboard);
      await expectLater(find.text("Dashboard"), findsNWidgets(2));
    });

    testWidgets("No Password Cancel", (widgetTester) async {
      await startAppBare(widgetTester);

      Finder startbutton = find.byKey(const Key("Start_Button"));
      await pumpUntilFound(widgetTester, startbutton);
      await tap(widgetTester, startbutton);

      Finder enterPasswordButton = find.byKey(const Key('Create_Password'));

// Tap enter button to create password ----------------------------------------------
      await tap(widgetTester, enterPasswordButton);

// Find the confirm button ---------------------------------------------------------
      Finder confirmNoPasswordButton = find.text("No");
      await tap(widgetTester, confirmNoPasswordButton);
    });

    testWidgets("Password Account creation", (widgetTester) async {
      const String password = "password123@";
      await startAppBare(widgetTester);
      Finder startbutton = find.byKey(const Key("Start_Button"));
      await pumpUntilFound(widgetTester, startbutton);

      await tap(widgetTester, startbutton);

      Finder passwordField = find.descendant(
          of: find.byKey(const Key('Enter_Password_Field')),
          matching: find.byType(TextFormField));

      await pumpUntilFound(widgetTester, passwordField);

      await widgetTester.enterText(passwordField, password);
      await widgetTester.pump();

      /// Submit the first password ( stores it ) // Tap enter button to create password ----------------------------------------------
      await tap(widgetTester, find.byKey(const Key('Create_Password')));
      await tap(widgetTester, find.byKey(const Key('Verify_Password')));

      await widgetTester.showKeyboard(find.ancestor(
        of: find.text("Confirm Password"),
        matching: find.byType(TextFormField),
      ));
      await widgetTester.pump();

      await widgetTester.enterText(
          find.ancestor(
            of: find.text("Confirm Password"),
            matching: find.byType(TextFormField),
          ),
          password);
      await tap(widgetTester, find.byKey(const Key('Verify_Password')));
    });
  });
}
