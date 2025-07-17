// lib/model/service/transaction_hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../omega_transaction_model.dart';

class TransactionHiveService {
  static const String _boxName = 'transactionsBox';

  /// Инициализация: адаптерди каттоо жана боксту ачуу
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(OmegaTransactionModelAdapter());
    }
    await Hive.openBox<OmegaTransactionModel>(_boxName);
  }

  Box<OmegaTransactionModel> get _box =>
      Hive.box<OmegaTransactionModel>(_boxName);

  /// Бардыгын карап чык
  List<OmegaTransactionModel> getAll() => _box.values.toList();

  /// Жаңысын кош
  Future<int> addTransaction(OmegaTransactionModel tx) => _box.add(tx);

  /// Жаңыртуу
  Future<void> updateTransaction(int key, OmegaTransactionModel tx) =>
      _box.put(key, tx);

  /// Өчүрүү
  Future<void> deleteTransaction(int key) => _box.delete(key);

  /// Бардыгын өчүрүү
  Future<void> clearAll() => _box.clear();
}
