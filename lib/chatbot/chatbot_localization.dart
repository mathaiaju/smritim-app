import 'chatbot_state.dart';

class ChatbotLocalization {
  final BotLanguage language;

  ChatbotLocalization(this.language);

  /* =====================================================
     LOCALIZED STRINGS
  ===================================================== */

  Map<String, String> _en = {
    'assistant': 'Medication Assistant',
    'no_pending':
        'You have no pending medicines right now 😊\n\nYou can ask me questions about your treatment.',
    'taken_yes': 'Great 👍 I’ve marked it as taken.',
    'taken_no': 'Okay, I’ve noted that you missed it.',
    'discomfort': 'Did you experience any discomfort today?',
    'glad': 'Glad to hear that 😊',
    'select_symptoms': 'Please select any symptoms you experienced:',
    'recorded': 'Thank you. I’ve recorded these responses 💙',
    'block1': '⚠️ Important safety alert',
    'block2':
        'Please do not take further doses until your clinician contacts you.',
    'yes': 'Yes',
    'no': 'No',
    'submit': 'Submit',
    'other': 'Other (type)',
    'type': 'Type your message...',
    'select': 'Select an option above',
    'med_taken_q_prefix': 'Have you taken',
    'med_taken_q_suffix': 'as scheduled?',
    'scheduled': 'scheduled',
    // 🧠 Mood
    'mood_intro': 'Let’s quickly check how you’ve been feeling today.',
    'mood_q1': 'How has your overall mood been today?',
    'mood_q2': 'How was your energy level today?',
    'mood_q3': 'How much did you sleep last night compared to usual?',
    'mood_q4': 'How fast were your thoughts today?',
    'mood_q5':
        'Did you feel more talkative, impulsive, or driven than usual today?',
    'mood_q6': 'How well did you manage your usual daily activities today?',

    // 😴 Sleep
    'sleep_intro': 'Now let’s talk a little about your sleep.',
    'survey_done': 'Thank you 🙏 Your responses have been recorded.',

    'sleep_start': 'How would you rate your sleep quality last night?',
    'sleep_q1': 'How long did it take you to fall asleep?',
    'sleep_q2': 'How often did you wake up during the night?',
    'sleep_q3': 'How many hours did you sleep?',
    'sleep_q4': 'How refreshed did you feel on waking?',
    'sleep_q5': 'Did poor sleep affect your daytime functioning?',

    'sleep_opt_very_poor': '😴 Very poor',
    'sleep_opt_poor': '😕 Poor',
    'sleep_opt_fair': '😐 Fair',
    'sleep_opt_good': '🙂 Good',
    'sleep_opt_very_good': '😃 Very good',

    'sleep_result_excellent': 'Excellent sleep ⭐⭐⭐⭐⭐',
    'sleep_result_good': 'Good sleep ⭐⭐⭐⭐☆',
    'sleep_result_poor': 'Poor sleep ⭐⭐☆☆☆',
    'sleep_result_very_poor': 'Very poor sleep ⭐☆☆☆☆',

    'sleep_tip_excellent': 'Keep up your healthy sleep habits.',
    'sleep_tip_good': 'Try maintaining a consistent sleep schedule.',
    'sleep_tip_poor': 'Try limiting screen use at least 1 hour before bedtime.',
    'sleep_tip_very_poor':
        'Consider discussing these sleep problems with your doctor.',

    // 😴 Sleep – Options
    'sleep_onset_fast': '<15 minutes',
    'sleep_onset_medium': '15–30 minutes',
    'sleep_onset_slow': '30–60 minutes',
    'sleep_onset_very_slow': 'More than 60 minutes',

    'sleep_maint_none': 'Did not wake up',
    'sleep_maint_few': '1–2 times',
    'sleep_maint_some': '3–4 times',
    'sleep_maint_many': '5 or more times',

    'sleep_duration_long': '7 hours or more',
    'sleep_duration_ok': '6–7 hours',
    'sleep_duration_short': '5–6 hours',
    'sleep_duration_very_short': 'Less than 5 hours',

    'sleep_rest_very_good': 'Very refreshed',
    'sleep_rest_good': 'Somewhat refreshed',
    'sleep_rest_poor': 'Slightly tired',
    'sleep_rest_very_poor': 'Very tired',

    'sleep_impact_none': 'Not at all',
    'sleep_impact_mild': 'Mildly',
    'sleep_impact_moderate': 'Moderately',
    'sleep_impact_severe': 'Severely',

    // 🙂 Mood Flow (Core)
    'mood_start': 'How has your mood been today?',
    'mood_energy': 'How was your energy level today?',
    'mood_sleep_change': 'How much did you sleep compared to your usual?',
    'mood_thought_speed': 'How fast were your thoughts today?',
    'mood_impulsivity':
        'Did you feel more talkative, impulsive, or driven than usual today?',
    'mood_functioning':
        'How well did you manage your usual daily activities today?',

    // 📊 Mood Options
    'mood_opt_very_low': 'Very low',
    'mood_opt_low': 'Low',
    'mood_opt_okay': 'Balanced / okay',
    'mood_opt_high': 'High',
    'mood_opt_very_high': 'Very high',

    'mood_opt_energy_very_low': 'Very low',
    'mood_opt_energy_slight_low': 'Slightly low',
    'mood_opt_energy_normal': 'Normal',
    'mood_opt_energy_high': 'Higher than usual',
    'mood_opt_energy_very_high': 'Much higher than usual',

    'mood_opt_sleep_more': 'More than usual',
    'mood_opt_sleep_same': 'About usual',
    'mood_opt_sleep_less': 'Slightly less than usual',
    'mood_opt_sleep_much_less': 'Much less than usual',

    'mood_opt_thought_slow': 'Slower than usual',
    'mood_opt_thought_normal': 'Normal',
    'mood_opt_thought_fast': 'A bit fast',
    'mood_opt_thought_racing': 'Very fast / racing',

    'mood_opt_none': 'No',
    'mood_opt_slight': 'Slightly',
    'mood_opt_moderate': 'Moderately',
    'mood_opt_a_lot': 'A lot',

    'mood_opt_confidence_none': 'No',
    'mood_opt_confidence_slight': 'Slightly',
    'mood_opt_confidence_moderate': 'Moderately',
    'mood_opt_confidence_extreme': 'Extremely',

    'mood_opt_function_very_poor': 'Very poorly',
    'mood_opt_function_poor': 'Poorly',
    'mood_opt_function_okay': 'Okay',
    'mood_opt_function_well': 'Well',
    'mood_opt_function_very_well': 'Very well',

    // ➕ Depression Add-on
    'addon_depression_q1':
        'Did you feel hopeless or uninterested in things today?',
    'addon_depression_q2': 'Did you feel slowed down or exhausted today?',

    'mood_opt_not_at_all': 'Not at all',
    'mood_opt_a_little': 'A little',
    'mood_opt_quite_bit': 'Quite a bit',
    'mood_opt_most_day': 'Most of the day',

    'mood_opt_slow_no': 'No',
    'mood_opt_slow_slight': 'Slightly',
    'mood_opt_slow_moderate': 'Moderately',
    'mood_opt_slow_severe': 'Severely',

    // ⚡ Mania Add-on

    'addon_mania_q2': 'Did you take risks or spend more than usual today?',

    'mood_result_mania_summary': 'Higher energy + reduced sleep detected',
    'mood_result_mania_text':
        'Your energy has been higher with less sleep and increased activity. Monitor patterns and consider discussing with your clinician.',

    'mood_result_depression_summary': 'Lower mood + reduced functioning',
    'mood_result_depression_text':
        'Your mood and energy have been lower, with increased sleep.',

    'mood_result_stable_summary': 'Balanced mood and energy levels',
    'mood_result_stable_text':
        'You seem to be in a stable phase. Keep up the good work!',

    "mood_depression_q":
        "Did you feel hopeless or uninterested in things today?",
    "mood_depression_0": "Not at all",
    "mood_depression_1": "A little",
    "mood_depression_2": "Quite a bit",
    "mood_depression_3": "Most of the day",

    "addon_mania_q1": "Did you feel unusually confident or invincible today?",
    "mood_mania_0": "No",
    "mood_mania_1": "Slightly",
    "mood_mania_2": "Moderately",
    "mood_mania_3": "Extremely",

    // 🛡 Safety Check
    "mood_safety_q": "Did you have thoughts about harming yourself today?",
    "mood_safety_0": "No",
    "mood_safety_1": "Brief thoughts, no intent",
    "mood_safety_2": "Strong thoughts",
    "mood_safety_3": "Prefer not to answer",
  };

  Map<String, String> _ml = {
    'assistant': 'മരുന്ന് സഹായകൻ',
    'no_pending':
        'ഇപ്പോൾ എടുക്കാനുള്ള മരുന്നുകളൊന്നുമില്ല 😊\n\nനിങ്ങളുടെ ചികിത്സയെക്കുറിച്ച് ചോദിക്കാം.',
    'taken_yes': 'നന്നായി 👍 എടുത്തതായി രേഖപ്പെടുത്തി.',
    'taken_no': 'ശരി, എടുത്തില്ലെന്ന് രേഖപ്പെടുത്തി.',
    'discomfort': 'ഇന്ന് എന്തെങ്കിലും അസ്വസ്ഥത അനുഭവപ്പെട്ടോ?',
    'glad': 'അത് കേട്ടത് സന്തോഷം 😊',
    'select_symptoms': 'നിങ്ങൾക്ക് അനുഭവപ്പെട്ട ലക്ഷണങ്ങൾ തിരഞ്ഞെടുക്കുക:',
    'recorded': 'നന്ദി. ലക്ഷണങ്ങൾ രേഖപ്പെടുത്തി 💙',
    'block1': '⚠️ പ്രധാന സുരക്ഷാ മുന്നറിയിപ്പ്',
    'block2': 'ഡോക്ടർ ബന്ധപ്പെടുന്നതുവരെ കൂടുതൽ മരുന്ന് കഴിക്കരുത്.',
    'yes': 'അതെ',
    'no': 'ഇല്ല',
    'submit': 'സമർപ്പിക്കുക',
    'other': 'മറ്റുള്ളത് (ടൈപ്പ് ചെയ്യുക)',
    'type': 'സന്ദേശം ടൈപ്പ് ചെയ്യുക...',
    'select': 'മുകളിലെ ഓപ്ഷൻ തിരഞ്ഞെടുക്കുക',

    'med_taken_q_prefix_ml': 'നിങ്ങൾ മരുന്ന് എടുത്തോ',
    'med_taken_q_suffix_ml': 'നിശ്ചയിച്ച സമയത്ത്?',
    'scheduled_ml': 'നിശ്ചയിച്ചത്',

    // 🧠 Mood
    'mood_intro': 'ഇന്ന് നിങ്ങള്‍ക്ക് എങ്ങനെ തോന്നുന്നു എന്ന് ചെറുതായി അറിയാം.',
    'mood_q1': 'ഇന്ന് നിങ്ങളുടെ മാനസികാവസ്ഥ എങ്ങനെ ആയിരുന്നു?',
    'mood_q2': 'ഇന്ന് നിങ്ങളുടെ ഊര്‍ജ്ജനില എങ്ങനെയായിരുന്നു?',
    'mood_q3': 'ഇന്നലെ രാത്രി നിങ്ങള്‍ എത്ര ഉറങ്ങി?',
    'mood_q4': 'ഇന്ന് നിങ്ങളുടെ ചിന്തകള്‍ എത്ര വേഗത്തിലായിരുന്നു?',
    'mood_q5':
        'ഇന്ന് നിങ്ങള്‍ക്ക് സാധാരണയേക്കാള്‍ അധികം സംസാരിക്കാനോ ആവേശമോ തോന്നിയോ?',
    'mood_q6': 'ഇന്ന് നിങ്ങളുടെ ദിനചര്യ എത്രമാത്രം കൈകാര്യം ചെയ്തു?',

    // 😴 Sleep
    'sleep_intro': 'ഇപ്പോള്‍ ഉറക്കത്തെക്കുറിച്ച് കുറച്ച് ചോദ്യങ്ങള്‍.',
    'survey_done': 'നന്ദി 🙏 നിങ്ങളുടെ മറുപടികള്‍ സൂക്ഷിച്ചിരിക്കുന്നു.',

    'sleep_start':
        'ഇന്നലെ രാത്രി നിങ്ങളുടെ ഉറക്കത്തിന്റെ ഗുണനിലവാരം എങ്ങനെ ആയിരുന്നു?',
    'sleep_q1': 'നിങ്ങൾക്ക് ഉറങ്ങാൻ എത്ര സമയം എടുത്തു?',
    'sleep_q2': 'രാത്രിയിൽ എത്ര പ്രാവശ്യം നിങ്ങൾ ഉണർന്നു?',
    'sleep_q3': 'നിങ്ങൾ എത്ര മണിക്കൂർ ഉറങ്ങി?',
    'sleep_q4':
        'ഉണർന്നപ്പോൾ നിങ്ങൾ എത്രത്തോളം തഴച്ചതായും വിശ്രമിച്ചതായും അനുഭവപ്പെട്ടു?',
    'sleep_q5': 'ഉറക്കക്കുറവ് നിങ്ങളുടെ ദിവസ പ്രവർത്തനങ്ങളെ ബാധിച്ചോ?',

    'sleep_opt_very_poor': '😴 വളരെ മോശം',
    'sleep_opt_poor': '😕 മോശം',
    'sleep_opt_fair': '😐 ശരാശരി',
    'sleep_opt_good': '🙂 നല്ലത്',
    'sleep_opt_very_good': '😃 വളരെ നല്ലത്',

    'sleep_result_excellent': 'മികച്ച ഉറക്കം ⭐⭐⭐⭐⭐',
    'sleep_result_good': 'നല്ല ഉറക്കം ⭐⭐⭐⭐☆',
    'sleep_result_poor': 'മോശം ഉറക്കം ⭐⭐☆☆☆',
    'sleep_result_very_poor': 'വളരെ മോശം ഉറക്കം ⭐☆☆☆☆',

    'sleep_tip_excellent': 'നിങ്ങളുടെ നല്ല ഉറക്കശീലങ്ങൾ തുടരുക.',
    'sleep_tip_good': 'സ്ഥിരമായ ഉറക്കക്രമം പാലിക്കാൻ ശ്രമിക്കുക.',
    'sleep_tip_poor':
        'ഉറങ്ങുന്നതിന് മുൻപ് സ്ക്രീൻ ഉപയോഗം കുറയ്ക്കാൻ ശ്രമിക്കുക.',
    'sleep_tip_very_poor':
        'ഡോക്ടറുമായി ഈ ഉറക്കപ്രശ്നങ്ങളെ കുറിച്ച് സംസാരിക്കുക.',

    // 😴 Sleep – Options
    'sleep_onset_fast': '15 മിനിറ്റിനകം',
    'sleep_onset_medium': '15–30 മിനിറ്റ്',
    'sleep_onset_slow': '30–60 മിനിറ്റ്',
    'sleep_onset_very_slow': '60 മിനിറ്റിൽ കൂടുതൽ',

    'sleep_maint_none': 'ഉണർന്നില്ല',
    'sleep_maint_few': '1–2 പ്രാവശ്യം',
    'sleep_maint_some': '3–4 പ്രാവശ്യം',
    'sleep_maint_many': '5 പ്രാവശ്യം അല്ലെങ്കിൽ കൂടുതൽ',

    'sleep_duration_long': '7 മണിക്കൂർ അല്ലെങ്കിൽ കൂടുതൽ',
    'sleep_duration_ok': '6–7 മണിക്കൂർ',
    'sleep_duration_short': '5–6 മണിക്കൂർ',
    'sleep_duration_very_short': '5 മണിക്കൂറിൽ കുറവ്',

    'sleep_rest_very_good': 'വളരെ തഴച്ചതായി',
    'sleep_rest_good': 'ഒരളവ് തഴച്ചതായി',
    'sleep_rest_poor': 'അൽപ്പം ക്ഷീണം',
    'sleep_rest_very_poor': 'വളരെ ക്ഷീണം',

    'sleep_impact_none': 'ഒട്ടും ഇല്ല',
    'sleep_impact_mild': 'ലഘുവായി',
    'sleep_impact_moderate': 'മിതമായി',
    'sleep_impact_severe': 'കഠിനമായി',

    // 🙂 Mood Flow (Core)
    'mood_start': 'ഇന്ന് നിങ്ങളുടെ മനോഭാവം എങ്ങനെ ആയിരുന്നു?',
    'mood_energy': 'ഇന്ന് നിങ്ങളുടെ ഊർജ്ജനില എങ്ങനെ ആയിരുന്നു?',
    'mood_sleep_change': 'ഇന്നലെ നിങ്ങൾ സാധാരണയേക്കാൾ എത്ര ഉറങ്ങി?',
    'mood_thought_speed': 'ഇന്ന് നിങ്ങളുടെ ചിന്തകളുടെ വേഗത എങ്ങനെ ആയിരുന്നു?',
    'mood_impulsivity':
        'ഇന്ന് നിങ്ങൾ സാധാരണയേക്കാൾ കൂടുതൽ സംസാരിക്കുന്നതോ ആവേശത്തോടെയോ ആയിരുന്നോ?',
    'mood_functioning':
        'ഇന്ന് നിങ്ങളുടെ ദൈനംദിന പ്രവർത്തനങ്ങൾ എങ്ങനെ കൈകാര്യം ചെയ്തു?',

    // 📊 Mood Options
    'mood_opt_very_low': 'വളരെ കുറവ്',
    'mood_opt_low': 'കുറവ്',
    'mood_opt_okay': 'സാധാരണ / ശരാശരി',
    'mood_opt_high': 'കൂടുതൽ',
    'mood_opt_very_high': 'വളരെ കൂടുതൽ',

    'mood_opt_confidence_none': 'ഇല്ല',
    'mood_opt_confidence_slight': 'സ്വൽപം',
    'mood_opt_confidence_moderate': 'മിതമായി',
    'mood_opt_confidence_extreme': 'അത്യധികമായി',

    'mood_opt_energy_very_low': 'വളരെ കുറവ്',
    'mood_opt_energy_slight_low': 'അൽപ്പം കുറവ്',
    'mood_opt_energy_normal': 'സാധാരണ',
    'mood_opt_energy_high': 'സാധാരണയേക്കാൾ കൂടുതൽ',
    'mood_opt_energy_very_high': 'വളരെ കൂടുതൽ',

    'mood_opt_sleep_more': 'സാധാരണയേക്കാൾ കൂടുതൽ',
    'mood_opt_sleep_same': 'സാധാരണ പോലെ',
    'mood_opt_sleep_less': 'അൽപ്പം കുറവ്',
    'mood_opt_sleep_much_less': 'വളരെ കുറവ്',

    'mood_opt_thought_slow': 'സാധാരണയേക്കാൾ മന്ദം',
    'mood_opt_thought_normal': 'സാധാരണ',
    'mood_opt_thought_fast': 'അൽപ്പം വേഗം',
    'mood_opt_thought_racing': 'വളരെ വേഗം',

    'mood_opt_none': 'ഇല്ല',
    'mood_opt_slight': 'അൽപ്പം',
    'mood_opt_moderate': 'മിതമായ',
    'mood_opt_a_lot': 'വളരെ കൂടുതലായി',

    'mood_opt_function_very_poor': 'വളരെ മോശം',
    'mood_opt_function_poor': 'മോശം',
    'mood_opt_function_okay': 'ശരി',
    'mood_opt_function_well': 'നന്നായി',
    'mood_opt_function_very_well': 'വളരെ നന്നായി',

    // ➕ Depression Add-on
    'addon_depression_q1':
        'ഇന്ന് നിങ്ങൾക്ക് നിരാശയോ കാര്യങ്ങളോട് താൽപര്യം കുറവോ ഉണ്ടായിരുന്നോ?',
    'addon_depression_q2': 'ഇന്ന് നിങ്ങൾക്ക് ക്ഷീണമോ മന്ദഗതിയോ അനുഭവപ്പെട്ടോ?',

    'mood_opt_not_at_all': 'ഒട്ടും ഇല്ല',
    'mood_opt_a_little': 'അൽപ്പം',
    'mood_opt_quite_bit': 'കുറച്ച് കൂടുതലായി',
    'mood_opt_most_day': 'ദിവസം മുഴുവൻ',

    'mood_opt_slow_no': 'ഇല്ല',
    'mood_opt_slow_slight': 'അൽപ്പം',
    'mood_opt_slow_moderate': 'മിതമായി',
    'mood_opt_slow_severe': 'വളരെ കൂടുതലായി',

    // ⚡ Mania Add-on
    'addon_mania_q1':
        'ഇന്ന് നിങ്ങൾ അസാധാരണമായ ആത്മവിശ്വാസമോ അതിരുകടന്ന ആത്മവിശ്വാസമോ അനുഭവിച്ചോ?',
    'addon_mania_q2':
        'ഇന്ന് നിങ്ങൾ സാധാരണയേക്കാൾ അപകടകരമായ തീരുമാനങ്ങൾ എടുത്തോ അല്ലെങ്കിൽ കൂടുതൽ ചെലവഴിച്ചോ?',

    'mood_result_mania_summary': 'ഉയർന്ന ഊർജവും കുറഞ്ഞ ഉറക്കവും കണ്ടെത്തി',
    'mood_result_mania_text':
        'കുറഞ്ഞ ഉറക്കത്തോടൊപ്പം ഉയർന്ന ഊർജവും പ്രവർത്തനവും ഉണ്ടായതായി തോന്നുന്നു. ഈ മാതൃകകൾ ശ്രദ്ധിക്കുകയും ഡോക്ടറുമായി സംസാരിക്കുകയും ചെയ്യുക.',

    'mood_result_depression_summary': 'കുറഞ്ഞ മാനസികാവസ്ഥയും പ്രവർത്തനക്ഷമതയും',
    'mood_result_depression_text':
        'മാനസികാവസ്ഥയും ഊർജവും കുറഞ്ഞതും ഉറക്കം കൂടുതലായതും ശ്രദ്ധയിൽപ്പെട്ടു.',

    'mood_result_stable_summary': 'സമതുലിതമായ മാനസികാവസ്ഥയും ഊർജവും',
    'mood_result_stable_text':
        'നിങ്ങൾ ഒരു സ്ഥിരമായ ഘട്ടത്തിലാണ്. നല്ല രീതിയിൽ തുടരുക!',

    "mood_depression_q":
        "ഇന്ന് നിങ്ങള്‍ക്ക് പ്രതീക്ഷയില്ലാതെയോ കാര്യങ്ങളിലേക്കുള്ള താത്പര്യം കുറവായോ തോന്നിയുണ്ടോ?",
    "mood_depression_0": "ഒന്നും തോന്നിയില്ല",
    "mood_depression_1": "അൽപം തോന്നി",
    "mood_depression_2": "വളരെ അധികം തോന്നി",
    "mood_depression_3": "ദിവസത്തിന്റെ ഭൂരിഭാഗവും തോന്നി",

    // 🛡 Safety Check
    'mood_safety_q':
        'ഇന്ന് നിങ്ങൾക്ക് സ്വയം കേടുപാടുകൾ ചെയ്യണമെന്നുള്ള ചിന്തകൾ ഉണ്ടായിരുന്നോ?',
    'mood_safety_no': 'ഇല്ല',
    'mood_safety_brief': 'ചുരുങ്ങിയ ചിന്തകൾ, ഉദ്ദേശമില്ല',
    'mood_safety_strong': 'ശക്തമായ ചിന്തകൾ',
    'mood_safety_skip': 'ഉത്തരം നൽകാൻ ഇഷ്ടമില്ല',
    
    "addon_mania_q1": "ഇന്ന് നിങ്ങൾ അസാധാരണമായ ആത്മവിശ്വാസമോ അതിരുകടന്ന ആത്മവിശ്വാസമോ അനുഭവിച്ചോ?",
    "mood_mania_0": "ഇല്ല",
    "mood_mania_1": "സ്വൽപം",
    "mood_mania_2": "മിതമായി",
    "mood_mania_3": "അത്യധികമായി",
    
    'mood_safety_prefer_not': 'ഉത്തരം നൽകാൻ ഇഷ്ടമില്ല',
  };

  String t(String key) {
    return language == BotLanguage.en ? _en[key] ?? key : _ml[key] ?? key;
  }
}
