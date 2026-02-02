import 'dart:convert';
import 'package:flutter/material.dart';
import '../../api_client.dart';

import '../../chatbot/chatbot_state.dart';
import '../../chatbot/chatbot_localization.dart';
import 'chatbot_reply_handler.dart';
import 'chatbot_ui_builder.dart';
import '../../flows/sleep_flow.dart';
import '../../flows/mood_flow.dart';

class PatientChatbotScreen extends StatefulWidget {
  const PatientChatbotScreen({super.key});

  @override
  State<PatientChatbotScreen> createState() => _PatientChatbotScreenState();
}

class _PatientChatbotScreenState extends State<PatientChatbotScreen> {
  final List<ChatMessage> messages = [];
  final TextEditingController controller = TextEditingController();

  // ================= MOOD STATE =================
  int? moodScore;
  int? energyScore;
  int? sleepChangeScore;
  int? thoughtSpeedScore;
  int? impulsivityScore;
  int? dailyFunctionScore;

  bool triggerDepressionAddon = false;
  bool triggerManiaAddon = false;
  bool triggerSafetyCheck = false;

// ================= SLEEP STATE =================
  int sleepQualityScore = 0;
  int sleepTotalScore = 0;
  int sleepQuestionIndex = 0;

  final List<int> sleepScores = []; // holds each answer

  ChatPhase phase = ChatPhase.idle;
  BotLanguage botLanguage = BotLanguage.en;
  ActiveFlow activeFlow = ActiveFlow.none;

  Map<String, dynamic>? currentSchedule;

  List<String> availableSymptoms = [];
  Set<String> selectedSymptoms = {};

  bool submittingSymptoms = false;

  // 🧠 Mood answers
  final Map<String, int> mood = {};

  // 😴 Sleep answers
  final Map<String, int> sleep = {};

  bool submittingSurvey = false;

  bool moodCapturedToday = false;

  bool sleepCapturedToday = false;

  late ChatbotLocalization i18n;
  late ChatbotReplyHandler replyHandler;

  final List<String> sleepQualityOptions = [
    "😴 Very poor",
    "😕 Poor",
    "😐 Fair",
    "🙂 Good",
    "😃 Very good",
  ];

  /* =====================================================
     EXISTING CODE BELOW IS UNCHANGED
     (Only mood/sleep flow added)
  ===================================================== */

  @override
  void initState() {
    super.initState();
    i18n = ChatbotLocalization(botLanguage);
    _initializeReplyHandler();
    _loadContext();
  }

  String _cleanSymptom(String s) {
    return s
        .replaceAll('/', '') // remove /
        .replaceAll('+', '') // (safe guard)
        .trim();
  }

  void _initializeReplyHandler() {
    replyHandler = ChatbotReplyHandler(
      setState: setState,
      messages: messages,
      i18n: i18n,
      currentSchedule: currentSchedule,
      mood: mood,
      sleep: sleep,
      selectedSymptoms: selectedSymptoms,
      availableSymptoms: availableSymptoms,
      screen: this,
      askDepressionAddon: askDepressionAddon,
      askManiaAddon: askManiaAddon,
      askSafetyQuestion: askSafetyQuestion,
      submitSelectedSymptoms: ({String? extra}) =>
          _submitSelectedSymptoms(extra: extra),
      handleAdherence: _handleAdherence,
      handleComfortAnswer: _handleComfortAnswer,
      handleLLM: _handleLLM,
      handleBlocking: _handleBlocking,
      scoreIndex: _scoreIndex,
      submitMood: submitMood,
      submitSleep: _submitSleep,
      startSleepFlow: () => SleepFlow.start(this),
      initialPhase: phase,
      moodCapturedToday: moodCapturedToday,
      sleepCapturedToday: sleepCapturedToday,
    );
  }

  /* =====================================================
     INITIAL CONTEXT
  ===================================================== */
  Future<void> _loadContext() async {
    // 🔒 SAFETY LOCK:
    // If a flow is already running, never override it.
    if (activeFlow == ActiveFlow.sleep ||
        activeFlow == ActiveFlow.mood ||
        activeFlow == ActiveFlow.medication) {
      return;
    }

    // 1️⃣ Blocking alert check (show alert but DO NOT block flows permanently)
    if (await _hasBlockingAlert()) {
      phase = ChatPhase.blockedByAlert;
      setState(() {});
      // ⚠️ Do NOT return — allow flows to continue
    }

    // 2️⃣ Medication flow (highest priority)
    final pending = await _getPendingMedications();
    if (pending.isNotEmpty && activeFlow == ActiveFlow.none) {
      activeFlow = ActiveFlow.medication;
      _startMedicationFlow(pending.first);
      return;
    }

    // 3️⃣ Sleep survey (runs even if no medication today)
    if (await _shouldAskSleepToday() && activeFlow == ActiveFlow.none) {
      Future.microtask(() {
        activeFlow = ActiveFlow.sleep;
        SleepFlow.start(this);
        setState(() {});
      });
      return;
    }

    // 4️⃣ Mood survey
    if (await _shouldAskMoodToday() && activeFlow == ActiveFlow.none) {
      Future.microtask(() {
        activeFlow = ActiveFlow.mood;
        _startMoodFlow();
        setState(() {});
      });
      return;
    }

    // 5️⃣ Idle fallback
    activeFlow = ActiveFlow.none;
    phase = ChatPhase.idle;
    setState(() {});
  }

  Future<bool> _hasBlockingAlert() async {
    final alertRes = await ApiClient.get('/alerts');
    final alertData = jsonDecode(alertRes.body);

    final alerts = List<Map<String, dynamic>>.from(alertData['alerts'] ?? []);

    // 🔴 Find first unresolved HIGH / CRITICAL alert
    final blocking = alerts.firstWhere(
      (a) {
        final rule = a['Rule'];
        if (a['resolved'] == true || rule == null) return false;

        return rule['severity'] == 'high' || rule['severity'] == 'critical';
      },
      orElse: () => {},
    );

    if (blocking.isEmpty) return false;

    final rule = blocking['Rule'];

    // 🌐 LANGUAGE-AWARE ACTION CARD
    final actionCard = botLanguage == BotLanguage.en
        ? rule['action_card']
        : rule['action_card_ml'];

    // 🧠 BLOCKING MESSAGE
    messages.add(
      ChatMessage(
        role: ChatRole.bot,
        text: "${i18n.t('block1')}\n\n${actionCard ?? ''}",
      ),
    );

    messages.add(
      ChatMessage(
        role: ChatRole.bot,
        text: i18n.t('block2'),
      ),
    );

    setState(() {});
    return true;
  }

  Future<List<Map<String, dynamic>>> _getPendingMedications() async {
    final res = await ApiClient.get("/patient/chatbot/context");
    final data = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(data['pending'] ?? []);
  }

  Future<bool> _shouldAskSleepToday() async {
    return !sleepCapturedToday;
  }

  Future<bool> _shouldAskMoodToday() async {
    return !moodCapturedToday;
  }

  void _startMedicationFlow(Map<String, dynamic> schedule) {
    currentSchedule = schedule;
    phase = ChatPhase.awaitingAdherence;

    final drugName = schedule['drug_name'];
    final dose = schedule['dose'];
    final timing = schedule['timing'];
    final time = schedule['scheduled_time'];

    final questionText = botLanguage == BotLanguage.en
        ? "${i18n.t('med_taken_q_prefix')} "
            "**$drugName ($dose)**, "
            "${i18n.t('scheduled')} **$timing at $time** "
            "${i18n.t('med_taken_q_suffix')}"
        : "${i18n.t('med_taken_q_prefix_ml')} "
            "**$drugName ($dose)** "
            "${i18n.t('scheduled_ml')} **$timing $time** "
            "${i18n.t('med_taken_q_suffix_ml')}";

    messages.add(
      ChatMessage(
        role: ChatRole.bot,
        text: questionText,
        quickReplies: [i18n.t('yes'), i18n.t('no')],
      ),
    );

    setState(() {});
  }

  void _startMoodFlow() {
    activeFlow = ActiveFlow.mood;
    MoodFlow.start(this);

    // ✅ Ensure UI refresh
    setState(() {});
  }

  Future<void> _handleAdherence(String text) async {
    addUserMessage(text);

    final taken = text == i18n.t('yes') || text.toLowerCase() == 'yes';

    final res = await ApiClient.postJson(
      "/patient/chatbot/adherence",
      {
        "medication_schedule_id": currentSchedule!['medication_schedule_id'],
        "medication_id": currentSchedule!['medication_id'],
        "status": taken ? "taken" : "missed",
        "log_date": DateTime.now().toIso8601String().substring(0, 10),
      },
    );

    final decoded = jsonDecode(res.body);
    if (_handleBlocking(decoded)) return;

    if (taken) {
      addBotMessage(i18n.t('taken_yes'));
      phase = ChatPhase.awaitingComfortAnswer;
      addBotMessage(
        i18n.t('discomfort'),
        quickReplies: [i18n.t('no'), i18n.t('yes')],
      );
    } else {
      addBotMessage(i18n.t('taken_no'));
      _finishMedicationFlow();
      setState(() {});
    }
  }

  Future<void> _handleComfortAnswer(String text) async {
    addUserMessage(text);

    final isNo = text == i18n.t('no') || text.toLowerCase() == 'no';
    final isYes = text == i18n.t('yes') || text.toLowerCase() == 'yes';

    // -------------------------
    // NO DISCOMFORT
    // -------------------------

    if (isNo) {
      addBotMessage(i18n.t('glad'));

      currentSchedule = null;
      availableSymptoms.clear();
      selectedSymptoms.clear();

      // ✅ Let SleepFlow manage state
      SleepFlow.start(this);

      setState(() {});
      return;
    }

    // -------------------------
    // YES – DISCOMFORT PRESENT
    // -------------------------
    if (isYes) {
      final drug = currentSchedule!['drug_name'];
      /*final res = await ApiClient.get(
        "/drugs/${Uri.encodeComponent(drug)}/symptoms",
      );*/
      final res = await ApiClient.get(
        "/drugs/${Uri.encodeComponent(drug)}/symptoms"
        "?lang=${botLanguage == BotLanguage.en ? 'en' : 'ml'}",
      );

      final decoded = jsonDecode(res.body);

      availableSymptoms = (decoded['symptoms'] as List<dynamic>? ?? [])
          .map((s) => _cleanSymptom(s.toString()))
          .where((s) => s.isNotEmpty)
          .toList();

      selectedSymptoms.clear();

      // 🔴 CRITICAL FIXES
      activeFlow = ActiveFlow.medication;
      phase = ChatPhase.awaitingSymptomSelection;

      addBotMessage(
        i18n.t('select_symptoms'),
        quickReplies: availableSymptoms, // <-- THIS WAS MISSING
      );

      setState(() {}); // <-- FORCE UI UPDATE
      return;
    }

    // -------------------------
    // FALLBACK
    // -------------------------
    addBotMessage(i18n.t('glad'));
    _finishMedicationFlow();
    //setState(() {});
  }

  /* =====================================================
     SUBMIT SYMPTOMS (ROBUST)
  ===================================================== */
  Future<void> _submitSelectedSymptoms({String? extra}) async {
    if (submittingSymptoms) return;

    final symptoms = {...selectedSymptoms};
    if (extra != null && extra.isNotEmpty) symptoms.add(extra);

    if (symptoms.isEmpty) return;

    submittingSymptoms = true;

    messages.add(ChatMessage(
      role: ChatRole.user,
      text: symptoms.join(', '),
    ));

    try {
      final res = await ApiClient.postJson(
        "/patient/chatbot/symptoms",
        /*{
          "medication_schedule_id": currentSchedule!['medication_schedule_id'],
          "medication_id": currentSchedule!['medication_id'],
          "log_date": DateTime.now().toIso8601String().substring(0, 10),
          "symptoms": symptoms.toList(),
        },*/
        {
          "medication_schedule_id": currentSchedule!['medication_schedule_id'],
          "medication_id": currentSchedule!['medication_id'],
          "log_date": DateTime.now().toIso8601String().substring(0, 10),
          "symptoms": symptoms.toList(),
          "lang": botLanguage == BotLanguage.en ? "en" : "ml",
        },
      );

      final decoded = jsonDecode(res.body);
      if (_handleBlocking(decoded)) return;

      addBotMessage(i18n.t('recorded'));
    } catch (_) {
      addBotMessage(i18n.t('recorded'));
    } finally {
      submittingSymptoms = false;
      selectedSymptoms.clear();
      availableSymptoms.clear();
      // ✅ Move directly into sleep flow
      activeFlow = ActiveFlow.sleep;
      SleepFlow.start(this);

      setState(() {});
    }
  }

  Future<void> _handleLLM(String text) async {
    final res =
        await ApiClient.postJson("/patient/chatbot/llm", {"message": text});
    final decoded = jsonDecode(res.body);
    messages.add(ChatMessage(
      role: ChatRole.bot,
      text: decoded['reply'] ?? i18n.t('recorded'),
    ));
  }

  bool _handleBlocking(Map decoded) {
    //Don't block for now when alert is triggered

    /*if (decoded['evaluation']?['alert'] == true) {
      phase = ChatPhase.blockedByAlert;
      messages.add(ChatMessage(
        role: ChatRole.bot,
        text:
            "${i18n.t('block1')}\n\n${decoded['evaluation']['rule']['action_card']}",
      ));
      messages.add(ChatMessage(role: ChatRole.bot, text: i18n.t('block2')));
      return true;
    }*/
    return false;
  }

  /* =====================================================
     MOOD + SLEEP FLOW HELPERS
  ===================================================== */

  void _finishMedicationFlow() {
    currentSchedule = null;
    availableSymptoms.clear();
    selectedSymptoms.clear();

    activeFlow = ActiveFlow.none;
    phase = ChatPhase.idle;

    // Commit medication UI cleanup
    setState(() {});

    // 🚀 Deterministically start next flow AFTER frame settles
    Future.microtask(() {
      if (!sleepCapturedToday) {
        activeFlow = ActiveFlow.sleep;
        SleepFlow.start(this);
      } else if (!moodCapturedToday) {
        activeFlow = ActiveFlow.mood;
        _startMoodFlow();
      } else {
        activeFlow = ActiveFlow.none;
        phase = ChatPhase.idle;
      }

      setState(() {});
    });
  }

  // Helper methods for flows
  void addUserMessage(String text) {
    messages.add(ChatMessage(role: ChatRole.user, text: text));
    setState(() {}); // ✅ FORCE UI REFRESH
  }

  void addBotMessage(String text, {List<String>? quickReplies}) {
    messages.add(ChatMessage(
      role: ChatRole.bot,
      text: text,
      quickReplies: quickReplies,
    ));
    setState(() {}); // ✅ FORCE UI REFRESH
  }

  int _scoreIndex(String text) => 1 + (text.hashCode.abs() % 5);

  Future<void> submitMood() async {
    final payload = {
      "log_date": DateTime.now().toIso8601String().substring(0, 10),
      "mood_level": mood['overall_mood'],
      "energy_level": mood['energy_level'],
      "sleep_change": mood['sleep_change'],
      "thought_speed": mood['thought_speed'],
      "impulsivity": mood['risk_taking'] ?? mood['impulsivity'],
      "daily_functioning": mood['daily_function'],
      if (mood.containsKey('self_harm_thoughts'))
        "self_harm_ideation": mood['self_harm_thoughts'],
      if (mood.containsKey('hopelessness'))
        "hopelessness": mood['hopelessness'],
      if (mood.containsKey('exhaustion')) "exhaustion": mood['exhaustion'],
      if (mood.containsKey('risk_taking')) "risk_taking": mood['risk_taking'],
    };

    try {
      submittingSurvey = true;

      final response = await ApiClient.postJson("/mood-logs", payload);

      print(
        "📤 Mood submit → status: ${response.statusCode}, body: ${response.body}",
      );
    } catch (e, stack) {
      print("❌ Mood submit failed: $e\n$stack");
    } finally {
      submittingSurvey = false;
    }
  }

  Future<void> _submitSleep() async {
    final sleep = this.sleep;

    final totalScore = [
      sleep['quality'],
      sleep['onset'],
      sleep['maintenance'],
      sleep['duration'],
      sleep['restfulness'],
      sleep['daytime_impact'],
    ].whereType<int>().fold(0, (a, b) => a + b);

    final payload = {
      "log_date": DateTime.now().toIso8601String().substring(0, 10),
      "sleep_quality_rating": sleep['quality'],
      "q1_sleep_onset": sleep['onset'],
      "q2_maintenance": sleep['maintenance'],
      "q3_duration": sleep['duration'],
      "q4_restfulness": sleep['restfulness'],
      "q5_daytime_impact": sleep['daytime_impact'],
      "notes": null,
      "total_score": totalScore,
      "interpretation": _interpretSleepScore(totalScore),
    };

    print("📤 Sleep payload → $payload");

    try {
      submittingSurvey = true;

      final response = await ApiClient.postJson('/sleep-logs', payload);

      print(
        "sleep submit → status: ${response.statusCode} | body: ${response.body}",
      );

      if (response.statusCode ~/ 100 != 2) {
        print("Sleep log FAILED");
      }
    } catch (e, stack) {
      print("sleep submit exception: $e\n$stack");
    } finally {
      submittingSurvey = false;
      setState(() {});
    }
  }

  /* =====================================================
     USER INPUT EXTENSION
  ===================================================== */

  Future<void> _handleUserReply(String text) async {
    // Sync phase with handler
    replyHandler.phase = phase;
    await replyHandler.handleUserReply(text);
    // Sync phase back from handler
    phase = replyHandler.phase;
    // Sync captured flags (handler may have updated them)
    if (replyHandler.moodCapturedToday) moodCapturedToday = true;
    if (replyHandler.sleepCapturedToday) sleepCapturedToday = true;
    setState(() {});
  }

  String _interpretSleepScore(int score) {
    if (score >= 17) return "excellent";
    if (score >= 13) return "good";
    if (score >= 9) return "fair";
    return "poor";
  }

  //Called from Mood Flow
  void askDepressionAddon() {
    addBotMessage(
      i18n.t('mood_depression_q'),
      quickReplies: [
        i18n.t('mood_depression_0'),
        i18n.t('mood_depression_1'),
        i18n.t('mood_depression_2'),
        i18n.t('mood_depression_3'),
      ].cast<String>(),
    );
  }

  //Called from Mood Flow

  /*void askManiaAddon() {
    addBotMessage(
      'Did you feel unusually confident or invincible today?',
      quickReplies: ['No', 'Slightly', 'Moderately', 'Extremely'],
    );
  }*/

  void askManiaAddon() {
    addBotMessage(
      i18n.t('addon_mania_q1'),
      quickReplies: [
        i18n.t('mood_mania_0'),
        i18n.t('mood_mania_1'),
        i18n.t('mood_mania_2'),
        i18n.t('mood_mania_3'),
      ].cast<String>(),
    );
  }

  //Called from Mood Flow

  /*void askSafetyQuestion() {
    addBotMessage(
      'Did you have thoughts about harming yourself today?',
      quickReplies: [
        'No',
        'Brief thoughts, no intent',
        'Strong thoughts',
        'Prefer not to answer'
      ],
    );
  }*/

  void askSafetyQuestion() {
    addBotMessage(
      i18n.t('mood_safety_q'),
      quickReplies: [
        i18n.t('mood_safety_no'),
        i18n.t('mood_safety_brief'),
        i18n.t('mood_safety_strong'),
        i18n.t('mood_safety_prefer_not'),
      ].cast<String>(),
    );
  }

  /* =====================================================
     UI
  ===================================================== */
  @override
  Widget build(BuildContext context) {
    return ChatbotUIBuilder.build(
      context,
      phase: phase,
      botLanguage: botLanguage,
      i18n: i18n,
      messages: messages,
      availableSymptoms: availableSymptoms,
      selectedSymptoms: selectedSymptoms,
      submittingSymptoms: submittingSymptoms,
      controller: controller,
      setState: setState,
      handleUserReply: _handleUserReply,
      submitSelectedSymptoms: _submitSelectedSymptoms,
      onLanguageToggle: () {
        setState(() {
          botLanguage =
              botLanguage == BotLanguage.en ? BotLanguage.ml : BotLanguage.en;

          // 🔥 RECREATE LOCALIZATION
          i18n = ChatbotLocalization(botLanguage);

          // 🔥 RECREATE REPLY HANDLER (CRITICAL)
          _initializeReplyHandler();
        });
      },
      onOtherPressed: () {
        setState(() {
          phase = ChatPhase.awaitingSymptomText;
        });
      },
    );
  }
}
