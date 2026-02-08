import 'package:dysch_mobile/presentation/screens/auth/login_screen.dart';
import 'package:dysch_mobile/presentation/screens/home/home_screen.dart';
import 'package:dysch_mobile/presentation/screens/notifications/notification_screen.dart';
import 'package:dysch_mobile/presentation/screens/payroll/payroll_screen.dart';
import 'package:dysch_mobile/presentation/screens/profile/profile_screen.dart';
import 'package:dysch_mobile/presentation/screens/qr_scanner/qr_scanner_screen.dart';
import 'package:dysch_mobile/presentation/screens/request/request_absence_screen.dart';
import 'package:dysch_mobile/presentation/screens/schedule/schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/main/main_screen.dart';

// Claves para la navegación
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
    ],
  );
}
