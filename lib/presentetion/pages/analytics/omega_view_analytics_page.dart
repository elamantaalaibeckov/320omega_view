import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omega_view_smart_plan_320/cubit/shoots/shoots_cubit.dart';
import 'package:omega_view_smart_plan_320/cubit/transactions/transactions_cubit.dart';
import 'package:omega_view_smart_plan_320/model/omega_shoot_model.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';

class OmegaViewAnalyticsPage extends StatefulWidget {
  const OmegaViewAnalyticsPage({Key? key}) : super(key: key);

  @override
  State<OmegaViewAnalyticsPage> createState() => _OmegaViewAnalyticsPageState();
}

class _OmegaViewAnalyticsPageState extends State<OmegaViewAnalyticsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<int> _periodDays = [7, 30, 90, 180];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _periodDays.length, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txState = context.watch<TransactionsCubit>().state;
    final allTx = txState.transactions;
    final shoots = context.watch<ShootsCubit>().state.shoots;

    final now = DateTime.now();
    final days = _periodDays[_tabController.index];
    final from = now.subtract(Duration(days: days));

    final periodTx =
        allTx.where((t) => t.date.isAfter(from) && t.date.isBefore(now));

    // Суммы
    final incomeSum = periodTx
        .where((t) => t.category == 'Income')
        .map((t) => t.amount)
        .fold(0.0, (a, b) => a + b);
    final expenseSum = periodTx
        .where((t) => t.category == 'Expense')
        .map((t) => t.amount)
        .fold(0.0, (a, b) => a + b);

    // Топ‑5 клиентов по доходу
    final Map<String, double> incomeByClient = {};
    for (var t in periodTx.where((t) => t.category == 'Income')) {
      final shoot = shoots.firstWhere((s) => s.id == t.shootId,
          orElse: () => OmegaShootModel.empty());
      incomeByClient.update(
        shoot.clientName,
        (prev) => prev + t.amount,
        ifAbsent: () => t.amount,
      );
    }
    final topClients = incomeByClient.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = topClients.take(5).toList();
    final totalTopIncome = top5.map((e) => e.value).fold(0.0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavigatorAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Analytics',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          children: [
            // Периоды
            TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                border: Border.all(color: AppColors.mainAccent, width: 1.5),
                borderRadius: BorderRadius.circular(16.r),
              ),
              labelColor: AppColors.textWhite,
              unselectedLabelColor: AppColors.textgrey,
              labelStyle:
                  TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: '1 week'),
                Tab(text: '1 month'),
                Tab(text: '3 months'),
                Tab(text: '6 months'),
              ],
            ),
            SizedBox(height: 24.h),
            // Donut chart
            SizedBox(
              width: 200.w,
              height: 200.h,
              child: CustomPaint(
                painter: _DonutPainter(
                  income: incomeSum,
                  expense: expenseSum,
                ),
                child: Center(
                  child: Text(
                    // знак минус, если расход больше
                    '${(incomeSum - expenseSum) < 0 ? '-' : ''}'
                    '\$${(incomeSum - expenseSum).abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      color: (incomeSum >= expenseSum)
                          ? AppColors.mainAccent
                          : Colors.redAccent,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // карточки Income / Expense
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InfoCard(
                  color: AppColors.mainAccent,
                  label: 'Income',
                  amount: incomeSum,
                ),
                _InfoCard(
                  color: Colors.redAccent,
                  label: 'Expenses',
                  amount: expenseSum,
                ),
              ],
            ),
            SizedBox(height: 24.h),
            // Top 5 clients
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Top 5 clients:',
                style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: top5.isEmpty
                  ? Center(
                      child: Text(
                        'No top clients have been selected yet',
                        style: TextStyle(
                            color: AppColors.textgrey, fontSize: 14.sp),
                      ),
                    )
                  : ListView.separated(
                      itemCount: top5.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (context, i) {
                        final entry = top5[i];
                        final clientName = entry.key;
                        final clientSum = entry.value;
                        // найдём первый shoot с этим клиентом для фото
                        final firstShoot = shoots.firstWhere(
                          (s) => s.clientName == clientName,
                          orElse: () => OmegaShootModel.empty(),
                        );
                        File? preview;
                        if (firstShoot.finalShotsPaths != null &&
                            firstShoot.finalShotsPaths!.isNotEmpty) {
                          final f = File(firstShoot.finalShotsPaths!.first);
                          if (f.existsSync()) preview = f;
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardGrey,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 12.h, horizontal: 12.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(clientName,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '\$${clientSum.toStringAsFixed(0)}',
                                      style: TextStyle(
                                          color: AppColors.textgrey,
                                          fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ),
                              if (preview != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.file(preview,
                                      width: 40.w,
                                      height: 40.h,
                                      fit: BoxFit.cover),
                                ),
                              SizedBox(width: 8.w),
                              Container(
                                width: 32.w,
                                height: 32.h,
                                decoration: BoxDecoration(
                                  color: AppColors.grey2,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Text(
                                    '+${entry.value == 0 ? 0 : '+'}',
                                    style: TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 12.sp),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // итог
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total income from top clients',
                  style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${totalTopIncome.toStringAsFixed(0)}',
                  style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

/// Рисует donut-диаграмму
class _DonutPainter extends CustomPainter {
  final double income, expense;
  _DonutPainter({required this.income, required this.expense});

  @override
  void paint(Canvas canvas, Size size) {
    final total = income + expense;
    final rect = Offset.zero & size;
    final thickness = size.width * 0.15;
    final paintBg = Paint()
      ..color = AppColors.grey2
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawArc(rect, 0, 2 * pi, false, paintBg);
    if (total > 0) {
      final paintInc = Paint()
        ..color = AppColors.mainAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;
      final paintExp = Paint()
        ..color = Colors.redAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;
      final sweepInc = 2 * pi * (income / total);
      canvas.drawArc(
        rect,
        -pi / 2,
        sweepInc,
        false,
        paintInc,
      );
      canvas.drawArc(
        rect,
        -pi / 2 + sweepInc,
        2 * pi - sweepInc,
        false,
        paintExp,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

/// Небольшая карточка с цифрой
class _InfoCard extends StatelessWidget {
  final Color color;
  final String label;
  final double amount;

  const _InfoCard({
    Key? key,
    required this.color,
    required this.label,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 4.h),
          Text('\$${amount.toStringAsFixed(0)}',
              style: TextStyle(color: color, fontSize: 16.sp)),
        ],
      ),
    );
  }
}
