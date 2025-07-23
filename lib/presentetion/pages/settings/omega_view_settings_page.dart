import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omega_view_smart_plan_320/main.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';

class OmegaViewSettingsPage extends StatefulWidget {
  const OmegaViewSettingsPage({super.key});

  @override
  State<OmegaViewSettingsPage> createState() => _OmegaViewSettingsPageState();
}

class _OmegaViewSettingsPageState extends State<OmegaViewSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavigatorAppBarColor,
        title: Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
        children: [
          _SettingsItem(
            title: 'Privacy Policy',
            onTap: () => webOutfit(
              context,
              'Privacy Policy',
            ),
          ),
          SizedBox(height: 12.h),
          _SettingsItem(
            title: 'Terms of Use',
            onTap: () => webOutfit(
              context,
              'Terms of Use',
            ),
          ),
          SizedBox(height: 12.h),
          _SettingsItem(
            title: 'Support',
            onTap: () => webOutfit(
              context,
              'Support',
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.filedGrey,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
