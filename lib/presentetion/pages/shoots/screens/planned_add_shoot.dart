// lib/presentation/pages/planned_add_shoot.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/shoots/screens/cupertino_date_picker.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text_filed.dart';

class PlannedAddShoot extends StatefulWidget {
  const PlannedAddShoot({Key? key}) : super(key: key);

  @override
  State<PlannedAddShoot> createState() => _PlannedAddShootState();
}

class _PlannedAddShootState extends State<PlannedAddShoot>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedTime = DateTime(
    0,
    0,
    0,
    TimeOfDay.now().hour,
    TimeOfDay.now().minute,
  );

  late final TabController _tc;
  bool _notify = false;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.mainAccent;
    final isFirst = _tc.index == 0;
    final indicatorDecoration = BoxDecoration(
      border: Border.all(color: accent, width: 1.5),
      borderRadius: isFirst
          ? BorderRadius.only(
              topLeft: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
            )
          : BorderRadius.only(
              topRight: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
            ),
    );

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavigatorAppBarColor,
        automaticallyImplyLeading: true,
        title: Text(
          'Add Shoot',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20.sp,
            fontFamily: 'SF PRO',
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // таббар
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TabBar(
              dividerColor: AppColors.bgColor,
              controller: _tc,
              indicator: indicatorDecoration,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.textWhite,
              unselectedLabelColor: AppColors.textgrey,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Planned'),
                Tab(text: 'Completed'),
              ],
            ),
          ),

          // форма
          Expanded(
            child: TabBarView(
              controller: _tc,
              children: [
                _buildPlannedForm(),
                _buildCompletedForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannedForm() {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        const AppTexts(texTs: 'Select Day'),
        SizedBox(height: 8.h),
        CupertinoDateTimeField(
          labelText: '',
          initialDateTime: _selectedDate,
          mode: CupertinoDatePickerMode.date,
          formatter: DateFormat('MMM dd, yyyy'),
          onDateTimeChanged: (dt) => setState(() => _selectedDate = dt),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Select Time'),
        SizedBox(height: 8.h),
        CupertinoDateTimeField(
          labelText: '',
          initialDateTime: _selectedTime,
          mode: CupertinoDatePickerMode.time,
          use24hFormat: false,
          formatter: DateFormat('HH:mm'),
          onDateTimeChanged: (dt) => setState(() => _selectedTime = dt),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Client’s Name'),
        SizedBox(height: 8.h),
        const AppTextField(hintText: 'Client’s Name'),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Address'),
        SizedBox(height: 8.h),
        const AppTextField(hintText: 'Add Address'),
        SizedBox(height: 16.h),
        const AppTexts(
            texTs: 'Shoot References (optional). Limit: 0/17 photos'),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.only(
              left: 0.w,
              right: 234.w,
            ),
            child: Container(
              height: 109.h,
              decoration: BoxDecoration(
                color: AppColors.bottomNavigatorAppBarColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                size: 32.w,
                color: AppColors.textgrey,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Comments (optional)'),
        SizedBox(height: 8.h),
        AppTextField(hintText: 'Add Comments'),
        SizedBox(height: 16.h),

        // Notification
        Container(
          width: double.infinity,
          height: 108.h,
          decoration: BoxDecoration(
            color: AppColors.bottomNavigatorAppBarColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notification',
                    style: TextStyle(
                      color: AppColors.textgrey,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CupertinoSwitch(
                    activeColor: AppColors.mainAccent,
                    value: _notify,
                    onChanged: (v) => setState(() => _notify = v),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                "With notifications, you won't miss any planned shootings.",
                style: TextStyle(
                  color: AppColors.textgrey,
                  fontSize: 12.sp,
                  fontFamily: 'SF PRO',
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        // Add button
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textgrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            onPressed: () {},
            child: Text(
              'Add',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedForm() {
    return Center(
      child: Text(
        'Completed fields здесь…',
        style: TextStyle(color: AppColors.textWhite),
      ),
    );
  }
}
