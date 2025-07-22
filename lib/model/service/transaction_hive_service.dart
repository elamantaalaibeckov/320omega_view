// lib/model/service/transaction_hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../omega_transaction_model.dart';

class TransactionHiveService {
  static const String _boxName = 'transactionsBox';

  /// Инициализация: адаптерди каттоо жана боксту ачуу
  static Future<void> init() async {
    // Адаптер для OmegaTransactionModel должен быть зарегистрирован в main.dart
    await Hive.openBox<OmegaTransactionModel>(_boxName);
  }

  Box<OmegaTransactionModel> get _box => Hive.box<OmegaTransactionModel>(_boxName);

  /// Бардыгын карап чык
  List<OmegaTransactionModel> getAll() => _box.values.toList();

  /// Жаңысын кош
  Future<void> addTransaction(OmegaTransactionModel tx) => _box.put(tx.id, tx); // Используем id как ключ

  /// Жаңыртуу
  Future<void> updateTransaction(String id, OmegaTransactionModel tx) =>
      _box.put(id, tx); // Обновляем по id

  /// Өчүрүү
  Future<void> deleteTransaction(String id) => _box.delete(id); // Удаляем по id

  /// Бардыгын өчүрүү
  Future<void> clearAll() => _box.clear();
}