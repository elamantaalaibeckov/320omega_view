import 'package:hive_flutter/hive_flutter.dart';
import 'package:omega_view_smart_plan_320/model/omega_shoot_model.dart';

class ShootsHiveService {
  static const String _boxName = 'shootsBox';

  static Future<void> init() async {
    // Adapter for OmegaShootModel should be registered in main.dart
    // Здесь мы просто открываем бокс, регистрация будет в main.dart
    await Hive.openBox<OmegaShootModel>(_boxName);
  }

  Box<OmegaShootModel> get _shootBox => Hive.box<OmegaShootModel>(_boxName);

  List<OmegaShootModel> getAll() {
    return _shootBox.values.toList();
  }

  OmegaShootModel? getShoot(String id) {
    // Ищем съемку по её id (который является ключом в Hive)
    return _shootBox.get(id); // Используем .get() для прямого поиска по ключу
  }

  Future<void> addShoot(OmegaShootModel shoot) async {
    await _shootBox.put(shoot.id, shoot); // Используем shoot.id как ключ
  }

  Future<void> updateShoot(String id, OmegaShootModel updatedShoot) async {
    await _shootBox.put(id, updatedShoot); // Обновляем по id
  }

  Future<void> deleteShoot(String id) async {
    await _shootBox.delete(id); // Удаляем по id
  }

  Future<void> clearAll() async {
    await _shootBox.clear();
  }
}