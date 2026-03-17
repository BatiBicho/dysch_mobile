import 'package:dysch_mobile/presentation/screens/auth/login_screen.dart';
import 'package:dysch_mobile/presentation/screens/feedback/feedback_screen.dart';
import 'package:dysch_mobile/presentation/screens/feedback/feedback_results_screen.dart';
import 'package:dysch_mobile/presentation/screens/feedback/take_feedback_screen.dart';
import 'package:dysch_mobile/presentation/screens/home/home_screen.dart';
import 'package:dysch_mobile/presentation/screens/incedent_history/incedent_history_screen.dart';
import 'package:dysch_mobile/presentation/screens/notifications/notification_screen.dart';
import 'package:dysch_mobile/presentation/screens/payroll/payroll_screen.dart';
import 'package:dysch_mobile/presentation/screens/profile/profile_screen.dart';
import 'package:dysch_mobile/presentation/screens/qr_scanner/qr_scanner_screen.dart';
import 'package:dysch_mobile/presentation/screens/request/request_absence_screen.dart';
import 'package:dysch_mobile/presentation/screens/schedule/schedule_screen.dart';
import 'package:dysch_mobile/presentation/screens/vacations/vacations_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/main/main_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    routes: [
      // Ruta de Login (Fuera del menú principal)
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // Ruta con el Bottom Navigation Bar
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScreen(child: child); // El "cascarón" con el menú
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/horarios',
            builder: (context, state) => const SchedulesScreen(),
          ),
          GoRoute(
            path: '/nomina',
            builder: (context, state) => const PayrollScreen(),
          ),

          GoRoute(
            path: '/feedback',
            builder: (context, state) => const FeedbackScreen(),
          ),
        ],
      ),
      // Rutas sin Bottom Navigation Bar
      GoRoute(
        path: '/qr',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/request-absence',
        builder: (context, state) => const RequestAbsenceScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const IncidentHistoryScreen(),
      ),
      GoRoute(
        path: '/vacations',
        builder: (context, state) => const VacationsScreen(),
      ),

      GoRoute(
        path: '/take-feedback',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return TakeFeedbackScreen(
            campaignId: extra['campaignId'] as String,
            campaignName: extra['campaignName'] as String,
            topicId: extra['topicId'] as String,
            topicTitle: extra['topicTitle'] as String,
            resultsVisibleToEmployees:
                extra['resultsVisibleToEmployees'] as bool? ?? false,
            isAnonymous: extra['isAnonymous'] as bool? ?? false,
            employeeCode: extra['employeeCode'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/feedback-results',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return FeedbackResultsScreen(
            campaignId: extra['campaignId'] as String,
            employeeCode: extra['employeeCode'] as String? ?? '',
          );
        },
      ),

    ],
  );
}