import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omega_view_smart_plan_320/model/omega_shoot_model.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/shoots/screens/planned_add_shoot.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_icons.dart';

class ShootDetailsPage extends StatelessWidget {
  final OmegaShootModel shoot;
  const ShootDetailsPage({super.key, required this.shoot});

  bool get isPlanned => shoot.isPlanned;

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime(
      shoot.date.year,
      shoot.date.month,
      shoot.date.day,
      shoot.time.hour,
      shoot.time.minute,
    );
    final bool isCompleted = !isPlanned;
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavigatorAppBarColor,
        leading: const BackButton(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Shoot Details',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlannedAddShoot(editShoot: shoot),
                ),
              );
            },
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GreyCard(
              isCompleted: isCompleted,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: isPlanned
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.start,
                children: [
                  _TopInfo(
                    dateTime: dateTime,
                    shoot: shoot,
                    isCompleted: isCompleted,
                  ),
                  if (isPlanned && (shoot.notificationsEnabled ?? false))
                    Padding(
                      padding: EdgeInsets.only(left: 8.w, top: 4.h),
                      child: Image.asset(
                        AppIcons.notficationIcon,
                        width: 20.w,
                        height: 21.h,
                        color: AppColors.textWhite,
                      ),
                    ),
                  if (isCompleted)
                    Padding(
                        padding: EdgeInsets.only(left: 8.w, top: 2.h),
                        child: Image.asset(
                          'assets/icons/completed_icon.png',
                          width: 16.w,
                          height: 16.w,
                          fit: BoxFit.contain,
                        )),
                ],
              ),
            ),
            if (shoot.shootReferencesPaths.isNotEmpty) ...[
              SizedBox(height: 16.h),
              // _SectionTitle('Shoot References:'),
              _GreyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shoot References:',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 15.sp,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    _PhotosGrid(
                      paths: shoot.shootReferencesPaths,
                      onTap: (path) => _showPhotoViewer(context, path),
                    ),
                  ],
                ),
              ),
            ],
            if (!isPlanned &&
                shoot.finalShotsPaths != null &&
                shoot.finalShotsPaths!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              // _SectionTitle('Final Shots:'),
              _GreyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Final Shots:',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 15.sp,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    _PhotosGrid(
                      paths: shoot.finalShotsPaths!,
                      onTap: (path) => _showPhotoViewer(context, path),
                    ),
                  ],
                ),
              ),
            ],
            if ((shoot.comments ?? '').trim().isNotEmpty) ...[
              SizedBox(height: 16.h),
              // _SectionTitle('Comments:'),
              _GreyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comments:',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 15.sp,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      shoot.comments!.trim(),
                      style: TextStyle(
                        color: AppColors.textWhite.withValues(alpha: 0.7),
                        fontSize: 13.sp,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        height: 1.38,
                        letterSpacing: -0.08,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPhotoViewer(BuildContext context, String path) {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) {
        return Dialog(
          // backgroundColor: Color(0xff464646),
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: size.width - 32.w, // ширина = экран - 2*16
                maxHeight:
                    size.height - 120.h, // чтобы не упиралось в края по высоте
              ),
              child: Material(
                color: const Color(0xff464646),
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: InteractiveViewer(
                            child: Image.file(
                              File(path),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          borderRadius: BorderRadius.circular(12.r),
                          color: AppColors.mainAccent,
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 17.sp,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w500,
                              height: 1.29,
                              letterSpacing: -0.43,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopInfo extends StatelessWidget {
  const _TopInfo({
    required this.dateTime,
    required this.shoot,
    this.isCompleted = false,
  });

  final DateTime dateTime;
  final OmegaShootModel shoot;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy, h:mm a').format(dateTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateStr,
          style: TextStyle(
            color: isCompleted ? AppColors.grey2 : AppColors.textWhite,
            fontSize: 17.sp,
            fontWeight: FontWeight.w500,
            height: 1.29,
            letterSpacing: -0.43,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          shoot.clientName,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            height: 1.33,
            letterSpacing: -0.23,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          shoot.address,
          style: TextStyle(
            color: AppColors.grey2,
            fontSize: 15.sp,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
            height: 1.33,
            letterSpacing: -0.23,
          ),
        ),
      ],
    );
  }
}

class _GreyCard extends StatelessWidget {
  final Widget child;
  final bool isCompleted;
  const _GreyCard({
    required this.child,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF464646), // цвет для planned
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: child,
    );
  }
}

class _PhotosGrid extends StatelessWidget {
  final List<String> paths;
  final ValueChanged<String> onTap;

  const _PhotosGrid({required this.paths, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: paths.map((p) {
        return GestureDetector(
          onTap: () => onTap(p),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              File(p),
              width: 56.w,
              height: 56.h,
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }
}
