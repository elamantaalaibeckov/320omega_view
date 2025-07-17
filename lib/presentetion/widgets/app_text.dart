import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';

class AppTexts extends StatelessWidget {
  final String texTs;
  const AppTexts({super.key, required this.texTs});

  @override
  Widget build(BuildContext context) {
    return Text(
      texTs,
      style: TextStyle(
        color: AppColors.textWhite,
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
