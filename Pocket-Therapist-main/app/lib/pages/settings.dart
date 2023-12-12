import 'dart:ui';
import 'package:app/provider/entry.dart';
import 'package:app/uiwidgets/decorations.dart';
import 'package:app/uiwidgets/emotion_chart.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/theme_settings.dart';
import 'package:app/provider/settings.dart' as settings;
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Drop down menu items
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeSettings>(context);
    List<String> themeStrings = ['Dark', 'Light'];
    String? chosenTheme = provider.theme == ThemeSettings.lightTheme ? 'Light' : 'Dark';
    String directory = settings.getVaultFolder();
    directory = settings.getVaultFolder().substring(directory.length - 22, directory.length);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        // Settings title
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Settings"),
        ),

        // Stack to make background and foreground
        body: Stack(children: [
          // Stripe in the background
          Transform.translate(
              offset: Offset(0, -(MediaQuery.of(context).padding.top + kToolbarHeight)),
              // This is not const, it changes with theme, don't set it to be const
              // no matter how much the flutter gods beg
              // ignore: prefer_const_constructors
              child: StripeBackground()),

          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            )
          ),

          // Intractable Foreground
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Create a drop down menu to choose a theme
                SizedBox(
                    width: MediaQuery.of(context).size.width - 200,
                    child: DropdownButtonFormField<String>(
                      //dropdownColor: ,
                      key: const ValueKey('StyleDropDown'),
                      decoration: InputDecoration(
                          // Add icons based on theme
                          prefixIcon: Transform.rotate(
                              angle: .5,
                              child: Icon(
                                chosenTheme == 'Dark'
                                    ? Icons.brightness_2
                                    : Icons.brightness_5_outlined,
                                color: darkenColor(
                                    settings
                                        .getCurrentTheme()
                                        .colorScheme
                                        .secondary,
                                    .1),
                                size: 30,
                              ))),
                      borderRadius: BorderRadius.circular(10.0),

                      // Set up the dropdown menu items
                      value: chosenTheme,
                      items: themeStrings
                          .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                // style: const TextStyle(color: Colors.black),
                              )))
                          .toList(),

                      // if changed set the new theme
                      onChanged: (item) => setState (() {
                        chosenTheme = item;
                        provider.changeTheme(chosenTheme!);
                      }),
                    )),

                // Edit emotions list button
                StandardElevatedButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'Edit Emotion List',
                              style: Theme.of(context).textTheme.bodyLarge,
                            )),
                        Icon(Icons.arrow_forward_ios,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                      ],
                    )),

                // Edit Tag list button
                StandardElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          // Go to settings page
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TagSettingsPage()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text('Edit Tag List',
                                style: Theme.of(context).textTheme.bodyLarge)),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ],
                    )),
//Toggleing emotion graph display type
                StandardElevatedButton(
                    onPressed: ()=> setState(() {
                      final otherGraphType = switch(settings.getEmotionGraphType()) {
                        GraphTypes.time => GraphTypes.frequency,
                        GraphTypes.frequency => GraphTypes.time,
                      };
                      settings.setEmotionGraphType(otherGraphType);
                    }),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'Toggle Emotion Graph Display Type',
                              style: Theme.of(context).textTheme.bodyLarge,
                            )),
                        Text(settings.getEmotionGraphType().toString(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      ],
                    )),

                StandardElevatedButton(
                    onPressed: settings.loadFile,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'Open Vault File',
                              style: Theme.of(context).textTheme.bodyLarge,
                            )),
                        Text(directory,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      ],
                    )),

                // Erase everything
                StandardElevatedButton(
                    key: const Key("Erase_Button"),
                    onPressed: () =>
                        settings.handleResetEverythingPress(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text('Erase Everything',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error
                                          .withRed(255),
                                    ))),
                        Icon(
                          Icons.delete_forever_rounded,
                          color:
                              Theme.of(context).colorScheme.error.withRed(255),
                        ),
                      ],
                    )
                ),

                // Enable/Disable encryption Button
                Visibility(
                  visible: true,
                  maintainState: true,
                  // visible: settings.isConfigured(),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: darkenColor(
                                  settings
                                      .getCurrentTheme()
                                      .colorScheme
                                      .secondary,
                                  .1)
                              .withAlpha(200),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: kTextTabBarHeight,
                        //color: settings.getCurrentTheme().colorScheme.background,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                'Enable/Disable Encryption',
                                style: Theme.of(context).textTheme.bodyLarge,
                              )),
                          Switch(
                            key: const Key('Enable/Disable Encryption'),
                            splashRadius: 50.0,
                            value: encryption,
                            onChanged: (value) =>
                                setState(() => encryption = value),
                            // (value) => setState(() =>
                            // settings.setEncryptionStatus(value)
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ]));
  }
}
//TODO: Fix this thing, if enc on, then prompt pw, decrypt db, save db, else prompt pw, confirm, encrypt db, save, done.
bool encryption = false;

class TagSettingsPage extends StatefulWidget {

  const TagSettingsPage({super.key});

  @override
  State<TagSettingsPage> createState() => _TagSettingsState();
}

class _TagSettingsState extends State<TagSettingsPage> {
  TextEditingController textController = TextEditingController();
  Iterable<Tag> displayedTags = tagList;
  bool exactMatchFound = false;

  /// [tag] is that Tag that will be deleted, it always exists because this method cannot be called before such a time
  /// Even if the tag were not to exist, it is safe to call this, no error will occur.
  void deleteTag(Tag tag) async  {
    tagList.remove(tag);
    await settings.save();
    displayedTags = tagList.where((element) => element.name.contains(textController.text));
    exactMatchFound = displayedTags.where((element) => element.name == textController.text).isNotEmpty;
    setState(() {});
  }

  /// [addTag] shows a dialogue that will accept the parameters to create a new [Tag]
  /// The name is required
  void addTag(BuildContext context, String name) async {
    Color color = Colors.grey;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create a New Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Tag name
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextFormField(
                  key: const Key('Tag Name Field'),
                  decoration: const InputDecoration(hintText: "Tag name"),
                  initialValue: name,
                  onChanged: (newName) { name = newName; },
                ),
              ),
              //Tag Color
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: DropdownMenu<Color>(
                  key: const Key('Tag Color Field'),
                  initialSelection: color,
                  dropdownMenuEntries: selectableColors,
                  //Show 5 colors at a time
                  menuHeight: 4 * 50.0,
                  onSelected: (newColor) => setState(() => color = newColor!),
                ),
              ),
            ],
          ),
          //Conformation buttons
          actions: <Widget>[
            TextButton(
                key: const Key('Save New Tag Button'),
                child: const Text('Save'),
                onPressed: () async {
                  final newTag = Tag(name: name, color: color);
                  tagList.add(newTag);
                  //call save
                  await settings.save();

                  //Update search bar with new name
                  textController.clear();
                  if (context.mounted) Navigator.pop(context);
                  displayedTags = tagList;
                  setState(() {});
                }
            ),
            TextButton(
              key: const Key('Cancel New Tag Button'),
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
    setState((){});
  }

  Widget _tagColumn() {
    List<Widget> displayedTagListWidgets = [
      const Text("List of compatible tags: ")
    ];
    /// User entered text and that tag does not exist
    if (textController.text.isNotEmpty && !exactMatchFound) {
      displayedTagListWidgets.add(
          StandardElevatedButton(
              key: const Key('Create Tag'),
              //on pressed adds the phrase in the text form field to the tag list
              onPressed: () async => addTag(context, textController.text),
              child: const Text('Create Tag')
          ));
    }

    for (Tag tag in displayedTags) {
      //generate 1 row for each name in list
      displayedTagListWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: darkenColor(
                          settings.getCurrentTheme().colorScheme.secondary, .1)
                          .withAlpha(90),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: kTextTabBarHeight,
                    //color: settings.getCurrentTheme().colorScheme.background,
                  ),
                  // First child is tag
                  // Size box and center to align tags and delete button
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                          width: 100,
                          child: Center(
                              child: Text(tag.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ))),

                      //second is delete button
                      TextButton(
                          key: Key('Delete ${tag.name} Button'),
                          onPressed: () async => deleteTag(tag),
                          child: Text('Delete',
                            style: Theme.of(context).textTheme.bodyMedium,
                          )),
                    ],
                  )
                ]
            )
          ],
        ),
      );
    }

    //final column starts will text widget displayed
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: displayedTagListWidgets
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar for back button
      appBar: AppBar(),
      body: Stack(
          children: [
            // Stripe in the background
            Transform.translate(
                offset: Offset(
                    0, -(MediaQuery.of(context).padding.top + kToolbarHeight)),
                // This is not const, it changes with theme, don't set it to be const
                // no matter how much the flutter gods beg
                // ignore: prefer_const_constructors
                child: StripeBackground()
            ),
            BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                )
            ),
            SafeArea(
              //Ensure that selected tags are returned after quitting
              // WillPopScope is deprecated, use pops cope instead
              child: PopScope(
                canPop: false,
                onPopInvoked: (bool didPop) {
                  if (didPop) {
                    return;
                  }
                  Navigator.pop(context);
                },

                child: SingleChildScrollView(
                  //create column that will go on to contain the tag list and the search bar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        textAlign: TextAlign.center,
                        controller: textController,
                        key: const Key('Tag Search Bar'),
                        onChanged: (inputText) {
                          //the validator will update the compatible tag list to a state
                          //that will be used in the tagsExist function to build the display
                          if (inputText.isEmpty) {
                            //no input found yet so we update the compatible list to null and prompt user
                            //update list to screen
                            displayedTags = tagList;
                            setState(() {});
                            return;
                          }
                          displayedTags = tagList.where((element) => element.name.contains(inputText));
                          exactMatchFound = displayedTags.where((element) => element.name == inputText).isNotEmpty;
                          //update screen before return
                          setState(() {});
                        },
                        //ideally would prompt if they would like to create tag
                        onFieldSubmitted: (value) {
                          //trim off white space from both sides
                          value = value.trim();
                          if (value.isNotEmpty) {
                            addTag(context, value);
                            value = "";
                          }
                        },
                      ),
                      SingleChildScrollView(
                        child: _tagColumn(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
    );
  }
}

const List<DropdownMenuEntry<Color>> selectableColors = [
  DropdownMenuEntry<Color>(value: Colors.red, label: "Red", leadingIcon: Icon(Icons.circle, color: Colors.red)),
  DropdownMenuEntry<Color>(value: Colors.pink, label: "Pink", leadingIcon: Icon(Icons.circle, color: Colors.pink)),
  DropdownMenuEntry<Color>(value: Colors.purple, label: "purple", leadingIcon: Icon(Icons.circle, color: Colors.purple)),
  DropdownMenuEntry<Color>(value: Colors.deepPurple, label: "deepPurple", leadingIcon: Icon(Icons.circle, color: Colors.deepPurple)),
  DropdownMenuEntry<Color>(value: Colors.indigo, label: "indigo", leadingIcon: Icon(Icons.circle, color: Colors.indigo)),
  DropdownMenuEntry<Color>(value: Colors.blue, label: "blue", leadingIcon: Icon(Icons.circle, color: Colors.blue)),
  DropdownMenuEntry<Color>(value: Colors.lightBlue, label: "lightBlue", leadingIcon: Icon(Icons.circle, color: Colors.lightBlue)),
  DropdownMenuEntry<Color>(value: Colors.cyan, label: "cyan", leadingIcon: Icon(Icons.circle, color: Colors.cyan)),
  DropdownMenuEntry<Color>(value: Colors.teal, label: "teal", leadingIcon: Icon(Icons.circle, color: Colors.teal)),
  DropdownMenuEntry<Color>(value: Colors.green, label: "green", leadingIcon: Icon(Icons.circle, color: Colors.green)),
  DropdownMenuEntry<Color>(value: Colors.lightGreen, label: "lightGreen", leadingIcon: Icon(Icons.circle, color: Colors.lightGreen)),
  DropdownMenuEntry<Color>(value: Colors.lime, label: "lime", leadingIcon: Icon(Icons.circle, color: Colors.lime)),
  DropdownMenuEntry<Color>(value: Colors.yellow, label: "yellow", leadingIcon: Icon(Icons.circle, color: Colors.yellow)),
  DropdownMenuEntry<Color>(value: Colors.amber, label: "amber", leadingIcon: Icon(Icons.circle, color: Colors.amber)),
  DropdownMenuEntry<Color>(value: Colors.orange, label: "orange", leadingIcon: Icon(Icons.circle, color: Colors.orange)),
  DropdownMenuEntry<Color>(value: Colors.deepOrange, label: "deepOrange", leadingIcon: Icon(Icons.circle, color: Colors.deepOrange)),
  DropdownMenuEntry<Color>(value: Colors.brown, label: "brown", leadingIcon: Icon(Icons.circle, color: Colors.brown)),
  DropdownMenuEntry<Color>(value: Colors.grey, label: "grey", leadingIcon: Icon(Icons.circle, color: Colors.grey)),
];
