import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/schedule_model.dart';
import '../../services/schedule_service.dart';

class ScheduleManagerScreen extends StatefulWidget {
  const ScheduleManagerScreen({super.key});

  @override
  State<ScheduleManagerScreen> createState() => _ScheduleManagerScreenState();
}

class _ScheduleManagerScreenState extends State<ScheduleManagerScreen> {
  String _filter = 'All';
  final ScheduleService _scheduleService = ScheduleService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule Manager',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage waste collection schedules',
                      style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddExceptionDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Schedule Exception'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: ['All', 'Scheduled', 'Cancelled', 'Rescheduled'].map((
                f,
              ) {
                final isActive = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF1565C0) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFF1565C0)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF555555),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8ECF0)),
                ),
                child: Column(
                  children: [
                    // Table header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFEEEEEE)),
                        ),
                      ),
                      child: Row(
                        children:
                            [
                                  'BARANGAY',
                                  'DATE',
                                  'TIME',
                                  'STATUS',
                                  'REASON',
                                  'ACTIONS',
                                ]
                                .map(
                                  (h) => Expanded(
                                    child: Text(
                                      h,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF999999),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    // Table body
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('exceptions')
                            .orderBy('date', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return const Center(
                              child: CircularProgressIndicator(),
                            );

                          var docs = snapshot.data!.docs;
                          if (_filter != 'All') {
                            docs = docs.where((d) {
                              final data = d.data() as Map<String, dynamic>;
                              return (data['type'] ?? '')
                                      .toString()
                                      .toLowerCase() ==
                                  _filter.toLowerCase();
                            }).toList();
                          }

                          if (docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'No exceptions found.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final data =
                                  docs[index].data() as Map<String, dynamic>;
                              final id = docs[index].id;
                              final exception = ExceptionModel.fromMap(
                                id,
                                data,
                              );
                              final isEven = index % 2 == 0;

                              return Container(
                                color: isEven
                                    ? Colors.white
                                    : const Color(0xFFFAFAFA),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        exception.barangay,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF111111),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        DateFormat(
                                          'MMM d, yyyy',
                                        ).format(exception.date),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        exception.newTime.isEmpty
                                            ? '—'
                                            : exception.newTime,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: exception.isCancelled
                                              ? const Color(0xFFFFEBEE)
                                              : const Color(0xFFFFF3E0),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          exception.isCancelled
                                              ? 'Cancelled'
                                              : 'Rescheduled',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: exception.isCancelled
                                                ? Colors.red
                                                : const Color(0xFFE65100),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        exception.reason.isEmpty
                                            ? '—'
                                            : exception.reason,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                              color: Color(0xFF1565C0),
                                            ),
                                            onPressed: () =>
                                                _showAddExceptionDialog(
                                                  context,
                                                  existing: exception,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _deleteException(id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteException(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Exception'),
        content: const Text(
          'Are you sure you want to delete this schedule exception?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _scheduleService.deleteException(id);
    }
  }

  void _showAddExceptionDialog(
    BuildContext context, {
    ExceptionModel? existing,
  }) {
    final barangayController = TextEditingController(
      text: existing?.barangay ?? '',
    );
    final reasonController = TextEditingController(
      text: existing?.reason ?? '',
    );
    final newTimeController = TextEditingController(
      text: existing?.newTime ?? '',
    );
    String selectedType = existing?.type ?? 'cancelled';
    DateTime selectedDate = existing?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Text(
            existing == null ? 'Add Schedule Exception' : 'Edit Exception',
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Barangay',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: barangayController,
                  decoration: const InputDecoration(
                    hintText: 'Barangay San Jose',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null)
                      setModalState(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Type',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('Cancelled'),
                    ),
                    DropdownMenuItem(
                      value: 'rescheduled',
                      child: Text('Rescheduled'),
                    ),
                  ],
                  onChanged: (v) => setModalState(() => selectedType = v!),
                ),
                if (selectedType == 'rescheduled') ...[
                  const SizedBox(height: 14),
                  const Text(
                    'New Time',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: newTimeController,
                    decoration: const InputDecoration(
                      hintText: '8:00 AM',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                const Text(
                  'Reason',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Holiday',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final exception = ExceptionModel(
                  id: existing?.id ?? '',
                  barangay: barangayController.text.trim(),
                  date: selectedDate,
                  type: selectedType,
                  newTime: newTimeController.text.trim(),
                  reason: reasonController.text.trim(),
                  createdAt: DateTime.now(),
                );
                if (existing != null) {
                  await FirebaseFirestore.instance
                      .collection('exceptions')
                      .doc(existing.id)
                      .update(exception.toMap());
                } else {
                  await _scheduleService.addException(exception);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
              ),
              child: Text(existing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
