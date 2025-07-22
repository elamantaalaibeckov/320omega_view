import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/omega_bottomnavigation_bar.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';

class OmegaOnboardingPage extends StatefulWidget {
  const OmegaOnboardingPage({super.key});
  @override
  State<OmegaOnboardingPage> createState() => _OmegaOnboardingPageState();
}

class _OmegaOnboardingPageState extends State<OmegaOnboardingPage> {
  final _pc = PageController();
  int _index = 0;

  final _slides = const [
    _OnbSlide('assets/images/onboarding1.png',
        'Organize your shoots – track all details in one place!'),
    _OnbSlide('assets/images/onboarding2.png',
        'Track your earnings & expenses – see profits from shoots!'),
    _OnbSlide('assets/images/onboarding3.png',
        'Clear analytics –  best clients and financial trends!'),
  ];

  void _next() => _index < _slides.length - 1
      ? _pc.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut)
      : _finish();

  Future<void> _finish() async {
    Hive.box('settings').put('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OmegaBottomnavigationBar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.mainAccent,
        body: Column(
          children: [
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: PageView.builder(
                  controller: _pc,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: _slides.length,
                  itemBuilder: (_, i) => Image.asset(
                    _slides[i].image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            _Dots(count: _slides.length, current: _index),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _slides[_index].title,
                  key: ValueKey(_slides[_index].title),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 28.sp,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                    height: 1.21,
                    letterSpacing: 0.38,
                  ),
                ),
              ),
            ),
            SizedBox(height: 48.h),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 48.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textWhite,
                    foregroundColor: AppColors.mainAccent,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    textStyle: TextStyle(
                      fontSize: 17.sp,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      height: 1.29,
                      letterSpacing: -0.43,
                    ),
                  ),
                  onPressed: _next,
                  child: Text(_index == _slides.length - 1 ? 'Start' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnbSlide {
  final String image;
  final String title;
  const _OnbSlide(this.image, this.title);
}

class _Dots extends StatelessWidget {
  final int count;
  final int current;
  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: active
                ? AppColors.textWhite
                : Color(0xFFC9C9C9).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
