import 'package:go_router/go_router.dart';
import '../../screens/main_shell.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/analytics/analytics_screen.dart';
import '../../screens/prediction/prediction_screen.dart';
import '../../screens/chatbot/chatbot_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const HistoryScreen(),
          ),
        ),
        GoRoute(
          path: '/analytics',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const AnalyticsScreen(),
          ),
        ),
        GoRoute(
          path: '/prediction',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const PredictionScreen(),
          ),
        ),
        GoRoute(
          path: '/chatbot',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const ChatbotScreen(),
          ),
        ),
      ],
    ),
  ],
);
