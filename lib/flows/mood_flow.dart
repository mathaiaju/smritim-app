import '../chatbot/chatbot_state.dart';

class MoodResult {
  final String summary;
  final String interpretation;

  MoodResult(this.summary, this.interpretation);
}

class MoodFlow {
  static bool _depressionAsked = false;
  static bool _maniaAsked = false;
  static bool _safetyAsked = false;
  static void start(dynamic screen) {
    screen.mood.clear();

    _depressionAsked = false;
    _maniaAsked = false;
    _safetyAsked = false;

    screen.activeFlow = ActiveFlow.mood;
    screen.phase = ChatPhase.moodStart;

    screen.addBotMessage(screen.i18n.t('mood_intro'));

    // 🔑 AUTO-ADVANCE — DO NOT WAIT FOR USER INPUT
    handleMoodStart(screen);
  }

  static void handleMoodStart(dynamic screen) {
    screen.phase = ChatPhase.moodQ1;

    /*screen.addBotMessage(
      'How has your mood been today?',
      quickReplies: ['Very low', 'Low', 'Balanced / okay', 'High', 'Very high'],
    );*/

    screen.addBotMessage(
      screen.i18n.t('mood_q1'),
      quickReplies: [
        screen.i18n.t('mood_opt_very_low'),
        screen.i18n.t('mood_opt_low'),
        screen.i18n.t('mood_opt_okay'),
        screen.i18n.t('mood_opt_high'),
        screen.i18n.t('mood_opt_very_high'),
      ].cast<String>(),
    );

    screen.setState(() {});
  }

  static void handleMoodQ1(dynamic screen, String text) {
    screen.addUserMessage(text);

    /*screen.mood['overall_mood'] = mapMoodLevel(text);
    screen.moodScore = screen.mood['overall_mood'];

    screen.phase = ChatPhase.moodQ2;

    screen.addBotMessage(
      'How was your energy level today?',
      quickReplies: [
        'Very low',
        'Slightly low',
        'Normal',
        'Higher than usual',
        'Much higher than usual'
      ],
    );*/

    screen.mood['overall_mood'] = mapByIndex(
      text,
      [
        screen.i18n.t('mood_opt_very_low'),
        screen.i18n.t('mood_opt_low'),
        screen.i18n.t('mood_opt_okay'),
        screen.i18n.t('mood_opt_high'),
        screen.i18n.t('mood_opt_very_high'),
      ],
    );
    screen.moodScore = screen.mood['overall_mood'];

    screen.phase = ChatPhase.moodQ2;

    screen.addBotMessage(
      screen.i18n.t('mood_q2'),
      quickReplies: [
        screen.i18n.t('mood_opt_energy_very_low'),
        screen.i18n.t('mood_opt_energy_slight_low'),
        screen.i18n.t('mood_opt_energy_normal'),
        screen.i18n.t('mood_opt_energy_high'),
        screen.i18n.t('mood_opt_energy_very_high'),
      ].cast<String>(),
    );

    screen.setState(() {});
  }

  static void handleMoodQ2(dynamic screen, String text) {
    screen.addUserMessage(text);

    /*screen.mood['energy_level'] = mapEnergyLevel(text);
    screen.energyScore = screen.mood['energy_level'];

    screen.phase = ChatPhase.moodQ3;

    screen.addBotMessage(
      'How much did you sleep last night?',
      quickReplies: [
        'More than usual',
        'About usual',
        'Slightly less than usual',
        'Much less than usual'
      ],
    );*/

    screen.mood['energy_level'] = mapByIndex(
      text,
      [
        screen.i18n.t('mood_opt_energy_very_low'),
        screen.i18n.t('mood_opt_energy_slight_low'),
        screen.i18n.t('mood_opt_energy_normal'),
        screen.i18n.t('mood_opt_energy_high'),
        screen.i18n.t('mood_opt_energy_very_high'),
      ],
    );
    screen.energyScore = screen.mood['energy_level'];
    screen.phase = ChatPhase.moodQ3;

    screen.addBotMessage(
      screen.i18n.t('mood_q3'),
      quickReplies: [
        screen.i18n.t('mood_opt_sleep_more'),
        screen.i18n.t('mood_opt_sleep_same'),
        screen.i18n.t('mood_opt_sleep_less'),
        screen.i18n.t('mood_opt_sleep_much_less'),
      ].cast<String>(),
    );

    screen.setState(() {});
  }

  static void handleMoodQ3(dynamic screen, String text) {
    screen.addUserMessage(text);

    /*screen.mood['sleep_change'] = mapSleepChange(text);
    screen.sleepChangeScore = screen.mood['sleep_change'];

    screen.phase = ChatPhase.moodQ4;

    screen.addBotMessage(
      'How fast were your thoughts today?',
      quickReplies: [
        'Slower than usual',
        'Normal',
        'A bit fast',
        'Very fast / racing'
      ],
    );*/

    screen.mood['sleep_change'] = mapByIndex(
      text,
      [
        screen.i18n.t('mood_opt_sleep_more'),
        screen.i18n.t('mood_opt_sleep_same'),
        screen.i18n.t('mood_opt_sleep_less'),
        screen.i18n.t('mood_opt_sleep_much_less'),
      ],
    );
    screen.sleepChangeScore = screen.mood['sleep_change'];
    screen.phase = ChatPhase.moodQ4;

    screen.addBotMessage(
      screen.i18n.t('mood_q4'),
      quickReplies: [
        screen.i18n.t('mood_opt_thought_slow'),
        screen.i18n.t('mood_opt_thought_normal'),
        screen.i18n.t('mood_opt_thought_fast'),
        screen.i18n.t('mood_opt_thought_racing'),
      ].cast<String>(),
    );

    screen.setState(() {});
  }

  static void handleMoodQ4(dynamic screen, String text) {
    screen.addUserMessage(text);

    /*screen.mood['thought_speed'] = mapThoughtSpeed(text);
    screen.thoughtSpeedScore = screen.mood['thought_speed'];

    screen.phase = ChatPhase.moodQ5;

    screen.addBotMessage(
      'Did you feel more talkative, impulsive, or driven than usual today?',
      quickReplies: ['No', 'Slightly', 'Moderately', 'A lot'],
    );*/

    screen.mood['thought_speed'] = mapByIndex(
      text,
      [
        screen.i18n.t('mood_opt_thought_slow'),
        screen.i18n.t('mood_opt_thought_normal'),
        screen.i18n.t('mood_opt_thought_fast'),
        screen.i18n.t('mood_opt_thought_racing'),
      ],
    );
    screen.thoughtSpeedScore = screen.mood['thought_speed'];
    screen.phase = ChatPhase.moodQ5;

    screen.addBotMessage(
      screen.i18n.t('mood_q5'),
      quickReplies: [
        screen.i18n.t('mood_opt_none'),
        screen.i18n.t('mood_opt_slight'),
        screen.i18n.t('mood_opt_moderate'),
        screen.i18n.t('mood_opt_a_lot'),
      ].cast<String>(),
    );

    screen.setState(() {});
  }

  static void handleMoodQ5(dynamic screen, String text) {
    screen.addUserMessage(text);

    /*screen.mood['impulsivity'] = mapImpulsivity(text);
    screen.impulsivityScore = screen.mood['impulsivity'];

    screen.phase = ChatPhase.moodQ6;

    screen.addBotMessage(
      'How well did you manage your usual daily activities today?',
      quickReplies: ['Very poorly', 'Poorly', 'Okay', 'Well', 'Very well'],
    );*/

    screen.mood['impulsivity'] = mapByIndex(
      text,
      [
        screen.i18n.t('mood_opt_none'),
        screen.i18n.t('mood_opt_slight'),
        screen.i18n.t('mood_opt_moderate'),
        screen.i18n.t('mood_opt_a_lot'),
      ],
    );
    screen.impulsivityScore = screen.mood['impulsivity'];
    screen.phase = ChatPhase.moodQ6;

    screen.addBotMessage(
      screen.i18n.t('mood_q6'),
      quickReplies: [
        screen.i18n.t('mood_opt_function_very_poor'),
        screen.i18n.t('mood_opt_function_poor'),
        screen.i18n.t('mood_opt_function_okay'),
        screen.i18n.t('mood_opt_function_well'),
        screen.i18n.t('mood_opt_function_very_well'),
      ].cast<String>(),
    );

    screen.setState(() {});
  }

  static Future<void> handleMoodQ6(dynamic screen, String text) async {
    screen.addUserMessage(text);

    /*screen.mood['daily_function'] = mapDailyFunction(text);
    screen.dailyFunctionScore = screen.mood['daily_function'];*/

    screen.mood['daily_function'] = mapByIndex(
      text,
      [
        screen.i18n.t('mood_opt_function_very_poor'),
        screen.i18n.t('mood_opt_function_poor'),
        screen.i18n.t('mood_opt_function_okay'),
        screen.i18n.t('mood_opt_function_well'),
        screen.i18n.t('mood_opt_function_very_well'),
      ],
    );
    screen.dailyFunctionScore = screen.mood['daily_function'];

    // 🔑 RESET FLAGS BEFORE EVALUATION
    screen.triggerDepressionAddon = false;
    screen.triggerManiaAddon = false;
    screen.triggerSafetyCheck = false;

    // 🔑 RE-EVALUATE USING UPDATED SCORES
    final mood = screen.moodScore ?? 3;
    final energy = screen.energyScore ?? 3;
    final sleep = screen.sleepChangeScore ?? 2;
    final thoughts = screen.thoughtSpeedScore ?? 2;
    final impulsivity = screen.impulsivityScore ?? 1;

// 1️⃣ SAFETY ALWAYS FIRST
    if (mood <= 1 && !_safetyAsked) {
      _safetyAsked = true;
      screen.phase = ChatPhase.safetyCheck;
      screen.triggerSafetyCheck = true;
      screen.askSafetyQuestion();
      screen.setState(() {});
      return;
    }

// 2️⃣ DEPRESSION SCREEN
// Low mood/energy + oversleeping OR poor functioning
    if (!_depressionAsked &&
        (mood <= 2 || energy <= 2) &&
        (sleep == 1 || screen.dailyFunctionScore! <= 2)) {
      _depressionAsked = true;
      screen.phase = ChatPhase.depAddon1;
      screen.askDepressionAddon();
      screen.setState(() {});
      return;
    }

// 3️⃣ MANIA SCREEN
// High mood/energy + reduced sleep + activation
    if (!_maniaAsked &&
        (mood >= 4 || energy >= 4) &&
        sleep >= 3 &&
        (thoughts >= 3 || impulsivity >= 3)) {
      _maniaAsked = true;
      screen.phase = ChatPhase.maniaAddon1;
      screen.triggerManiaAddon = true;
      screen.askManiaAddon();
      screen.setState(() {});
      return;
    }

// 4️⃣ DONE
    await _finishMoodFlow(screen);
  }

  static void handleDepressionAddon1(dynamic screen, String text) {
    screen.addUserMessage(text);
    //screen.mood['hopelessness'] = mapHopelessness(text);

    screen.mood['hopelessness'] = mapByIndex(
      text,
      [
        screen.i18n.t('mood_opt_not_at_all'),
        screen.i18n.t('mood_opt_a_little'),
        screen.i18n.t('mood_opt_quite_bit'),
        screen.i18n.t('mood_opt_most_day'),
      ],
    );

    screen.phase = ChatPhase.depAddon2;

    /*screen.addBotMessage(
      'Did you feel slowed down or exhausted?',
      quickReplies: ['No', 'Slightly', 'Moderately', 'Severely'],
    );*/

    screen.addBotMessage(
      screen.i18n.t('dep_q1'),
      quickReplies: [
        screen.i18n.t('mood_opt_slow_no'),
        screen.i18n.t('mood_opt_slow_slight'),
        screen.i18n.t('mood_opt_slow_moderate'),
        screen.i18n.t('mood_opt_slow_severe'),
      ].cast<String>(),
    );

    screen.setState(() {});
  }

  static void handleDepressionAddon2(dynamic screen, String text) {
    final hopelessness = screen.mood['hopelessness'] ?? 1;

    screen.addUserMessage(text);
    //screen.mood['exhaustion'] = mapExhaustion(text);
    //final exhaustion = screen.mood['exhaustion']!;

    screen.mood['exhaustion'] = mapByIndex(
      text,
      [
        screen.i18n.t('mood_opt_slow_no'),
        screen.i18n.t('mood_opt_slow_slight'),
        screen.i18n.t('mood_opt_slow_moderate'),
        screen.i18n.t('mood_opt_slow_severe'),
      ],
    );
    final exhaustion = screen.mood['exhaustion']!;

    // Safety always wins
    if (screen.triggerSafetyCheck && !_safetyAsked) {
      _safetyAsked = true;
      screen.phase = ChatPhase.safetyCheck;
      screen.askSafetyQuestion();
      screen.setState(() {});
      return;
    }

    // Mania next if applicable
    if (screen.triggerManiaAddon && !_maniaAsked) {
      _maniaAsked = true;
      screen.phase = ChatPhase.maniaAddon1;
      screen.askManiaAddon();
      screen.setState(() {});
      return;
    }

    if ((hopelessness >= 3 || exhaustion >= 3) && !_safetyAsked) {
      _safetyAsked = true;
      screen.phase = ChatPhase.safetyCheck;
      screen.askSafetyQuestion();
      screen.setState(() {});
      return;
    }

    _finishMoodFlow(screen);
  }

  static void handleManiaAddon(dynamic screen, String text) {
    screen.addUserMessage(text);
    //screen.mood['confidence'] = mapConfidence(text);

    screen.mood['confidence'] = mapByIndex(
      screen.i18n.t('addon_mania_q1'),
      [
        screen.i18n.t('mood_opt_confidence_none'),
        screen.i18n.t('mood_opt_confidence_slight'),
        screen.i18n.t('mood_opt_confidence_moderate'),
        screen.i18n.t('mood_opt_confidence_extreme'),
      ],
    );

    screen.phase = ChatPhase.maniaAddon2;
    /*screen.addBotMessage(
      'Did you take risks or spend more than usual?',
      quickReplies: ['No', 'Slightly', 'Moderately', 'A lot'],
    );*/

    screen.addBotMessage(
      screen.i18n.t('addon_mania_q2'),
      quickReplies: [
        screen.i18n.t('mood_opt_none'),
        screen.i18n.t('mood_opt_slight'),
        screen.i18n.t('mood_opt_moderate'),
        screen.i18n.t('mood_opt_a_lot'),
      ].cast<String>(),
    );
    screen.setState(() {});
  }

  static Future<void> handleManiaAddon2(dynamic screen, String text) async {
    screen.addUserMessage(text);
    //screen.mood['risk_taking'] = mapImpulsivity(text);

    screen.mood['risk_taking'] = mapByIndex(
      text,
      [
        screen.i18n.t('mood_opt_none'),
        screen.i18n.t('mood_opt_slight'),
        screen.i18n.t('mood_opt_moderate'),
        screen.i18n.t('mood_opt_a_lot'),
      ],
    );

    screen.impulsivityScore = screen.mood['risk_taking'];

    await _finishMoodFlow(screen); // 🔥 THIS WAS MISSING
    screen.setState(() {});
  }

  static Future<void> handleSafetyCheck(dynamic screen, String text) async {
    screen.addUserMessage(text);
    //screen.mood['self_harm_thoughts'] = mapSelfHarmThoughts(text);

    screen.mood['self_harm_thoughts'] = mapByIndex(
      text,
      [
        screen.i18n.t('safety_no'),
        screen.i18n.t('safety_brief'),
        screen.i18n.t('safety_strong'),
        screen.i18n.t('safety_prefer_not'),
      ],
    );

    await _finishMoodFlow(screen);
    screen.setState(() {});
  }

  static bool _finishing = false;

  static Future<void> _finishMoodFlow(dynamic screen) async {
    if (_finishing) return;
    _finishing = true;

    final result = interpretMood(screen.mood, screen.i18n);

    screen.addBotMessage(result.summary);
    if (result.interpretation.isNotEmpty) {
      screen.addBotMessage(result.interpretation);
    }

    screen.moodCapturedToday = true;

    await screen.submitMood();

    screen.phase = ChatPhase.idle;
    screen.activeFlow = ActiveFlow.none;

    _finishing = false;
    screen.setState(() {});
  }

  static MoodResult interpretMood(
    Map<String, int> moodAnswers,
    dynamic i18n,
  ) {
    final mood = moodAnswers['overall_mood'] ?? 3;
    final energy = moodAnswers['energy_level'] ?? 3;
    final sleepChange = moodAnswers['sleep_change'] ?? 2;
    final thoughtSpeed = moodAnswers['thought_speed'] ?? 2;
    final confidence = moodAnswers['confidence'] ?? 1;
    final risk = moodAnswers['risk_taking'] ?? 1;

    String summary;
    String interpretation;

    // 🔴 MANIA / HYPOMANIA
    if ((mood >= 4 || energy >= 4) &&
        sleepChange >= 3 &&
        (thoughtSpeed >= 3 || confidence >= 3 || risk >= 3)) {
      summary = i18n.t('mood_result_mania_summary');
      interpretation = i18n.t('mood_result_mania_text');
    }

    // 🔵 DEPRESSION
    else if (mood <= 2 && energy <= 2 && sleepChange == 1) {
      summary = i18n.t('mood_result_depression_summary');
      interpretation = i18n.t('mood_result_depression_text');
    }

    // 🟢 STABLE
    else {
      summary = i18n.t('mood_result_stable_summary');
      interpretation = i18n.t('mood_result_stable_text');
    }

    return MoodResult(summary, interpretation);
  }

  static int mapByIndex(
    String text,
    List<String> options, {
    bool invert = false,
  }) {
    final index = options.indexOf(text);
    if (index == -1) return invert ? options.length : 1;
    return invert ? options.length - index : index + 1;
  }
}
