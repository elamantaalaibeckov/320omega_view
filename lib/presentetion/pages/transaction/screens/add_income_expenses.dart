import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omega_view_smart_plan_320/cubit/shoots/shoots_cubit.dart';
import 'package:omega_view_smart_plan_320/cubit/transactions/transactions_cubit.dart';
import 'package:omega_view_smart_plan_320/model/omega_shoot_model.dart';
import 'package:omega_view_smart_plan_320/model/omega_transaction_model.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_icons.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text_filed.dart';
import 'package:uuid/uuid.dart';

/// Один элемент расхода
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

class AddTransactionPage extends StatefulWidget {
  final OmegaTransactionModel? initialTx;
  final OmegaShootModel? initialShoot;

  const AddTransactionPage({
    Key? key,
    this.initialTx,
    this.initialShoot,
  }) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isDirty = false;
  int _tabIndex = 0;

  // ==== FIX: раздельные состояния для вкладок ====
  OmegaShootModel? _incomeShoot;
  OmegaShootModel? _expenseShoot;

  final TextEditingController _incomeAmountCtrl = TextEditingController();
  final TextEditingController _incomeCommentCtrl = TextEditingController();

  final TextEditingController _expenseCommentCtrl = TextEditingController();
  final List<ExpenseItem> _expenseItems = [];

  bool _isIncomeShootPickerOpen = false;
  bool _isExpenseShootPickerOpen = false;
  // ==============================================

  final Uuid _uuid = const Uuid();

  bool get _isEditing => widget.initialTx != null;

  bool get _canSaveTransaction {
    if (_tabIndex == 0) {
      return _incomeShoot != null && _parseAmount(_incomeAmountCtrl.text) > 0;
    } else {
      if (_expenseShoot == null) return false;
      if (_expenseItems.isEmpty) return false;
      return _expenseItems.any((e) =>
          e.nameController.text.trim().isNotEmpty &&
          _parseAmount(e.priceController.text) > 0);
    }
  }

  @override
  void initState() {
    super.initState();

    _attachDollarFormatter(_incomeAmountCtrl);

    if (_isEditing) {
      final tx = widget.initialTx!;
      if (tx.category == 'Income') {
        _tabIndex = 0;
        _incomeShoot = widget.initialShoot;
        _incomeAmountCtrl.text = _formatWithDollar(tx.amount);
        _incomeCommentCtrl.text = tx.note ?? '';

        _createEmptyExpenseItem();
      } else {
        _tabIndex = 1;
        _expenseShoot = widget.initialShoot;

        final nameCtrl = TextEditingController(text: tx.note)
          ..addListener(_updateSaveButton);
        final priceCtrl =
            TextEditingController(text: _formatWithDollar(tx.amount))
              ..addListener(_updateSaveButton);
        _attachDollarFormatter(priceCtrl);

        _expenseItems.add(
          ExpenseItem(
            id: _uuid.v4(),
            nameController: nameCtrl,
            priceController: priceCtrl,
          ),
        );
        _incomeAmountCtrl.clear();
        _incomeCommentCtrl.clear();
      }
    } else {
      _createEmptyExpenseItem();
    }

    [
      _incomeAmountCtrl,
      _incomeCommentCtrl,
      _expenseCommentCtrl,
      ..._expenseItems.map((e) => e.nameController),
      ..._expenseItems.map((e) => e.priceController),
    ].forEach((c) => c.addListener(_markDirty));

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _tabIndex,
    )..addListener(_handleTabChange);

    context.read<ShootsCubit>().loadShoots();
  }

  void _createEmptyExpenseItem() {
    if (_expenseItems.isNotEmpty) return;
    final nc = TextEditingController()..addListener(_updateSaveButton);
    final pc = TextEditingController()..addListener(_updateSaveButton);
    _attachDollarFormatter(pc);
    _expenseItems.add(
      ExpenseItem(id: _uuid.v4(), nameController: nc, priceController: pc),
    );
  }

  void _attachDollarFormatter(TextEditingController c) {
    c.addListener(() {
      final raw = c.text;
      if (raw.isEmpty || raw.startsWith('\$')) return;
      final onlyNums = raw.replaceAll(RegExp(r'[^\d.]'), '');
      final formatted = '\$ $onlyNums';
      c.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  String _formatWithDollar(num v) => '\$ ${v.toStringAsFixed(0)}';

  double _parseAmount(String t) {
    final cleaned = t.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _updateSaveButton() => setState(() {});

  void _handleTabChange() {
    if (_tabController.index == _tabIndex) return;
    setState(() {
      _tabIndex = _tabController.index;

      _isIncomeShootPickerOpen = false;
      _isExpenseShootPickerOpen = false;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();

    _incomeAmountCtrl.dispose();
    _incomeCommentCtrl.dispose();
    _expenseCommentCtrl.dispose();

    for (final e in _expenseItems) {
      e.dispose();
    }
    super.dispose();
  }

  void _addExpenseItem() {
    if (_expenseItems.isNotEmpty) {
      final last = _expenseItems.last;
      if (last.nameController.text.trim().isEmpty ||
          last.priceController.text.trim().isEmpty) {
        return;
      }
    }
    setState(() {
      final nc = TextEditingController()
        ..addListener(_markDirty)
        ..addListener(_updateSaveButton);
      final pc = TextEditingController()
        ..addListener(_markDirty)
        ..addListener(_updateSaveButton);
      _attachDollarFormatter(pc);
      _expenseItems.add(
        ExpenseItem(id: _uuid.v4(), nameController: nc, priceController: pc),
      );
    });
  }

  void _removeExpenseItem(String id) {
    setState(() {
      final idx = _expenseItems.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _expenseItems[idx].dispose();
        _expenseItems.removeAt(idx);
        if (_expenseItems.isEmpty) _createEmptyExpenseItem();
      }
    });
  }

  double _calculateTotalExpenses() => _expenseItems.fold(
      0.0, (sum, e) => sum + _parseAmount(e.priceController.text));

  bool _expenseRowFilled(ExpenseItem e) =>
      e.nameController.text.trim().isNotEmpty &&
      _parseAmount(e.priceController.text) > 0;

  Future<void> _saveTransaction() async {
    if (!_canSaveTransaction) {
      return;
    }

    final cubit = context.read<TransactionsCubit>();
    if (_isEditing) {
      await cubit.deleteTransaction(widget.initialTx!.id);
    }

    if (_tabIndex == 0) {
      final amount = _parseAmount(_incomeAmountCtrl.text);
      final tx = OmegaTransactionModel(
        id: _uuid.v4(),
        shootId: _incomeShoot!.id,
        amount: amount,
        category: 'Income',
        date: DateTime.now(),
        note: _incomeCommentCtrl.text.isEmpty ? null : _incomeCommentCtrl.text,
      );
      await cubit.addTransaction(tx);
    } else {
      for (final item in _expenseItems) {
        final name = item.nameController.text.trim();
        final price = _parseAmount(item.priceController.text);
        if (name.isEmpty || price <= 0) continue;
        final tx = OmegaTransactionModel(
          id: _uuid.v4(),
          shootId: _expenseShoot!.id,
          amount: price,
          category: 'Expense',
          date: DateTime.now(),
          note: name,
        );
        await cubit.addTransaction(tx);
      }
    }

    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('Delete Transaction?', style: TextStyle(fontSize: 17.sp)),
        content: Text(
          'If you delete this transaction, you will not be able to recover it.',
          style: TextStyle(fontSize: 13.sp),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await context
          .read<TransactionsCubit>()
          .deleteTransaction(widget.initialTx!.id);
      Navigator.of(context).pop();
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;
    final leave = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('Leave the page?', style: TextStyle(fontSize: 17.sp)),
        content: Text(
          'You have unsaved changes. Are you sure you want to leave?',
          style: TextStyle(fontSize: 13.sp),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: const Text('Leave',
                style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return leave ?? false;
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: AppColors.bottomNavigatorAppBarColor,
          leading: const BackButton(color: Colors.white),
          title: Text(
            _isEditing ? 'Edit Transaction' : 'Add Transaction',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
          actions: [
            if (_isEditing)
              IconButton(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                icon: Image.asset(
                  AppIcons.deleteshoot,
                  width: 24.w,
                  height: 24.h,
                ),
                onPressed: _confirmDelete,
              ),
          ],
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
                      dividerColor: AppColors.bgColor,
                      controller: _tabController,
                      indicator: BoxDecoration(
                        border: Border.all(color: accent, width: 1.5),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppColors.textWhite,
                      unselectedLabelColor: AppColors.textgrey,
                      labelStyle: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w500),
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
                  onPressed: _canSaveTransaction ? _saveTransaction : null,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      return states.contains(WidgetState.disabled)
                          ? AppColors.grey2
                          : AppColors.mainAccent;
                    }),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r)),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Save' : 'Add',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Income UI ----------
  Widget _buildIncomeForm(List<OmegaShootModel> shoots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Income Amount'),
        SizedBox(height: 8.h),
        AppTextField(
          hintText: 'Add Income',
          controller: _incomeAmountCtrl,
          isNumberOnly: true,
          onChanged: (_) => _updateSaveButton(),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Select Shoot'),
        SizedBox(height: 8.h),
        _buildShootPickerButton(
          selected: _incomeShoot,
          isOpen: _isIncomeShootPickerOpen,
          onToggle: () => setState(
              () => _isIncomeShootPickerOpen = !_isIncomeShootPickerOpen),
          onSelect: (s) => setState(() {
            _incomeShoot = s;
            _isIncomeShootPickerOpen = false;
            _updateSaveButton();
          }),
        ),
        if (_isIncomeShootPickerOpen)
          _buildShootList(
            shoots: shoots,
            selected: _incomeShoot,
            onSelect: (s) => setState(() {
              _incomeShoot = s;
              _isIncomeShootPickerOpen = false;
              _updateSaveButton();
            }),
          ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Comments (optional)'),
        SizedBox(height: 8.h),
        AppTextField(
          hintText: 'Add Comments',
          controller: _incomeCommentCtrl,
          onChanged: (_) => _updateSaveButton(),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  // ---------- Expenses UI ----------
  Widget _buildExpensesForm(List<OmegaShootModel> shoots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Select Shoot'),
        SizedBox(height: 8.h),
        _buildShootPickerButton(
          selected: _expenseShoot,
          isOpen: _isExpenseShootPickerOpen,
          onToggle: () => setState(
              () => _isExpenseShootPickerOpen = !_isExpenseShootPickerOpen),
          onSelect: (s) => setState(() {
            _expenseShoot = s;
            _isExpenseShootPickerOpen = false;
            _updateSaveButton();
          }),
        ),
        if (_isExpenseShootPickerOpen)
          _buildShootList(
            shoots: shoots,
            selected: _expenseShoot,
            onSelect: (s) => setState(() {
              _expenseShoot = s;
              _isExpenseShootPickerOpen = false;
              _updateSaveButton();
            }),
          ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Expenses'),
        SizedBox(height: 8.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: _expenseItems.length,
          itemBuilder: (context, idx) {
            final e = _expenseItems[idx];
            final filled = _expenseRowFilled(e);
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.filedGrey,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      hintText: 'Add name',
                      controller: e.nameController,
                      fillColor: AppColors.cardGrey,
                      onChanged: (_) => _updateSaveButton(),
                    ),
                    SizedBox(height: 12.h),
                    AppTextField(
                      hintText: 'Add Price',
                      controller: e.priceController,
                      fillColor: AppColors.cardGrey,
                      isNumberOnly: true,
                      onChanged: (_) => _updateSaveButton(),
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
                                color: AppColors.filedGrey,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Image.asset(
                                  AppIcons.deleteshoot,
                                  width: 18.w,
                                  height: 22.h,
                                  color: filled
                                      ? AppColors.textWhite
                                      : AppColors.textWhite.withOpacity(0.5),
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
              backgroundColor: AppColors.addexpense,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
            ),
            child: Text(
              'Add Expense',
              style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            Text('\$${_calculateTotalExpenses().toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Comments (optional)'),
        SizedBox(height: 8.h),
        AppTextField(
          hintText: 'Add Comments',
          controller: _expenseCommentCtrl,
          onChanged: (_) => _updateSaveButton(),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  // ---------- Общие виджеты ----------
  Widget _buildShootPickerButton({
    required OmegaShootModel? selected,
    required bool isOpen,
    required VoidCallback onToggle,
    required ValueChanged<OmegaShootModel> onSelect,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.filedGrey,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: selected == null
                  ? Text('Select',
                      style:
                          TextStyle(color: AppColors.textgrey, fontSize: 14.sp))
                  : _buildSelectedShoot(selected),
            ),
            if (selected != null &&
                selected.finalShotsPaths != null &&
                selected.finalShotsPaths!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.file(
                    File(selected.finalShotsPaths!.first),
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40.w,
                      height: 40.h,
                      color: AppColors.textgrey.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            Icon(
              isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: AppColors.textgrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShootList({
    required List<OmegaShootModel> shoots,
    required OmegaShootModel? selected,
    required ValueChanged<OmegaShootModel> onSelect,
  }) {
    final visibleCount = min(shoots.length, 3);
    final itemHeight = 80.h;
    final separator = 12.h;
    final totalHeight =
        visibleCount * itemHeight + max(0, visibleCount - 1) * separator + 24.h;

    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Container(
        height: totalHeight,
        decoration: BoxDecoration(
          color: AppColors.filedGrey,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          itemCount: shoots.length,
          separatorBuilder: (_, __) => SizedBox(height: separator),
          itemBuilder: (context, i) {
            final shoot = shoots[i];
            final isSel = selected?.id == shoot.id;
            final dt = DateTime(
              shoot.date.year,
              shoot.date.month,
              shoot.date.day,
              shoot.time.hour,
              shoot.time.minute,
            );
            File? preview;
            final photos = shoot.finalShotsPaths ?? [];
            if (photos.isNotEmpty) {
              final f = File(photos.first);
              if (f.existsSync()) preview = f;
            }
            return InkWell(
              onTap: () => onSelect(shoot),
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                height: 80.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.cardGrey,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSel ? AppColors.mainAccent : AppColors.cardGrey,
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
}
