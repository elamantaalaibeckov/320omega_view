import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omega_view_smart_plan_320/model/omega_shoot_model.dart';
import 'package:omega_view_smart_plan_320/model/omega_transaction_model.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/transaction/screens/add_income_expenses.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
// Импорт экрана редактирования/добавления транзакции

class TransactionCard extends StatelessWidget {
  final OmegaTransactionModel transaction;
  final OmegaShootModel shoot;

  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.shoot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.category == 'Income';
    final isExpense = transaction.category == 'Expense';
    final sign = isIncome ? '+' : '-';
    final amountColor = AppColors.textWhite;

    // Подготовка превью изображения
    File? preview;
    if (shoot.finalShotsPaths != null && shoot.finalShotsPaths!.isNotEmpty) {
      final f = File(shoot.finalShotsPaths!.first);
      if (f.existsSync() && f.lengthSync() > 0) {
        preview = f;
      }
    }
    final photosCount = shoot.finalShotsPaths?.length ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        // Навигация в экран AddTransactionPage в режиме редактирования
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddTransactionPage(
              initialTx: transaction,
              initialShoot: shoot,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardGrey,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Сумма
            Text(
              '$sign${transaction.amount.toStringAsFixed(0)}\$',
              style: TextStyle(
                color: amountColor,
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isExpense)
              Text(
                '(Total)',
                style: TextStyle(
                  color: AppColors.textWhite.withOpacity(0.70),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            SizedBox(height: 8.h),

            // Дата и съёмка + фото
            Container(
              decoration: BoxDecoration(
                color: AppColors.filedGrey,
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy, h:mm a')
                              .format(transaction.date),
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          (shoot.clientAddress?.isNotEmpty ?? false)
                              ? '${shoot.clientName}, ${shoot.clientAddress!}'
                              : shoot.clientName,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Превью фото
                  if (preview != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        preview,
                        width: 40.w,
                        height: 40.h,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _emptyPhoto(),
                      ),
                    )
                  else
                    _emptyPhoto(),

                  // Счётчик доп. фото
                  if (photosCount > 1) ...[
                    SizedBox(width: 8.w),
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.grey2,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          '+${photosCount - 1}',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Категория и сумма (для расхода)
            if (isExpense) ...[
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    transaction.note ?? 'No category',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '\$${transaction.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],

            // Комментарий (для дохода)
            if (transaction.note != null &&
                transaction.note!.isNotEmpty &&
                !isExpense) ...[
              SizedBox(height: 12.h),
              Text(
                transaction.note!,
                style: TextStyle(
                  color: AppColors.textWhite.withOpacity(0.70),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.38,
                  letterSpacing: -0.08,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Показываем заглушку, если фото нет
  Widget _emptyPhoto() {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColors.textgrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.no_photography_outlined,
        color: AppColors.textgrey,
        size: 24.r,
      ),
    );
  }
}
