// lib/model/omega_transaction_model.dart

import 'package:hive/hive.dart';

part 'omega_transaction_model.g.dart';

@HiveType(typeId: 1)
class OmegaTransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String note;

  OmegaTransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
  });
}
