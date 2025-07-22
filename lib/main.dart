import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/omega_splash_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';

// Сервисы Hive
import 'model/service/shoots_hive_service.dart';
import 'model/service/transaction_hive_service.dart';

// Cубиты
import 'cubit/shoots/shoots_cubit.dart';
import 'cubit/transactions/transactions_cubit.dart';

// Модели
import 'model/omega_shoot_model.dart';
import 'model/omega_transaction_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Получаем путь к директории приложения
  final appDocumentDir = await getApplicationDocumentsDirectory();
  // Инициализируем Hive с этим путём
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox('settings');

  // Регистрируем адаптеры (типId 0 — для съёмок, 1 — для транзакций)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(OmegaShootModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(OmegaTransactionModelAdapter());
  }

  // Открываем боксы
  await ShootsHiveService.init();
  await TransactionHiveService.init();

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => child!,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ShootsCubit>(
            create: (_) => ShootsCubit(ShootsHiveService())..loadShoots(),
          ),
          BlocProvider<TransactionsCubit>(
            create: (_) =>
                TransactionsCubit(TransactionHiveService())..loadTransactions(),
          ),
        ],
        child: const OmegaApp(),
      ),
    ),
  );
}

class OmegaApp extends StatelessWidget {
  const OmegaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Omega App',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgColor,
        bottomAppBarTheme: BottomAppBarTheme(
          color: AppColors.bottomNavigatorAppBarColor,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.bottomNavigatorAppBarColor,
          selectedItemColor: AppColors.mainAccent,
          unselectedItemColor: AppColors.textWhite,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const OmegaSplashScreen(),
    );
  }
}
