import 'package:flutter/material.dart';
import '../../api_client.dart';

class AddScheduleScreen extends StatefulWidget {
  final int medicationId;

  const AddScheduleScreen({
    super.key,
    required this.medicationId,
  });

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final TextEditingController doseCtrl = TextEditingController();

  bool wholeDay = false;
  String timeOfDay = 'morning';
  TimeOfDay? selectedTime;

  bool submitting = false;

  /* ============================
     PICK TIME
  ============================ */
  Future<void> pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (t != null) {
      setState(() => selectedTime = t);
    }
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /* ============================
     SUBMIT
  ============================ */
  Future<void> submit() async {
    if (doseCtrl.text.trim().isEmpty) {
      _error('Dose is required');
      return;
    }

    if (!wholeDay && selectedTime == null) {
      _error('Time is required');
      return;
    }

    setState(() => submitting = true);

    try {
      if (wholeDay) {
        // 🔁 CREATE 3 SCHEDULES
        const schedules = [
          {'time_of_day': 'morning', 'time': '08:00'},
          {'time_of_day': 'afternoon', 'time': '13:00'},
          {'time_of_day': 'night', 'time': '21:00'},
        ];

        for (final s in schedules) {
          await ApiClient.postJson(
            '/medication-schedules',
            {
              "medication_id": widget.medicationId,
              "dose": doseCtrl.text.trim(),
              "time_of_day": s['time_of_day'],
              "scheduled_time": s['time'],
            },
          );
        }
      } else {
        // SINGLE TIME
        await ApiClient.postJson(
          '/medication-schedules',
          {
            "medication_id": widget.medicationId,
            "dose": doseCtrl.text.trim(),
            "time_of_day": timeOfDay,
            "scheduled_time": _formatTime(selectedTime!),
          },
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _error('Failed to save schedule');
    } finally {
      setState(() => submitting = false);
    }
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Add Medication Schedule'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Schedule Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// DOSE
                  const Text('Dose',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: doseCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 5 mg',
                      prefixIcon: Icon(Icons.medication),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// WHOLE DAY TOGGLE
                  SwitchListTile(
                    value: wholeDay,
                    title:
                        const Text('Whole Day (Morning + Afternoon + Night)'),
                    subtitle: const Text('Automatically schedules 3 doses'),
                    onChanged: (v) => setState(() => wholeDay = v),
                  ),

                  if (!wholeDay) ...[
                    const SizedBox(height: 16),

                    /// TIME OF DAY
                    DropdownButtonFormField<String>(
                      value: timeOfDay,
                      items: const [
                        DropdownMenuItem(
                            value: 'morning', child: Text('Morning')),
                        DropdownMenuItem(
                            value: 'afternoon', child: Text('Afternoon')),
                        DropdownMenuItem(value: 'night', child: Text('Night')),
                      ],
                      onChanged: (v) => setState(() => timeOfDay = v!),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.wb_sunny_outlined),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// CLOCK
                    OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        selectedTime == null
                            ? 'Pick Time'
                            : selectedTime!.format(context),
                      ),
                      onPressed: pickTime,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(submitting ? 'Saving...' : 'Save Schedule'),
              onPressed: submitting ? null : submit,
            ),
          ),
        ],
      ),
    );
  }
}
