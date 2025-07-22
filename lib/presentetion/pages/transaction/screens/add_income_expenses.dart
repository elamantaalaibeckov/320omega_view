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
import 'package:omega_view_smart_plan_320/presentetion/themes/app_icons.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text_filed.dart';
import 'package:uuid/uuid.dart';

/// Для одного поля расхода
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

/// Страница добавления/редактирования транзакции
class AddTransactionPage extends StatefulWidget {
  /// Если передаём existing, то работаем в режиме редактирования
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
  bool _isDirty = false; // флаг изменений
  int _tabIndex = 0;

  OmegaShootModel? _selectedShoot;
  final TextEditingController _incomeAmountController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  bool _isShootPickerOpen = false;

  final List<ExpenseItem> _expenseItems = [];
  final Uuid _uuid = const Uuid();

  bool get _isEditing => widget.initialTx != null;

  // Новое свойство для определения, можно ли сохранить транзакцию
  bool get _canSaveTransaction {
    if (_selectedShoot == null) return false;

    if (_tabIndex == 0) {
      // Income tab
      return (_incomeAmountController.text.isNotEmpty &&
          (double.tryParse(_incomeAmountController.text) ?? 0) > 0);
    } else {
      // Expenses tab
      if (_expenseItems.isEmpty) return false;
      // Проверяем, что хотя бы один элемент расхода заполнен полностью
      return _expenseItems.any((item) =>
          item.nameController.text.trim().isNotEmpty &&
          (double.tryParse(item.priceController.text) ?? 0) > 0);
    }
  }

  @override
  void initState() {
    super.initState();
    // Если редактируем, префилл контроллеров
    if (_isEditing) {
      final tx = widget.initialTx!;
      _selectedShoot = widget.initialShoot;
      if (tx.category == 'Income') {
        _tabIndex = 0;
        _incomeAmountController.text = tx.amount.toStringAsFixed(0);
        _commentsController.text = tx.note ?? '';
      } else {
        _tabIndex = 1;
        _expenseItems.add(
          ExpenseItem(
            id: _uuid.v4(),
            nameController: TextEditingController(text: tx.note)
              ..addListener(_updateSaveButton), // Добавляем слушатель
            priceController:
                TextEditingController(text: tx.amount.toStringAsFixed(0))
                  ..addListener(_updateSaveButton), // Добавляем слушатель
          ),
        );
      }
    } else {
      // при добавлении в расходах создаём пустой item
      _expenseItems.add(
        ExpenseItem(
          id: _uuid.v4(),
          nameController: TextEditingController()
            ..addListener(_updateSaveButton), // Добавляем слушатель
          priceController: TextEditingController()
            ..addListener(_updateSaveButton), // Добавляем слушатель
        ),
      );
    }

    // слушатели для dirty‑флага
    _incomeAmountController.addListener(_markDirty);
    _commentsController.addListener(_markDirty);
    _incomeAmountController
        .addListener(_updateSaveButton); // Добавляем слушатель для Income
    _commentsController
        .addListener(_updateSaveButton); // Добавляем слушатель для Comments

    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabSelection);

    context.read<ShootsCubit>().loadShoots();
  }

  void _markDirty([_]) {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  // Новый метод для обновления состояния кнопки "Add/Save"
  void _updateSaveButton() {
    setState(() {
      // Это пустой setState, но он заставит виджет перестроиться
      // и пересчитать значение _canSaveTransaction
    });
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
      _isDirty = true;
      _updateSaveButton(); // Обновляем состояние кнопки при смене вкладки
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _incomeAmountController
        .removeListener(_updateSaveButton); // Удаляем слушатель
    _incomeAmountController.dispose();
    _commentsController.removeListener(_updateSaveButton); // Удаляем слушатель
    _commentsController.dispose();
    _disposeExpenseItems();
    super.dispose();
  }

  void _disposeExpenseItems() {
    for (var item in _expenseItems) item.dispose();
  }

  void _addExpenseItem() {
    // валидируем предыдущий
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
          nameController: TextEditingController()
            ..addListener(_markDirty)
            ..addListener(_updateSaveButton),
          priceController: TextEditingController()
            ..addListener(_markDirty)
            ..addListener(_updateSaveButton),
        ),
      );
      _isDirty = true;
      _updateSaveButton(); // Обновляем состояние кнопки
    });
  }

  void _removeExpenseItem(String id) {
    setState(() {
      final idx = _expenseItems.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _expenseItems[idx]
            .nameController
            .removeListener(_updateSaveButton); // Удаляем слушатель
        _expenseItems[idx]
            .priceController
            .removeListener(_updateSaveButton); // Удаляем слушатель
        _expenseItems[idx].dispose();
        _expenseItems.removeAt(idx);
        if (_expenseItems.isEmpty) _addExpenseItem();
        _isDirty = true;
        _updateSaveButton(); // Обновляем состояние кнопки
      }
    });
  }

  double _calculateTotalExpenses() {
    return _expenseItems.fold(0.0, (sum, item) {
      final p = double.tryParse(item.priceController.text) ?? 0;
      return sum + p;
    });
  }

  Future<void> _saveTransaction() async {
    if (!_canSaveTransaction) {
      _showSnackBar('Пожалуйста, заполните все необходимые поля.', Colors.red);
      return;
    }

    final cubit = context.read<TransactionsCubit>();

    // Если мы в режиме редактирования — удаляем старую запись
    if (_isEditing) {
      await cubit.deleteTransaction(widget.initialTx!.id);
    }

    if (_tabIndex == 0) {
      // Income
      final amount = double.tryParse(_incomeAmountController.text) ?? 0;
      final tx = OmegaTransactionModel(
        id: _uuid.v4(),
        shootId: _selectedShoot!.id,
        amount: amount,
        category: 'Income',
        date: DateTime.now(),
        note:
            _commentsController.text.isEmpty ? null : _commentsController.text,
      );
      await cubit.addTransaction(tx);
    } else {
      // Expenses: по одной транзакции на каждую статью расхода
      for (var item in _expenseItems) {
        final name = item.nameController.text.trim();
        final price = double.tryParse(item.priceController.text) ?? 0;
        if (name.isEmpty || price <= 0) continue; // Пропускаем незаполненные
        final tx = OmegaTransactionModel(
          id: _uuid.v4(),
          shootId: _selectedShoot!.id,
          amount: price,
          category: 'Expense',
          date: DateTime.now(),
          note: name,
        );
        await cubit.addTransaction(tx);
      }
    }

    Navigator.of(context).pop();
    _showSnackBar(
      _isEditing ? 'Транзакция обновлена!' : 'Транзакция успешно добавлена!',
      AppColors.mainAccent,
    );
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
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
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
      _showSnackBar('Транзакция удалена', AppColors.mainAccent);
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
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text('Leave', style: TextStyle(fontWeight: FontWeight.w600)),
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
          elevation: 0,
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
                onPressed: () => _confirmDelete(),
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
                      controller: _tabController,
                      indicator: BoxDecoration(
                        border: Border.all(color: accent, width: 1.5),
                        borderRadius: BorderRadius.circular(16.r),
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
                          ? AppColors.grey2 // серый, когда нельзя
                          : AppColors.mainAccent; // синий, когда можно
                    }),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r)),
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
          onChanged: (_) => _updateSaveButton(), // Добавляем слушатель
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
          onChanged: (_) => _updateSaveButton(), // Добавляем слушатель
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
                      _updateSaveButton(); // Обновляем состояние кнопки при выборе съемки
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
                      fillColor: AppColors.cardGrey,
                      onChanged: (_) =>
                          _updateSaveButton(), // Добавляем слушатель
                    ),
                    SizedBox(height: 12.h),
                    AppTextField(
                      hintText: 'Add Price',
                      controller: e.priceController,
                      fillColor: AppColors.cardGrey,
                      isNumberOnly: true,
                      onChanged: (_) =>
                          _updateSaveButton(), // Добавляем слушатель
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
              backgroundColor: AppColors.addexpense,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
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
          onChanged: (_) => _updateSaveButton(), // Добавляем слушатель
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildShootPickerButton() {
    return GestureDetector(
      onTap: () => setState(() {
        _isShootPickerOpen = !_isShootPickerOpen;
        _updateSaveButton(); // Обновляем состояние кнопки при открытии/закрытии пикера
      }),
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
                _updateSaveButton(); // Обновляем состояние кнопки при выборе съемки
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
