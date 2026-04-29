import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              'Resident Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage registered residents',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 360,
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search residents...',
                  hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8ECF0)),
                ),
                child: Column(
                  children: [
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
                                  'NAME',
                                  'EMAIL',
                                  'BARANGAY',
                                  'DATE REGISTERED',
                                  'STATUS',
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
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('role', isEqualTo: 'resident')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          var docs = snapshot.data!.docs;
                          if (_searchQuery.isNotEmpty) {
                            docs = docs.where((d) {
                              final data = d.data() as Map<String, dynamic>;
                              return (data['name'] ?? '')
                                      .toString()
                                      .toLowerCase()
                                      .contains(_searchQuery) ||
                                  (data['email'] ?? '')
                                      .toString()
                                      .toLowerCase()
                                      .contains(_searchQuery) ||
                                  (data['barangay'] ?? '')
                                      .toString()
                                      .toLowerCase()
                                      .contains(_searchQuery);
                            }).toList();
                          }
                          if (docs.isEmpty)
                            return const Center(
                              child: Text(
                                'No residents found.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final data =
                                  docs[index].data() as Map<String, dynamic>;
                              final isEven = index % 2 == 0;
                              DateTime? createdAt;
                              try {
                                createdAt = (data['createdAt'] as Timestamp?)
                                    ?.toDate();
                              } catch (_) {}
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
                                        data['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF111111),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data['email'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data['barangay'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        createdAt != null
                                            ? DateFormat(
                                                'MMM d, yyyy',
                                              ).format(createdAt)
                                            : '—',
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
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          'Active',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2E7D32),
                                          ),
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
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {},
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
}
