import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/analytics/omega_view_analytics_page.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/settings/omega_view_settings_page.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/shoots/omega_view_shoots_page.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/transaction/omega_view_transaction_page.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_icons.dart';

class OmegaBottomnavigationBar extends StatefulWidget {
  const OmegaBottomnavigationBar({super.key});

  @override
  State<OmegaBottomnavigationBar> createState() =>
      _OmegaBottomnavigationBarState();
}

class _OmegaBottomnavigationBarState extends State<OmegaBottomnavigationBar> {
  int selecIndaex = 0;

  final List<Widget> _pages = [
    const KeyedSubtree(key: ValueKey(0), child: OmegaViewShootsPage()),
    const KeyedSubtree(key: ValueKey(1), child: OmegaViewTransactionPage()),
    const KeyedSubtree(key: ValueKey(2), child: OmegaViewAnalyticsPage()),
    const KeyedSubtree(key: ValueKey(3), child: OmegaViewSettingsPage()),
  ];

  // Иконки и подписи
  final List<String> _icons = [
    AppIcons.btNavigator1,
    AppIcons.btNavigator2,
    AppIcons.btNavigator3,
    AppIcons.btNavigator4,
  ];
  final List<String> _labels = [
    'Shoots',
    'Transaction',
    'Analytics',
    'Settings',
  ];

  void ontapItem(int index) {
    setState(() {
      selecIndaex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        child: _pages[selecIndaex],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 90.h,
          color: AppColors.bottomNavigatorAppBarColor,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_icons.length, (i) {
              final isSelected = selecIndaex == i;
              return InkWell(
                onTap: () => ontapItem(i),
                borderRadius: BorderRadius.circular(24.r),
                child: isSelected
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mainAccent,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              _icons[i],
                              width: 24.w,
                              height: 24.h,
                              color: AppColors.textWhite,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _labels[i],
                              style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  height: 1.38,
                                  letterSpacing: -0.08),
                            ),
                          ],
                        ),
                      )
                    : Image.asset(
                        _icons[i],
                        width: 24.w,
                        height: 24.h,
                        color: AppColors.textWhite,
                      ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
