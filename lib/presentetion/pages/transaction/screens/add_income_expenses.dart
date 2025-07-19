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

// Предполагаем, что у вас есть TransactionCubit и TransactionModel
// Если нет, вам нужно будет их создать, чтобы добавлять транзакции.
// import 'package:omega_view_smart_plan_320/cubit/transactions/transactions_cubit.dart';
// import 'package:omega_view_smart_plan_320/model/transaction_model.dart';
// import 'package:uuid/uuid.dart'; // Для генерации уникальных ID транзакций

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;
  int _tabIndex = 0;
  final TextEditingController _amountCtrl = TextEditingController();
  OmegaShootModel? _selectedShoot;
  final TextEditingController _commentsCtrl = TextEditingController();
  bool _isShootPickerOpen =
      false; // Новое состояние для отслеживания открытия/закрытия списка

  // final Uuid _uuid = const Uuid(); // Для генерации уникальных ID транзакций

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() => _tabIndex = _tc.index));
    context.read<ShootsCubit>().loadShoots();
  }

  @override
  void dispose() {
    _tc.dispose();
    _amountCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
  }

  // Метод для добавления транзакции (добавьте логику для вашего TransactionCubit)
  void _addTransaction() {
    if (_amountCtrl.text.isEmpty || _selectedShoot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Пожалуйста, введите сумму и выберите съемку.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double? amount = double.tryParse(_amountCtrl.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Пожалуйста, введите корректную сумму.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Здесь вам нужно будет создать объект TransactionModel
    // и добавить его через TransactionsCubit.
    /*
    final newTransaction = TransactionModel(
      id: _uuid.v4(),
      amount: amount,
      type: _tabIndex == 0 ? TransactionType.income : TransactionType.expense,
      shootId: _selectedShoot!.id,
      comments: _commentsCtrl.text.isNotEmpty ? _commentsCtrl.text : null,
      date: DateTime.now(),
    );
    context.read<TransactionsCubit>().addTransaction(newTransaction);
    */

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
                    child: _buildForm(_tabIndex == 0, completedShoots),
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
            color: AppColors.textgrey, // Используем textgrey для имени клиента
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isIncome, List<OmegaShootModel> completedShoots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        AppTexts(texTs: isIncome ? 'Income Amount' : 'Expense Amount'),
        SizedBox(height: 8.h),
        AppTextField(
          hintText: isIncome ? 'Add Income' : 'Add Expense',
          controller: _amountCtrl,
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
        // Здесь добавляем список карточек, если _isShootPickerOpen == true
        if (_isShootPickerOpen)
          Padding(
            padding: EdgeInsets.only(top: 16.h), // Отступ 16 пикселей сверху
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.filedGrey,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w), // Добавлен горизонтальный паддинг
                itemCount: completedShoots.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, i) {
                  final shoot = completedShoots[i];
                  final isSel = _selectedShoot?.id == shoot.id;

                  // Объединяем дату и время для форматирования
                  final combinedDateTime = DateTime(
                    shoot.date.year,
                    shoot.date.month,
                    shoot.date.day,
                    shoot.time.hour,
                    shoot.time.minute,
                  );

                  // Берем только первое фото для отображения в карточке
                  final displayPhotos =
                      shoot.shootReferencesPaths.take(1).toList();
                  final remainingCount =
                      shoot.shootReferencesPaths.length - displayPhotos.length;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedShoot = shoot;
                        _isShootPickerOpen =
                            false; // Закрываем список после выбора
                      });
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      height: 80.h, // Высота карточки
                      decoration: BoxDecoration(
                        color: AppColors.cardGrey, // Цвет фона карточки
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color:
                              isSel ? AppColors.mainAccent : AppColors.cardGrey,
                          width: 1.5,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w), // Внутренний паддинг карточки
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
                                    color: AppColors
                                        .textgrey, // Имя клиента серым цветом
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
                                width: 56.w, // Ширина изображения
                                height: 56.h, // Высота изображения
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            if (remainingCount > 0)
                              Container(
                                width: 56.w, // Ширина контейнера +N
                                height: 56.h, // Высота контейнера +N
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
        SizedBox(height: 16.h), // Отступ после списка или поля выбора
        AppTexts(texTs: 'Comments (optional)'),
        SizedBox(height: 8.h),
        AppTextField(hintText: 'Add Comments', controller: _commentsCtrl),
        SizedBox(height: 24.h),
      ],
    );
  }
}
