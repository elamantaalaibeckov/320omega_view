// lib/model/omega_transaction_model.dart

import 'package:hive/hive.dart';

part 'omega_transaction_model.g.dart';

@HiveType(typeId: 1) // Изменено на typeId: 1
class OmegaTransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String shootId; // Добавлено для связи со съемкой
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final String category; // Например: 'Income', 'Expense'
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  final String? note; // Сделано nullable

  OmegaTransactionModel({
    required this.id,
    required this.shootId, // Добавлено
    required this.amount,
    required this.category,
    required this.date,
    this.note, // Сделано nullable
  });

  OmegaTransactionModel copyWith({
    String? id,
    String? shootId,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return OmegaTransactionModel(
      id: id ?? this.id,
      shootId: shootId ?? this.shootId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}