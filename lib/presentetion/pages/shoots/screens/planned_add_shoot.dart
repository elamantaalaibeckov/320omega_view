// lib/presentation/pages/shoots/screens/planned_add_shoot.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'package:omega_view_smart_plan_320/cubit/shoots/shoots_cubit.dart';
import 'package:omega_view_smart_plan_320/model/omega_shoot_model.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/shoots/screens/cupertino_date_picker.dart';
import 'package:omega_view_smart_plan_320/presentetion/themes/app_colors.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text.dart';
import 'package:omega_view_smart_plan_320/presentetion/widgets/app_text_filed.dart';

class PlannedAddShoot extends StatefulWidget {
  final OmegaShootModel? editShoot;
  const PlannedAddShoot({Key? key, this.editShoot}) : super(key: key);

  @override
  State<PlannedAddShoot> createState() => _PlannedAddShootState();
}

class _PlannedAddShootState extends State<PlannedAddShoot>
    with SingleTickerProviderStateMixin {
  bool _isDirty = false;

  late final TabController _tc;
  int _tabIndex = 0; // <-- текущее состояние вкладки

  // Planned fields
  DateTime _plannedSelectedDate = DateTime.now();
  DateTime _plannedSelectedTime =
      DateTime(0, 0, 0, TimeOfDay.now().hour, TimeOfDay.now().minute);
  bool _plannedDatePicked = false;
  bool _plannedTimePicked = false;
  final _plannedClientNameCtrl = TextEditingController();
  final _plannedAddressCtrl = TextEditingController();
  final _plannedCommentsCtrl = TextEditingController();
  bool _notify = false;

  // Completed fields
  DateTime _completedSelectedDate = DateTime.now();
  DateTime _completedSelectedTime =
      DateTime(0, 0, 0, TimeOfDay.now().hour, TimeOfDay.now().minute);
  bool _completedDatePicked = false;
  bool _completedTimePicked = false;
  final _completedClientNameCtrl = TextEditingController();
  final _completedAddressCtrl = TextEditingController();
  final _completedCommentsCtrl = TextEditingController();

  // photos (общие списки, как у тебя)
  final List<XFile> _refPhotos = [];
  final List<XFile> _finalShots = [];
  static const int _maxPhotos = 17;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // ---------- ADDED helpers ----------
  void _clearPlanned() {
    _plannedSelectedDate = DateTime.now();
    _plannedSelectedTime =
        DateTime(0, 0, 0, TimeOfDay.now().hour, TimeOfDay.now().minute);
    _plannedDatePicked = false;
    _plannedTimePicked = false;
    _plannedClientNameCtrl.clear();
    _plannedAddressCtrl.clear();
    _plannedCommentsCtrl.clear();
    _notify = false;
  }

  void _clearCompleted() {
    _completedSelectedDate = DateTime.now();
    _completedSelectedTime =
        DateTime(0, 0, 0, TimeOfDay.now().hour, TimeOfDay.now().minute);
    _completedDatePicked = false;
    _completedTimePicked = false;
    _completedClientNameCtrl.clear();
    _completedAddressCtrl.clear();
    _completedCommentsCtrl.clear();
    _finalShots.clear();
  }
  // ------------------------------------

  @override
  void initState() {
    super.initState();

    // Prefill only the side we're editing
    if (widget.editShoot != null) {
      final s = widget.editShoot!;
      _tabIndex = s.isPlanned ? 0 : 1;

      if (s.isPlanned) {
        // ---- FILL PLANNED ONLY ----
        _plannedSelectedDate = s.date;
        _plannedDatePicked = true;
        _plannedSelectedTime = s.time;
        _plannedTimePicked = true;
        _plannedClientNameCtrl.text = s.clientName;
        _plannedAddressCtrl.text = s.address;
        if (s.comments != null) _plannedCommentsCtrl.text = s.comments!;
        if (s.shootReferencesPaths.isNotEmpty) {
          _refPhotos.addAll(s.shootReferencesPaths.map((p) => XFile(p)));
        }
        _notify = s.notificationsEnabled ?? false;

        // other side empty
        _clearCompleted();
      } else {
        // ---- FILL COMPLETED ONLY ----
        _completedSelectedDate = s.date;
        _completedDatePicked = true;
        _completedSelectedTime = s.time;
        _completedTimePicked = true;
        _completedClientNameCtrl.text = s.clientName;
        _completedAddressCtrl.text = s.address;
        if (s.comments != null) _completedCommentsCtrl.text = s.comments!;
        if (s.finalShotsPaths != null) {
          _finalShots.addAll(s.finalShotsPaths!.map((p) => XFile(p)));
        }
        if (s.shootReferencesPaths.isNotEmpty) {
          _refPhotos.addAll(s.shootReferencesPaths.map((p) => XFile(p)));
        }

        // other side empty
        _clearPlanned();
      }
    }

    _tc = TabController(
      length: 2,
      vsync: this,
      initialIndex: _tabIndex,
    )..addListener(_onTabChanged);

    // mark dirty on text fields
    [
      _plannedClientNameCtrl,
      _plannedAddressCtrl,
      _plannedCommentsCtrl,
      _completedClientNameCtrl,
      _completedAddressCtrl,
      _completedCommentsCtrl,
    ].forEach((c) => c.addListener(() => _isDirty = true));
  }

  void _onTabChanged() {
    if (_tc.index == _tabIndex) return;
    setState(() => _tabIndex = _tc.index);
  }

  @override
  void dispose() {
    _tc.removeListener(_onTabChanged);
    _tc.dispose();
    _plannedClientNameCtrl.dispose();
    _plannedAddressCtrl.dispose();
    _plannedCommentsCtrl.dispose();
    _completedClientNameCtrl.dispose();
    _completedAddressCtrl.dispose();
    _completedCommentsCtrl.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;
    final bool? confirmExit = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: Text('Leave the page?',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600)),
          content: Text(
            'Are you sure you want to get out? These transaction changes will not be saved',
            style: TextStyle(color: Colors.black, fontSize: 13.sp),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel',
                  style:
                      TextStyle(color: AppColors.mainAccent, fontSize: 17.sp)),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Leave',
                  style: TextStyle(
                      color: AppColors.mainAccent,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
    return confirmExit ?? false;
  }

  Future<void> _pickPhotos(List<XFile> targetList) async {
    _isDirty = true;
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Access to photos denied'),
          content: const Text('Allow access in settings to add photos.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Settings')),
          ],
        ),
      );
    }
    final picked = await _picker.pickMultiImage();
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        final space = _maxPhotos - targetList.length;
        targetList.addAll(picked.take(space));
      });
    }
  }

  void _removePhoto(List<XFile> list, int i) {
    _isDirty = true;
    setState(() => list.removeAt(i));
  }

  void _saveShoot() {
    final isPlanned = _tabIndex == 0;
    final id = widget.editShoot?.id ?? const Uuid().v4();

    final model = isPlanned
        ? OmegaShootModel.planned(
            id: id,
            clientName: _plannedClientNameCtrl.text,
            date: _plannedSelectedDate,
            time: _plannedSelectedTime,
            address: _plannedAddressCtrl.text,
            comments: _plannedCommentsCtrl.text.isNotEmpty
                ? _plannedCommentsCtrl.text
                : null,
            shootReferencesPaths: _refPhotos.map((x) => x.path).toList(),
            notificationsEnabled: _notify,
          )
        : OmegaShootModel.completed(
            id: id,
            clientName: _completedClientNameCtrl.text,
            date: _completedSelectedDate,
            time: _completedSelectedTime,
            address: _completedAddressCtrl.text,
            comments: _completedCommentsCtrl.text.isNotEmpty
                ? _completedCommentsCtrl.text
                : null,
            shootReferencesPaths: _refPhotos.map((x) => x.path).toList(),
            finalShotsPaths: _finalShots.map((x) => x.path).toList(),
          );

    final cubit = context.read<ShootsCubit>();
    if (widget.editShoot == null) {
      cubit.addShoot(model);
    } else {
      cubit.updateShoot(model.id, model);
    }
    Navigator.pop(context);
  }

  Future<void> _deleteShoot() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(
          'Delete shoot',
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 17.sp, fontFamily: 'Lato'),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
              'If you delete this shoot, you will not be able to recover it.',
              style: TextStyle(fontSize: 12.sp, fontFamily: 'Lato')),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('Cancel', style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text('Delete',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      context.read<ShootsCubit>().deleteShoot(widget.editShoot!.id);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.mainAccent;
    final isFirstTab = _tabIndex == 0;

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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: AppColors.bottomNavigatorAppBarColor,
          leading: const BackButton(color: Colors.white),
          title: Text(
            widget.editShoot == null ? 'Add Shoot' : 'Edit Shoot',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          actions: [
            if (widget.editShoot != null)
              GestureDetector(
                onTap: _deleteShoot,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Image.asset(
                      AppIcons.deleteshoot,
                      width: 24.w,
                      height: 24.h,
                      color: AppColors.textWhite,
                    )),
              ),
          ],
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
      ),
    );
  }

  Widget _buildPlannedForm() {
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
            color: AppColors.filedGrey,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notification',
                    style: TextStyle(
                      color: _notify ? AppColors.textWhite : AppColors.textgrey,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
            onPressed: plannedEnabled ? _saveShoot : null,
            child: Text(widget.editShoot == null ? 'Add' : 'Save',
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
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
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
            onPressed: completedEnabled ? _saveShoot : null,
            child: Text(widget.editShoot == null ? 'Add' : 'Save',
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
    final hasAdd = list.length < _maxPhotos;
    final total = hasAdd ? list.length + 1 : list.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTexts(texTs: title),
        SizedBox(height: 8.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: total,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, i) {
            if (hasAdd && i == 0) {
              return GestureDetector(
                onTap: onAdd,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.filedGrey,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Image.asset(
                      AppIcons.plusIcon,
                      width: 32.w,
                      height: 32.h,
                    ),
                  ),
                ),
              );
            }

            final photoIdx = hasAdd ? i - 1 : i;
            if (photoIdx < list.length) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(
                      File(list[photoIdx].path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => onRemove(photoIdx),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: AppColors.filedGrey,
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
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
