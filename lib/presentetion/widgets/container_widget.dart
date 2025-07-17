import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';

class ContainerWidget extends StatelessWidget {
  final String textcontainer;
  final VoidCallback onTap;
  final bool icons;

  const ContainerWidget({
    Key? key,
    required this.textcontainer,
    required this.onTap,
    this.icons = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.bottomNavigatorAppBarColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              textcontainer,
              style: TextStyle(
                color: const Color(0xFF7A7A7A),
                fontSize: 15.sp,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                height: 1.33,
                letterSpacing: -0.23,
              ),
            ),
            icons
                ? Icon(Icons.calendar_month, color: AppColors.textgrey)
                : Icon(Icons.access_time, color: AppColors.textgrey),
          ],
        ),
      ),
    );
  }
}
