import 'package:dysch_mobile/core/api/dio_client.dart';
import 'package:dysch_mobile/core/router/app_router.dart';
import 'package:dysch_mobile/core/services/notification_service.dart';
import 'package:dysch_mobile/core/services/storage_service.dart';
import 'package:dysch_mobile/data/repositories/feedback_repository.dart';
import 'package:dysch_mobile/data/repositories/attendance_repository.dart';
import 'package:dysch_mobile/data/repositories/notification_repository.dart';
import 'package:dysch_mobile/data/repositories/schedule_repository.dart';
import 'package:dysch_mobile/data/repositories/user_repository.dart';
import 'package:dysch_mobile/data/repositories/incident_repository.dart';
import 'package:dysch_mobile/logic/auth/auth_cubit.dart';
import 'package:dysch_mobile/logic/feedback/feedback_cubit.dart';
import 'package:dysch_mobile/logic/schedule/schedule_cubit.dart';
import 'package:dysch_mobile/logic/incident/incident_cubit.dart';
import 'package:dysch_mobile/logic/profile/profile_cubit.dart';
import 'package:dysch_mobile/logic/attendance/attendance_cubit.dart';
import 'package:dysch_mobile/logic/notification/notification_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ← Solo una vez, al inicio
  final logger = Logger(printer: PrettyPrinter(methodCount: 0));
  try {
    await dotenv.load(fileName: '.env');
    logger.i("✅ Variables de entorno cargadas");
  } catch (e) {
    logger.e("❌ Error cargando .env: $e");
  }

  // Inicializar Firebase con variables de entorno
  final isAndroid = defaultTargetPlatform == TargetPlatform.android;
  final apiKey = dotenv.get(
    isAndroid ? 'API_KEY_ANDROID' : 'API_KEY_IOS',
    fallback: '',
  );
  final appId = dotenv.get(
    isAndroid ? 'APP_ID_ANDROID' : 'APP_ID_IOS',
    fallback: '',
  );
  final messagingSenderId = dotenv.get('MSG_SENDER_ID', fallback: '');
  final projectId = dotenv.get('PROJECT_ID', fallback: '');
  final storageBucket = dotenv.get('STORAGE_BUCKET', fallback: '');

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket: storageBucket.isNotEmpty ? storageBucket : null,
    ),
  );

  // Formateo de fechas en español
  await initializeDateFormatting('es', null);

  final dio = DioClient.instance;
  final storage = StorageService();

  final userRepository = UserRepository(dio);
  final scheduleReporsitory = ScheduleRepository(dio);
  final incidentRepository = IncidentRepository(dio);
  final feedbackRepository = FeedbackRepository(dio);
  final notificationRepository = NotificationRepository(dio);
  final attendanceRepository = AttendanceRepository(dio);
  final notificationService = NotificationService(notificationRepository);

  await notificationService.setup();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: scheduleReporsitory),
        RepositoryProvider.value(value: incidentRepository),
        RepositoryProvider.value(value: feedbackRepository),
        RepositoryProvider.value(value: storage),
        RepositoryProvider.value(value: notificationRepository),
        RepositoryProvider.value(value: attendanceRepository),
        RepositoryProvider.value(value: notificationService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthCubit(userRepository, storage, notificationService),
          ),
          BlocProvider(create: (context) => ScheduleCubit(scheduleReporsitory)),
          BlocProvider(create: (context) => IncidentCubit(incidentRepository)),
          BlocProvider(
            create: (context) => ProfileCubit(userRepository, storage),
          ),
          BlocProvider(
            create: (context) => AttendanceCubit(attendanceRepository),
          ),
          BlocProvider(
            create: (context) =>
                FeedbackCubit(feedbackRepository)..loadPendingAssignments(),
          ),
          BlocProvider(
            create: (context) => NotificationCubit(notificationRepository),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DYSCH Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
