import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ResidentInboxScreen extends StatefulWidget {
  const ResidentInboxScreen({super.key});

  @override
  State<ResidentInboxScreen> createState() => _ResidentInboxScreenState();
}

class _ResidentInboxScreenState extends State<ResidentInboxScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resident Inbox',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage resident messages and requests',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 20),
            Row(
              children: ['All', 'Pending', 'Replied'].map((f) {
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('requests')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  var docs = snapshot.data!.docs;
                  if (_filter != 'All') {
                    docs = docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return (data['status'] ?? '') == _filter.toLowerCase();
                    }).toList();
                  }
                  if (docs.isEmpty)
                    return const Center(
                      child: Text(
                        'No requests found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final id = docs[index].id;
                      final status = data['status'] ?? 'pending';
                      final type = data['type'] ?? 'request';
                      final isPending = status == 'pending';
                      DateTime? createdAt;
                      try {
                        createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                      } catch (_) {}

                      Color typeBg;
                      Color typeColor;
                      switch (type) {
                        case 'review':
                          typeBg = const Color(0xFFFFF3E0);
                          typeColor = const Color(0xFFE65100);
                          break;
                        case 'recommendation':
                          typeBg = const Color(0xFFE8F5E9);
                          typeColor = const Color(0xFF2E7D32);
                          break;
                        default:
                          typeBg = const Color(0xFFE3F2FD);
                          typeColor = const Color(0xFF1565C0);
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8ECF0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['residentName'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111111),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      data['barangay'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isPending
                                          ? const Color(0xFFE65100)
                                          : const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: typeBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    type.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: typeColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (createdAt != null)
                                  Text(
                                    DateFormat('MMM d, yyyy').format(createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF999999),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              data['message'] ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF333333),
                                height: 1.5,
                              ),
                            ),
                            if (data['adminReply'] != null &&
                                (data['adminReply'] as String).isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Admin Reply:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1565C0),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['adminReply'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            if (isPending)
                              ElevatedButton(
                                onPressed: () =>
                                    _showReplyDialog(context, id, data),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1565C0),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Reply',
                                  style: TextStyle(fontSize: 13),
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
    );
  }

  void _showReplyDialog(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reply to Request'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Message from ${data['residentName']}:',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data['message'] ?? '',
                style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Reply',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: replyController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Type your reply here...',
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
              await FirebaseFirestore.instance
                  .collection('requests')
                  .doc(id)
                  .update({
                    'adminReply': replyController.text.trim(),
                    'status': 'replied',
                    'repliedAt': FieldValue.serverTimestamp(),
                  });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }
}
