import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/admin/dashboard') return 0;
    if (location == '/admin/schedules') return 1;
    if (location == '/admin/announcements') return 2;
    if (location == '/admin/residents') return 3;
    if (location == '/admin/inbox') return 4;
    if (location == '/admin/history') return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final currentIndex = _selectedIndex(context);
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 900) {
      return Scaffold(
        backgroundColor: const Color(0xFF1565C0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.desktop_windows_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Desktop only',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'The admin dashboard is only accessible on a desktop or laptop browser.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final initials = (user?.name ?? 'A')
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 216,
            color: const Color(0xFF1A56C4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QCEcoTrack',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _navItem(
                  context,
                  0,
                  currentIndex,
                  Icons.dashboard_outlined,
                  Icons.dashboard_rounded,
                  'Dashboard',
                  '/admin/dashboard',
                ),
                _navItem(
                  context,
                  1,
                  currentIndex,
                  Icons.calendar_month_outlined,
                  Icons.calendar_month_rounded,
                  'Schedule Manager',
                  '/admin/schedules',
                ),
                _navItem(
                  context,
                  2,
                  currentIndex,
                  Icons.campaign_outlined,
                  Icons.campaign_rounded,
                  'Announcements',
                  '/admin/announcements',
                ),
                _navItem(
                  context,
                  3,
                  currentIndex,
                  Icons.people_outline,
                  Icons.people_rounded,
                  'Resident Management',
                  '/admin/residents',
                ),
                _navItem(
                  context,
                  4,
                  currentIndex,
                  Icons.inbox_outlined,
                  Icons.inbox_rounded,
                  'Resident Inbox',
                  '/admin/inbox',
                ),
                _navItem(
                  context,
                  5,
                  currentIndex,
                  Icons.history_outlined,
                  Icons.history_rounded,
                  'Collection History',
                  '/admin/history',
                ),
                const Spacer(),
                const Divider(color: Colors.white24, height: 1),
                // Logout
                GestureDetector(
                  onTap: () async =>
                      await context.read<AuthProvider>().logout(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 64,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Stack(
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            size: 24,
                            color: Color(0xFF555555),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
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
                      const SizedBox(width: 20),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF1565C0),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Admin User',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111111),
                            ),
                          ),
                          const Text(
                            'Administrator',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE8ECF0)),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    int index,
    int currentIndex,
    IconData icon,
    IconData activeIcon,
    String label,
    String route,
  ) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.white : Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
