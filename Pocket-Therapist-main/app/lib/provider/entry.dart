import 'package:app/pages/entries.dart';
import 'package:flutter/material.dart';
import 'package:app/provider/settings.dart' as settings;
import 'dart:math';

List<JournalEntry> entries = [];
List<Plan> plans = [];

//add tag list
List<Tag> tagList = [
  Tag(name: 'Calm', color: const Color(0xff90c6cf)),
  Tag(name: 'Centered', color: const Color(0xff794e5d)),
  Tag(name: 'Content', color: const Color(0xfff1903a)),
  Tag(name: 'Fulfilled', color: const Color(0xff59b1a1)),
  Tag(name: 'Patient', color: const Color(0xff00c5cb)),
  Tag(name: 'Peaceful', color: const Color(0xffa7d7d6)),
  Tag(name: 'Present', color: const Color(0xffff706f)),
  Tag(name: 'Relaxed', color: const Color(0xff3f6961)),
  Tag(name: 'Serene', color: const Color(0xffb7d2c4)),
  Tag(name: 'Trusting', color: const Color(0xff41aa8b)),
];

//Map<String, Tag> tags = {
// 'Calm': Tag(name: 'Calm', color: const Color(0xff90c6cf)),
// 'Centered': Tag(name: 'Centered', color: const Color(0xff794e5d)),
// 'Content': Tag(name: 'Content', color: const Color(0xfff1903a)),
// 'Fulfilled': Tag(name: 'Fulfilled', color: const Color(0xff59b1a1)),
// 'Patient': Tag(name: 'Patient', color: const Color(0xff00c5cb)),
// 'Peaceful': Tag(name: 'Peaceful', color: const Color(0xffa7d7d6)),
// 'Present': Tag(name: 'Present', color: const Color(0xffff706f)),
// 'Relaxed': Tag(name: 'Relaxed', color: const Color(0xff3f6961)),
// 'Serene': Tag(name: 'Serene', color: const Color(0xffb7d2c4)),
// 'Trusting': Tag(name: 'Trusting', color: const Color(0xff41aa8b)),
//};

//add emotion list
// List<Emotion> emotionList = [];
Map<String, Color> emotionList = {
  'Happy': const Color(0xfffddd67),
  'Trust': const Color(0xff308c7d),
  'Fear': const Color(0xff4c4e51),
  'Anticipation': const Color(0xffff7fff),
  'Disgust': const Color(0xff384e35),
  'Anger': const Color(0xffb51c1b),
  'Sad': const Color(0xff1f3550),
  'Surprise': const Color(0xFFFF8200),
};

//Map<String, Emotion> emotions = {
//  'Happy': Emotion(name: 'Happy', color: const Color(0xfffddd67)),
//  'Trust': Emotion(name: 'Trust', color: const Color(0xff308c7d)),
//  'Fear': Emotion(name: 'Fear', color: const Color(0xff4c4e51)),
//  'Sad': Emotion(name: 'Happy', color: const Color(0xff1f3550)),
//  'Disgust': Emotion(name: 'Happy', color: const Color(0xff384e35)),
//  'Anger': Emotion(name: 'Happy', color: const Color(0xffb51c1b)),
//  'Anticipation': Emotion(name: 'Happy', color: const Color(0xffff7fff)),
//  'Surprise': Emotion(name: 'Happy', color: const Color(0xFFFF8200)),
//
//};

const Map<String, List<String>> templateSet = {
  "Relationships": [
    "Who do you trust most? Why?",
    "What are your strengths in relationships (kindness, empathy, etc.)?",
    "How do you draw strength from loved ones?",
    "What do you value most in relationships (trust, respect, sense of humor, etc.)?",
    "What three important things have you learned from previous relationships?",
    "What five traits do you value most in potential partners?",
    "How do you show compassion to others? How can you extend that same compassion to yourself?",
    "What are three things working well in your current relationship? What are three things that could be better?",
    "What boundaries could you set in your relationships to safeguard your own well-being?",
    "What do you most want your children (or future children) to learn from you?",
    "How can you better support and appreciate your loved ones?",
    "What does love mean to you? How do you recognize it in a relationship?",
    "List three things you’d like to tell a friend, family member, or partner.",
  ],
  "Career": [
    "How do you use your personal strengths and abilities at work?",
    "How do your co-workers and supervisors recognize your strengths?",
    "How does work fulfill you? Does it leave you wanting more?",
    "What part of your workday do you most enjoy?",
    "What about your work feels real, necessary, or important to you?",
    "Do you see yourself in the same job in 10 years?",
    "What are your career ambitions?",
    "What three things can help you begin working to accomplish those goals?",
    "What can you do to improve your work performance?",
    "What does your work teach you? Does it offer continued opportunities for learning and growth?",
    "Does your work drain or overwhelm you? Why? Is this something you can change?",
  ],
  "Reflection": [
    "What values do you consider most important in life (honesty, justice, altruism, loyalty, etc.)? How do your actions align with those values?",
    "What three changes can you make to live according to your personal values?",
    "Describe yourself using the first 10 words that come to mind. Then, list 10 words that you’d like to use to describe yourself. List a few ways to transform those descriptions into reality.",
    "What do you appreciate most about your personality? What aspects do you find harder to accept?",
    "Explore an opinion or two that you held in the past but have since questioned or changed. What led you to change that opinion?",
    "List three personal beliefs that you’re willing to reconsider or further explore.",
    "Finish this sentence: “My life would be incomplete without …”",
    "Describe one or two significant life events that helped shape you into who you are today.",
    "When do you trust yourself most? When do you find it harder to have faith in your instincts?",
    "What three things would you most like others (loved ones, potential friends and partners, professional acquaintances, etc.) to know about you?",
  ],
  "Emotions": [
    "What difficult thoughts or emotions come up most frequently for you?",
    "Which emotions do you find hardest to accept (guilt, anger, disappointment, etc.)? How do you handle these emotions?",
    "Describe a choice you regret. What did you learn from it?",
    "What parts of daily life cause stress, frustration, or sadness? What can you do to change those experiences?",
    "What are three things that can instantly disrupt a good mood and bring you down? What strategies do you use to counter these effects?",
    "What are three self-defeating thoughts that show up in your self-talk? How can you reframe them to encourage yourself instead?",
    "What go-to coping strategies help you get through moments of emotional or physical pain?",
    "Who do you trust with your most painful and upsetting feelings? How can you connect with them when feeling low?",
    "What do you fear most? Have your fears changed throughout life?",
  ],
  "Goals": [
    "What parts of life surprised you most? What turned out the way you expected it would?",
    "What three things would you share with your teenage self? What three questions would you want to ask an older version of yourself?",
    "List three important goals. How do they match up to your goals from 5 years ago?",
    "Do your goals truly reflect your desires? Or do they reflect what someone else (a parent, partner, friend, etc.) wants for you?",
    "What helps you stay focused and motivated when you feel discouraged?",
    "What do you look forward to most in the future?",
    "Identify one area where you’d like to improve. Then, list three specific actions you can take to create that change.",
    "How do you make time for yourself each day?",
    "What do you most want to accomplish in life?",
    "List three obstacles lying in the way of your contentment or happiness. Then, list two potential solutions to begin overcoming each obstacle.",
  ],
};

String getTemplateEntryBody(String category, int num) {
  // If category doenst exist we dont generate anything.
  if (templateSet[category] == null) return "";
  List<String> questions = List.from(templateSet[category]!);
  questions
      .shuffle(); // Shuffle to make things random, doesnt matter if it modifies.
  int length = questions.length;
  if (num > length) num = length;
  if (num == length){
    return questions
        .join("\n\n\n"); // Join questions with 2 spaces between for answering.
	}

  // num < length
  Set<int> indexes = {};
  // Generate 'num' random unique numbers.
  while (indexes.length != num) {
    indexes.add(Random().nextInt(length));
  }
  return indexes
      .map((e) => questions[e])
      .join("\n\n\n"); // pull those questions and join them.
}

(String, String) getTemplateRandom() {
  String cat, body = "";
  cat = templateSet.keys.toList()[Random().nextInt(templateSet.length)];
  body = templateSet[cat]![Random().nextInt(templateSet[cat]!.length)];
  return (cat, body);
}

void loadTagsEmotions() {
//load tags
  Object? foundTags = settings.getOtherSetting("tags");
  //if (foundTags != null && foundTags is Map<String, int>){
  //  tags.clear();
  //  foundTags.forEach((key, value) => tags[key] = Tag(name: key, color: Color(value)));
  //}
  if (foundTags != null && foundTags is Map<String, int>) {
    tagList.clear();
    for (final MapEntry<String, int>(:key, :value) in foundTags.entries) {
      tagList.add(Tag(name: key, color: Color(value)));
    }
  }

  Object? foundEmotions = settings.getOtherSetting('emotions');
  if (foundEmotions != null && foundEmotions is Map<String, int>) {
    emotionList.clear();
    for (final MapEntry<String, int>(:key, :value) in foundEmotions.entries) {
      emotionList[key] = Color(value);
    }
  }
  //if(foundEmotions != null && foundEmotions is Map<String, int>){
  //  foundEmotions.forEach((key, value) {
  //    if(emotions.containsKey(key)){
  //      emotions[key] = Emotion(name:key, color: Color(value));
  //    }
  //  });
  //}
}

void saveTagsEmotions() {
  Map<String, int> map = {};
  //tags.forEach((key, value) => map[key] = value.color.value);
  for (final Tag element in tagList) {
    map[element.name] = element.color.value;
  }
  settings.setOtherSetting('tags', Map<String, int>.of(map));
  map.clear();
  //emotions.forEach((key, value) => map[key] = value.color.value);
  settings.setOtherSetting('emotions', map);
}

//void reset() {
//  emotions = {
//    'Happy': Emotion(name: 'Happy', color: const Color(0xfffddd67)),
//    'Trust': Emotion(name: 'Trust', color: const Color(0xff308c7d)),
//    'Fear': Emotion(name: 'Fear', color: const Color(0xff4c4e51)),
//    'Sad': Emotion(name: 'Happy', color: const Color(0xff1f3550)),
//    'Disgust': Emotion(name: 'Happy', color: const Color(0xff384e35)),
//    'Anger': Emotion(name: 'Happy', color: const Color(0xffb51c1b)),
//    'Anticipation': Emotion(name: 'Happy', color: const Color(0xffff7fff)),
//    'Surprise': Emotion(name: 'Happy', color: const Color(0xFFFF8200)),
//  };
//
//  tags = {
//   'Calm': Tag(name: 'Calm', color: const Color(0xff90c6cf)),
//   'Centered': Tag(name: 'Centered', color: const Color(0xff794e5d)),
//   'Content': Tag(name: 'Content', color: const Color(0xfff1903a)),
//   'Fulfilled': Tag(name: 'Fulfilled', color: const Color(0xff59b1a1)),
//   'Patient': Tag(name: 'Patient', color: const Color(0xff00c5cb)),
//   'Peaceful': Tag(name: 'Peaceful', color: const Color(0xffa7d7d6)),
//   'Present': Tag(name: 'Present', color: const Color(0xffff706f)),
//   'Relaxed': Tag(name: 'Relaxed', color: const Color(0xff3f6961)),
//   'Serene': Tag(name: 'Serene', color: const Color(0xffb7d2c4)),
//   'Trusting': Tag(name: 'Trusting', color: const Color(0xff41aa8b)),
//  };
//}

/// Tags
///
class Tag {
  final String name;
  Color color;

  Tag({
    required this.name,
    required this.color,
  });
}

/// Emotions
///
class Emotion {
  final String name;
  Color color;
  int strength = 0;

  Emotion({
    required this.name,
    this.strength = 0,
    required this.color,
  });
}

class JournalEntry implements Comparable<JournalEntry> {
  // unique id for each entry
  final int id = UniqueKey().hashCode;

  // Journal entry title and body
  String title = "";
  String entryText = "";
  String previewText = "";

  // year, month, day
  DateTime creationDate = DateTime.now();
  DateTime? scheduledDate;
  List<Tag> tags = [];
  List<Emotion> emotions = [];

  static const previewLength = 25;

  JournalEntry(
      {required this.title,
      required this.entryText,
      this.tags = const [],
      this.emotions = const [],
      this.scheduledDate,
      DateTime? dateOverride}) {
    if (dateOverride != null) creationDate = dateOverride;
    previewText = entryText.substring(0, min(previewLength, entryText.length));
  }

  void update([
    String? newTitle,
    String? newEntryText,
    List<Tag>? newTags,
    List<Emotion>? newEmotions,
    DateTime? newDate,
  ]) {
    if (newTitle != null) title = newTitle;
    if (newEntryText != null) {
      entryText = newEntryText;
      previewText =
          entryText.substring(0, min(previewLength, entryText.length));
    }
    if (newTags != null) tags = newTags;
    if (newEmotions != null) emotions = newEmotions;
    if (newDate != null) scheduledDate = newDate;
  }

  List<Color> getGradientColors() {
    List<Color> colors = [];
    if (emotions.length >= 2) {
      emotions.sort((e1, e2) => e1.strength > e2.strength ? 1 : 0);
      colors.add(emotions[0].color);
      colors.add(emotions[1].color);
    } else if (emotions.isNotEmpty) {
      colors.add(emotions[0].color);
      colors.add(Colors.white24);
    } else if (tags.length >= 2) {
      colors.add(tags[0].color);
      colors.add(tags[1].color);
    } else if (tags.isNotEmpty) {
      colors.add(tags[0].color);
      colors.add(Colors.white24);
    } else {
      colors.add(Colors.black12);
      colors.add(Colors.white24);
    }
    return colors;
  }

  // Get the strongest emotion in the entry
  Emotion getStrongestEmotion() {
    if (emotions.isNotEmpty) {
      Emotion strongestEmotion = emotions[0];
      for (int i = 1; i < emotions.length; i++) {
        (strongestEmotion.strength < emotions[i].strength)
            ? strongestEmotion = emotions[i]
            : 0;
      }
      return strongestEmotion;
    }
    return Emotion(
        name: 'None',
        strength: 0,
        color: Colors.grey); // This shouldn't happen
  }

  /* TODO
	List<Image> pictures;
	List<Image> getPictures();
	*/

  /// If this [JournalEntry] has the same [earliestDate] as [other]
  /// we will compare them based on the [title]
  @override
  int compareTo(JournalEntry other) {
    int order = other.creationDate.compareTo(creationDate);
    return order == 0 ? other.title.compareTo(title) : order;
  }
}

/// [Plan]s can be marked as completed and store the date at which it was completed
class Plan extends JournalEntry {
  DateTime? completionDate;
  late bool planCompleted;

  Plan({
    required super.title,
    required super.entryText,
    super.tags,
    super.emotions,
    required super.scheduledDate,
  }) {
    planCompleted = false;
  }

  /// Toggle completion status
  /// If marked as completed, set completed time to current time
  /// Otherwise, delete the completion time
  void toggleCompletion() {
    planCompleted = !planCompleted;
    completionDate = planCompleted ? DateTime.now() : null;
  }

  /// If this [JournalEntry] has the same [earliestDate] as [other]
  /// we will compare them based on the [title]
  @override
  int compareTo(JournalEntry other) {
    if (other.scheduledDate == null) return -1;
    int order = other.scheduledDate!.compareTo(scheduledDate!);
    return order == 0 ? other.title.compareTo(title) : order;
  }
}

Future<void> makeNewEntry(BuildContext context) async {
  final JournalEntry? result = await Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => const EntryPage()));
  if (result is Plan) {
    plans.add(result);
  } else if (result is JournalEntry) {
    entries.add(result);
  }
}

Iterable<JournalEntry> entriesInDateRange(
        DateTime startDate, DateTime endDate, List<JournalEntry> entryList) =>
    entryList.where((entry) {
      return (entry.creationDate
                  .isBefore(endDate.add(const Duration(days: 1))) &&
              entry.creationDate
                  .isAfter(startDate.subtract(const Duration(days: 1)))) ||
          DateTime(entry.creationDate.year, entry.creationDate.month,
                  entry.creationDate.day) ==
              DateTime(startDate.year, startDate.month, startDate.day) ||
          DateTime(entry.creationDate.year, entry.creationDate.month,
                  entry.creationDate.day) ==
              DateTime(endDate.year, endDate.month, endDate.day);
    });

Iterable<JournalEntry> plansInDateRange(
        DateTime startDate, DateTime endDate, List<JournalEntry> planList) =>
    planList.where((plan) {
      return (plan.creationDate
                  .isBefore(endDate.add(const Duration(days: 1))) &&
              plan.creationDate
                  .isAfter(startDate.subtract(const Duration(days: 1)))) ||
          DateTime(plan.creationDate.year, plan.creationDate.month,
                  plan.creationDate.day) ==
              DateTime(startDate.year, startDate.month, startDate.day) ||
          DateTime(plan.creationDate.year, plan.creationDate.month,
                  plan.creationDate.day) ==
              DateTime(endDate.year, endDate.month, endDate.day);
    });
