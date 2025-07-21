import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omega_view_smart_plan_320/cubit/shoots/shoots_cubit.dart';
import 'package:omega_view_smart_plan_320/cubit/transactions/transactions_cubit.dart';
import 'package:omega_view_smart_plan_320/model/omega_shoot_model.dart';
import 'package:omega_view_smart_plan_320/model/omega_transaction_model.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text_filed.dart';
import 'package:uuid/uuid.dart';

/// Represents a single expense item with its name and price controllers.
class ExpenseItem {
  final String id;
  final TextEditingController nameController;
  final TextEditingController priceController;

  ExpenseItem({
    required this.id,
    required this.nameController,
    required this.priceController,
  });

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}

/// A page for adding income or expense transactions related to shoots.
class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _tabIndex = 0;

  OmegaShootModel? _selectedShoot;
  final TextEditingController _commentsController = TextEditingController();
  bool _isShootPickerOpen = false;
  final TextEditingController _incomeAmountController = TextEditingController();

  final List<ExpenseItem> _expenseItems = [];
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabSelection);
    context.read<ShootsCubit>().loadShoots();
  }

  void _handleTabSelection() {
    setState(() {
      _tabIndex = _tabController.index;
      _selectedShoot = null;
      _isShootPickerOpen = false;
      _incomeAmountController.clear();
      _commentsController.clear();
      _disposeExpenseItems();
      _expenseItems.clear();
      if (_tabIndex == 1) _addExpenseItem();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _incomeAmountController.dispose();
    _commentsController.dispose();
    _disposeExpenseItems();
    super.dispose();
  }

  void _disposeExpenseItems() {
    for (var item in _expenseItems) item.dispose();
  }

  void _addExpenseItem() {
    if (_expenseItems.isNotEmpty) {
      final last = _expenseItems.last;
      if (last.nameController.text.trim().isEmpty ||
          last.priceController.text.trim().isEmpty) {
        _showSnackBar(
          'Заполните все поля текущего расхода перед добавлением нового.',
          Colors.red,
        );
        return;
      }
    }
    setState(() {
      _expenseItems.add(
        ExpenseItem(
          id: _uuid.v4(),
          nameController: TextEditingController(),
          priceController: TextEditingController(),
        ),
      );
    });
  }

  void _removeExpenseItem(String id) {
    setState(() {
      final idx = _expenseItems.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _expenseItems[idx].dispose();
        _expenseItems.removeAt(idx);
        if (_expenseItems.isEmpty) _addExpenseItem();
      }
    });
  }

  double _calculateTotalExpenses() {
    return _expenseItems.fold(0.0, (sum, item) {
      final p = double.tryParse(item.priceController.text) ?? 0;
      return sum + p;
    });
  }

  Future<void> _addTransaction() async {
    if (_selectedShoot == null) {
      _showSnackBar('Пожалуйста, выберите съемку.', Colors.red);
      return;
    }

    final transactionsCubit = context.read<TransactionsCubit>();

    if (_tabIndex == 0) {
      // Income
      final amount = double.tryParse(_incomeAmountController.text) ?? 0;
      if (amount <= 0) {
        _showSnackBar('Введите корректную сумму дохода.', Colors.red);
        return;
      }

      final tx = OmegaTransactionModel(
        id: _uuid.v4(),
        shootId: _selectedShoot!.id,
        amount: amount,
        category: 'Income',
        date: DateTime.now(),
        note:
            _commentsController.text.isEmpty ? null : _commentsController.text,
      );

      await transactionsCubit.addTransaction(tx);
    } else {
      // Expenses: создаём отдельную транзакцию на каждую статью расхода
      for (var item in _expenseItems) {
        final name = item.nameController.text.trim();
        final price = double.tryParse(item.priceController.text) ?? 0;
        if (name.isEmpty || price <= 0) continue;

        final tx = OmegaTransactionModel(
          id: _uuid.v4(),
          shootId: _selectedShoot!.id,
          amount: price,
          category: 'Expense',
          date: DateTime.now(),
          note: name,
        );
        await transactionsCubit.addTransaction(tx);
      }
    }

    Navigator.pop(context);
    _showSnackBar('Транзакция успешно добавлена!', AppColors.mainAccent);
  }

  void _showSnackBar(String msg, Color bg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: bg));
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.mainAccent;
    final shoots = context
        .watch<ShootsCubit>()
        .state
        .shoots
        .where((s) => !s.isPlanned)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavigatorAppBarColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text('Add Transaction',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 80.h),
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      border: Border.all(color: accent, width: 1.5),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.textWhite,
                    unselectedLabelColor: AppColors.textgrey,
                    labelStyle:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                    tabs: const [Tab(text: 'Income'), Tab(text: 'Expenses')],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _tabIndex == 0
                        ? _buildIncomeForm(shoots)
                        : _buildExpensesForm(shoots),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
            child: SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: _addTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r)),
                ),
                child: Text('Add',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedShoot(OmegaShootModel shoot) {
    final dt = DateTime(
      shoot.date.year,
      shoot.date.month,
      shoot.date.day,
      shoot.time.hour,
      shoot.time.minute,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat('MMM d, yyyy, h:mm a').format(dt),
          style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4.h),
        Text(
          '${shoot.clientName}, ${shoot.address}',
          style: TextStyle(color: AppColors.textgrey, fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildIncomeForm(List<OmegaShootModel> shoots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        AppTexts(texTs: 'Income Amount'),
        SizedBox(height: 8.h),
        AppTextField(
          hintText: 'Add Income',
          controller: _incomeAmountController,
          isNumberOnly: true,
        ),
        SizedBox(height: 16.h),
        AppTexts(texTs: 'Select Shoot'),
        SizedBox(height: 8.h),
        _buildShootPickerButton(),
        if (_isShootPickerOpen) _buildShootList(shoots),
        SizedBox(height: 16.h),
        AppTexts(texTs: 'Comments (optional)'),
        SizedBox(height: 8.h),
        AppTextField(
          hintText: 'Add Comments',
          controller: _commentsController,
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildExpensesForm(List<OmegaShootModel> shoots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        AppTexts(texTs: 'Select Shoot'),
        SizedBox(height: 8.h),
        _buildShootPickerButton(),

        // список съёмок с BouncingScrollPhysics
        if (_isShootPickerOpen)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Container(
              height: 288.h,
              decoration: BoxDecoration(
                color: AppColors.filedGrey,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                itemCount: shoots.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, i) {
                  final shoot = shoots[i];
                  final isSel = _selectedShoot?.id == shoot.id;
                  final dt = DateTime(shoot.date.year, shoot.date.month,
                      shoot.date.day, shoot.time.hour, shoot.time.minute);
                  File? preview;
                  final photos = shoot.finalShotsPaths ?? [];
                  if (photos.isNotEmpty) {
                    final f = File(photos.first);
                    if (f.existsSync()) preview = f;
                  }
                  return InkWell(
                    onTap: () => setState(() {
                      _selectedShoot = shoot;
                      _isShootPickerOpen = false;
                    }),
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      height: 80.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: AppColors.cardGrey,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color:
                              isSel ? AppColors.mainAccent : AppColors.cardGrey,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('MMM d, yyyy, h:mm a').format(dt),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  shoot.clientName,
                                  style: TextStyle(
                                      color: AppColors.textgrey,
                                      fontSize: 14.sp),
                                ),
                              ],
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: preview != null
                                ? Image.file(preview,
                                    width: 40.w,
                                    height: 40.h,
                                    fit: BoxFit.cover)
                                : Container(
                                    width: 40.w,
                                    height: 40.h,
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.textgrey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(
                                      photos.isNotEmpty
                                          ? Icons.broken_image
                                          : Icons.no_photography_outlined,
                                      color: AppColors.textgrey,
                                      size: 24.r,
                                    ),
                                  ),
                          ),
                          if (photos.length > 1)
                            Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: Container(
                                width: 40.w,
                                height: 40.h,
                                decoration: BoxDecoration(
                                  color: AppColors.grey2,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Text(
                                    '+${photos.length - 1}',
                                    style: TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        SizedBox(height: 16.h),
        AppTexts(texTs: 'Expenses'),
        SizedBox(height: 8.h),

        // список полей расходов с BouncingScrollPhysics
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: _expenseItems.length,
          itemBuilder: (context, idx) {
            final e = _expenseItems[idx];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.filedGrey,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      hintText: 'Add name',
                      controller: e.nameController,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 12.h),
                    AppTextField(
                      hintText: 'Add Price',
                      controller: e.priceController,
                      isNumberOnly: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    if (idx > 0)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () => _removeExpenseItem(e.id),
                            borderRadius: BorderRadius.circular(8.r),
                            child: Container(
                              width: 48.w,
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: AppColors.bottomNavigatorAppBarColor,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.delete_outline,
                                  color: AppColors.textgrey,
                                  size: 24.r,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: _addExpenseItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r)),
            ),
            child: Text('Add Expense',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600)),
          ),
        ),

        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600)),
            Text('\$${_calculateTotalExpenses().toStringAsFixed(2)}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600)),
          ],
        ),

        SizedBox(height: 16.h),
        AppTexts(texTs: 'Comments (optional)'),
        SizedBox(height: 8.h),
        AppTextField(
          hintText: 'Add Comments',
          controller: _commentsController,
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildShootPickerButton() {
    return GestureDetector(
      onTap: () => setState(() => _isShootPickerOpen = !_isShootPickerOpen),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.filedGrey,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: _selectedShoot == null
                  ? Text('Select',
                      style:
                          TextStyle(color: AppColors.textgrey, fontSize: 14.sp))
                  : _buildSelectedShoot(_selectedShoot!),
            ),
            if (_selectedShoot != null &&
                _selectedShoot!.finalShotsPaths != null &&
                _selectedShoot!.finalShotsPaths!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.file(
                    File(_selectedShoot!.finalShotsPaths!.first),
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40.w,
                      height: 40.h,
                      color: AppColors.textgrey.withOpacity(0.2),
                      child: Icon(Icons.broken_image,
                          color: AppColors.textgrey, size: 24.r),
                    ),
                  ),
                ),
              ),
            Icon(
              _isShootPickerOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: AppColors.textgrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShootList(List<OmegaShootModel> shoots,
      {bool isExpanded = false}) {
    final visibleCount = isExpanded ? shoots.length : min(shoots.length, 3);
    final itemHeight = 80.h;
    final separator = 12.h;
    final totalHeight =
        visibleCount * itemHeight + max(0, visibleCount - 1) * separator + 24.h;

    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Container(
        height: isExpanded ? null : totalHeight,
        decoration: BoxDecoration(
          color: AppColors.filedGrey,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ListView.separated(
          shrinkWrap: isExpanded,
          physics: isExpanded
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          itemCount: shoots.length,
          separatorBuilder: (_, __) => SizedBox(height: separator),
          itemBuilder: (context, i) {
            final shoot = shoots[i];
            final isSel = _selectedShoot?.id == shoot.id;
            final dt = DateTime(shoot.date.year, shoot.date.month,
                shoot.date.day, shoot.time.hour, shoot.time.minute);
            File? preview;
            final photos = shoot.finalShotsPaths ?? [];
            if (photos.isNotEmpty) {
              final f = File(photos.first);
              if (f.existsSync()) preview = f;
            }
            return InkWell(
              onTap: () => setState(() {
                _selectedShoot = shoot;
                _isShootPickerOpen = false;
              }),
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                height: itemHeight,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.cardGrey,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                      color: isSel ? AppColors.mainAccent : AppColors.cardGrey,
                      width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy, h:mm a').format(dt),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            shoot.clientName,
                            style: TextStyle(
                                color: AppColors.textgrey, fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: preview != null
                          ? Image.file(preview,
                              width: 40.w, height: 40.h, fit: BoxFit.cover)
                          : Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: AppColors.textgrey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                  photos.isNotEmpty
                                      ? Icons.broken_image
                                      : Icons.no_photography_outlined,
                                  color: AppColors.textgrey,
                                  size: 24.r),
                            ),
                    ),
                    if (photos.length > 1)
                      Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: AppColors.grey2,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              '+${photos.length - 1}',
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
