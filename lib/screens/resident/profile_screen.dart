import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
              color: const Color(0xFF1565C0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your account',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE0E8F0)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1565C0),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _getInitials(user?.name ?? 'User'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              user?.name ?? '',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.barangay ?? '',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildSettingItem(
                      icon: Icons.person_outline,
                      label: 'Edit Profile',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _buildSettingItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _buildSettingItem(
                      icon: Icons.info_outline,
                      label: 'About',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _buildSettingItem(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      isDestructive: true,
                      onTap: () async {
                        await context.read<AuthProvider>().logout();
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'QCEchoTrack v1.0.0',
                      style: TextStyle(fontSize: 12, color: Color(0xFFBBBBBB)),
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

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFFFF8F8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? const Color(0xFFFFCDD2) : const Color(0xFFE0E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDestructive ? const Color(0xFFFFEBEE) : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isDestructive ? Colors.red : const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : const Color(0xFF111111),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: isDestructive ? const Color(0xFFFFCDD2) : const Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }
}