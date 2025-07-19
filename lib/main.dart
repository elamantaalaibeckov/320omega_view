import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:omega_view_smart_plan_320/presentetion/pages/omega_bottomnavigation_bar.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'model/service/shoots_hive_service.dart';
import 'model/service/transaction_hive_service.dart';
import 'cubit/shoots/shoots_cubit.dart';
import 'cubit/transactions/transactions_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // -------- очистка бокса (выполни один раз и потом удали строку) ----------
  await Hive.deleteBoxFromDisk('shootsBox');
  // ------------------------------------------------------------------------

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
