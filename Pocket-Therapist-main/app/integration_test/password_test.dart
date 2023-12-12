import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_utils.dart';

void main() async {
  testWidgets("Reset Password w/ recovery code", (widgetTester) async {
    // the recovery phrase
    String recovery = "46jDQvvpxNNsX7yb4mrg6F+e2lg=";
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
    await pumpUntilFound(widgetTester, find.byKey(const Key("Reset_Button")));

    Finder resetButton = find.byKey(const Key("Reset_Button"));
    await tap(widgetTester, resetButton);
    Finder passwordResetField = find.byKey(const Key("Reset_Password_Field"));

    await widgetTester.enterText(passwordResetField, "PotatoChips");
    await widgetTester.pump();

		Finder resetPasswordbutton = find.byKey(const Key("Reset_Password_Button"));
		await tap(widgetTester, resetPasswordbutton);
		await widgetTester.pump(const Duration(seconds: 1));

		Finder okResetPassButton = find.byKey(const Key("Fail_Pass_Reset"));
    //wait until incorrect password prompt appears
    await pumpUntilFound(widgetTester, okResetPassButton);
    await tap(widgetTester, okResetPassButton);
    //let dialog get dismissed
    await widgetTester.pump(const Duration(seconds: 1));

    await widgetTester.enterText(passwordResetField, recovery);
    await widgetTester.pump();

    await tap(widgetTester, resetPasswordbutton);

    okResetPassButton = find.byKey(const Key("Success_Pass_Reset"));
    await pumpUntilFound(widgetTester, okResetPassButton);
    await tap(widgetTester, okResetPassButton);
    //minimum number of pumps needed to dismiss the 2 dialog boxes
    //await widgetTester.pump();
    //await widgetTester.pump();
    //await widgetTester.pump();
    //await widgetTester.pump();
    //await widgetTester.pump();
    //await widgetTester.pump();
    //instead of the pumps above we could use a pump with duration below
    await widgetTester.pump(const Duration(milliseconds: 400));

    //reset button option should not be present but start button should be
    expect(find.byKey(const Key("Start_Button")), findsOneWidget);
    expect(resetPasswordbutton, findsNothing);
  }, timeout: const Timeout(Duration(minutes: 5)));

  testWidgets("Reset Password w/ password", (widgetTester) async {
    String password = "password123@";
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

    await pumpUntilFound(widgetTester, find.byKey(const Key("Reset_Button")));

    Finder resetButton = find.byKey(const Key("Reset_Button"));
    await tap(widgetTester, resetButton);
    Finder passwordResetField = find.byKey(const Key("Reset_Password_Field"));

    await widgetTester.enterText(passwordResetField, password);
    await widgetTester.pump();

		Finder resetPasswordbutton = find.byKey(const Key("Reset_Password_Button"));
		await tap(widgetTester, resetPasswordbutton);
		await widgetTester.pump(const Duration(seconds: 1));

		Finder okResetPassButton = find.byKey(const Key("Success_Pass_Reset"));
    //wait until loading is done
    await pumpUntilFound(widgetTester, okResetPassButton);
    await widgetTester.tap(okResetPassButton);
    //minimum number of pumps needed to dismiss the 2 dialog boxes
    //await widgetTester.pump();
    //await widgetTester.pump();
    //await widgetTester.pump();
    //await widgetTester.pump();
    //await widgetTester.pump();
    //await widgetTester.pump();
    await widgetTester.pump(const Duration(milliseconds: 400));
    //reset button option should not be present but start button should be
    expect(resetButton, findsNothing);
    expect(find.byKey(const Key("Start_Button")), findsOneWidget);
  }, timeout: const Timeout(Duration(minutes: 5)));
}
