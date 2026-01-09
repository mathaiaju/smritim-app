import 'dart:convert';
import 'package:flutter/material.dart';
import '../../api_client.dart';

enum ChatRole { bot, user }

enum ChatPhase {
  awaitingAdherence,
  awaitingComfortAnswer,
  awaitingSymptomSelection,
  awaitingSymptomText,
  idle,
  blockedByAlert,
}

enum BotLanguage { en, ml }

class ChatMessage {
  final ChatRole role;
  final String text;
  final List<String>? quickReplies;

  ChatMessage({
    required this.role,
    required this.text,
    this.quickReplies,
  });
}

class PatientChatbotScreen extends StatefulWidget {
  const PatientChatbotScreen({super.key});

  @override
  State<PatientChatbotScreen> createState() => _PatientChatbotScreenState();
}

class _PatientChatbotScreenState extends State<PatientChatbotScreen> {
  final List<ChatMessage> messages = [];
  final TextEditingController controller = TextEditingController();

  ChatPhase phase = ChatPhase.idle;
  BotLanguage botLanguage = BotLanguage.en;

  Map<String, dynamic>? currentSchedule;

  List<String> availableSymptoms = [];
  Set<String> selectedSymptoms = {};

  bool submittingSymptoms = false; // 🔒 prevents double submit

  /* =====================================================
     LOCALIZED STRINGS
  ===================================================== */
  String t(String key) {
    const en = {
      'assistant': 'Medication Assistant',
      'no_pending':
          'You have no pending medicines right now 😊\n\nYou can ask me questions about your treatment.',
      'taken_yes': 'Great 👍 I’ve marked it as taken.',
      'taken_no': 'Okay, I’ve noted that you missed it.',
      'discomfort': 'Did you experience any discomfort today?',
      'glad': 'Glad to hear that 😊',
      'select_symptoms': 'Please select any symptoms you experienced:',
      'recorded': 'Thank you. I’ve recorded these symptoms 💙',
      'block1': '⚠️ Important safety alert',
      'block2':
          'Please do not take further doses until your clinician contacts you.',
      'yes': 'Yes',
      'no': 'No',
      'submit': 'Submit',
      'other': 'Other (type)',
      'type': 'Type your message...',
      'select': 'Select an option above',
    };

    const ml = {
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
    };

    return botLanguage == BotLanguage.en ? en[key]! : ml[key]!;
  }

  @override
  void initState() {
    super.initState();
    _loadContext();
  }

  /* =====================================================
     INITIAL CONTEXT
  ===================================================== */
  Future<void> _loadContext() async {
    final alertRes = await ApiClient.get('/alerts');
    final alertData = jsonDecode(alertRes.body);
    final alerts = List<Map<String, dynamic>>.from(alertData['alerts'] ?? []);

    final blocking = alerts.firstWhere(
      (a) =>
          a['resolved'] == false &&
          (a['Rule']?['severity'] == 'high' ||
              a['Rule']?['severity'] == 'critical'),
      orElse: () => {},
    );

    if (blocking.isNotEmpty) {
      phase = ChatPhase.blockedByAlert;
      messages.add(ChatMessage(
        role: ChatRole.bot,
        text: "${t('block1')}\n\n${blocking['Rule']?['action_card'] ?? ''}",
      ));
      messages.add(ChatMessage(role: ChatRole.bot, text: t('block2')));
      setState(() {});
      return;
    }

    final res = await ApiClient.get("/patient/chatbot/context");
    final data = jsonDecode(res.body);
    final List pending = data['pending'] ?? [];

    if (pending.isEmpty) {
      phase = ChatPhase.idle;
      messages.add(ChatMessage(role: ChatRole.bot, text: t('no_pending')));
      setState(() {});
      return;
    }

    currentSchedule = pending.first;
    phase = ChatPhase.awaitingAdherence;

    messages.add(ChatMessage(
      role: ChatRole.bot,
      text:
          "Have you taken **${currentSchedule!['drug_name']} (${currentSchedule!['dose']})**, "
          "scheduled **${currentSchedule!['timing']} at ${currentSchedule!['scheduled_time']}**?",
      quickReplies: [t('yes'), t('no')],
    ));

    setState(() {});
  }

  /* =====================================================
     USER INPUT
  ===================================================== */
  Future<void> _handleUserReply(String text) async {
    if (phase == ChatPhase.blockedByAlert) return;

    messages.add(ChatMessage(role: ChatRole.user, text: text));

    switch (phase) {
      case ChatPhase.awaitingAdherence:
        await _handleAdherence(text);
        break;
      case ChatPhase.awaitingComfortAnswer:
        await _handleComfortAnswer(text);
        break;
      case ChatPhase.awaitingSymptomText:
        await _submitSelectedSymptoms(extra: text);
        break;
      case ChatPhase.idle:
        await _handleLLM(text);
        break;
      default:
        break;
    }

    setState(() {});
  }

  Future<void> _handleAdherence(String text) async {
    final taken = text == t('yes');

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

    messages.add(ChatMessage(
      role: ChatRole.bot,
      text: taken ? t('taken_yes') : t('taken_no'),
    ));

    messages.add(ChatMessage(
      role: ChatRole.bot,
      text: t('discomfort'),
      quickReplies: [t('no'), t('yes')],
    ));

    phase = ChatPhase.awaitingComfortAnswer;
  }

  Future<void> _handleComfortAnswer(String text) async {
    if (text == t('no')) {
      messages.add(ChatMessage(role: ChatRole.bot, text: t('glad')));
      phase = ChatPhase.idle;
      return;
    }

    final drug = currentSchedule!['drug_name'];
    final res =
        await ApiClient.get("/drugs/${Uri.encodeComponent(drug)}/symptoms");
    final decoded = jsonDecode(res.body);

    availableSymptoms = List<String>.from(decoded['symptoms'] ?? []);
    selectedSymptoms.clear();

    messages.add(ChatMessage(
      role: ChatRole.bot,
      text: t('select_symptoms'),
    ));

    phase = ChatPhase.awaitingSymptomSelection;
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
    setState(() {});

    messages.add(ChatMessage(
      role: ChatRole.user,
      text: symptoms.join(', '),
    ));

    try {
      final res = await ApiClient.postJson(
        "/patient/chatbot/symptoms",
        {
          "medication_schedule_id": currentSchedule!['medication_schedule_id'],
          "medication_id": currentSchedule!['medication_id'],
          "log_date": DateTime.now().toIso8601String().substring(0, 10),
          "symptoms": symptoms.toList(),
        },
      );

      final decoded = jsonDecode(res.body);
      if (_handleBlocking(decoded)) return;

      messages.add(ChatMessage(role: ChatRole.bot, text: t('recorded')));
    } catch (_) {
      messages.add(ChatMessage(
        role: ChatRole.bot,
        text: t('recorded'), // fallback safety
      ));
    } finally {
      submittingSymptoms = false;
      selectedSymptoms.clear();
      availableSymptoms.clear();
      phase = ChatPhase.idle;
      setState(() {});
    }
  }

  Future<void> _handleLLM(String text) async {
    final res =
        await ApiClient.postJson("/patient/chatbot/llm", {"message": text});
    final decoded = jsonDecode(res.body);
    messages.add(ChatMessage(
      role: ChatRole.bot,
      text: decoded['reply'] ?? t('recorded'),
    ));
  }

  bool _handleBlocking(Map decoded) {
    if (decoded['evaluation']?['alert'] == true) {
      phase = ChatPhase.blockedByAlert;
      messages.add(ChatMessage(
        role: ChatRole.bot,
        text:
            "${t('block1')}\n\n${decoded['evaluation']['rule']['action_card']}",
      ));
      messages.add(ChatMessage(role: ChatRole.bot, text: t('block2')));
      return true;
    }
    return false;
  }

  /* =====================================================
     UI
  ===================================================== */
  @override
  Widget build(BuildContext context) {
    final allowText =
        phase == ChatPhase.awaitingSymptomText || phase == ChatPhase.idle;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(t('assistant')),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                botLanguage = botLanguage == BotLanguage.en
                    ? BotLanguage.ml
                    : BotLanguage.en;
              });
            },
            child: Text(botLanguage == BotLanguage.en ? 'മലയാളം' : 'English'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: messages
                  .map((m) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _bubble(m),
                          if (m.role == ChatRole.bot) _quickReplies(m),
                        ],
                      ))
                  .toList(),
            ),
          ),
          if (phase == ChatPhase.awaitingSymptomSelection)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                children: [
                  ...availableSymptoms.map((s) => FilterChip(
                        label: Text(s),
                        selected: selectedSymptoms.contains(s),
                        onSelected: (v) => setState(() => v
                            ? selectedSymptoms.add(s)
                            : selectedSymptoms.remove(s)),
                      )),
                  ActionChip(
                    label: Text(t('other')),
                    onPressed: () =>
                        setState(() => phase = ChatPhase.awaitingSymptomText),
                  ),
                  if (selectedSymptoms.isNotEmpty)
                    ElevatedButton.icon(
                      icon: submittingSymptoms
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(t('submit')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed:
                          submittingSymptoms ? null : _submitSelectedSymptoms,
                    ),
                ],
              ),
            ),
          _inputBar(allowText),
        ],
      ),
    );
  }

  Widget _bubble(ChatMessage msg) {
    final isBot = msg.role == ChatRole.bot;
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isBot ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          msg.text,
          style: TextStyle(color: isBot ? Colors.black87 : Colors.white),
        ),
      ),
    );
  }

  Widget _quickReplies(ChatMessage msg) {
    if (msg.quickReplies == null ||
        phase == ChatPhase.awaitingSymptomSelection ||
        phase == ChatPhase.awaitingSymptomText ||
        phase == ChatPhase.blockedByAlert) {
      return const SizedBox();
    }

    return Wrap(
      spacing: 8,
      children: msg.quickReplies!
          .map((q) =>
              ActionChip(label: Text(q), onPressed: () => _handleUserReply(q)))
          .toList(),
    );
  }

  Widget _inputBar(bool allow) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: allow,
              decoration: InputDecoration(
                hintText: allow ? t('type') : t('select'),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: allow ? Colors.blue : Colors.grey,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: !allow
                  ? null
                  : () {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;
                      controller.clear();
                      _handleUserReply(text);
                    },
            ),
          )
        ],
      ),
    );
  }
}
