import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';
import '../../features/landing/landing_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/farmer/farmer_dashboard_screen.dart';
import '../../features/farmer/ask_question_screen.dart';
import '../../features/farmer/grounded_response_screen.dart';
import '../../features/farmer/settings_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/admin/admin_farmers_screen.dart';
import '../../features/graph/knowledge_graph_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthService authService) {
    return GoRouter(
      initialLocation: '/landing',
      refreshListenable: authService,
      redirect: (BuildContext context, GoRouterState state) {
        final loc = state.matchedLocation;
        final isLoggedIn = authService.isLoggedIn;
        final isAdmin = authService.isAdmin;

        // Public routes
        if (loc == '/landing' || loc == '/login' || loc == '/register') {
          return null;
        }

        // Protected Farmer routes
        if (loc.startsWith('/farmer')) {
          if (!isLoggedIn) {
            return '/login';
          }
          return null;
        }

        // Protected Admin routes
        if (loc.startsWith('/admin')) {
          if (!isLoggedIn || !isAdmin) {
            return '/login';
          }
          return null;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/landing',
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/graph',
          builder: (context, state) => const KnowledgeGraphScreen(),
        ),
        GoRoute(
          path: '/farmer',
          builder: (context, state) => const FarmerDashboardScreen(),
          routes: [
            GoRoute(
              path: 'ask',
              builder: (context, state) => const AskQuestionScreen(),
            ),
            GoRoute(
              path: 'response',
              builder: (context, state) {
                final sessionIdStr = state.uri.queryParameters['sessionId'] ?? state.uri.queryParameters['session_id'];
                final sessionId = int.tryParse(sessionIdStr ?? '');
                return GroundedResponseScreen(sessionId: sessionId);
              },
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
          routes: [
            GoRoute(
              path: 'farmers',
              builder: (context, state) => const AdminFarmersScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
