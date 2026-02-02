import 'package:flutter/material.dart';
import '../../chatbot/chatbot_state.dart';
import '../../chatbot/chatbot_localization.dart';

class ChatbotUIBuilder {
  static Widget build(
    BuildContext context, {
    required ChatPhase phase,
    required BotLanguage botLanguage,
    required ChatbotLocalization i18n,
    required List<ChatMessage> messages,
    required List<String> availableSymptoms,
    required Set<String> selectedSymptoms,
    required bool submittingSymptoms,
    required TextEditingController controller,
    required Function(void Function()) setState,
    required Function(String) handleUserReply,
    required Function() submitSelectedSymptoms,
    required Function() onLanguageToggle,
    required Function() onOtherPressed,
  }) {
    final allowText =
        phase == ChatPhase.awaitingSymptomText || phase == ChatPhase.idle;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          i18n.t('assistant'),
          style: const TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: buildLanguageToggle(
              botLanguage: botLanguage,
              onToggle: onLanguageToggle,
            ),
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
                          if (m.role == ChatRole.bot)
                            _quickReplies(m, phase, handleUserReply),
                        ],
                      ))
                  .toList(),
            ),
          ),
          if (phase == ChatPhase.awaitingSymptomSelection)
            _symptomSelection(
              availableSymptoms,
              selectedSymptoms,
              submittingSymptoms,
              i18n,
              setState,
              submitSelectedSymptoms,
              onOtherPressed,
            ),
          _inputBar(allowText, controller, i18n, handleUserReply),
        ],
      ),
    );
  }

  static Widget _bubble(ChatMessage msg) {
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

  static Widget buildLanguageToggle({
    required BotLanguage botLanguage,
    required VoidCallback onToggle,
  }) {
    final isEnglish = botLanguage == BotLanguage.en;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isEnglish ? Colors.blue.shade50 : Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnglish ? Colors.blue : Colors.green,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 18),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                isEnglish ? 'EN' : 'മലയാളം',
                key: ValueKey(botLanguage),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _quickReplies(
      ChatMessage msg, ChatPhase phase, Function(String) handleUserReply) {
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
              ActionChip(label: Text(q), onPressed: () => handleUserReply(q)))
          .toList(),
    );
  }

  static Widget _symptomSelection(
    List<String> availableSymptoms,
    Set<String> selectedSymptoms,
    bool submittingSymptoms,
    ChatbotLocalization i18n,
    Function(void Function()) setState,
    Function() submitSelectedSymptoms,
    Function() onOtherPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        children: [
          ...availableSymptoms.map((s) => FilterChip(
                label: Text(s),
                selected: selectedSymptoms.contains(s),
                onSelected: (v) => setState(() =>
                    v ? selectedSymptoms.add(s) : selectedSymptoms.remove(s)),
              )),
          ActionChip(
            label: Text(i18n.t('other')),
            onPressed: onOtherPressed,
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
              label: Text(i18n.t('submit')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: submittingSymptoms ? null : submitSelectedSymptoms,
            ),
        ],
      ),
    );
  }

  static Widget _inputBar(
    bool allow,
    TextEditingController controller,
    ChatbotLocalization i18n,
    Function(String) handleUserReply,
  ) {
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
                hintText: allow ? i18n.t('type') : i18n.t('select'),
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
                      handleUserReply(text);
                    },
            ),
          )
        ],
      ),
    );
  }
}
