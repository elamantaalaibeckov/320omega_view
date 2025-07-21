import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omega_view_smart_plan_320/model/omega_shoot_model.dart';
import 'package:omega_view_smart_plan_320/model/omega_transaction_model.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';

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

    File? preview;
    if (shoot.finalShotsPaths != null && shoot.finalShotsPaths!.isNotEmpty) {
      final f = File(shoot.finalShotsPaths!.first);
      if (f.existsSync() && f.lengthSync() > 0) {
        preview = f;
      }
    }

    final int photosCount = shoot.finalShotsPaths?.length ?? 0; //

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$sign${transaction.amount.toStringAsFixed(0)}\$', //
            style: TextStyle(
              color: amountColor,
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isExpense) // Если это расход, добавляем "(Total)"
            Text(
              '(Total)',
              style: TextStyle(
                color: AppColors.textWhite.withOpacity(0.70),
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          SizedBox(height: 8.h),
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
                            .format(transaction.date), //
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        shoot.clientAddress != null &&
                                shoot.clientAddress!.isNotEmpty
                            ? '${shoot.clientName}, ${shoot.clientAddress!}' //
                            : shoot.clientName, //
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (preview != null) //
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(
                      preview,
                      width: 40.w,
                      height: 40.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: AppColors.textgrey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.broken_image,
                              color: AppColors.textgrey, size: 24.r),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.textgrey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.no_photography_outlined,
                        color: AppColors.textgrey, size: 24.r),
                  ),
                if (photosCount > 0) ...[
                  //
                  SizedBox(width: 8.w),
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.grey2, //
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        '+$photosCount', //
                        style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isExpense) ...[
            // Добавляем секцию для отображения категории и суммы расхода
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // Используем transaction.note как категорию для расхода
                  // Если note null, выводим 'No category'
                  transaction.note ?? 'No category', //
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '\$ ${transaction.amount.toStringAsFixed(0)}', //
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
          if (transaction.note != null &&
              transaction.note!.isNotEmpty &&
              !isExpense) ...[
            // Отображаем комментарий только если это не расход ИЛИ если расход,
            // но transaction.note не используется как категория.
            // В данном случае, если это расход, transaction.note уже используется выше,
            // поэтому дублировать его не нужно.
            SizedBox(height: 12.h),
            Text(
              transaction.note!, //
              style: TextStyle(
                color: AppColors.textWhite.withOpacity(0.70),
                fontSize: 13.sp,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                height: 1.38,
                letterSpacing: -0.08,
              ),
            ),
          ],
          // Если это расход, а комментарий отличается от "категории"
          // ИЛИ если у расхода есть дополнительный комментарий, который нужно показать
          // (это предполагает, что "Light" был в category, а "Bought light..." в note)
          // Вам нужно будет уточнить, как именно вы храните эти данные.
          // В текущей реализации, если isExpense, то transaction.note уже отображается как "категория".
          // Если вам нужен отдельный комментарий для расхода, то transaction.note должен быть только комментарием.
          // И, в этом случае, у вас должна быть отдельная переменная для 'Light'.
          // Например, transaction.expenseCategory.
          // Поскольку у вас нет `transaction.description`, я предполагаю, что `transaction.note`
          // используется для 'Light' на скриншоте расхода.
          // Если же "Light" - это `category` в модели, то это усложнит, так как `category` = 'Expense'.
          // В таком случае, я бы все равно рекомендовал добавить `description` поле в `OmegaTransactionModel`.
        ],
      ),
    );
  }
}
