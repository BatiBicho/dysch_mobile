import 'package:dysch_mobile/core/api/dio_client.dart';
import 'package:dysch_mobile/core/router/app_router.dart';
import 'package:dysch_mobile/core/services/storage_service.dart';
import 'package:dysch_mobile/data/repositories/user_repository.dart';
import 'package:dysch_mobile/logic/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("✅ Variables de entorno cargadas");
  } catch (e) {
    print("❌ Error cargando .env: $e");
  }

  final dio = DioClient.instance;
  final storage = StorageService();
  final userRepository = UserRepository(dio);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: storage),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthCubit(userRepository, storage)),
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
