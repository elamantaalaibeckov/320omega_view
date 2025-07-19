import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_icons.dart';

class OmegaViewTransactionPage extends StatefulWidget {
  const OmegaViewTransactionPage({Key? key}) : super(key: key);

  @override
  State<OmegaViewTransactionPage> createState() =>
      _OmegaViewTransactionPageState();
}

class _OmegaViewTransactionPageState extends State<OmegaViewTransactionPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this)
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
    final int idx = _tc.index;
    // Dynamic indicator shape: rounded on ends, square in middle
    final BorderRadius indicatorRadius = idx == 0
        ? BorderRadius.only(
            topLeft: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
          )
        : idx == 2
            ? BorderRadius.only(
                topRight: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              )
            : BorderRadius.zero;
    final indicatorDecoration = BoxDecoration(
      border: Border.all(color: accent, width: 1.5),
      borderRadius: indicatorRadius,
    );

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavigatorAppBarColor,
        elevation: 0,
        title: Text(
          'Transaction',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: TabBar(
                  controller: _tc,
                  indicator: indicatorDecoration,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppColors.textWhite,
                  unselectedLabelColor: AppColors.textgrey,
                  labelStyle:
                      TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Income'),
                    Tab(text: 'Expenses'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tc,
                  children: [
                    _buildEmptyState('No transactions have been added yet'),
                    _buildEmptyState('No income has been added yet'),
                    _buildEmptyState('No expenses have been\nadded yet'),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: FloatingActionButton(
              onPressed: () {},
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppIcons.transacktionImage,
            width: 182.w,
            height: 170.h,
          ),
          SizedBox(height: 24.h),
          Text(
            message,
            style: TextStyle(
              color: AppColors.textgrey,
              fontSize: 19.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
