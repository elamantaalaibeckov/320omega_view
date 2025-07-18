// lib/presentation/widgets/cupertino_date_time_field.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';

typedef DateTimeChanged = void Function(DateTime);

class CupertinoDateTimeField extends StatefulWidget {
  /// Текст метки над полем
  final String labelText;

  /// Начальное значение (для date — дата, для time — время в DateTime)
  final DateTime initialDateTime;

  /// Режим пикера: date или time
  final CupertinoDatePickerMode mode;

  /// Коллбэк, возвращающий выбранное DateTime
  final DateTimeChanged onDateTimeChanged;

  /// Форматтер (опционально). Если не указан, для date — yyyy-MM-dd, для time — HH:mm
  final DateFormat? formatter;

  /// Для time-пикера: 24‑часовой режим
  final bool use24hFormat;

  const CupertinoDateTimeField({
    Key? key,
    required this.labelText,
    required this.initialDateTime,
    required this.mode,
    required this.onDateTimeChanged,
    this.formatter,
    this.use24hFormat = false,
  }) : super(key: key);

  @override
  _CupertinoDateTimeFieldState createState() => _CupertinoDateTimeFieldState();
}

class _CupertinoDateTimeFieldState extends State<CupertinoDateTimeField> {
  late DateTime _tempDateTime;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _tempDateTime = widget.initialDateTime;
    _controller = TextEditingController(
      text: _displayString(widget.initialDateTime),
    );
  }

  String _displayString(DateTime dt) {
    if (widget.formatter != null) return widget.formatter!.format(dt);
    if (widget.mode == CupertinoDatePickerMode.date) {
      return DateFormat('yyyy-MM-dd').format(dt);
    } else {
      return DateFormat('HH:mm').format(dt);
    }
  }

  void _showPicker() {
    DateTime picked = _tempDateTime;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            // — Панель Cancel / Done —
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
                        _tempDateTime = picked;
                        _controller.text = _displayString(_tempDateTime);
                      });
                      widget.onDateTimeChanged(_tempDateTime);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: 0.6,
              thickness: 0.6, // толщина линии
              color: AppColors.textgrey, // или любой другой цвет
            ),

            // — Сам пикер —
            Expanded(
              child: CupertinoDatePicker(
                mode: widget.mode,
                initialDateTime: picked,
                onDateTimeChanged: (dt) => picked = dt,
                use24hFormat: widget.use24hFormat,
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
        height: 52.h, // настраиваем по дизайну
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.bottomNavigatorAppBarColor, // фон как на фото
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _displayString(_tempDateTime),
              style: TextStyle(
                color: AppColors.textgrey,
                fontSize: 14.sp,
                fontFamily: 'SF PRO',
              ),
            ),
            Icon(
              widget.mode == CupertinoDatePickerMode.date
                  ? Icons.calendar_month
                  : Icons.access_time,
              color: AppColors.textgrey,
            ),
          ],
        ),
      ),
    );
  }
}
