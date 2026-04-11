import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/request_model.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final _messageController = TextEditingController();
  String _selectedType = 'Request';
  bool _isSubmitting = false;

  final List<String> _types = ['Request', 'Review', 'Recommendation'];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final request = RequestModel(
      id: '',
      residentId: user.uid,
      residentName: user.name,
      barangay: user.barangay,
      type: _selectedType.toLowerCase(),
      message: _messageController.text.trim(),
      status: 'pending',
      adminReply: '',
      createdAt: DateTime.now(),
    );

    await FirebaseFirestore.instance.collection('requests').add(request.toMap());

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request submitted successfully!'),
        backgroundColor: Color(0xFF1565C0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              color: const Color(0xFF1565C0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Send Message',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Contact your barangay',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Message Type',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: _types.map((type) {
                        final isSelected = _selectedType == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedType = type),
                            child: Container(
                              margin: EdgeInsets.only(right: type != _types.last ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF1565C0) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF1565C0) : const Color(0xFFE0E0E0),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                type,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF555555),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Message',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: 'Type your message here...',
                          hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Barangay',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Text(
                        user?.barangay ?? '',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Submit Request',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF90CAF9)),
                      ),
                      child: const Text(
                        'Your request will be sent to your barangay office. You will receive a response in the Messages section.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1565C0), height: 1.5),
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
}