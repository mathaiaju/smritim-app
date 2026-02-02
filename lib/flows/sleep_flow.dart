import 'dart:developer';
import 'package:smritim_app/flows/mood_flow.dart';

import '../chatbot/chatbot_state.dart';

class SleepResult {
  final String titleKey;
  final String tipKey;

  SleepResult(this.titleKey, this.tipKey);
}

class SleepFlow {
  static void start(dynamic screen) {
    log('🛌 SleepFlow.start()');

    screen.sleep.clear();

    // 🔑 ENTER SLEEP FLOW
    screen.activeFlow = ActiveFlow.sleep;
    screen.phase = ChatPhase.sleepStart;

    /*screen.addBotMessage(
      'How would you rate your sleep quality?',
      quickReplies: [
        '😴 Very poor',
        '😕 Poor',
        '😐 Fair',
        '🙂 Good',
        '😃 Very good',
      ],
    );*/

    screen.addBotMessage(
      screen.i18n.t('sleep_start'),
      quickReplies: [
        screen.i18n.t('sleep_opt_very_poor'),
        screen.i18n.t('sleep_opt_poor'),
        screen.i18n.t('sleep_opt_fair'),
        screen.i18n.t('sleep_opt_good'),
        screen.i18n.t('sleep_opt_very_good'),
      ].cast<String>(),
    );

    screen.setState(() {});
  }

  static void handleSleepStart(dynamic screen, String text) {
    screen.addUserMessage(text);

    screen.sleep['quality'] = mapSleepQuality(text, screen);
    screen.sleepQualityScore = screen.sleep['quality'];

    screen.phase = ChatPhase.sleepQ1;

    /*screen.addBotMessage(
      'How long did it take you to fall asleep?',
      quickReplies: onsetOptions(screen),
    );*/

    screen.addBotMessage(
      screen.i18n.t('sleep_q1'),
      quickReplies: onsetOptions(screen),
    );

    screen.setState(() {});
  }

  static void handleSleepQ1(dynamic screen, String text) {
    screen.addUserMessage(text);

    screen.sleep['onset'] = mapSleepOnset(text, screen);
    screen.phase = ChatPhase.sleepQ2;

    /*screen.addBotMessage(
      'How often did you wake up during the night?',
      quickReplies: maintenanceOptions(screen),
    );*/

    screen.addBotMessage(
      screen.i18n.t('sleep_q2'),
      quickReplies: maintenanceOptions(screen),
    );

    screen.setState(() {});
  }

  static void handleSleepQ2(dynamic screen, String text) {
    screen.addUserMessage(text);

    screen.sleep['maintenance'] = mapSleepMaintenance(text, screen);
    screen.phase = ChatPhase.sleepQ3;

    /*screen.addBotMessage(
      'How many hours did you sleep?',
      quickReplies: durationOptions(screen),
    );*/

    screen.addBotMessage(
      screen.i18n.t('sleep_q3'),
      quickReplies: durationOptions(screen),
    );

    screen.setState(() {});
  }

  static void handleSleepQ3(dynamic screen, String text) {
    screen.addUserMessage(text);

    screen.sleep['duration'] = mapSleepDuration(text, screen);
    screen.phase = ChatPhase.sleepQ4;

    /*screen.addBotMessage(
      'How refreshed did you feel on waking?',
      quickReplies: restfulnessOptions(screen),
    );*/

    screen.addBotMessage(
      screen.i18n.t('sleep_q4'),
      quickReplies: restfulnessOptions(screen),
    );

    screen.setState(() {});
  }

  static void handleSleepQ4(dynamic screen, String text) {
    screen.addUserMessage(text);

    screen.sleep['restfulness'] = mapSleepRestfulness(text, screen);
    screen.phase = ChatPhase.sleepQ5;

    /*screen.addBotMessage(
      'Did poor sleep affect your daytime functioning?',
      quickReplies: daytimeImpactOptions(screen),
    );*/

    screen.addBotMessage(
      screen.i18n.t('sleep_q5'),
      quickReplies: daytimeImpactOptions(screen),
    );

    screen.setState(() {});
  }

  static Future<void> handleSleepQ5(dynamic screen, String text) async {
    print("🔥 ENTERED handleSleepQ5");
    screen.addUserMessage(text);

    screen.sleep['daytime_impact'] = mapDaytimeImpact(text, screen);

    final result = calculateScore(screen);

    screen.addBotMessage('Sleep Quality: ${result.titleKey}');
    screen.addBotMessage('Tip: ${result.tipKey}');

    // ────────────── Critical ──────────────
    screen.sleepCapturedToday = true;
    screen.activeFlow = ActiveFlow.none;
    screen.setState(() {});

// 🔥 DIRECT orchestration (no routing)
    screen.replyHandler.submitSleep();

    if (!screen.moodCapturedToday) {
      MoodFlow.start(screen);
    }
  }

  static SleepResult calculateScore(screen) {
    Map<String, int> sleepAnswers = screen.sleep;
    final totalScore = sleepAnswers.values.fold(0, (sum, score) => sum + score);

    if (totalScore >= 17) {
      /*return SleepResult(
        'Excellent sleep ⭐⭐⭐⭐⭐',
        'Great job maintaining healthy sleep habits.',
      );*/
      return SleepResult(
        screen.i18n.t('sleep_result_excellent'),
        screen.i18n.t('sleep_tip_excellent'),
      );
    } else if (totalScore >= 13) {
      /*return SleepResult(
        'Good sleep ⭐⭐⭐⭐☆',
        'You slept fairly well. Maintain consistency.',
      );*/
      return SleepResult(
        screen.i18n.t('sleep_result_good'),
        screen.i18n.t('sleep_tip_good'),
      );
    } else if (totalScore >= 9) {
      /*return SleepResult(
        'Poor sleep ⭐⭐☆☆☆',
        'Try improving bedtime routines and reducing screen exposure.',
      );*/
      return SleepResult(
        screen.i18n.t('sleep_result_poor'),
        screen.i18n.t('sleep_tip_poor'),
      );
    } else {
      /*return SleepResult(
        'Very poor sleep ⭐☆☆☆☆',
        'Consider discussing sleep concerns with your clinician.',
      );*/
      return SleepResult(
        'sleep_result_very_poor',
        'sleep_tip_very_poor',
      );
    }
  }

  // ───────── OPTIONS (LOCALIZED) ─────────

  static List<String> onsetOptions(dynamic screen) => [
        screen.i18n.t('sleep_onset_fast'),
        screen.i18n.t('sleep_onset_medium'),
        screen.i18n.t('sleep_onset_slow'),
        screen.i18n.t('sleep_onset_very_slow'),
      ];

  static List<String> maintenanceOptions(dynamic screen) => [
        screen.i18n.t('sleep_maint_none'),
        screen.i18n.t('sleep_maint_few'),
        screen.i18n.t('sleep_maint_some'),
        screen.i18n.t('sleep_maint_many'),
      ];

  static List<String> durationOptions(dynamic screen) => [
        screen.i18n.t('sleep_duration_long'),
        screen.i18n.t('sleep_duration_ok'),
        screen.i18n.t('sleep_duration_short'),
        screen.i18n.t('sleep_duration_very_short'),
      ];

  static List<String> restfulnessOptions(dynamic screen) => [
        screen.i18n.t('sleep_rest_very_good'),
        screen.i18n.t('sleep_rest_good'),
        screen.i18n.t('sleep_rest_poor'),
        screen.i18n.t('sleep_rest_very_poor'),
      ];

  static List<String> daytimeImpactOptions(dynamic screen) => [
        screen.i18n.t('sleep_impact_none'),
        screen.i18n.t('sleep_impact_mild'),
        screen.i18n.t('sleep_impact_moderate'),
        screen.i18n.t('sleep_impact_severe'),
      ];

// ───────── MAPPING (INDEX-BASED, LANGUAGE SAFE) ─────────

  static int mapSleepQuality(String text, dynamic screen) {
    final options = [
      screen.i18n.t('sleep_opt_very_poor'),
      screen.i18n.t('sleep_opt_poor'),
      screen.i18n.t('sleep_opt_fair'),
      screen.i18n.t('sleep_opt_good'),
      screen.i18n.t('sleep_opt_very_good'),
    ];
    final index = options.indexOf(text);
    return index == -1 ? 1 : index + 1; // 1–5
  }

  static int mapSleepOnset(String text, dynamic screen) {
    final index = onsetOptions(screen).indexOf(text);
    return index == -1 ? 1 : 4 - index;
  }

  static int mapSleepMaintenance(String text, dynamic screen) {
    final index = maintenanceOptions(screen).indexOf(text);
    return index == -1 ? 1 : 4 - index;
  }

  static int mapSleepDuration(String text, dynamic screen) {
    final index = durationOptions(screen).indexOf(text);
    return index == -1 ? 1 : 4 - index;
  }

  static int mapSleepRestfulness(String text, dynamic screen) {
    final index = restfulnessOptions(screen).indexOf(text);
    return index == -1 ? 1 : 4 - index;
  }

  static int mapDaytimeImpact(String text, dynamic screen) {
    final index = daytimeImpactOptions(screen).indexOf(text);
    return index == -1 ? 1 : 4 - index;
  }
}
