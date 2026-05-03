import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/schedule_service.dart';
import '../../services/announcement_service.dart';
import '../../models/announcement_model.dart';
import '../../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final AnnouncementService _announcementService = AnnouncementService();
  Map<String, dynamic>? _nextCollection;
  bool _loadingSchedule = true;

  @override
  void initState() {
    super.initState();
    _loadNextCollection();
  }

  Future<void> _loadNextCollection() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final result = await _scheduleService.getNextCollection(user.barangay);
    if (mounted) {
      setState(() {
        _nextCollection = result;
        _loadingSchedule = false;
      });

      if (result != null) {
        await NotificationService().scheduleCollectionReminder(
          collectionDate: result['date'],
          barangay: result['barangay'],
          time: result['time'],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final firstName = user?.name.split(' ').first ?? 'Resident';

    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
              color: const Color(0xFF1565C0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello,',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      Text(
                        '$firstName!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -24),
                      child: _buildNextCollectionCard(),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Announcements',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildAnnouncementsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextCollectionCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E8F0)),
      ),
      child: _loadingSchedule
          ? const SizedBox(
              height: 48,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF1565C0)),
              ),
            )
          : _nextCollection == null
          ? const Text('No upcoming collection.', style: TextStyle(color: Colors.grey))  
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'NEXT COLLECTION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF888888),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF90CAF9)),
                      ),
                      child: Text(
                        _nextCollection!['status'] == 'rescheduled'
                            ? 'Rescheduled'
                            : 'Scheduled',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _nextCollection!['barangay'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat(
                        'MMMM d, yyyy',
                      ).format(_nextCollection!['date']),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _nextCollection!['time'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildAnnouncementsList() {
    return StreamBuilder<List<AnnouncementModel>>(
      stream: _announcementService.getAnnouncements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1565C0)),
          );
        }
        final announcements = snapshot.data ?? [];
        if (announcements.isEmpty) {
          return const Text(
            'No announcements yet.',
            style: TextStyle(color: Colors.grey),
          );
        }
        return Column(
          children: announcements
              .take(3)
              .map((a) => _buildAnnouncementCard(a))
              .toList(),
        );
      },
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF1565C0), width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            announcement.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            announcement.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM d, yyyy').format(announcement.createdAt),
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}
