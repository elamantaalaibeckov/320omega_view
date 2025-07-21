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
      print('Error loading shoots: $e'); // Добавим для отладки
    }
  }

  Future<void> addShoot(OmegaShootModel shoot) async {
    try {
      await _service.addShoot(shoot);
      await loadShoots();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to add shoot: $e'));
      print('Error adding shoot: $e');
    }
  }

  Future<void> updateShoot(String id, OmegaShootModel shoot) async { // Используем String id
    try {
      await _service.updateShoot(id, shoot);
      await loadShoots();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update shoot: $e'));
      print('Error updating shoot: $e');
    }
  }

  Future<void> deleteShoot(String id) async { // Используем String id
    try {
      await _service.deleteShoot(id);
      await loadShoots();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete shoot: $e'));
      print('Error deleting shoot: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _service.clearAll();
      emit(ShootsState.initial());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to clear all shoots: $e'));
      print('Error clearing all shoots: $e');
    }
  }
}