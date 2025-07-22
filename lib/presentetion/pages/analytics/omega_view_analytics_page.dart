import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omega_view_smart_plan_320/cubit/transactions/transactions_cubit.dart';
import 'package:omega_view_smart_plan_320/cubit/shoots/shoots_cubit.dart';
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

  // 1 неделя, 1 месяц, 3 месяца, 6 месяцев
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

    final incomeSum = periodTx
        .where((t) => t.category == 'Income')
        .map((t) => t.amount)
        .fold(0.0, (a, b) => a + b);
    final expenseSum = periodTx
        .where((t) => t.category == 'Expense')
        .map((t) => t.amount)
        .fold(0.0, (a, b) => a + b);

    // топ-5 клиентов по доходу
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

    // стили для табов
    final accent = AppColors.mainAccent;
    final idx = _tabController.index;
    final indicatorRadius = idx == 0
        ? BorderRadius.only(
            topLeft: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
          )
        : idx == _periodDays.length - 1
            ? BorderRadius.only(
                topRight: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              )
            : BorderRadius.zero;

    final net = incomeSum - expenseSum;
    final netColor = net >= 0 ? accent : Colors.redAccent;

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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          children: [
            // TabBar
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: AppColors.bgColor,
                  isScrollable: false,
                  indicator: BoxDecoration(
                    border: Border.all(color: accent, width: 1.5),
                    borderRadius: indicatorRadius,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppColors.textWhite,
                  unselectedLabelColor: AppColors.textgrey,
                  labelStyle:
                      TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: '1 week'),
                    Tab(text: '1 month'),
                    Tab(text: '3 months'),
                    Tab(text: '6 months'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Donut chart
            SizedBox(
              width: 220.w,
              height: 220.h,
              child: CustomPaint(
                painter: _DonutPainter(income: incomeSum, expense: expenseSum),
                child: Center(
                  child: Text(
                    '${net < 0 ? '-' : ''}\$${net.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      color: netColor,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // InfoCards
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    label: 'Income',
                    amount: incomeSum,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _InfoCard(
                    label: 'Expenses',
                    amount: expenseSum,
                  ),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.filedGrey,
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              child: top5.isEmpty
                  ? Center(
                      child: Text(
                        'No top clients have been selected yet',
                        style: TextStyle(
                            color: AppColors.textgrey, fontSize: 14.sp),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: top5.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (context, i) {
                        final entry = top5[i];
                        final clientName = entry.key;
                        final clientSum = entry.value;
                        final firstShoot = shoots.firstWhere(
                          (s) => s.clientName == clientName,
                          orElse: () => OmegaShootModel.empty(),
                        );

                        // фотография клиента
                        File? preview;
                        final photos = firstShoot.finalShotsPaths ?? [];
                        if (photos.isNotEmpty) {
                          final f = File(photos.first);
                          if (f.existsSync()) preview = f;
                        }

                        // бейдж +N
                        final badgeCount =
                            photos.length > 1 ? photos.length - 1 : 0;

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
                                    Text(
                                      clientName,
                                      style: TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '\$${clientSum.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (preview != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: SizedBox(
                                    width: 40.w,
                                    height: 40.h,
                                    child:
                                        Image.file(preview, fit: BoxFit.cover),
                                  ),
                                ),
                              SizedBox(width: 8.w),
                              if (badgeCount > 0)
                                Container(
                                  width: 40.w,
                                  height: 40.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.grey2,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+$badgeCount',
                                      style: TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total income from top clients',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${totalTopIncome.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
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

class _DonutPainter extends CustomPainter {
  final double income, expense;
  const _DonutPainter({required this.income, required this.expense});

  @override
  void paint(Canvas canvas, Size size) {
    final total = income + expense;
    final rect = Offset.zero & size;
    final thickness = size.width * 0.15;

    // фон
    final paintBg = Paint()
      ..color = AppColors.grey2
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawArc(rect, 0, 2 * pi, false, paintBg);

    if (total > 0) {
      final paintInc = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;
      final paintExp = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;

      final sweepInc = 2 * pi * (income / total);
      canvas.drawArc(rect, -pi / 2, sweepInc, false, paintInc);
      canvas.drawArc(
          rect, -pi / 2 + sweepInc, 2 * pi - sweepInc, false, paintExp);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _InfoCard extends StatelessWidget {
  final String label; // "Income" или "Expenses"
  final double amount;

  const _InfoCard({
    super.key,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = label == 'Income';
    final Color dotColor = isIncome ? Colors.green : Colors.red;
    final Color textColor = AppColors.textWhite;
    final Color amountColor = AppColors.textgrey;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: amountColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
