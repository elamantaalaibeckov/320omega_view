// lib/presentation/widgets/cupertino_date_time_field.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';

typedef DateTimeChanged = void Function(DateTime);

class CupertinoDateTimeField extends StatefulWidget {
  /// Текст метки над полем (если нужен снаружи — можно не использовать)
  final String labelText;

  /// Начальное значение
  final DateTime initialDateTime;

  /// Режим пикера: date или time
  final CupertinoDatePickerMode mode;

  /// Коллбэк выбора
  final DateTimeChanged onDateTimeChanged;

  /// Формат отображения
  final DateFormat? formatter;

  /// 24‑часовой формат для time
  final bool use24hFormat;

  /// Было ли выбрано значение (для цвета текста)
  final bool isPicked;

  /// Цвет фона (по умолчанию filedGrey — то, что ты просил)
  final Color bgColor;

  const CupertinoDateTimeField({
    Key? key,
    this.labelText = '',
    required this.initialDateTime,
    required this.mode,
    required this.onDateTimeChanged,
    this.formatter,
    this.use24hFormat = false,
    this.isPicked = false,
    this.bgColor = AppColors.filedGrey,
  }) : super(key: key);

  @override
  _CupertinoDateTimeFieldState createState() => _CupertinoDateTimeFieldState();
}

class _CupertinoDateTimeFieldState extends State<CupertinoDateTimeField> {
  late DateTime _currentDateTime;

  @override
  void initState() {
    super.initState();
    _currentDateTime = widget.initialDateTime;
  }

  @override
  void didUpdateWidget(covariant CupertinoDateTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDateTime != oldWidget.initialDateTime) {
      _currentDateTime = widget.initialDateTime;
    }
  }

  String _getDisplayText() {
    if (!widget.isPicked) return 'Select';

    if (widget.formatter != null) {
      return widget.formatter!.format(_currentDateTime);
    } else if (widget.mode == CupertinoDatePickerMode.date) {
      return DateFormat('MMM dd, yyyy').format(_currentDateTime);
    } else {
      return DateFormat('HH:mm').format(_currentDateTime);
    }
  }

  void _showPicker() {
    DateTime picked = _currentDateTime;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            // Верхняя панель
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.mainAccent,
                        fontSize: 17,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppColors.mainAccent,
                        fontSize: 17,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentDateTime = picked;
                      });
                      widget.onDateTimeChanged(_currentDateTime);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: 0.6,
              thickness: 0.6,
              color: AppColors.textgrey,
            ),
            // Сам пикер
            Expanded(
              child: CupertinoDatePicker(
                mode: widget.mode,
                initialDateTime: picked,
                onDateTimeChanged: (dt) => picked = dt,
                use24hFormat: widget.use24hFormat,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPicker,
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: widget.bgColor, // ← filedGrey тут
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getDisplayText(),
              style: TextStyle(
                color:
                    widget.isPicked ? AppColors.textWhite : AppColors.textgrey,
                fontSize: 16.sp,
                fontFamily: 'SF PRO',
              ),
            ),
            Icon(
              widget.mode == CupertinoDatePickerMode.date
                  ? Icons.calendar_month
                  : Icons.access_time,
              color: widget.isPicked ? AppColors.textWhite : AppColors.textgrey,
            ),
          ],
        ),
      ),
    );
  }
}
