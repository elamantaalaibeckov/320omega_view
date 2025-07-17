// lib/cubit/shoots/shoots_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/omega_shoot_model.dart';
import '../../model/service/shoots_hive_service.dart';
import 'shoots_state.dart';

class ShootsCubit extends Cubit<ShootsState> {
  final ShootsHiveService _service;

  ShootsCubit(this._service) : super(ShootsState.initial());

  Future<void> loadShoots() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final all = _service.getAll();
      emit(state.copyWith(shoots: all, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> addShoot(OmegaShootModel shoot) async {
    await _service.addShoot(shoot);
    await loadShoots();
  }

  Future<void> updateShoot(int key, OmegaShootModel shoot) async {
    await _service.updateShoot(key, shoot);
    await loadShoots();
  }

  Future<void> deleteShoot(int key) async {
    await _service.deleteShoot(key);
    await loadShoots();
  }

  Future<void> clearAll() async {
    await _service.clearAll();
    emit(ShootsState.initial());
  }
}
