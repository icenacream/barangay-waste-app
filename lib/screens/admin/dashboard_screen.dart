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
    return FutureBuilder<List<int>>(
      future: Future.wait([
        // Total Schedules = number of barangay settings docs
        FirebaseFirestore.instance
            .collection('settings')
            .count()
            .get()
            .then((r) => r.count ?? 0),
        // Active Residents = users with role 'resident'
        FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'resident')
            .count()
            .get()
            .then((r) => r.count ?? 0),
        // Pending Requests
        FirebaseFirestore.instance
            .collection('requests')
            .where('status', isEqualTo: 'pending')
            .count()
            .get()
            .then((r) => r.count ?? 0),
        // Completed Collections — update 'type' value to match your Firestore
        FirebaseFirestore.instance
            .collection('exceptions')
            .where('type', isEqualTo: 'completed')
            .count()
            .get()
            .then((r) => r.count ?? 0),
      ]),
      builder: (context, snapshot) {
        final counts = snapshot.data ?? [0, 0, 0, 0];
        final fmt = NumberFormat('#,###');
        final hasData = snapshot.hasData;

        return Row(
          children: [
            Expanded(
              child: _metricCard(
                'Total Schedules',
                hasData ? counts[0].toString() : '—',
                Icons.calendar_month_rounded,
                const Color(0xFF1565C0),
                const Color(0xFFE3F2FD),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _metricCard(
                'Active Residents',
                hasData ? fmt.format(counts[1]) : '—',
                Icons.people_rounded,
                const Color(0xFF2E7D32),
                const Color(0xFFE8F5E9),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _metricCard(
                'Pending Requests',
                hasData ? counts[2].toString() : '—',
                Icons.inbox_rounded,
                const Color(0xFFE65100),
                const Color(0xFFFFF3E0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _metricCard(
                'Completed Collections',
                hasData ? counts[3].toString() : '—',
                Icons.check_circle_rounded,
                const Color(0xFF555555),
                const Color(0xFFF5F5F5),
              ),
            ),
          ],
        );
      },
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
          // Header row
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
                .snapshots(),
            builder: (context, settingsSnap) {
              if (!settingsSnap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final docs = settingsSnap.data!.docs;
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No schedules found.'),
                );
              }

              // For each barangay, find its next collection day
              final today = DateTime.now();
              final base = DateTime(today.year, today.month, today.day);
              const dayNames = [
                'Monday', 'Tuesday', 'Wednesday', 'Thursday',
                'Friday', 'Saturday', 'Sunday',
              ];

              final List<Map<String, String>> rows = [];
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final barangay = data['barangay'] ?? '';
                final time = data['defaultTime'] ?? '7:00 AM';
                final days = List<String>.from(data['collectionDays'] ?? [])
                    .where((d) => !d.contains(','))
                    .toList();

                for (int i = 0; i < 7; i++) {
                  final checkDate = base.add(Duration(days: i));
                  if (days.contains(dayNames[checkDate.weekday - 1])) {
                    rows.add({
                      'barangay': barangay,
                      'date': DateFormat('MMM d, yyyy').format(checkDate),
                      'time': time,
                    });
                    break;
                  }
                }
              }

              // Sort by date ascending
              rows.sort((a, b) => a['date']!.compareTo(b['date']!));

              if (rows.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No upcoming schedules.'),
                );
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
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Text(
                  'No requests yet.',
                  style: TextStyle(color: Colors.grey),
                );
              }
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'pending';
                  final type = data['type'] ?? 'request';
                  final isPending = status == 'pending';

                  // Parse createdAt for display
                  String timeAgo = '';
                  if (data['createdAt'] != null) {
                    final createdAt =
                        (data['createdAt'] as Timestamp).toDate();
                    final diff = DateTime.now().difference(createdAt);
                    if (diff.inMinutes < 60) {
                      timeAgo = '${diff.inMinutes}m ago';
                    } else if (diff.inHours < 24) {
                      timeAgo = '${diff.inHours}h ago';
                    } else {
                      timeAgo = DateFormat('MMM d').format(createdAt);
                    }
                  }

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
                            Expanded(
                              child: Text(
                                data['residentName'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111111),
                                ),
                                overflow: TextOverflow.ellipsis,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['barangay'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                            if (timeAgo.isNotEmpty)
                              Text(
                                timeAgo,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF999999),
                                ),
                              ),
                          ],
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