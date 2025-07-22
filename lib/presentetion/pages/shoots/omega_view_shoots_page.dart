import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omega_view_smart_plan_320/cubit/shoots/shoots_cubit.dart';
import 'package:omega_view_smart_plan_320/cubit/shoots/shoots_state.dart';
import 'package:omega_view_smart_plan_320/model/omega_shoot_model.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/shoots/screens/omega_shoot_details_page.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/shoots/screens/planned_add_shoot.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_icons.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_images.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class OmegaViewShootsPage extends StatefulWidget {
  const OmegaViewShootsPage({super.key});

  @override
  State<OmegaViewShootsPage> createState() => _OmegaViewShootsPageState();
}

class _OmegaViewShootsPageState extends State<OmegaViewShootsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
    // Load shoots when the page initializes
    context.read<ShootsCubit>().loadShoots();
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.mainAccent;
    final bool isFirst = _tc.index == 0;
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
        elevation: 0,
        shadowColor: Colors.transparent,
        title: Text(
          'Shoots',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            fontFamily: 'SF PRO',
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: TabBar(
                  dividerColor: AppColors.bgColor,
                  controller: _tc,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: indicatorDecoration,
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
              Expanded(
                child: BlocBuilder<ShootsCubit, ShootsState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CupertinoActivityIndicator());
                    }
                    if (state.errorMessage != null) {
                      return Center(
                          child: Text('Error: ${state.errorMessage}'));
                    }

                    final plannedShoots =
                        state.shoots.where((shoot) => shoot.isPlanned).toList();
                    final completedShoots = state.shoots
                        .where((shoot) => !shoot.isPlanned)
                        .toList();

                    return TabBarView(
                      controller: _tc,
                      children: [
                        _buildShootList(plannedShoots, true),
                        _buildShootList(completedShoots, false),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlannedAddShoot(),
                  ),
                );
              },
              backgroundColor: accent,
              child: const Icon(
                Icons.add,
                color: AppColors.textWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShootList(List<OmegaShootModel> shoots, bool isPlannedTab) {
    if (shoots.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 84.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.shootImage,
              width: 173.w,
              height: 166.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            Text(
              isPlannedTab
                  ? 'No planned shoots\nhave been added yet'
                  : 'No completed shoots\nhave been added yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textgrey,
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'SF PRO',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: shoots.length,
      itemBuilder: (context, index) {
        final shoot = shoots[index];
        return _buildShootCard(shoot, isPlannedTab);
      },
    );
  }

  Widget _buildShootCard(OmegaShootModel shoot, bool isPlannedTab) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShootDetailsPage(shoot: shoot),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: AppColors.bottomNavigatorAppBarColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  DateFormat('MMM dd, yyyy, HH:mm').format(
                    DateTime(
                      shoot.date.year,
                      shoot.date.month,
                      shoot.date.day,
                      shoot.time.hour,
                      shoot.time.minute,
                    ),
                  ),
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.29,
                    letterSpacing: -0.43,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  'AM',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.29,
                    letterSpacing: -0.43,
                  ),
                ),
                Spacer(),
                if (!isPlannedTab)
                  Padding(
                    padding: EdgeInsets.only(right: 115),
                    child: Container(
                      width: 12.w,
                      height: 12.h,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/icons/first_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                if (isPlannedTab && shoot.notificationsEnabled == true)
                  Image.asset(
                    AppIcons.notficationIcon,
                    width: 20.w,
                    height: 21.h,
                  )
              ],
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
                color: AppColors.textWhite,
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                height: 1.33,
                letterSpacing: -0.23,
              ),
            ),
            if (!isPlannedTab &&
                shoot.finalShotsPaths != null &&
                shoot.finalShotsPaths!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  Text(
                    'Your Photos',
                    style: TextStyle(
                      color: AppColors.grey2,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.38,
                      letterSpacing: -0.08,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildPhotoRow(shoot.finalShotsPaths!),
                ],
              ),
            if (shoot.shootReferencesPaths.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  if (!isPlannedTab)
                    Text(
                      'Shoot References',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 13.sp,
                      ),
                    ),
                  if (!isPlannedTab) SizedBox(height: 8.h),
                  SizedBox(height: 8.h),
                  _buildPhotoRow(shoot.shootReferencesPaths),
                ],
              ),
            if (shoot.comments != null && shoot.comments!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Text(
                    shoot.comments!,
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoRow(List<String> photoPaths) {
    final preview = photoPaths.take(4).toList();
    final restCount = photoPaths.length - preview.length;

    return Row(
      children: [
        for (final path in preview)
          Padding(
            padding: EdgeInsets.only(right: 8.120.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(
                File(path),
                width: 56.w,
                height: 56.h,
                fit: BoxFit.cover,
              ),
            ),
          ),
        if (restCount > 0)
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: AppColors.textgrey,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                '+$restCount',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                  letterSpacing: -0.23,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
