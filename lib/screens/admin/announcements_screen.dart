import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/announcement_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/announcement_service.dart';

class AdminAnnouncementsScreen extends StatelessWidget {
  const AdminAnnouncementsScreen({super.key});

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
                      'Announcements',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage barangay announcements',
                      style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showPostDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Post Announcement'),
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
            Expanded(
              child: StreamBuilder<List<AnnouncementModel>>(
                stream: AnnouncementService().getAnnouncements(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final announcements = snapshot.data!;
                  if (announcements.isEmpty) {
                    return const Center(
                      child: Text(
                        'No announcements yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.2,
                        ),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final a = announcements[index];
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: const Border(
                            left: BorderSide(
                              color: Color(0xFF1565C0),
                              width: 4,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111111),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                a.message,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF555555),
                                  height: 1.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('MMM d, yyyy').format(a.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                            const Divider(height: 16),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      _showPostDialog(context, existing: a),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: Color(0xFF1565C0),
                                  ),
                                  label: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: Color(0xFF1565C0),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () => _deleteAnnouncement(a.id),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
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
    );
  }

  Future<void> _deleteAnnouncement(String id) async {
    await AnnouncementService().deleteAnnouncement(id);
  }

  void _showPostDialog(BuildContext context, {AnnouncementModel? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final messageController = TextEditingController(
      text: existing?.message ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          existing == null ? 'Post Announcement' : 'Edit Announcement',
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Title',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Announcement title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Message',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Write your announcement here...',
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
              final user = ctx.read<AuthProvider>().user;
              if (existing != null) {
                await FirebaseFirestore.instance
                    .collection('announcements')
                    .doc(existing.id)
                    .update({
                      'title': titleController.text.trim(),
                      'message': messageController.text.trim(),
                    });
              } else {
                final announcement = AnnouncementModel(
                  id: '',
                  title: titleController.text.trim(),
                  message: messageController.text.trim(),
                  postedBy: user?.uid ?? '',
                  createdAt: DateTime.now(),
                );
                await AnnouncementService().addAnnouncement(announcement);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: Text(existing == null ? 'Post' : 'Save'),
          ),
        ],
      ),
    );
  }
}
