import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'views/auth/login_page.dart';
import 'views/auth/forgot_password_page.dart';
import 'views/dashboard/dashboard_main.dart';
import 'views/pages/incidents_page.dart';
import 'views/pages/incident_details_page.dart';
import 'views/pages/users_page.dart';
import 'views/pages/alerts_page.dart';
import 'views/pages/analytics_page.dart';
import 'views/pages/settings_page.dart';
import 'views/pages/maps_page.dart';
import 'views/pages/audit_logs_page.dart';
import 'views/pages/profile_page.dart';
import 'views/pages/overview_page.dart';
import 'providers/auth_provider.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.currentUser != null;
      final isInitialized = authProvider.isInitialized;
      final isLoggingIn = state.uri.toString() == '/login';
      final isResettingPassword = state.uri.toString() == '/forgot-password';

      // If not initialized, don't redirect yet (or show loading)
      if (!isInitialized) {
        return null; 
      }

      if (!isLoggedIn && !isLoggingIn && !isResettingPassword) {
        return '/login';
      }
      if (isLoggedIn && isLoggingIn) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          // Show loading if not initialized (though redirect handles most cases)
          if (!authProvider.isInitialized) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return DashboardMain(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const OverviewPage(),
          ),
          GoRoute(
            path: '/incidents',
            builder: (context, state) => const IncidentsPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return IncidentDetailsPage(incidentId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersPage(),
          ),
          GoRoute(
            path: '/alerts',
            builder: (context, state) => const AlertsPage(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => SettingsPage(),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapsPage(),
          ),
          GoRoute(
            path: '/audit-logs',
            builder: (context, state) => const AuditLogsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}
