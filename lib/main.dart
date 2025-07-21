import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:omega_view_smart_plan_320/presentetion/pages/omega_bottomnavigation_bar.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'model/service/shoots_hive_service.dart'; // <--- ДОБАВЛЕН ЭТОТ ИМПОРТ
import 'model/service/transaction_hive_service.dart';
import 'cubit/shoots/shoots_cubit.dart';
import 'cubit/transactions/transactions_cubit.dart';
import 'model/omega_shoot_model.dart';
import 'model/omega_transaction_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // --- ВАЖНО: Регистрация адаптеров Hive ---
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(
        OmegaShootModelAdapter()); // ТОЛЬКО ЭТОТ АДАПТЕР для OmegaShootModel
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(OmegaTransactionModelAdapter());
  }
  // Убедитесь, что здесь НЕТ строки Hive.registerAdapter(OmegaShootModelV2Adapter());
  // И удалите import 'package:omega_view_smart_plan_320/model/omega_shoot_model_adapter_v2.dart'; из этого файла!

  // Опционально: Удаление боксов для чистого старта (раскомментируйте, если нужно сбросить данные)
  // try {
  //   await Hive.deleteBoxFromDisk('shootsBox');
  //   await Hive.deleteBoxFromDisk('transactionsBox');
  // } catch (e) {
  //   print('Error deleting Hive boxes on startup: $e');
  // }

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
  const OmegaApp({Key? key}) : super(key: key);

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
      home: const OmegaBottomnavigationBar(),
    );
  }
}
