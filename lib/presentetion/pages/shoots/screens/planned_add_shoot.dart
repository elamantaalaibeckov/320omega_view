import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// Сиздин custom виджеттериңиздин импорттору
import 'package:omega_view_smart_plan_320/presentetion/pages/shoots/screens/cupertino_date_picker.dart'; // Бул файлдын атын туураладым
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_icons.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text_filed.dart';

class PlannedAddShoot extends StatefulWidget {
  const PlannedAddShoot({Key? key}) : super(key: key);

  @override
  State<PlannedAddShoot> createState() => _PlannedAddShootState();
}

class _PlannedAddShootState extends State<PlannedAddShoot>
    with SingleTickerProviderStateMixin {
  // Planned үчүн өзүнчө дата/убакыт өзгөрмөлөрү
  DateTime _plannedSelectedDate = DateTime.now();
  DateTime _plannedSelectedTime = DateTime(
    0,
    0,
    0,
    TimeOfDay.now().hour,
    TimeOfDay.now().minute,
  );

  // Completed үчүн өзүнчө дата/убакыт өзгөрмөлөрү
  DateTime _completedSelectedDate = DateTime.now();
  DateTime _completedSelectedTime = DateTime(
    0,
    0,
    0,
    TimeOfDay.now().hour,
    TimeOfDay.now().minute,
  );

  late final TabController _tc;
  bool _notify = false;

  // PICK FLAGS - Бул флагдар ар бир дата/убакыт тандалганын көзөмөлдөйт.
  // Башында false болгондуктан, "Select" деген текст көрүнөт.
  bool _plannedDatePicked = false;
  bool _plannedTimePicked = false;
  bool _completedDatePicked = false;
  bool _completedTimePicked = false;

  // TEXT CONTROLLERS
  final _plannedNameCtrl = TextEditingController();
  final _plannedAddressCtrl = TextEditingController();
  final _completedNameCtrl = TextEditingController();
  final _completedAddressCtrl = TextEditingController();

  // PHOTO LISTS
  final List<XFile> _refPhotos = [];
  final List<XFile> _finalShots = [];
  static const int _maxPhotos = 17;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tc.dispose();
    _plannedNameCtrl.dispose();
    _plannedAddressCtrl.dispose();
    _completedNameCtrl.dispose();
    _completedAddressCtrl.dispose();
    super.dispose();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Access to Photos Denied'),
        content: const Text(
          'Allow access in Settings to add images of your shoot references and final shots.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhotos(List<XFile> targetList) async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      _showPermissionDialog();
      return;
    }
    final picked = await _picker.pickMultiImage();
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        final space = _maxPhotos - targetList.length;
        targetList.addAll(picked.take(space));
      });
    }
  }

  void _removePhoto(List<XFile> list, int i) =>
      setState(() => list.removeAt(i));

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.mainAccent;
    final isFirstTab = _tc.index == 0;
    final indicatorDecoration = BoxDecoration(
      border: Border.all(color: accent, width: 1.5),
      borderRadius: isFirstTab
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
        leading: const BackButton(color: Colors.white),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TabBar(
              controller: _tc,
              indicator: indicatorDecoration,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.textWhite,
              unselectedLabelColor: AppColors.textgrey,
              labelStyle:
                  TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              tabs: const [Tab(text: 'Planned'), Tab(text: 'Completed')],
            ),
          ),
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
    // enable when all 4 filled
    final bool plannedEnabled = _plannedDatePicked &&
        _plannedTimePicked &&
        _plannedNameCtrl.text.isNotEmpty &&
        _plannedAddressCtrl.text.isNotEmpty;

    final ButtonStyle style = ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        return states.contains(MaterialState.disabled)
            ? AppColors.textgrey
            : AppColors.mainAccent;
      }),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
      ),
    );

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        const AppTexts(texTs: 'Select Day'),
        SizedBox(height: 8.h),
        CupertinoDateTimeField(
          isPicked: _plannedDatePicked, // Жаңы касиетти берүү
          initialDateTime: _plannedSelectedDate,
          mode: CupertinoDatePickerMode.date,
          formatter: DateFormat('MMM dd, yyyy'),
          onDateTimeChanged: (dt) => setState(() {
            _plannedSelectedDate = dt;
            _plannedDatePicked = true; // Бул дата тандалды дегенди билдирет
          }),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Select Time'),
        SizedBox(height: 8.h),
        CupertinoDateTimeField(
          isPicked: _plannedTimePicked, // Жаңы касиетти берүү
          initialDateTime: _plannedSelectedTime,
          mode: CupertinoDatePickerMode.time,
          formatter: DateFormat('HH:mm'),
          onDateTimeChanged: (dt) => setState(() {
            _plannedSelectedTime = dt;
            _plannedTimePicked = true; // Бул убакыт тандалды дегенди билдирет
          }),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Client’s Name'),
        SizedBox(height: 8.h),
        AppTextField(
          controller: _plannedNameCtrl,
          hintText: 'Client’s Name',
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Address'),
        SizedBox(height: 8.h),
        AppTextField(
          controller: _plannedAddressCtrl,
          hintText: 'Add Address',
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        _buildPhotoGrid(
          title: 'Shoot References (optional)',
          list: _refPhotos,
          onAdd: () => _pickPhotos(_refPhotos),
          onRemove: (i) => _removePhoto(_refPhotos, i),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Comments (optional)'),
        SizedBox(height: 8.h),
        AppTextField(hintText: 'Add Comments'),
        SizedBox(height: 16.h),
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
                  Text('Notification',
                      style: TextStyle(
                          color: AppColors.textgrey,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500)),
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
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            style: style,
            onPressed: plannedEnabled
                ? () {
                    // Planned save action
                  }
                : null,
            child: Text('Add',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedForm() {
    final bool completedEnabled = _completedDatePicked &&
        _completedTimePicked &&
        _completedNameCtrl.text.isNotEmpty &&
        _completedAddressCtrl.text.isNotEmpty &&
        _finalShots.isNotEmpty;

    final ButtonStyle style = ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        return states.contains(MaterialState.disabled)
            ? AppColors.textgrey
            : AppColors.mainAccent;
      }),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
      ),
    );

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        const AppTexts(texTs: 'Select Day'),
        SizedBox(height: 8.h),
        CupertinoDateTimeField(
          isPicked: _completedDatePicked, // Жаңы касиетти берүү
          initialDateTime: _completedSelectedDate,
          mode: CupertinoDatePickerMode.date,
          formatter: DateFormat('MMM dd, yyyy'),
          onDateTimeChanged: (dt) => setState(() {
            _completedSelectedDate = dt;
            _completedDatePicked = true;
          }),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Select Time'),
        SizedBox(height: 8.h),
        CupertinoDateTimeField(
          isPicked: _completedTimePicked, // Жаңы касиетти берүү
          initialDateTime: _completedSelectedTime,
          mode: CupertinoDatePickerMode.time,
          formatter: DateFormat('HH:mm'),
          onDateTimeChanged: (dt) => setState(() {
            _completedSelectedTime = dt;
            _completedTimePicked = true;
          }),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Client’s Name'),
        SizedBox(height: 8.h),
        AppTextField(
          controller: _completedNameCtrl,
          hintText: 'Client’s Name',
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Address'),
        SizedBox(height: 8.h),
        AppTextField(
          controller: _completedAddressCtrl,
          hintText: 'Add Address',
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        _buildPhotoGrid(
          title: 'Final Shots',
          list: _finalShots,
          onAdd: () => _pickPhotos(_finalShots),
          onRemove: (i) => _removePhoto(_finalShots, i),
        ),
        SizedBox(height: 16.h),
        _buildPhotoGrid(
          title: 'Shoot References (optional)',
          list: _refPhotos,
          onAdd: () => _pickPhotos(_refPhotos),
          onRemove: (i) => _removePhoto(_refPhotos, i),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Comments (optional)'),
        SizedBox(height: 8.h),
        AppTextField(hintText: 'Add Comments'),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            style: style,
            onPressed: completedEnabled
                ? () {
                    // Completed save action
                  }
                : null,
            child: Text('Add',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid({
    required String title,
    required List<XFile> list,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
  }) {
    final total = list.length < _maxPhotos ? list.length + 1 : _maxPhotos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: Limit ${list.length}/$_maxPhotos',
          style: TextStyle(color: AppColors.textgrey, fontSize: 12.sp),
        ),
        SizedBox(height: 8.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1,
          ),
          itemCount: total,
          itemBuilder: (_, idx) {
            if (idx == 0 && list.length < _maxPhotos) {
              return InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bottomNavigatorAppBarColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Icon(Icons.add, size: 32.r, color: Colors.white),
                  ),
                ),
              );
            }
            final photoIdx = idx - 1;
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    image: DecorationImage(
                      image: FileImage(File(list[photoIdx].path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: InkWell(
                    onTap: () => onRemove(photoIdx),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: AppColors.bottomNavigatorAppBarColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Image.asset(
                          AppIcons.deleteshoot,
                          width: 18.w,
                          height: 22.h,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
