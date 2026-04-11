import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/announcement_service.dart';
import '../../models/announcement_model.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              color: const Color(0xFF1565C0),
              child: const Text(
                'Announcements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<AnnouncementModel>>(
                stream: AnnouncementService().getAnnouncements(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)));
                  }
                  final announcements = snapshot.data ?? [];
                  if (announcements.isEmpty) {
                    return const Center(child: Text('No announcements yet.', style: TextStyle(color: Colors.grey)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: announcements.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final a = announcements[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: const Border(left: BorderSide(color: Color(0xFF1565C0), width: 3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
                            const SizedBox(height: 6),
                            Text(a.message, style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.5)),
                            const SizedBox(height: 8),
                            Text(DateFormat('MMM d, yyyy').format(a.createdAt), style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
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
    );
  }
}