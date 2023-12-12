import 'dart:math';
import 'package:app/pages/entries.dart';
import 'package:app/provider/entry.dart';
import 'package:app/provider/settings.dart';
import 'package:flutter/material.dart';
import 'package:starsview/starsview.dart';
import 'package:app/provider/theme_settings.dart';
import 'package:app/provider/encryptor.dart' as encryptor;
import 'package:app/helper/dates_and_times.dart';

List<String> quotes = [
  "Is God willing to prevent evil, but not able? Then he is not omnipotent. Is he able, but not willing? Then he is Malevolent. Is he both able and willing? Then whence cometh evil? Is he neither able nor willing? Then why call him God?",
  "I have love in me the likes of which you can scarcely imagine and rage the likes of which you would not believe. If I cannot satisfy the one, I will indulge the other.",
  "There is no good or evil, just men trying to control the world.",
  "The mind is not a vessel to be filled but a fire to be kindled.\n- Plutarch",
  "The miserable have no other medicine but only hope.\n- William Shakespeare",
  "Man is the cruelest animal.\n- Friedrich Nietzsche",
  "Whatever you are, be a good one.\n- Abraham Lincoln",
  "Falling down is not a failure. Failure comes when you stay where you have fallen.\n- Socrates",
  "The only true possession you have is your own self.\n- Socrates",
  "I cannot teach anybody anything. I can only make them think.\n- Socrates",
  "A system of morality which is based on relative emotional values is a mere illusion, a thoroughly vulgar conception which has nothing sound in it and nothing true.\n- Socrates",
  "If life were predictable it would cease to be life and be without flavor.\n-Eleanor Roosevelt",
  "Darkness cannot drive out darkness: only light can do that. Hate cannot drive out hate: only love can do that.\n- Martin Luther King Jr.",
  "The way to get started is to quit talking and begin doing.\n- Walt Disney",
  "It does not matter how slowly you go as long as you do not stop.\n- Confucius",
  "Reading maketh a full man; conference a ready man; and writing an exact man.\n- Francis Bacon",
  "Only one man ever understood me, and he didn't understand me\n- G.W.F. Hegel",
];

String currentQuote = "";
String nextQuote = "";

class Quote extends StatefulWidget {
  final Random rand = Random();

  Quote({super.key});

  String newQuote() {
    return quotes[rand.nextInt(quotes.length)];
  }

  @override
  State<Quote> createState() => _QuoteState();
}

class _QuoteState extends State<Quote> with TickerProviderStateMixin {
  // For quote fade in and out animations
  bool clicked = false;
  bool visible = true;

// For display quotes

  @override
  void initState() {
    super.initState();
    currentQuote = widget.newQuote();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key("Quote"),
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(
                width: 4,
                color: Theme.of(context).colorScheme.primaryContainer,
              )),
        ),
        //height: 210,
        width: MediaQuery.of(context).size.width,

        // animate the quote fade in and out
        child: AnimatedOpacity(
          onEnd: (() {
            setState(() {
              // To play the animation twice
              visible = true;
              clicked = false;

              // Update quote here so it doesn't change before fade out and after fade in
              currentQuote = nextQuote;
            });
          }),

          // If not clicked and is visible, then play fading in animation
          // Otherwise fade out
          opacity: (clicked == false && visible == true) ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 800),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Top Quotation
                Transform.flip(
                    origin: const Offset(-40, 0),
                    flipX: true,
                    child: Icon(Icons.format_quote_rounded,
                        size: 40,
                        color: getCurrentTheme().colorScheme.primaryContainer)),

                // Quote
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    // quote from app
                    currentQuote,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                // Bottom Quotation
                Transform(
                    transform: Matrix4.translationValues(80, 0, 0),
                    child: Icon(Icons.format_quote_rounded,
                        size: 40,
                        color: getCurrentTheme().colorScheme.primaryContainer)),
              ]),
        ),
        // ),
      ),
      onTap: () {
        // When tapping on the quote container, make the quote fade out and prepare the next quote
        setState(() {
          clicked = true;
          visible = !clicked;
          nextQuote = currentQuote;
          while (currentQuote == nextQuote) {
            nextQuote = widget.newQuote();
          }
        });
      },
    );
  }
}

/// This is used as a password field, but can be used for any generic secrets
/// It supports hintText from the TextFormField widget, and will display
/// what you provide inside of the field
///
/// Use the validator to provide validation to your field, this is required
/// and returns null if valid.
class ControlledTextField extends StatefulWidget {
  final String hintText;
  final String? Function(String?) validator;
  const ControlledTextField({
    super.key,
    this.hintText = "Password",
    this.validator = encryptor.defaultValidator,
  });

  @override
  State<ControlledTextField> createState() => _ControlledTextFieldState();
}

class _ControlledTextFieldState extends State<ControlledTextField> {
  // This key is used only to differentiate it from everything else in the widget
  // tree
  final _formKey = GlobalKey<FormState>();
  // this is used to control and track the text that is in the field
  final textController = TextEditingController();
  // This is used to request focus on the field
  final textFocusNode = FocusNode();
  // We obscure text by default
  bool _isObscured = true;

  @override
  void dispose() {
    textController.dispose();
    textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: TextFormField(
          //  This will only attempt to validate the field if user interacted
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: _isObscured,
          focusNode: textFocusNode,
          // changes the keyboard that the system displays to one that supports
          // email addressing with the @.
          keyboardType: TextInputType.emailAddress,
          controller: textController,
          decoration: InputDecoration(
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            suffixIcon: IconButton(
              padding: const EdgeInsetsDirectional.only(end: 12.0),
              icon: _isObscured
                  ? const Icon(Icons.visibility)
                  : const Icon(Icons.visibility_off),
              // Updates the state of the widget, requests a redraw.
              onPressed: () => setState(() => _isObscured = !_isObscured),
            ),
            hintText: widget.hintText,
          ),
          // Call whatever function is supplied.
          validator: widget.validator,
        ));
  }
}

/// Button that can do something with an elevation component
class StandardElevatedButton extends StatelessWidget {
  final Widget child;
  final Function()? onPressed;
  final double elevation = 20.0;

  const StandardElevatedButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color shadowColor = Theme.of(context).colorScheme.shadow;
    Color backgroundColor = Theme.of(context).colorScheme.primary;
    return SizedBox(
        width: 350,
        height: 50,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            textStyle: const TextStyle(
              inherit: true,
              fontSize: 16,
            ),
            elevation: elevation,
            shadowColor: shadowColor,
            backgroundColor: backgroundColor,
            side: BorderSide(
                color: darkenColor(Theme.of(context).colorScheme.primary, .1),
                width: 3),
          ),
          child: child,
        ));
  }
}

/// Stripe background for reuse
class StripeBackground extends StatelessWidget {
  const StripeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Stripe
      Transform(
        transform: Matrix4.skewY(-0.45),
        origin: const Offset(60, 0),
        alignment: Alignment.bottomLeft,
        child: Container(
          decoration: BoxDecoration(
            color: darkenColor(getCurrentTheme().colorScheme.secondary, .05),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
        ),
      ),

      // Top primary color
      Transform(
        transform: Matrix4.skewY(-0.45),
        alignment: Alignment.bottomLeft,
        child: Container(
          decoration: BoxDecoration(
            color: getCurrentTheme().colorScheme.primary,
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
        ),
      ),
    ]);
  }
}

/// Background for Entries and Plans Currently
class StarBackground extends StatelessWidget {
  const StarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[
            getCurrentTheme().colorScheme.primary,
            getCurrentTheme().colorScheme.background,
          ],
        ))),
        const StarsView(
          fps: 60,
        )
      ],
    );
  }
}

/// [CustomNavigationBar] - The Navigator at the bottom of the screen
/// [destinations] is the list of destinations that this navigationbar should be able to reach
/// [selectedIndex] is the starting index that we will display, by default its 0
/// [onDestinationSelected] is the void Function(int) that should handle the routing of the navgations
// ignore: must_be_immutable
class CustomNavigationBar extends StatelessWidget {
  static const List<NavigationDestination> defaultDestinations = [
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

  /// [destinations] is the different icons at the bottom that a user could tap on to visit
  final List<NavigationDestination> destinations;

  /// [selectedIndex] is the currently selected destination as its place in the destination list.
  int selectedIndex;

  /// [onDestinationSelected] is a function that should be called every time a selection is made, which will
  /// update the navigation bar and perform any other necessary tasks for this navigation.
  final ValueChanged<int>? onDestinationSelected;

  /// [allowReselect] fill this in here
  bool allowReselect;

  CustomNavigationBar({
    super.key,
    this.selectedIndex = 0,
    this.destinations = defaultDestinations,
    this.onDestinationSelected,
    this.allowReselect = false,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: destinations,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (!allowReselect && index == selectedIndex) return;
        if (index >= destinations.length) return;
        onDestinationSelected == null
            ? defaultOnDestinationSelected(index, context)
            : onDestinationSelected!(index);

        // this may need a bool around it to enable your functionality.
        // selectedIndex = index; // This needs to be here to properly update the icons on other pages, as well as prevent re-evaluation of the navigation if we are already on that page.
      },
    );
  }

  void defaultOnDestinationSelected(int index, BuildContext context) async {
    switch (index) {
      case 2:
        makeNewEntry(context);
        return;
      case 5:
        Navigator.of(context).pushNamed(destinations[index].label);
        return;
      case _:
        Navigator.of(context).pushReplacementNamed(destinations[index].label);
        break;
    }
  }
}


/// A card that displays text with a title and main text body
class DisplayCard extends StatefulWidget {
  final JournalEntry entry;

  const DisplayCard({super.key, required this.entry});

  @override
  State<DisplayCard> createState() => _DisplayCardState();
}

class _DisplayCardState extends State<DisplayCard> {
  void toggleEntry() {
    setState(() {
      (widget.entry as Plan).toggleCompletion();
    });
  }

  String getTitle(){
    if(widget.entry is !Plan) {
      return (widget.entry.title.length > 23)
        ? '${widget.entry.title.substring(0, 23)}...'
       : widget.entry.title;
    }else{
      return (widget.entry.title.length > 20)
          ? '${widget.entry.title.substring(0, 20)}...'
          : widget.entry.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //The card should take the full width of the screen (with some padding)
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      width: MediaQuery.of(context).size.width,

      //Uses gesture detector to enable interactivity
      child: GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EntryPage(entry: widget.entry),
          )).then((value) => setState((){}));
          //update parent widget to sync search options or just rebuild display card
        },
        child: Card(
          shape: const RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: getCurrentTheme().colorScheme.background.withAlpha(150),
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: widget.entry.getGradientColors(),
              ),
            ),

            child: Row(
                // row to hold all information
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                      // Column to hold title and preview text
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          getTitle(),
                          overflow: TextOverflow.fade,
                          style: widget.entry is Plan &&
                                  (widget.entry as Plan).planCompleted
                              // If plan is finished, show a strikethrough
                              ? DefaultTextStyle.of(context).style.apply(
                                  fontSizeFactor: 1.3,
                                  fontWeightDelta: 1,
                                  decoration: TextDecoration.lineThrough,
                                  decorationStyle:
                                      TextDecorationStyle.wavy,
                                  decorationColor:
                                      Theme.of(context).primaryColor,
                                  decorationThicknessFactor: 1,
                                  decorationThicknessDelta: 0.0,
                                )
                              // Otherwise no text style changes
                              : DefaultTextStyle.of(context).style.apply(
                                  fontSizeFactor: 1.3,
                                  fontWeightDelta: 1,
                                ),
                        ),

                        // preview text
                        Text(
                          (widget.entry.entryText.length >= 30) ?
                          '${widget.entry.entryText.substring(0,30)}...' : widget.entry.entryText,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ]),

                  // Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Checkbox to mark plans as completed
                      if (widget.entry is Plan)
                        IconButton(
                          key: const Key("PlanCompleteButton"),
                          // Show filled outline for completed
                          icon: const Icon(Icons.check_box_outline_blank),
                          selectedIcon: const Icon(Icons.check_box),
                          isSelected: (widget.entry as Plan).planCompleted == true,
                          onPressed: toggleEntry,
                        ),

                      // Day
                      Text(
                        widget.entry is Plan ? widget.entry.scheduledDate!.day.toString() :widget.entry.creationDate.day.toString(),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),

                      const Padding(padding: EdgeInsets.only(left: 5)),

                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // First 3 letters of the month
                            Text(
                              widget.entry is Plan ? widget.entry.scheduledDate!.formatDate().month.substring(0, 3) :widget.entry.creationDate.formatDate().month.substring(0, 3),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),

                            // Year
                            Text(
                              widget.entry is Plan ? widget.entry.scheduledDate!.year.toString() :widget.entry.creationDate.year.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ])
                    ],
                  )
                ]),
          ),
        ),
      ),
    );
  }
}

class LoadingAnimation extends StatefulWidget {
  final String? loadingString;

  const LoadingAnimation({super.key, this.loadingString});

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
      lowerBound: 0.0,
      //approximately 2*pi for full spin
      upperBound: 6.283)
    ..repeat();
  final loadingImage = Image.asset(
    'assets/CenteredGlassesFrame.png',
    key: const Key('Loading_Animation'),
  );
  final dots = [".   ", "..  ", "... ", "...."];
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //first sized box used to control image size
            SizedBox(
              width: 130,
              height: 130,
              child: AnimatedBuilder(
                animation: _animationController,
                child: loadingImage,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animationController.value,
                    child: child,
                  );
                },
              ),
            ),
            //second sized box used to add spacing between image and text
            const SizedBox(
              height: 20,
            ),
            //update to move text below loading image
            Row(
              children: [
                //either uses the text passed in or uses default loading text
                Text(widget.loadingString ?? "Loading",
                    style: Theme.of(context).textTheme.titleLarge),
                AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) =>
                        //2 pi to even quarters
                        Text(
                          dots[((_animationController.value) / (6.283 / 4.0))
                              .truncate()],
                          style: Theme.of(context).textTheme.titleLarge,
                        )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
