enum ChatRole { bot, user }

enum BotLanguage { en, ml }

enum ActiveFlow { none, medication, sleep, mood }

enum ChatPhase {
  idle,
  blockedByAlert,

  // Medication
  awaitingAdherence,
  awaitingComfortAnswer,

  // Symptoms
  awaitingSymptomSelection,
  awaitingSymptomText,

  // Sleep
  sleepStart,
  sleepQ1,
  sleepQ2,
  sleepQ3,
  sleepQ4,
  sleepQ5,
  sleepCompleted,

  // Mood
  moodStart,
  moodQ1,
  moodQ2,
  moodQ3,
  moodQ4,
  moodQ5,
  moodQ6,
  moodDepressionAddon1,
  moodManiaAddon1,
  moodSafety,
  depAddon1,
  depAddon2,
  maniaAddon1,
  maniaAddon2,
  safetyCheck,
}

class ChatMessage {
  final ChatRole role;
  final String text;
  final List<String>? quickReplies;
  ActiveFlow activeFlow = ActiveFlow.none;

  ChatMessage({
    required this.role,
    required this.text,
    this.quickReplies,
    this.activeFlow = ActiveFlow.none,
  });
}
