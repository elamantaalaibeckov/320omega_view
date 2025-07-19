import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text_filed.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;
  int _tabIndex = 0;
  final TextEditingController _amountCtrl = TextEditingController();
  String? _selectedShoot;
  final TextEditingController _commentsCtrl = TextEditingController();

  // TODO: replace with real shoot list
  final List<String> _shoots = [];

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 2, vsync: this)
      ..addListener(() {
        setState(() {
          _tabIndex = _tc.index;
        });
      });
  }

  @override
  void dispose() {
    _tc.dispose();
    _amountCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.mainAccent;
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.bottomNavigatorAppBarColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          'Add Transaction',
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
          Padding(
            padding: EdgeInsets.only(bottom: 80.h), // leave space for button
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: TabBar(
                    controller: _tc,
                    indicator: BoxDecoration(
                      border: Border.all(color: accent, width: 1.5),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.textWhite,
                    unselectedLabelColor: AppColors.textgrey,
                    labelStyle:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                    tabs: const [Tab(text: 'Income'), Tab(text: 'Expenses')],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _buildForm(_tabIndex == 0),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
            child: SizedBox(
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                onPressed: () {
                  // TODO: save transaction
                },
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isIncome) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        AppTexts(
          texTs: 'Income amout',
        ),
        SizedBox(height: 8.h),
        AppTextField(
          hintText: 'Add Income',
          controller: _amountCtrl,
          isNumberOnly: true,
        ),
        SizedBox(height: 16.h),
        AppTexts(texTs: 'Select shoot'),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _selectedShoot,
          hint: Text(
            'Select',
            style: TextStyle(
              color: AppColors.textgrey,
              fontSize: 14.sp,
            ),
          ),
          items: _shoots.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(
                s,
                style: TextStyle(
                  color: AppColors.textgrey,
                  fontSize: 15.sp,
                ),
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedShoot = v),
          style: TextStyle(
            color: AppColors.textgrey,
            fontSize: 14.sp,
          ),
          iconEnabledColor: AppColors.textgrey,
          dropdownColor: AppColors.bottomNavigatorAppBarColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bottomNavigatorAppBarColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          ),
        ),
        SizedBox(height: 16.h),
        AppTexts(texTs: 'Comments (optional)'),
        SizedBox(height: 8.h),
        AppTextField(hintText: 'Add Comments'),
        SizedBox(height: 24.h),
      ],
    );
  }
}
