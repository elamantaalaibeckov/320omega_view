import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart'; // Add uuid for unique IDs

// Cubit and Model imports
import 'package:omega_view_smart_plan_320/cubit/shoots/shoots_cubit.dart';
import 'package:omega_view_smart_plan_320/model/omega_shoot_model.dart';

// Your custom widget imports
import 'package:omega_view_smart_plan_320/presentetion/pages/shoots/screens/cupertino_date_picker.dart';
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
  // Planned for own date/time variables
  DateTime _plannedSelectedDate = DateTime.now();
  DateTime _plannedSelectedTime = DateTime(
    0,
    0,
    0,
    TimeOfDay.now().hour,
    TimeOfDay.now().minute,
  );

  // Completed for own date/time variables
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

  // PICK FLAGS
  bool _plannedDatePicked = false;
  bool _plannedTimePicked = false;
  bool _completedDatePicked = false;
  bool _completedTimePicked = false;

  // TEXT CONTROLLERS
  final _plannedClientNameCtrl = TextEditingController();
  final _plannedAddressCtrl = TextEditingController();
  final _plannedCommentsCtrl =
      TextEditingController(); // Added comments controller

  final _completedClientNameCtrl = TextEditingController();
  final _completedAddressCtrl = TextEditingController();
  final _completedCommentsCtrl =
      TextEditingController(); // Added comments controller

  // PHOTO LISTS
  final List<XFile> _refPhotos = [];
  final List<XFile> _finalShots = [];
  static const int _maxPhotos = 17;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid(); // Initialize Uuid

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tc.dispose();
    _plannedClientNameCtrl.dispose();
    _plannedAddressCtrl.dispose();
    _plannedCommentsCtrl.dispose();
    _completedClientNameCtrl.dispose();
    _completedAddressCtrl.dispose();
    _completedCommentsCtrl.dispose();
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

  void _addPlannedShoot() {
    final newShoot = OmegaShootModel.planned(
      id: _uuid.v4(), // Generate a unique ID
      clientName: _plannedClientNameCtrl.text,
      date: _plannedSelectedDate,
      time: _plannedSelectedTime,
      address: _plannedAddressCtrl.text,
      comments: _plannedCommentsCtrl.text.isNotEmpty
          ? _plannedCommentsCtrl.text
          : null,
      shootReferencesPaths: _refPhotos.map((xfile) => xfile.path).toList(),
      notificationsEnabled: _notify,
    );
    context.read<ShootsCubit>().addShoot(newShoot);
    Navigator.pop(context);
  }

  void _addCompletedShoot() {
    final newShoot = OmegaShootModel.completed(
      id: _uuid.v4(), // Generate a unique ID
      clientName: _completedClientNameCtrl.text,
      date: _completedSelectedDate,
      time: _completedSelectedTime,
      address: _completedAddressCtrl.text,
      finalShotsPaths: _finalShots.map((xfile) => xfile.path).toList(),
      comments: _completedCommentsCtrl.text.isNotEmpty
          ? _completedCommentsCtrl.text
          : null,
      shootReferencesPaths: _refPhotos.map((xfile) => xfile.path).toList(),
    );
    context.read<ShootsCubit>().addShoot(newShoot);
    Navigator.pop(context);
  }

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
    // enable when all required fields filled
    final bool plannedEnabled = _plannedDatePicked &&
        _plannedTimePicked &&
        _plannedClientNameCtrl.text.isNotEmpty &&
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
          isPicked: _plannedDatePicked,
          initialDateTime: _plannedSelectedDate,
          mode: CupertinoDatePickerMode.date,
          formatter: DateFormat('MMM dd, yyyy'),
          onDateTimeChanged: (dt) => setState(() {
            _plannedSelectedDate = dt;
            _plannedDatePicked = true;
          }),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Select Time'),
        SizedBox(height: 8.h),
        CupertinoDateTimeField(
          isPicked: _plannedTimePicked,
          initialDateTime: _plannedSelectedTime,
          mode: CupertinoDatePickerMode.time,
          formatter: DateFormat('HH:mm'),
          onDateTimeChanged: (dt) => setState(() {
            _plannedSelectedTime = dt;
            _plannedTimePicked = true;
          }),
        ),
        SizedBox(height: 16.h),
        const AppTexts(texTs: 'Client’s Name'),
        SizedBox(height: 8.h),
        AppTextField(
          controller: _plannedClientNameCtrl,
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
        AppTextField(
          controller: _plannedCommentsCtrl,
          hintText: 'Add Comments',
        ),
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
            onPressed: plannedEnabled ? _addPlannedShoot : null,
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
        _completedClientNameCtrl.text.isNotEmpty &&
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
          isPicked: _completedDatePicked,
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
          isPicked: _completedTimePicked,
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
          controller: _completedClientNameCtrl,
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
        AppTextField(
          controller: _completedCommentsCtrl,
          hintText: 'Add Comments',
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            style: style,
            onPressed: completedEnabled ? _addCompletedShoot : null,
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
            // Adjust photoIdx because the first item is the add button
            final photoIdx = list.length < _maxPhotos ? idx - 1 : idx;
            if (photoIdx < 0 || photoIdx >= list.length) {
              return const SizedBox
                  .shrink(); // Should not happen with correct logic
            }
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
