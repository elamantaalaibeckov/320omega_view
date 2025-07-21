import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/transaction/screens/add_income_expenses.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/transaction/screens/transacktion_card.dart';

import '../../../model/omega_shoot_model.dart';
import '../../../model/omega_transaction_model.dart';
import '../../../cubit/shoots/shoots_cubit.dart';
import '../../../cubit/transactions/transactions_cubit.dart';
import '../../themes/app_colors.dart';

class OmegaViewTransactionPage extends StatefulWidget {
  const OmegaViewTransactionPage({Key? key}) : super(key: key);

  @override
  State<OmegaViewTransactionPage> createState() =>
      _OmegaViewTransactionPageState();
}

class _OmegaViewTransactionPageState extends State<OmegaViewTransactionPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Состояния кубитов
    final txState = context.watch<TransactionsCubit>().state;
    final shootsState = context.watch<ShootsCubit>().state;

    final allTx = txState.transactions;
    final incomeTx = allTx.where((t) => t.category == 'Income').toList();
    final expenseTx = allTx.where((t) => t.category == 'Expense').toList();

    final accent = AppColors.mainAccent;
    final idx = _tc.index;
    final indicatorRadius = idx == 0
        ? BorderRadius.only(
            topLeft: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
          )
        : idx == 2
            ? BorderRadius.only(
                topRight: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              )
            : BorderRadius.zero;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.bottomNavigatorAppBarColor,
        title: Text('Transaction',
            style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: TabBar(
              controller: _tc,
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
                Tab(text: 'All'),
                Tab(text: 'Income'),
                Tab(text: 'Expenses')
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tc,
              children: [
                _buildList(allTx, shootsState.shoots),
                _buildList(incomeTx, shootsState.shoots),
                _buildList(expenseTx, shootsState.shoots),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        child: const Icon(Icons.add, color: AppColors.textWhite),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
          );
        },
      ),
    );
  }

  Widget _buildList(
      List<OmegaTransactionModel> list, List<OmegaShootModel> shoots) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          'No transactions',
          style: TextStyle(color: AppColors.textgrey, fontSize: 18.sp),
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final tx = list[i];
        final shoot = shoots.firstWhere((s) => s.id == tx.shootId,
            orElse: () => OmegaShootModel.empty());
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: TransactionCard(transaction: tx, shoot: shoot),
        );
      },
    );
  }
}
