import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dysch_mobile/data/repositories/notification_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

// Handler para mensajes en background (debe ser top-level)
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  // Firebase ya está inicializado en main(), no hace falta reinicializarlo
}

class NotificationService {
  final NotificationRepository _repository;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  NotificationService(this._repository);

  // Llama esto en main() — solo configura, no hace peticiones al backend
  Future<void> setup() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    await _setupLocalNotifications();
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // Llama esto después del login exitoso
  Future<void> registerTokenAfterLogin() async {
    await _registerFCMToken();

    _fcm.onTokenRefresh.listen((newToken) {
      _logger.i('FCM token renovado');
      _registerFCMToken();
    });

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) _handleNotificationTap(initialMessage);
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Canal de alta importancia para Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'high_importance_channel',
            'Notificaciones importantes',
            importance: Importance.high,
          ),
        );
  }

  Future<void> _registerFCMToken() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;

      final deviceInfo = DeviceInfoPlugin();
      String deviceName = 'Unknown';
      String platform = Platform.isAndroid ? 'ANDROID' : 'IOS';

      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        deviceName = info.model; // Ej: "SM-A16"
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        deviceName = info.utsname.machine;
      }

      await _repository.registerToken(
        token: token,
        platform: platform,
        deviceName: deviceName,
      );
      _logger.i('✅ FCM token registrado en backend');
    } catch (e) {
      _logger.e('❌ Error registrando FCM token: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    _logger.i('Mensaje en foreground: ${notification.title}');

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Notificaciones importantes',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    _logger.i('Notificación tocada: ${message.data}');
    // Aquí puedes navegar usando GoRouter según message.data['type']
    // Ej: AppRouter.router.push('/schedule');
  }
}
