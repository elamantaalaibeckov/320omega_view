// lib/model/omega_shoot_model.dart

import 'package:hive/hive.dart';

part 'omega_shoot_model.g.dart';

@HiveType(typeId: 0)
class OmegaShootModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final String description;

  OmegaShootModel({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
  });
}
