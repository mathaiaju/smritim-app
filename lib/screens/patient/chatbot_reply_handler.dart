import '../../chatbot/chatbot_state.dart';
import '../../chatbot/chatbot_localization.dart';
import '../../flows/sleep_flow.dart';
import '../../flows/mood_flow.dart';

class ChatbotReplyHandler {
  final Function(void Function()) setState;
  final List<ChatMessage> messages;
  final ChatbotLocalization i18n;
  final Map<String, dynamic>? currentSchedule;
  final Map<String, int> mood;
  final Map<String, int> sleep;
  final Set<String> selectedSymptoms;
  final List<String> availableSymptoms;
  final dynamic screen;

  final Function() askDepressionAddon;
  final Function() askManiaAddon;
  final Function() askSafetyQuestion;
  final Function({String? extra}) submitSelectedSymptoms;
  final Function(String) handleAdherence;
  final Function(String) handleComfortAnswer;
  final Function(String) handleLLM;
  final Function(Map) handleBlocking;
  final Function(String) scoreIndex;
  final Function() submitMood;
  final Function() submitSleep;
  final Function() startSleepFlow;

  // 🔁 REQUIRED PUBLIC STATE (used by patient_chatbot_screen.dart)
  ChatPhase _phase = ChatPhase.idle;
  ChatPhase get phase => _phase;
  set phase(ChatPhase value) => _phase = value;

  bool _moodCapturedToday = false;
  bool _sleepCapturedToday = false;

  bool get moodCapturedToday => _moodCapturedToday;
  bool get sleepCapturedToday => _sleepCapturedToday;

  ChatbotReplyHandler({
    required this.setState,
    required this.messages,
    required this.i18n,
    required this.currentSchedule,
    required this.mood,
    required this.sleep,
    required this.selectedSymptoms,
    required this.availableSymptoms,
    required this.screen,
    required this.askDepressionAddon,
    required this.askManiaAddon,
    required this.askSafetyQuestion,
    required this.submitSelectedSymptoms,
    required this.handleAdherence,
    required this.handleComfortAnswer,
    required this.handleLLM,
    required this.handleBlocking,
    required this.scoreIndex,
    required this.submitMood,
    required this.submitSleep,
    required this.startSleepFlow,
    ChatPhase? initialPhase,
    bool? moodCapturedToday,
    bool? sleepCapturedToday,
  }) {
    if (initialPhase != null) _phase = initialPhase;
    if (moodCapturedToday != null) _moodCapturedToday = moodCapturedToday;
    if (sleepCapturedToday != null) _sleepCapturedToday = sleepCapturedToday;
  }

  Future<void> handleUserReply(String text) async {
    if (_phase == ChatPhase.blockedByAlert) return;

    switch (_phase) {
      /* ───────── MEDICATION / SYSTEM ───────── */

      case ChatPhase.awaitingAdherence:
        if (screen.activeFlow != ActiveFlow.medication) return;
        await handleAdherence(text);
        _phase = screen.phase;
        return;

      case ChatPhase.awaitingComfortAnswer:
        if (screen.activeFlow != ActiveFlow.medication) return;
        await handleComfortAnswer(text);
        _phase = screen.phase;
        return;

      case ChatPhase.awaitingSymptomText:
        if (screen.activeFlow != ActiveFlow.medication) return;
        await submitSelectedSymptoms(extra: text);
        _phase = screen.phase;
        return;

      /* ───────── SLEEP FLOW ───────── */

      case ChatPhase.sleepStart:
        if (screen.activeFlow != ActiveFlow.sleep) return;
        SleepFlow.handleSleepStart(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.sleepQ1:
        if (screen.activeFlow != ActiveFlow.sleep) return;
        SleepFlow.handleSleepQ1(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.sleepQ2:
        if (screen.activeFlow != ActiveFlow.sleep) return;
        SleepFlow.handleSleepQ2(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.sleepQ3:
        if (screen.activeFlow != ActiveFlow.sleep) return;
        SleepFlow.handleSleepQ3(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.sleepQ4:
        if (screen.activeFlow != ActiveFlow.sleep) return;
        SleepFlow.handleSleepQ4(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.sleepQ5:
        if (screen.activeFlow != ActiveFlow.sleep) return;
        await SleepFlow.handleSleepQ5(screen, text);
        _sleepCapturedToday = screen.sleepCapturedToday;
        _phase = screen.phase;
        break;

      case ChatPhase.sleepCompleted:
        print("🚀 Handling sleepCompleted");

        await submitSleep(); // ensure API + alerts finish

        if (!screen.moodCapturedToday) {
          MoodFlow.start(screen); // this sets phase + activeFlow
        } else {
          screen.phase = ChatPhase.idle;
          screen.activeFlow = ActiveFlow.none;
        }

        break;

      /* ───────── MOOD FLOW ───────── */

      case ChatPhase.moodStart:
        if (screen.activeFlow != ActiveFlow.mood) return;
        MoodFlow.handleMoodStart(screen);
        _phase = screen.phase;
        break;

      case ChatPhase.moodQ1:
        if (screen.activeFlow != ActiveFlow.mood) return;
        MoodFlow.handleMoodQ1(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.moodQ2:
        if (screen.activeFlow != ActiveFlow.mood) return;
        MoodFlow.handleMoodQ2(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.moodQ3:
        if (screen.activeFlow != ActiveFlow.mood) return;
        MoodFlow.handleMoodQ3(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.moodQ4:
        if (screen.activeFlow != ActiveFlow.mood) return;
        MoodFlow.handleMoodQ4(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.moodQ5:
        if (screen.activeFlow != ActiveFlow.mood) return;
        MoodFlow.handleMoodQ5(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.moodQ6:
        if (screen.activeFlow != ActiveFlow.mood) return;
        MoodFlow.handleMoodQ6(screen, text);
        _moodCapturedToday = screen.moodCapturedToday;
        _phase = screen.phase;
        break;

      case ChatPhase.depAddon1:
        MoodFlow.handleDepressionAddon1(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.depAddon2:
        MoodFlow.handleDepressionAddon2(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.maniaAddon1:
        MoodFlow.handleManiaAddon(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.maniaAddon2:
        MoodFlow.handleManiaAddon2(screen, text);
        _phase = screen.phase;
        break;

      case ChatPhase.safetyCheck:
        MoodFlow.handleSafetyCheck(screen, text);
        _moodCapturedToday = screen.moodCapturedToday;
        _phase = screen.phase;
        break;

      /* ───────── IDLE ───────── */

      case ChatPhase.idle:
        messages.add(ChatMessage(role: ChatRole.user, text: text));
        await handleLLM(text);
        break;

      default:
        break;
    }

    setState(() {});
  }
}
