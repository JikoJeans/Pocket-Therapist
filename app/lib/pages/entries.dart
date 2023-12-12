import 'dart:core';
import 'package:app/provider/entry.dart';
import 'package:app/provider/theme_settings.dart';
import 'package:circular_seek_bar/circular_seek_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../uiwidgets/decorations.dart';
import 'package:app/helper/dates_and_times.dart';

// Display options
enum DisplayOption {
  day,
  week,
  month,
  year;

  @override
  String toString() => switch (this) {
        DisplayOption.day => "Day",
        DisplayOption.week => "Week",
        DisplayOption.month => "Month",
        DisplayOption.year => "Year",
      };
}

DisplayOption chosenDisplay = DisplayOption.week;
final List<DropdownMenuItem<String>> displayDropDown = DisplayOption.values
    .map((item) => DropdownMenuItem<String>(
        value: item.toString(), child: Text(item.toString())))
    .toList();

//
// /// [getFilteredList] returns a list that is filtered by the [chosenDisplay] (week, month, year)
// /// [items] = journal entry list;
// /// [chosenDisplay] = 'Week', 'Month', 'Year';
// /// [getCompletedList] = print the completed list
// List<JournalEntry> getFilteredList(
//     List<JournalEntry> items, String? chosenDisplay, bool getCompleteList) {
// // Sort the Journal entries by most recent date
//   final sortedItems = items..sort();
//   List<JournalEntry> filteredList = [];
//
//   for (int i = 0; i < sortedItems.length; i++) {
//     if (getCompleteList) {
//       filteredList.add(sortedItems[i]);
//     } else {
//       final firstItem = sortedItems[0]; // get the most recent entry
//       final item = sortedItems[i]; // get the next item
//       final time = firstItem.date; // get the date for the first item
//
//       // check to see if the item is in the filter
//       bool isSameDate = time.isWithinDateRange(item.date, chosenDisplay!);
//
//       if (isSameDate) {
//         // if item is in the filter, add it to the return list
//         filteredList.add(sortedItems[i]);
//       }
//     }
//   }
//   return filteredList;
// }

/// [EntryPanelPage] is the page for all of the entries that user has entered.
class EntryPanelPage extends StatefulWidget {
  final bool showPlans;

  final DateTime? targetDate;

  static Route<dynamic> route({targetDate}) {
    return MaterialPageRoute(
        builder: (context) => EntryPanelPage(targetDate: targetDate));
  }

  /// [showPlans] to show either regular entries or plans
  const EntryPanelPage({super.key, this.targetDate, this.showPlans = false});

  @override
  State<EntryPanelPage> createState() => _EntryPanelPageState();
}

class _EntryPanelPageState extends State<EntryPanelPage> {
  //update so items is duplicate to original list rather than being a refernce to entries
  List<JournalEntry> items = entries;
  List<Tag> selectedTags = [];
  List<String> selectedEmotions = [];
  final TextEditingController searchBarInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    entries.sort(); //TODO mess around
    // Select appropriate list to display
    plans.sort();
    if (widget.targetDate != null) {
      items = _getEntriesInRange();
    }

    if (widget.showPlans) {
      items = plans.toList();
    }
    items.sort();
    return Consumer<ThemeSettings>(
      builder: (context, value, child) {
        return Scaffold(
            body: Stack(children: [
              // This is not const, it changes with theme, don't set it to be const
              // no matter how much the flutter gods beg
              // ignore: prefer_const_constructors
              StarBackground(),

              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.showPlans
                        ? const Text("Plans")
                        : const Text('Entries'),

                    // Pad filter to the right

                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      SizedBox(
                        //Has button for second Nav bar
                        width: MediaQuery.of(context).size.width / 6,
                        child: ElevatedButton(
                            onPressed: () {
                              showStats();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                            ),
                            key: const Key("toggleStats"),
                            child: const Icon(Icons.more_horiz)),
                      ),
                      //only works on entries page
                      Expanded(
                          flex: 2,
                          child: TextFormField(
                            key: const Key('Filter_By_TextForm'),
                            textAlign: TextAlign.center,
                            controller: searchBarInput,
                            onChanged: updateFilteredList,
                            decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Enter a journal title',
                                fillColor: Colors.transparent),
                          )),
                      Container(
                        //for drop down day-year
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        // Dropdown for filter by date
                        child: DropdownButtonFormField<String>(
                          key: const Key("SortByDateDropDown"),
                          borderRadius: BorderRadius.circular(10.0),
                          // Set up the dropdown menu items
                          value: chosenDisplay.toString(),
                          items: displayDropDown,
                          // if changed set new display option
                          onChanged: (item) => setState(() {
                            chosenDisplay = switch (item) {
                              "Day" => DisplayOption.day,
                              "Week" => DisplayOption.week,
                              "Month" => DisplayOption.month,
                              "Year" => DisplayOption.year,
                              _ => DisplayOption.year,
                            };
                          }),
                        ),
                      ),
                    ]),
                    //create new row for tag list and make it visible on journal entry page
                    const Text("Select tags to filter entries."),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: tagList
                            .map(
                              (tag) => FilterChip(
                                  selected: selectedTags.contains(tag),
                                  label: Text(tag.name),
                                  selectedColor: Color.alphaBlend(
                                      tag.color,
                                      Theme.of(context)
                                          .colorScheme
                                          .primaryContainer),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  onSelected: (selected) {
                                    //update to add or remove tag
                                    selectedTags.contains(tag)
                                        ? selectedTags.remove(tag)
                                        : selectedTags.add(tag);
                                    //by triggering udpate Filtered list with
                                    //either the text in the search bar or empty we
                                    //ensure that the title search and tag search are always synced
                                    updateFilteredList(searchBarInput.text);
                                  }),
                            )
                            .toList(),
                      ),
                    ),
                    const Text("Select emotions to filter entries."),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: generateEmotionFilterChips(),
                      ),
                    ),

                    //holds the list of entries
                    Expanded(
                        child: ListView.builder(
                      key: const Key('Entry_Builder'),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        // get one item
                        final item = items[index];
                        final time = widget.showPlans
                            ? item.scheduledDate!
                            : item.creationDate;

                        // Dividers by filter
                        bool isSameDate = true;
                        if (index == 0) {
                          // if first in list
                          isSameDate = false;
                        } else {
                          // else check if same date by filters
                          isSameDate = time.isWithinDateRange(
                              widget.showPlans
                                  ? items[index - 1].scheduledDate!
                                  : items[index - 1].creationDate,
                              chosenDisplay.toString());
                        }
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // if not same date or first in list make new list
                            children: [
                              if (index == 0 || !(isSameDate)) ...[
                                Text(getTimeRange(time))
                              ],
                              Dismissible(
                                // Each Dismissible must contain a Key. Keys allow Flutter to
                                // uniquely identify widgets.

                                // Issue with the key, needs to be specific id, not a
                                // name or will receive error that dismissible is still
                                // in the tree
                                key: Key(item.id.toString()),

                                //prevents right swipes
                                direction: DismissDirection.endToStart,

                                // Provide a function that tells the app
                                // what to do after an item has been swiped away.
                                onDismissed: (direction) {
                                  // Remove the item from the data source.
                                  setState(() {
                                    JournalEntry entry = items.removeAt(index);
                                    if (!widget.showPlans) {
                                      entries.remove(entry);
                                    } else {
                                      plans.remove(entry);
                                    }
                                  });

                                  // Then show a snackBar w/ item name as dismissed message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('${item.title} deleted')));
                                },
                                confirmDismiss:
                                    (DismissDirection direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Delete Entry?"),
                                        content: const Text(
                                            "Are you sure you wish to delete this entry?"),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text("DELETE")),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text("CANCEL"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: DisplayCard(
                                  entry: item,
                                ),
                              )
                            ]); // if in the same filter header list, then just make a new entry
                      },
                    )),
                  ],
                ),
              ),
            ]),
            bottomNavigationBar: CustomNavigationBar(
                selectedIndex: widget.showPlans ? 4 : 1,

                /// We need a custom navigator here because the page needs to update when a new entry is made, but make new entry should be separate from everything else.
                onDestinationSelected: (index) async {
                  switch (index) {
                    case 2:
                      await makeNewEntry(context);
                      //update so filter new entry appear in filtered list after being made
                      updateFilteredList(searchBarInput.text);
                      return;
                    case 5:
                      Navigator.of(context).pushNamed(
                          CustomNavigationBar.defaultDestinations[index].label);
                      return;
                    case _:
                      Navigator.of(context).pushReplacementNamed(
                          CustomNavigationBar.defaultDestinations[index].label);
                      break;
                  }
                }));
      },
    );
  }

  String getMostFrequentEmotion(List<JournalEntry> entries) {
    List<JournalEntry> filteredEntries = _getEntriesInRange();

    //map to track emotion use
    Map<String, int> emotionsAndAmounts = {
      'Happy': 0,
      'Trust': 0,
      'Fear': 0,
      'Sad': 0,
      'Disgust': 0,
      'Anger': 0,
      'Surprise': 0,
      'Anticipation': 0
    };
    //no entries
    if (filteredEntries.isEmpty) {
      return "N/A";
    }
    //go through all entries in the list
    for (var entry in filteredEntries) {
      //go through all emotions in the entry
      for (var emotion in entry.emotions) {
        emotionsAndAmounts[emotion.name] =
            emotionsAndAmounts[emotion.name]! + 1;
      } //ends inner for
    } // ends outer for

    var emotionCount = 0;
    var mostEmotion = "";
    emotionsAndAmounts.forEach((key, value) {
      if (value > emotionCount && value > 0) {
        //find the most frequent emotion and add it to the list
        mostEmotion = key;
        emotionCount = value;
      }
    });
    return mostEmotion;
  }

  String getMostCommonTag(List<JournalEntry> entries) {
    List<JournalEntry> filteredEntries = _getEntriesInRange();
//list if two or more tags are the most frequent

    //maps for tags and how often they appear
    Map<String, int> tagsAndOccurrences = {};
    //go through every entry
    for (var entry in filteredEntries) {
      //go through each tag in the entry
      for (var tag in entry.tags) {
        //if the tag is not a key in map add it, assign val to 0
        if (!tagsAndOccurrences.containsKey(tag.name)) {
          tagsAndOccurrences[tag.name] = 1;
        } else {
          tagsAndOccurrences[tag.name] = tagsAndOccurrences[tag.name]! + 1;
        }
      }
    }

    int maxValue = 0;
    String freqTag = "";
    //go through map and find most frequent tag based on value
    tagsAndOccurrences.forEach((key, value) {
      if (value > maxValue && value > 0) {
        //find the most frequent tag and add it to the list
        freqTag = key;
        maxValue = value;
      }
    });

    return freqTag;
  }

  //end of stats functions

  String getTimeRange(DateTime time) {
    if (chosenDisplay == DisplayOption.week) {
      DateTime firstOfYear = DateTime(DateTime.now().year, 1, 1);
      int weekNum = firstOfYear.getWeekNumber(firstOfYear, time);
      DateTime upper = firstOfYear.add(Duration(days: (weekNum * 7)));
      DateTime lower = upper.subtract(const Duration(days: 6));

      // Range for the week
      return '${lower.formatDate().month} ${lower.formatDate().day} - ${upper.formatDate().month} ${upper.formatDate().day}, ${time.year.toString()}';
    } else if (chosenDisplay == DisplayOption.month) {
      // If monthly, only display month and year
      return '${time.formatDate().month} ${time.year.toString()}';
    } // If day, only display day month and year
    else if (chosenDisplay == DisplayOption.day) {
      return '${time.formatDate().day} ${time.formatDate().month} ${time.year.toString()}';
    } else {
      // If yearly, only display year
      return time.year.toString();
    }
  }

  //create function to update the filtered list to only contain compatable entries
  //relative to the input passed
  void updateFilteredList(String input) {
    //first trim off excess spaces from the left and right side of input
    input = input.trim();
    //if input is empty then we return the full list, if it isnt then this will be overwritten
    items = widget.showPlans ? plans.toList() : entries.toList();
    items = items
        .where((element) =>
            element.title.toLowerCase().contains(input.toLowerCase()))
        .toList();

    //is triggered every time the serach bar is updated so that way filtered journal entries
    //are also filtered by tag selection
    items = items.where((element) {
      for (Tag tag in selectedTags) {
        if (!element.tags.map((e) => e.name).contains(tag.name)) {
          return false;
        }
      }
      return true;
    }).toList();

    /// Filter by selected emotions as well
    items = items.where((element) {
      for (String emote in selectedEmotions) {
        if (!element.emotions.map((e) => e.name).contains(emote)) {
          return false;
        }
      }
      return true;
    }).toList();
    setState(() {});
  }

  List<Widget> generateEmotionFilterChips() {
    List<FilterChip> chips = [];
    for (final MapEntry<String, Color>(:key, :value) in emotionList.entries) {
      chips.add(FilterChip(
        selected: selectedEmotions.contains(key),
        label: Text(key),
        selectedColor: Color.alphaBlend(
            value, Theme.of(context).colorScheme.primaryContainer),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        onSelected: (selected) {
          selectedEmotions.contains(key)
              ? selectedEmotions.remove(key)
              : selectedEmotions.add(key);
          updateFilteredList(searchBarInput.text);
        },
      ));
    }
    return chips;
  }

  List<JournalEntry> _getEntriesInRange() {
    // Sort the Journal entries by most recent date
    //Show entreis in range of given date or from today
    final today = widget.targetDate ?? DateTime.now();
    final startDate = switch (chosenDisplay) {
      DisplayOption.day => today.subtract(const Duration(days: 1)),
      DisplayOption.week => today.subtract(Duration(days: today.weekday - 1)),
      DisplayOption.month => DateTime(today.year, today.month, 1),
      DisplayOption.year => DateTime(today.year, 1, 1),
    };
    final endDate = switch (chosenDisplay) {
      DisplayOption.day => today.add(const Duration(days: 1)),
      DisplayOption.week => today.add(Duration(days: 7 - today.weekday)),
      DisplayOption.month => (today.month < DateTime.december
              ? DateTime(today.year, today.month + 1, 1)
              : DateTime(today.year + 1, 1, 1))
          .subtract(const Duration(days: 1)),
      DisplayOption.year =>
        DateTime(today.year + 1, 1, 1).subtract(const Duration(days: 1)),
    };
    //sortedItems = getFilteredList(entries, chosenDisplay, showAllItems);

    // Select appropriate list to display
    final filteredEntries =
        entriesInDateRange(startDate, endDate, items).toList();
    final filteredPlans = plansInDateRange(startDate, endDate, items).toList();

    return widget.showPlans ? filteredPlans : filteredEntries;
  }

  void showStats() {
    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (stfContext, stfSetState) {
              return AlertDialog(
                title: const Text("Statistics"),
                content: Text(
                    'Most Frequent Emotion: ${getMostFrequentEmotion(entries)} \n'
                    ' Most Common Tag: ${getMostCommonTag(entries)} \n'),
              );
            },
          );
        });
  }
} //ends page

/// [EntryPage] is the page where an individual entry is displayed. it handles both
/// creation of new entries, modification of them.
class EntryPage extends StatefulWidget {
  final JournalEntry? entry;

  const EntryPage({super.key, this.entry});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final ValueNotifier<double> progress = ValueNotifier(0);
  DateTime? datePicked;
  bool isPlan = false;

  // List of selected tags to keep track of when making the chip list
  List<Tag> selectedTags = [];
  List<Emotion> selectedEmotions = [];

  // Add text controllers to retrieve text data
  final titleController = TextEditingController();
  final entryTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      selectedTags = widget.entry!.tags;
      selectedEmotions = widget.entry!.emotions;
      titleController.text = widget.entry!.title;
      entryTextController.text = widget.entry!.entryText;
      isPlan = widget.entry!.scheduledDate == null;
      datePicked = widget.entry!.scheduledDate;
    } else {
      selectedTags = [];
      selectedEmotions = [];
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleController.dispose();
    entryTextController.dispose();
    super.dispose();
  }

  // Make an Alert Dialog Box that will display the emotional dial and a save button
  void _emotionalDial(BuildContext context, Emotion emotion) async {
    int strength = 0;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: CircularSeekBar(
              key: const Key('EmotionalDial'),
              width: double.infinity,
              height: 175,
              progress: emotion.strength.toDouble(),
              maxProgress: 60,
              barWidth: 8,
              startAngle: 5,
              sweepAngle: 360,
              strokeCap: StrokeCap.butt,
              progressGradientColors: [
                emotion.color.withAlpha(128),
                emotion.color,
              ],
              innerThumbRadius: 5,
              innerThumbStrokeWidth: 3,
              innerThumbColor: Colors.white,
              outerThumbRadius: 5,
              outerThumbStrokeWidth: 10,
              outerThumbColor: Colors.blueAccent,
              dashWidth: 20,
              dashGap: 10,
              animation: false,
              valueNotifier: progress,

              /// TODO: Remove the child center that displays the strength?
              child: Center(
                child: ValueListenableBuilder(
                    valueListenable: progress,
                    builder: (_, double value, __) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(() {
                              // on changed, set the strength
                              strength = value.round();
                              return '$strength';
                            }()),
                            const Text('Strength'),
                          ],
                        )),
              ),
            ),
            actions: [
              // pop the alert dialog off the screen and don't save the strength changes
              TextButton(
                  key: const Key('cancelDial'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),

              // Save the strength changes and pop the dialog off the screen
              TextButton(
                  key: const Key('saveDial'),
                  onPressed: () {
                    emotion.strength = strength;
                    Navigator.of(context).pop();
                  },
                  child: const Text("Save")),
            ],
          );
        });
  }

  // Date picker
  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDate: datePicked ?? DateTime.now(),
      );

  // Time picker
  Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

  Future<DateTime?> pickPlanDate() async {
    var selectedDate = await pickDate();
    if (selectedDate == null) return null;

    var selectedTime = await pickTime();
    if (selectedTime == null) return null;

    return selectedDate.toLocal();
  }

  void showTagPicker() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (stfContext, stfSetState) {
          return AlertDialog(
            title: const Text("Select Tags"),
            content: Wrap(
              spacing: 5.0,
              children: createAvailableTagsList(stfSetState),
            ),
            actions: <Widget>[
              TextButton(
                key: const Key('saveTagsButton'),
                child: const Text('Save'),
                onPressed: () {
                  Navigator.of(stfContext).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  void showEmotionPicker() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (stfContext, stfSetState) {
          return AlertDialog(
            title: const Text("Select Emotions"),
            content: Wrap(
              spacing: 5.0,
              children: createAvailableEmotionsList(stfSetState),
            ),
            actions: <Widget>[
              TextButton(
                key: const Key('saveEmotionsButton'),
                child: const Text('Save'),
                onPressed: () {
                  Navigator.of(stfContext).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  // Make the journal entry and save it
  JournalEntry? saveEntry() {
    // Database entry point for creating journal entry
    if (widget.entry == null && !isPlan) {
      //TODO: do database things to save new journal entry: db.insert
      return JournalEntry(
        title: titleController.text,
        entryText: entryTextController.text,
        tags: selectedTags,
        emotions: selectedEmotions,
      );
    } else if (widget.entry == null) {
      return Plan(
        title: titleController.text,
        entryText: entryTextController.text,
        tags: selectedTags,
        emotions: selectedEmotions,
        scheduledDate: datePicked!,
      );
    } else {
      // entry exists, we are modifying
      //TODO: do database things for updating journal entry
      // I have the full record, just patch the record.
      if (widget.entry! is Plan) {
        widget.entry!.update(titleController.text, entryTextController.text,
            selectedTags, selectedEmotions, datePicked);
      } else {
        widget.entry!.update(
          titleController.text,
          entryTextController.text,
          selectedTags,
          selectedEmotions,
        );
      }
      return widget.entry!;
    }
  }

  List<FilterChip> createAvailableTagsList(StateSetter stfSetState) {
    return tagList
        .map((tag) => FilterChip(
              label: Text(tag.name),
              selected: selectedTags.any((element) => element.name == tag.name),
              showCheckmark: false,
              selectedColor: tag.color,
              onSelected: (bool selected) {
                stfSetState(() {
                  setState(() {
                    /// When the corresponding tag is selected, add it or remove it based on the name
                    //TODO: Update this when references are added to work only with references.
                    selected
                        ? selectedTags.add(tag)
                        : selectedTags
                            .removeWhere((element) => element.name == tag.name);
                  });
                });
              },
            ))
        .toList();
  }

  List<FilterChip> createAvailableEmotionsList(StateSetter stfSetState) {
    return emotionList.entries
        .map((e) => FilterChip(
              label: Text(e.key),
              selected:
                  selectedEmotions.any((element) => element.name == e.key),
              showCheckmark: false,
              selectedColor: e.value,
              onSelected: (bool selected) {
                stfSetState(() {
                  setState(() {
                    /// When the corresponding emote is selected, add it or remove it based on the name
                    //TODO: Update this when references are added to work only with references.
                    selected
                        ? selectedEmotions
                            .add(Emotion(name: e.key, color: e.value))
                        : selectedEmotions
                            .removeWhere((element) => element.name == e.key);
                  });
                });
              },
            ))
        .toList();
  }

  List<ActionChip> createSelectedTagList() {
    return selectedTags
        .map((tag) => ActionChip(
              label: Text(tag.name),
              backgroundColor: tag.color,
              onPressed: () {
                setState(() {
                  selectedTags
                      .removeWhere((element) => element.name == tag.name);
                });
              },
            ))
        .toList();
  }

  List<ActionChip> createSelectedEmotionList() {
    return selectedEmotions
        .map((Emotion emotion) => ActionChip(
              label: Text(emotion.name),
              backgroundColor: emotion.color,
              onPressed: () => _emotionalDial(context, emotion),
            ))
        .toList();
  }

  void requestEntryTemplate(BuildContext context) async {
    String category = "";
    int questions = 6;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Guided Journaling"),
        content: SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.width / 3,
            child: Row(
              children: [
                const Text('Category: '),
                DropdownMenu<String>(
                  key: const Key("Template_Selection"),
                  dropdownMenuEntries: templateSet.keys
                      .map((e) => DropdownMenuEntry(value: e, label: e))
                      .toList(),
                  onSelected: (value) {
                    category = value!;
                  },
                ),
              ],
            )),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Generate!"))
        ],
      ),
    );
    if (category == "") return;
    DateTime today = DateTime.now();

    /// Format [dateSlug] is yyyy-mm-dd
    String dateSlug =
        "${today.year.toString()}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    if (titleController.text.isEmpty) {
      titleController.text = "$dateSlug - $category";
    }
    entryTextController.text = getTemplateEntryBody(category, questions);
  }

  void getRandomQuestion() {
    (String, String) results = getTemplateRandom();
    if (titleController.text.isEmpty) {
      titleController.text = results.$1;
    }
    entryTextController.text += "${results.$2}\n\n";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Entry' : widget.entry!.title),
        automaticallyImplyLeading: true,
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
          key: const Key("ScrollMe"),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(children: [
                // Text field for the Journal Entry Title
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: titleController,
                    key: const Key("titleInput"),
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Title',
                        hintText: 'Inspiration is a tap away...'),
                  ),
                ),
                // Text input field for the Journal Entry Body
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GestureDetector(
                    key: const Key("entryBodyKey"),
                    onHorizontalDragEnd: (details) async {
                      requestEntryTemplate(context);
                      setState(() {});
                    },
                    onDoubleTap: () => setState(() => getRandomQuestion()),
                    child: TextField(
                      controller: entryTextController,
                      key: const Key("journalInput"),
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Journal Entry',
                        hintText:
                            "Swipe right for ideas, double tap for a question...",
                      ),
                      maxLines: 20,
                      minLines: 1,
                    ),
                  ),
                ),

                // Chip display for the tags
                Padding(
                  padding: const EdgeInsets.all(20),
                  // Make the chips scrollable
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      key: const Key('TagChipsDisplay'),
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 5,
                        children: createSelectedTagList(),
                      ),
                    ),
                  ),
                ),
                // Chip display for the emotions
                Padding(
                    padding: const EdgeInsets.all(20),
                    // Make the chips scrollable
                    child: Scrollbar(
                        child: SingleChildScrollView(
                            key: const Key('EmotionChipsDisplay'),
                            scrollDirection: Axis.horizontal,
                            child: Wrap(
                              spacing: 5,
                              children: createSelectedEmotionList(),
                            )))),
              ]))),

      // Plan save tag in replacement of the nav bar
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: 3,
        allowReselect: true,
        destinations: const [
          NavigationDestination(
              key: Key("planButton"),
              icon: Icon(Icons.more_time),
              label: "Plan"),
          NavigationDestination(
              key: Key("tagButton"), icon: Icon(Icons.tag), label: "Tags"),
          NavigationDestination(
              key: Key("emotionButton"),
              icon: Icon(Icons.emoji_emotions),
              label: "Emotions"),
          NavigationDestination(
              key: Key("saveButton"), icon: Icon(Icons.save), label: "Save"),
        ],
        onDestinationSelected: (index) async {
          switch (index) {
            case 0:
              datePicked = await pickPlanDate() ?? datePicked;
              isPlan = datePicked != null;
            case 1:
              showTagPicker();
            case 2:
              showEmotionPicker();
            case 3:
              Navigator.of(context).pop(saveEntry());
          }
        },
      ),
    );
  }
}
