import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isNumberOnly;
  final bool isMultiline;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isNumberOnly = false,
    this.isMultiline = false,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.isMultiline ? null : 52.h,
      constraints: widget.isMultiline ? BoxConstraints(minHeight: 52.h) : null,
      decoration: BoxDecoration(
        color: AppColors.bottomNavigatorAppBarColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        readOnly: widget.readOnly,
        keyboardType: widget.isNumberOnly
            ? TextInputType.number
            : widget.isMultiline
                ? TextInputType.multiline
                : widget.keyboardType,
        inputFormatters: widget.isNumberOnly
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        minLines: widget.isMultiline ? 3 : 1,
        maxLines: widget.isMultiline ? 6 : 1,
        style: TextStyle(
          fontSize: 16.sp,
          color: AppColors.textWhite, // Киргизилген текст ак түстө
          fontWeight: FontWeight.w500,
          fontFamily: 'SF PRO',
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColors.textgrey, // Hint тексти боз түстө
            fontSize: 15.sp,
            fontFamily: 'SF PRO',
            fontWeight: FontWeight.w400,
            height: 1.33,
          ),
          filled: true,
          fillColor: AppColors.bottomNavigatorAppBarColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: widget.isMultiline ? 12.h : 14.5.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            // borderSide: BorderSide(
            //   color: AppColors.mainAccent,
            //   width: 1,
            // ),
          ),
        ),
      ),
    );
  }
}
