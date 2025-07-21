import 'package:hive_flutter/hive_flutter.dart';
import '../omega_shoot_model.dart'; // Только один, автогенерируемый адаптер

class ShootsHiveService {
  static const String _boxName = 'shootsBox';

  static Future<void> init() async {
    // Регистрация адаптера для OmegaShootModel должна быть в main.dart
    // Здесь мы просто открываем бокс
    await Hive.openBox<OmegaShootModel>(_boxName);
  }

  Box<OmegaShootModel> get _shootBox => Hive.box<OmegaShootModel>(_boxName);

  List<OmegaShootModel> getAll() {
    return _shootBox.values.toList();
  }

  OmegaShootModel? getShoot(String id) {
    // В Hive, если вы используете .put(key, value), то key - это и есть id вашей модели.
    return _shootBox.get(id);
  }

  Future<void> addShoot(OmegaShootModel shoot) async {
    // Используем id модели как ключ для хранения в Hive
    await _shootBox.put(shoot.id, shoot);
  }

  Future<void> updateShoot(String id, OmegaShootModel updatedShoot) async {
    // Обновляем запись по её id
    await _shootBox.put(id, updatedShoot);
  }

  Future<void> deleteShoot(String id) async {
    // Удаляем запись по её id
    await _shootBox.delete(id);
  }

  Future<void> clearAll() async {
    await _shootBox.clear();
  }
}