import 'dart:convert';
import 'dart:io';

import 'package:app/provider/theme_settings.dart';
import 'package:app/provider/encryptor.dart' as encryptor;
import 'package:app/uiwidgets/decorations.dart';
import 'package:app/uiwidgets/emotion_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app/provider/entry.dart' as entry;

/// Used for error messages
const String preferencesPrefix = "pocket-therapist";

/// True if loading has been completed, false otherwise.
bool _init = false;

/// These are the default settings and will be overwritten when loaded.

const String configuredKey = "configured";

/// true if the app has been setup before, false otherwise

const String themeKey = 'theme';

/// Which theme is being used currently, load and saves as an integer.

const String fontScaleKey = 'fontScale';

/// Scale of all font sizes

const String encryptionToggleKey = 'encryption';

/// True if encryption is enabled, false otherwise

const String accentColorKey = "accent";

const String emotionGraphTypeKey = 'emotionGraphType';

/// The color of all accents, like buttons and sizing.

Map<String, dynamic> _settings = {
  configuredKey: false,
  themeKey: ThemeOption.light.index,
  fontScaleKey: 1.0,
  encryptionToggleKey: false,
  accentColorKey: Colors.deepPurpleAccent[100]!.value,
  emotionGraphTypeKey: GraphTypes.time.toString(),
};

Directory? _settingsStorageDirectory;
File? _settingsFile;

/// [load] this function loads or installed the defaults for settings.
/// By default encryption is disabled, emotions are defaults, tags are defaults
Future<void> load() async {
  _settingsStorageDirectory = await getApplicationSupportDirectory();
  _settingsFile = File("${_settingsStorageDirectory!.path}/settings.yml");
  // first time setup
  if (!await _settingsFile!.exists()) {
    // cannot create settings file
    // attempt to create the whole directory path if it doesn't exist.
    await _settingsFile!.create();
    await save();
  }
  // Else settings exists, load them.
  else {
    String fileContent = await _settingsFile!.readAsString();
    if (fileContent.isNotEmpty) {
      // Settings file exists but empty, save the defaults
      _settings = json.decode(fileContent);
      encryptor.load();
      entry.loadTagsEmotions();
    }

    /// settings are loaded or defaults
  }
}

/// The saving function [save], will save settings to [_settingsStorageDirectory]
/// in a file called "settings.yml".
/// This will not happen if the system in unable to provide a storage location.
Future<void> save() async {
  _settingsStorageDirectory = await getApplicationSupportDirectory();
  _settingsFile = File("${_settingsStorageDirectory!.path}/settings.yml");

  // first time setup
  if (!await _settingsFile!.exists()) {
    // cannot create settings file
    // attempt to create the whole directory path if it doesn't exist.
    await _settingsFile!.create();
  }
  encryptor.save();
  entry.saveTagsEmotions();
  await _settingsFile!.writeAsString(json.encode(_settings));
  // Save them to the file
}

Future<void> reset([bool? all]) async {
  _settings = {
    configuredKey: false,
    themeKey: ThemeOption.light.index,
    fontScaleKey: 1.0,
    encryptionToggleKey: false,
    accentColorKey: const Color(0xFFB388FF).value,
    emotionGraphTypeKey: GraphTypes.time.toString(),
  };
  if (all != null && all) {
    // entry.reset();
    encryptor.reset();
    entry.saveTagsEmotions();
    encryptor.save();
  }
  // Probably message database to reset as well....
  await save();
}

/// Setters --------------------------
void setInitialized() {
  if (!_init) _init = true;
}

void setConfigured(bool value) => _settings[configuredKey] = value;
void setTheme(ThemeOption theme) => _settings[themeKey] = theme.index;
void setFontScale(double newFontScale) =>
    _settings[fontScaleKey] = newFontScale;
void setEncryptionStatus(bool newStatus) =>
    _settings[encryptionToggleKey] = newStatus;
void setAccentColor(Color newColor) =>
    _settings[accentColorKey] = newColor.value;
Future<void> setPassword(String newPassword) async =>
    await encryptor.setPassword(newPassword);
void setEmotionGraphType(GraphTypes type) => _settings[emotionGraphTypeKey] = type.toString();
void setOtherSetting(String key, Object? value) => _settings[key] = value;

void setMockValues(Map<String, dynamic> value) {
  _settings.addAll(value);
  encryptor.load();
  entry.loadTagsEmotions();
}

/// Getters --------------------------
bool isInitialized() => _init;
bool isConfigured() => _settings[configuredKey];
ThemeData getCurrentTheme() => switch (_settings[themeKey] as int) {
      0 => ThemeSettings.lightTheme,
      1 => ThemeSettings.lightTheme,
      2 => ThemeSettings.darkTheme,
      3 => ThemeSettings.darkTheme,
      _ => throw StateError("Invalid ThemeSetting")
    };
double getFontScale() => _settings[fontScaleKey];
bool isEncryptionEnabled() => _settings[encryptionToggleKey];
Color getAccentColor() => Color(_settings[accentColorKey]);
GraphTypes getEmotionGraphType() => GraphTypes.values.byName(_settings[emotionGraphTypeKey]);
Object? getOtherSetting(String key) {
  Object? value = _settings[key];
  if (value == null) {
    debugPrint("Settings did not have value $key");
  }
  return value;
}

String getVaultFolder() => _settingsStorageDirectory!.path;

/// [_handleResetEverythingPress] - Requests confirmation, if confirmed, erases
///                                 all user data & passwords securely.
void handleResetEverythingPress(BuildContext context) {
  // if (settings.isConfigured()) {
  // await showDialog(
  //     context: context,
  //     // Display prompt for password entry. it must be set.
  //     builder: (context) =>
  //         AlertDialog(
  //           backgroundColor: Theme
  //               .of(context)
  //               .colorScheme
  //               .onBackground,
  //           title: const Text("Reset Everything"),
  //           actions: [
  //             TextButton(
  //                 key: const Key('Reset_Everything'),
  //                 onPressed: () {
  //                   //Reset the password
  //                 },
  //                 child: const Text("Yes")),
  //             TextButton(

  //                 key: const Key('Don't_Reset_Everything'),
  //                 onPressed: () async {
  //                   //Reset the password
  //                 },
  //                 child: const Text("No")),
  //           ],
  //         ),
  //   );
  // }
}

void verifyPassword(BuildContext context, String password) async {
  await showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.onBackground,
            actions: [
              FutureBuilder(
                  future: encryptor.unlock(password),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<bool> snapshot,
                  ) {
                    List<Widget> finalDisplay = <Widget>[
                      const SizedBox(
                          width: 200,
                          height: 200,
                          child: LoadingAnimation(loadingString: 'Logging In')),
                    ];
                    //once encryptor.unlock(password) is done then run code based off value
                    if (snapshot.hasData) {
                      if (snapshot.data!) {
                        //gets called to change screen after future builder is done
                        skipToDashboard(context);
                      } else {
                        //on bad password we update the prompt
                        finalDisplay = [
                          const Text(
                            'Incorrect Password:',
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            key: const Key('Incorrect_Password'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Ok"),
                          )
                        ];
                      }
                    }
                    return Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: finalDisplay),
                    );
                  }),
            ],
          ));
}

Future skipToDashboard(BuildContext context) async {
//traverse to the dashboard page after updated prompt automatically
  Future.delayed(const Duration(milliseconds: 1)).whenComplete(() async {
    Navigator.of(context).pop(); //pop loading screen
    Navigator.of(context).pop(); //pop password prompt
    Navigator.of(context).pushReplacementNamed("Dashboard");
    if (isEncryptionEnabled()) {
      await showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (context) {
            String? recovery = encryptor.getRecoveryPhrase();
            return AlertDialog(
                title: const Text("Recovery Phrase"),
                backgroundColor: Theme.of(context).colorScheme.onBackground,
                actions: [
                  TextButton(
                      key: const Key("Recovery_Phrase_Confirm"),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Ok")),
                  TextButton(
                      key: const Key("Recovery_Phrase_Copy"),
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: recovery!)),
                      child: const Text("Copy")),
                ],
                content: Text(
                    'Here is your recovery phrase $recovery!\n\nKeep it safe!'));
          });
    }
  });
}

void attemptLogin(BuildContext context) async {
  String passwordFieldText = "";
  await showDialog(
    barrierColor: Colors.black.withOpacity(0.2),
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      title: const Text("Welcome Back!"),
      content: ControlledTextField(
        key: const Key("Login_Password_Field"),
        hintText: "Enter your password",
        validator: (value) {
          passwordFieldText = value ?? "";
          if (value == null || value.isEmpty) {
            return "Field is empty!";
          }
          return null;
        },
      ),
      actions: [
        // Entering the password, verify, and then report to user.
        TextButton(
            //add key for testing
            key: const Key('Submit_Password'),
            onPressed: () async {
              verifyPassword(context, passwordFieldText);
            },
            child: const Text("Enter")),
      ],
    ),
  );
}

void finishConfiguration(BuildContext context, String password) async {
  //display loading screen while password is being saved
  await showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.onBackground,
            actions: [
              FutureBuilder<void>(
                  future: setPassword(password),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<void> snapshot,
                  ) {
                    //once encryptor.unlock(password) is done then run code based off value
                    if (snapshot.connectionState == ConnectionState.done) {
                      //save configuration before changing screens
                      setConfigured(true);
                      //traverse to next page once encryption is done
                      save().whenComplete(() => skipToDashboard(context));
                    }
                    return const Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 200,
                                height: 200,
                                child: LoadingAnimation(
                                    loadingString: 'Generating Keys')),
                          ]),
                    );
                  }),
            ],
          ));
}

void confirmPassword(BuildContext context, String password) async {
  bool match = false;
  // if password supplied and valid
  if (password.isNotEmpty) {
    // begin confirmation loop (verification)
    await showDialog(
        //update to remove any barrier color after the first one due to color issue
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.onBackground,
              title: const Text("Confirm your password"),
              content: ControlledTextField(
                  key: const Key('Confirm_Password_Field'),
                  hintText: "Confirm Password",
                  validator: (value) {
                    match = password == value;
                    return match ? null : "Passwords do not match.";
                  }),
              actions: [
                TextButton(
                  key: const Key('Verify_Password'),
                  onPressed: () async =>
                      (match) ? finishConfiguration(context, password) : null,
                  child: const Text("Enter"),
                ),
              ],
            ));
  }
  // No password supplied
  else {
    //Password is empty, prompt for confirmation (ensure no encryption)
    await showDialog(
        //update to remove any barrier color after the first one due to color issue
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.onBackground,
              title: const Text("No Encryption?"),
              content: const Text(
                  'Encryption can keep your private thoughts, private. Continue?'),
              actions: [
                TextButton(
                    key: const Key('Confirm_No_Password'),
                    onPressed: () => finishConfiguration(context, password),
                    child: const Text("Yes")),
                TextButton(
                    key: const Key('Cancel_No_Password'),
                    onPressed: () async {
                      Navigator.of(context)
                          .pop(); // remove confirmation window to entry password.
                    },
                    child: const Text("No")),
              ],
            ));
  }
  password = "";
  match = false;
}

Future<void> createPassword(BuildContext context) async {
  String password = "";
  // Not initialized
  await showDialog(
    barrierColor: Colors.black.withOpacity(0.2),
    context: context,
    // Start user creation process.
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      title: const Text("Encryption?"),
      // User enters password, which is either empty (no encryption)
      // or is valid, and must be confirmed.
      content: ControlledTextField(
          key: const Key('Enter_Password_Field'),
          hintText: "Enter a password (Optional)",
          validator: (value) {
            String? message = encryptor.defaultValidator(value);
            password = value ?? "";
            return message;
          }),
      actions: [
        TextButton(
            key: const Key('Create_Password'),
            onPressed: () async => confirmPassword(context, password),
            child: const Text("Enter")),
      ],
    ),
  );
}

/// [_handleStartPress] handles taps of the start button, it uses the next 5
/// methods
/// - [_createPassword] - Creates the password if we are in that state
/// - [_confirmPassword] - Accepts a 2nd password to compare to the 1st
/// - [_finishConfiguration] - Completes the configuration process for passwords
///                           and recovery phrases
/// - [_attemptLogin] - Attempts to the log the user in after receiving the
///                     credentials
/// - [_verifyPassword] - Displays the errors or completes the transition to
///                       the DashboardPage
void handleStartPress(BuildContext context) async {
  if (isConfigured()) {
    if (isEncryptionEnabled()) {
      attemptLogin(context);
    } else {
      // Password not set, but initialized, no check, just entry to dashboard.
      Navigator.of(context).pushReplacementNamed("Dashboard");
    }
  } else {
    await createPassword(context);
  }
}

/// [_handleResetPasswordPress] - Requests the users 5 word phrase and interacts
///                             with [encryptor] to perform verification and reset
///                             If successful will start the [_createPassword]
///                             Process.
void handleResetPasswordPress(BuildContext context) async {
  String? maybePasswordOrPhrase = "";
  if (isConfigured()) {
    await showDialog(
      barrierColor: Colors.black.withOpacity(0.2),
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.onBackground,
        title: const Text("Reset Password"),
        content: ControlledTextField(
          key: const Key("Reset_Password_Field"),
          hintText: "Enter your recovery phrase or password",
          validator: (value) {
            maybePasswordOrPhrase = value;
            if (value == null || value.isEmpty) {
              return "Field is required.";
            }
            return null;
          },
        ),
        actions: [
          TextButton(
              key: const Key('Reset_Password_Button'),
              onPressed: () async {
                await showDialog(
                    barrierColor: Colors.transparent,
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AlertDialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.onBackground,
                          actions: [
                            FutureBuilder(
                                future: encryptor
                                    .resetCredentials(maybePasswordOrPhrase!),
                                builder: (
                                  BuildContext context,
                                  AsyncSnapshot<bool> snapshot,
                                ) {
                                  List<Widget> finalDisplay;
                                  //once encryptor.unlock(password) is done then run code based off value
                                  if (snapshot.hasData) {
                                    if (snapshot.data!) {
                                      finalDisplay = [
                                        const Text('Password Reset Successful',
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold)),
                                        TextButton(
                                            key:
                                                const Key("Success_Pass_Reset"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Ok"))
                                      ];
                                    } else {
                                      finalDisplay = [
                                        const Text(
                                          'Incorrect Password or Recovery Phrase',
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextButton(
                                            key: const Key("Fail_Pass_Reset"),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Ok")),
                                      ];
                                    }
                                  } else {
                                    finalDisplay = <Widget>[
                                      const SizedBox(
                                          width: 200,
                                          height: 200,
                                          child: LoadingAnimation(
                                            loadingString: 'Verifying password',
                                          )),
                                    ];
                                  }
                                  return Center(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: finalDisplay),
                                  );
                                }),
                          ],
                        ));
              },
              child: const Text("Enter")),
        ],
      ),
    );
  }
}

/// User picks a file, and once picked can read it
/// After database, deserialize data in the file to be used
void loadFile() async {
  await FilePicker.platform.pickFiles();
}
