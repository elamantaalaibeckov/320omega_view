import 'package:hive_flutter/hive_flutter.dart';

import '../omega_shoot_model.dart'; // автогенерируемый адаптер (typeId = 0)
import '../omega_shoot_model_adapter_v2.dart'; // «умный» адаптер (typeId = 2)

class ShootsHiveService {
  static const String _boxName = 'shootsBox';

  /// Регистрируем адаптеры и открываем бокс
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OmegaShootModelAdapter()); // обычный
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(OmegaShootModelV2Adapter()); // новый «умный»
    }
    await Hive.openBox<OmegaShootModel>(_boxName);
  }

  Box<OmegaShootModel> get _box => Hive.box<OmegaShootModel>(_boxName);

  List<OmegaShootModel> getAll() => _box.values.toList();
  Future<int> addShoot(OmegaShootModel shoot) => _box.add(shoot);
  Future<void> updateShoot(int key, OmegaShootModel shoot) =>
      _box.put(key, shoot);
  Future<void> deleteShoot(int key) => _box.delete(key);
  Future<void> clearAll() => _box.clear();
}
