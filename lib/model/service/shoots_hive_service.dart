// lib/model/service/shoots_hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../omega_shoot_model.dart';

class ShootsHiveService {
  static const String _boxName = 'shootsBox';

  /// Инициализацияны башта: адаптерди каттоo жана боксту ачуу
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OmegaShootModelAdapter());
    }
    await Hive.openBox<OmegaShootModel>(_boxName);
  }

  Box<OmegaShootModel> get _box => Hive.box<OmegaShootModel>(_boxName);

  /// Бардык “shoot” моделдерин ал
  List<OmegaShootModel> getAll() => _box.values.toList();

  /// Жаңы “shoot” кош
  Future<int> addShoot(OmegaShootModel shoot) => _box.add(shoot);

  /// Моделди ачкыч боюнча жаңырт
  Future<void> updateShoot(int key, OmegaShootModel shoot) =>
      _box.put(key, shoot);

  /// Ачкыч боюнча өчүр
  Future<void> deleteShoot(int key) => _box.delete(key);

  /// Бардыгын тазалоо (талап кылынса)
  Future<void> clearAll() => _box.clear();
}
