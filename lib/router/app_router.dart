import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/resident/resident_shell.dart';
import '../screens/resident/home_screen.dart';
import '../screens/resident/schedule_screen.dart';
import '../screens/resident/request_screen.dart';
import '../screens/resident/profile_screen.dart';
import '../screens/admin/admin_shell.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/schedule_manager_screen.dart';
import '../screens/admin/announcements_screen.dart';
import '../screens/admin/user_management_screen.dart';
import '../screens/admin/resident_inbox_screen.dart';
import '../screens/admin/collection_history_screen.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isOnAuth = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        if (!isLoggedIn && !isOnAuth) return '/login';
        if (isLoggedIn && isOnAuth) {
          if (authProvider.isAdmin) return '/admin/dashboard';
          return '/home';
        }
        return null;
      },
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => ResidentShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/schedule',
              builder: (context, state) => const ScheduleScreen(),
            ),
            GoRoute(
              path: '/request',
              builder: (context, state) => const RequestScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(
              path: '/admin/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/admin/schedules',
              builder: (context, state) => const ScheduleManagerScreen(),
            ),
            GoRoute(
              path: '/admin/announcements',
              builder: (context, state) => const AdminAnnouncementsScreen(),
            ),
            GoRoute(
              path: '/admin/residents',
              builder: (context, state) => const UserManagementScreen(),
            ),
            GoRoute(
              path: '/admin/inbox',
              builder: (context, state) => const ResidentInboxScreen(),
            ),
            GoRoute(
              path: '/admin/history',
              builder: (context, state) => const CollectionHistoryScreen(),
            ),
          ],
        ),
      ],
    );
  }
}