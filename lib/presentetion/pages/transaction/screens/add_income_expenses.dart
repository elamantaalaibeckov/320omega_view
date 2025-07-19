import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omega_view_smart_plan_320/cubit/shoots/shoots_cubit.dart';
import 'package:omega_view_smart_plan_320/cubit/shoots/shoots_state.dart';
import 'package:omega_view_smart_plan_320/model/omega_shoot_model.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text_filed.dart';
import 'package:uuid/uuid.dart'; // Для генерации уникальных ID

// Предполагаем, что у вас есть TransactionCubit и TransactionModel
// Если нет, вам нужно будет их создать, чтобы добавлять транзакции.
// import 'package:omega_view_smart_plan_320/cubit/transactions/transactions_cubit.dart';
// import 'package:omega_view_smart_plan_320/model/transaction_model.dart';

// Модель для отдельного элемента расхода
class ExpenseItem {
  final String id; // Уникальный ID для элемента расхода
  final TextEditingController nameController;
  final TextEditingController priceController;

  ExpenseItem({
    required this.id,
    required this.nameController,
    required this.priceController,
  });

  // Метод для очистки контроллеров при удалении элемента
  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;
  int _tabIndex = 0;

  // Общие контроллеры для обеих вкладок
  OmegaShootModel? _selectedShoot;
  final TextEditingController _commentsCtrl = TextEditingController();
  bool _isShootPickerOpen = false;

  // Контроллеры и список для вкладки "Income"
  final TextEditingController _incomeAmountCtrl = TextEditingController();

  // Список и контроллеры для вкладки "Expenses"
  final List<ExpenseItem> _expenseItems = [];
  final Uuid _uuid = const Uuid(); // Для генерации уникальных ID расходов

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 2, vsync: this)
      ..addListener(() {
        setState(() {
          _tabIndex = _tc.index;
          // Сбрасываем выбранную съемку и состояние списка при смене вкладки
          _selectedShoot = null;
          _isShootPickerOpen = false;
          // Очищаем поля ввода при смене вкладки
          _incomeAmountCtrl.clear();
          _commentsCtrl.clear();
          _expenseItems.forEach(
              (item) => item.dispose()); // Очищаем контроллеры расходов
          _expenseItems.clear(); // Очищаем список расходов
          // Добавляем один пустой элемент расхода для начала
          _addExpenseItem();
        });
      });
    context.read<ShootsCubit>().loadShoots();
    _addExpenseItem(); // Добавляем первый элемент расхода при инициализации
  }

  @override
  void dispose() {
    _tc.dispose();
    _incomeAmountCtrl.dispose();
    _commentsCtrl.dispose();
    _expenseItems
        .forEach((item) => item.dispose()); // Очищаем контроллеры всех расходов
    super.dispose();
  }

  // Метод для добавления нового элемента расхода
  void _addExpenseItem() {
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

  // Метод для удаления элемента расхода
  void _removeExpenseItem(String id) {
    setState(() {
      final itemToRemove = _expenseItems.firstWhere((item) => item.id == id);
      itemToRemove.dispose(); // Очищаем контроллеры перед удалением
      _expenseItems.removeWhere((item) => item.id == id);
    });
  }

  // Метод для расчета общей суммы расходов
  double _calculateTotalExpenses() {
    double total = 0.0;
    for (var item in _expenseItems) {
      final price = double.tryParse(item.priceController.text);
      if (price != null) {
        total += price;
      }
    }
    return total;
  }

  // Метод для добавления транзакции
  void _addTransaction() {
    if (_selectedShoot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Пожалуйста, выберите съемку.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tabIndex == 0) {
      // Income
      final double? amount = double.tryParse(_incomeAmountCtrl.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Пожалуйста, введите корректную сумму дохода.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Логика добавления дохода
      /*
      final newTransaction = TransactionModel(
        id: _uuid.v4(),
        amount: amount,
        type: TransactionType.income,
        shootId: _selectedShoot!.id,
        comments: _commentsCtrl.text.isNotEmpty ? _commentsCtrl.text : null,
        date: DateTime.now(),
      );
      context.read<TransactionsCubit>().addTransaction(newTransaction);
      */
    } else {
      // Expenses
      if (_expenseItems.isEmpty ||
          _expenseItems.any((item) =>
              item.nameController.text.isEmpty ||
              double.tryParse(item.priceController.text) == null ||
              double.tryParse(item.priceController.text)! <= 0)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Пожалуйста, заполните все поля расходов корректно.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Логика добавления расходов
      /*
      // Можно создать одну транзакцию с общей суммой или несколько отдельных
      final totalExpenses = _calculateTotalExpenses();
      final expenseDetails = _expenseItems.map((item) => {
        'name': item.nameController.text,
        'price': double.tryParse(item.priceController.text) ?? 0.0,
      }).toList();

      final newTransaction = TransactionModel(
        id: _uuid.v4(),
        amount: totalExpenses,
        type: TransactionType.expense,
        shootId: _selectedShoot!.id,
        comments: _commentsCtrl.text.isNotEmpty ? _commentsCtrl.text : null,
        date: DateTime.now(),
        // Возможно, добавить поле для деталей расходов, если нужно хранить каждый пункт
        // details: expenseDetails,
      );
      context.read<TransactionsCubit>().addTransaction(newTransaction);
      */
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Транзакция успешно добавлена!'),
        backgroundColor: AppColors.mainAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.mainAccent;
    final state = context.watch<ShootsCubit>().state;
    final completedShoots = state.shoots.where((s) => !s.isPlanned).toList();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.bottomNavigatorAppBarColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          'Add Transaction',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
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
                    controller: _tc,
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
                        ? _buildIncomeForm(completedShoots)
                        : _buildExpensesForm(completedShoots),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                onPressed: _addTransaction,
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Метод для построения выбранной съемки в поле выбора
  Widget _buildSelectedShoot(OmegaShootModel shoot) {
    final combinedDateTime = DateTime(
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
          DateFormat('MMM dd, yyyy, HH:mm').format(combinedDateTime),
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          shoot.clientName,
          style: TextStyle(
            color: AppColors.textgrey,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  // Новая форма для вкладки "Income"
  Widget _buildIncomeForm(List<OmegaShootModel> completedShoots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        AppTexts(texTs: 'Income Amount'),
        SizedBox(height: 8.h),
        AppTextField(
          hintText: 'Add Income',
          controller: _incomeAmountCtrl,
          isNumberOnly: true,
        ),
        SizedBox(height: 16.h),
        AppTexts(texTs: 'Select Shoot'),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {
            setState(() {
              _isShootPickerOpen = !_isShootPickerOpen;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.filedGrey,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: (_selectedShoot == null)
                      ? Text(
                          'Select',
                          style: TextStyle(
                            color: AppColors.textgrey,
                            fontSize: 14.sp,
                          ),
                        )
                      : _buildSelectedShoot(_selectedShoot!),
                ),
                Icon(
                  _isShootPickerOpen
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: AppColors.textgrey,
                ),
              ],
            ),
          ),
        ),
        if (_isShootPickerOpen)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Container(
              // 3 карточки по 80.h + 2 разделителя по 12.h + паддинги по 12.h сверху и снизу = 288.h
              height: 288.h,
              decoration: BoxDecoration(
                color: AppColors.filedGrey,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: ListView.separated(
                // теперь список сам скроллится
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: completedShoots.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, i) {
                  final shoot = completedShoots[i];
                  final isSel = _selectedShoot?.id == shoot.id;
                  final combinedDateTime = DateTime(
                    shoot.date.year,
                    shoot.date.month,
                    shoot.date.day,
                    shoot.time.hour,
                    shoot.time.minute,
                  );
                  final displayPhotos =
                      shoot.shootReferencesPaths.take(1).toList();
                  final remainingCount =
                      shoot.shootReferencesPaths.length - displayPhotos.length;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedShoot = shoot;
                        _isShootPickerOpen = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: AppColors.cardGrey,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color:
                              isSel ? AppColors.mainAccent : AppColors.cardGrey,
                          width: 1.5,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('MMM d, yyyy, h:mm a')
                                      .format(combinedDateTime),
                                  style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  shoot.clientName,
                                  style: TextStyle(
                                    color: AppColors.textgrey,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (displayPhotos.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.file(
                                File(displayPhotos.first),
                                width: 56.w,
                                height: 56.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            if (remainingCount > 0)
                              Container(
                                width: 56.w,
                                height: 56.h,
                                decoration: BoxDecoration(
                                  color: AppColors.cardGrey,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Center(
                                  child: Text(
                                    '+$remainingCount',
                                    style: TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        SizedBox(height: 16.h),
        AppTexts(texTs: 'Comments (optional)'),
        SizedBox(height: 8.h),
        AppTextField(hintText: 'Add Comments', controller: _commentsCtrl),
        SizedBox(height: 24.h),
      ],
    );
  }

  // Новая форма для вкладки "Expenses"
  Widget _buildExpensesForm(List<OmegaShootModel> completedShoots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        AppTexts(texTs: 'Select Shoot'),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {
            setState(() {
              _isShootPickerOpen = !_isShootPickerOpen;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.filedGrey, // Цвет фона поля выбора
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: (_selectedShoot == null)
                      ? Text(
                          'Select',
                          style: TextStyle(
                            color: AppColors.textgrey,
                            fontSize: 14.sp,
                          ),
                        )
                      : _buildSelectedShoot(_selectedShoot!),
                ),
                Icon(
                  _isShootPickerOpen
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: AppColors.textgrey,
                ),
              ],
            ),
          ),
        ),
        if (_isShootPickerOpen)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.filedGrey, // Цвет фона для выпадающего списка
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                itemCount: completedShoots.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, i) {
                  final shoot = completedShoots[i];
                  final isSel = _selectedShoot?.id == shoot.id;
                  final combinedDateTime = DateTime(
                    shoot.date.year,
                    shoot.date.month,
                    shoot.date.day,
                    shoot.time.hour,
                    shoot.time.minute,
                  );
                  final displayPhotos =
                      shoot.shootReferencesPaths.take(1).toList();
                  final remainingCount =
                      shoot.shootReferencesPaths.length - displayPhotos.length;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedShoot = shoot;
                        _isShootPickerOpen = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: AppColors.cardGrey, // Цвет фона карточки
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color:
                              isSel ? AppColors.mainAccent : AppColors.cardGrey,
                          width: 1.5,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('MMM d, yyyy, h:mm a')
                                      .format(combinedDateTime),
                                  style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  shoot.clientName,
                                  style: TextStyle(
                                    color: AppColors.textgrey,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (displayPhotos.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.file(
                                File(displayPhotos.first),
                                width: 56.w,
                                height: 56.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            if (remainingCount > 0)
                              Container(
                                width: 56.w,
                                height: 56.h,
                                decoration: BoxDecoration(
                                  color: AppColors.cardGrey,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Center(
                                  child: Text(
                                    '+$remainingCount',
                                    style: TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        SizedBox(height: 16.h),
        AppTexts(texTs: 'Expenses'), // Заголовок для списка расходов
        SizedBox(height: 8.h),
        // Динамический список полей для расходов
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _expenseItems.length,
          itemBuilder: (context, index) {
            final expense = _expenseItems[index];
            return Padding(
              padding: EdgeInsets.only(
                  bottom: 12.h), // Отступ между элементами расхода
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.filedGrey,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    AppTextField(
                      hintText: 'Add name',
                      controller: expense.nameController,
                      onChanged: (_) =>
                          setState(() {}), // Для обновления кнопки "Add"
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            hintText: 'Add Price',
                            controller: expense.priceController,
                            isNumberOnly: true,
                            onChanged: (_) => setState(
                                () {}), // Для обновления общей суммы и кнопки "Add"
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Кнопка удаления, если элементов больше одного
                        if (_expenseItems.length > 1)
                          InkWell(
                            onTap: () => _removeExpenseItem(expense.id),
                            borderRadius: BorderRadius.circular(8.r),
                            child: Container(
                              width: 48.w, // Ширина кнопки удаления
                              height: 48.h, // Высота кнопки удаления
                              decoration: BoxDecoration(
                                color: AppColors
                                    .bottomNavigatorAppBarColor, // Цвет фона кнопки
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Icon(Icons.delete_outline,
                                    color: AppColors.textgrey, size: 24.r),
                              ),
                            ),
                          ),
                      ],
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            onPressed: _addExpenseItem, // Добавляем новый элемент расхода
            child: Text(
              'Add Expense',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        // Общая сумма расходов
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '\$${_calculateTotalExpenses().toStringAsFixed(2)}', // Форматируем до двух знаков после запятой
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        AppTexts(texTs: 'Comments (optional)'),
        SizedBox(height: 8.h),
        AppTextField(hintText: 'Add Comments', controller: _commentsCtrl),
        SizedBox(height: 24.h),
      ],
    );
  }
}
