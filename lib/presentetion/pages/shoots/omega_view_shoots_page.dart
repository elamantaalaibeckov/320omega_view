import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/shoots/screens/planned_add_shoot.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_images.dart';

class OmegaViewShootsPage extends StatefulWidget {
  const OmegaViewShootsPage({Key? key}) : super(key: key);

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
                child: TabBarView(
                  controller: _tc,
                  children: [
                    Padding(
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
                            'No planned shoots\nhave been added yet',
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
                    ),
                    Padding(
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
                            'No completed shoots\nhave been added yet',
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
                    ),
                  ],
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
}
