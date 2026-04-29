import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final firstName = user?.name.split(' ').first ?? 'Admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $firstName!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Here's what's happening with waste collection today.",
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 24),
            _buildMetricCards(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildUpcomingSchedules()),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: _buildRecentRequests()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCards() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            'Total Schedules',
            '48',
            Icons.calendar_month_rounded,
            const Color(0xFF1565C0),
            const Color(0xFFE3F2FD),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _metricCard(
            'Active Residents',
            '1,234',
            Icons.people_rounded,
            const Color(0xFF2E7D32),
            const Color(0xFFE8F5E9),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _metricCard(
            'Pending Requests',
            '12',
            Icons.inbox_rounded,
            const Color(0xFFE65100),
            const Color(0xFFFFF3E0),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _metricCard(
            'Completed Collections',
            '156',
            Icons.check_circle_rounded,
            const Color(0xFF555555),
            const Color(0xFFF5F5F5),
          ),
        ),
      ],
    );
  }

  Widget _metricCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color iconBg,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSchedules() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Schedules',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                children: ['BARANGAY', 'DATE', 'TIME', 'STATUS']
                    .map(
                      (h) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
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
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('settings')
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              final docs = snapshot.data!.docs;
              if (docs.isEmpty)
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No schedules found.'),
                );

              final List<Map<String, String>> rows = [];
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final barangay = data['barangay'] ?? '';
                final time = data['defaultTime'] ?? '7:00 AM';
                final days = List<String>.from(data['collectionDays'] ?? []);
                DateTime check = DateTime.now();
                for (int i = 0; i < 7; i++) {
                  check = DateTime.now().add(Duration(days: i));
                  const dayNames = [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday',
                  ];
                  if (days.contains(dayNames[check.weekday - 1])) {
                    rows.add({
                      'barangay': barangay,
                      'date': DateFormat('MMM d, yyyy').format(check),
                      'time': time,
                    });
                    break;
                  }
                }
              }

              return Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                },
                children: rows
                    .map(
                      (row) => TableRow(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFF5F5F5)),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              row['barangay']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              row['date']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              row['time']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Scheduled',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequests() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Requests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('requests')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final docs = snapshot.data!.docs;
              if (docs.isEmpty)
                return const Text(
                  'No requests yet.',
                  style: TextStyle(color: Colors.grey),
                );
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'pending';
                  final type = data['type'] ?? 'request';
                  final isPending = status == 'pending';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE8ECF0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['residentName'] ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111111),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isPending
                                    ? const Color(0xFFFFF3E0)
                                    : const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isPending
                                      ? const Color(0xFFFFCC80)
                                      : const Color(0xFFA5D6A7),
                                ),
                              ),
                              child: Text(
                                isPending ? 'Pending' : 'Replied',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isPending
                                      ? const Color(0xFFE65100)
                                      : const Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['barangay'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data['message'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
