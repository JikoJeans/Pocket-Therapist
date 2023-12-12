// Page imports
import 'package:app/pages/settings.dart';

// Provider imports
import 'package:app/provider/settings.dart' as settings;
import 'package:app/provider/theme_settings.dart';

import '../uiwidgets/decorations.dart';

// Dependency imports
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

//create welcome page class like in app example starting with stateful widget
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {

  //
  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  //duplicate build method from example with changes noted below
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            WaveWidget(
              config: CustomConfig(
                gradients: [
                  [
                    settings.getCurrentTheme().colorScheme.primary,
                    settings.getCurrentTheme().colorScheme.secondary
                  ],
                  [
                    settings.getCurrentTheme().colorScheme.secondary,
                    settings.getCurrentTheme().colorScheme.onBackground
                  ],
                  [
                    settings.getCurrentTheme().colorScheme.onBackground,
                    settings.getCurrentTheme().colorScheme.background
                  ],
                  [
                    settings.getCurrentTheme().colorScheme.background,
                    settings.getCurrentTheme().colorScheme.primary
                  ],
                ],
                durations: [
                  19440,
                  17440,
                  15440,
                  13440,
                ],
                heightPercentages: [0.50, 0.63, 0.75, 0.80],
                gradientBegin: Alignment.centerLeft,
                gradientEnd: Alignment.centerRight,
                blur: const MaskFilter.blur(BlurStyle.solid, 40),
              ),
              backgroundColor: settings.getCurrentTheme().colorScheme.secondary,
              size: const Size(double.infinity, double.infinity),
              // waveAmplitude: 1,
            ),

            // This is not const, it changes with theme, don't set it to be const
            // no matter how much the flutter gods beg
            // ignore: prefer_const_constructors
            StripeBackground(),

            // Intractable widgets and the logo
            SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Padding(padding: EdgeInsets.only(top: 50)),

                    // Contains the logo, spinning circle, and catch phrase
                    SizedBox(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Wavy circle behind logo
                            Container(
                              alignment: Alignment.topCenter,
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (_, child) {
                                  return Transform.rotate(
                                    angle: _controller.value * .12 * math.pi,
                                    child: child,
                                  );
                                },
                                child: Image.asset(
                                  'assets/circleCutOut.png',
                                  scale: .8,
                                  color: darkenColor(
                                      settings.getCurrentTheme().colorScheme.primary, .1),
                                ),
                              ),
                            ),

                            // Logo
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Image(
                                  image: AssetImage('assets/logoSmall.png'),
                                ),
                                Transform(
                                  transform: Matrix4.translationValues(0, -37, 0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width/2,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: darkenColor(
                                          settings.getCurrentTheme()
                                              .colorScheme
                                              .primary,
                                          0.1),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15.0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'How are you ',
                                          style:
                                          Theme.of(context).textTheme.bodyLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          ' really ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                            color: Colors.amber,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          ' feeling?',
                                          style:
                                          Theme.of(context).textTheme.bodyLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                    ),
                    // ),

                    // Buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Start button
                        Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: StandardElevatedButton(
                            key: const Key("Start_Button"),
                            onPressed: () => settings.handleStartPress(context),
                            child: const Text(
                              'Start',
                              style: TextStyle(color: Colors.amber),
                            ),
                          ),
                        ),

                        // Reset Password Button
                        Visibility(
                          visible: (settings.isConfigured() && settings.isEncryptionEnabled()),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: StandardElevatedButton(
                                key: const Key("Reset_Button"),
                                onPressed: () {
                                  settings.handleResetPasswordPress(context);
                                },
                                child: Text(
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  'Reset Password',
                                ),
                              ),
                            ),
                        )
                      ],
                    ),

                    //use a size box for the quote of the day
                    SizedBox(
                      height: 180,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Quote()),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 20)),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          //add key for testing
          key: const Key('Settings_Button'),
          onPressed: () {
            Navigator.push(
                // Go to settings page
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()));
          },
          tooltip: 'Settings',
          backgroundColor: Theme.of(context).colorScheme.onBackground,
          foregroundColor: Theme.of(context).colorScheme.background,
          shape: const CircleBorder(eccentricity: 1.0),
          child: const Icon(Icons.settings),
        ));
  }
}
