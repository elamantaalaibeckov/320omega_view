// lib/model/omega_shoot_model.dart

import 'package:hive/hive.dart';

part 'omega_shoot_model.g.dart';

@HiveType(typeId: 0)
class OmegaShootModel extends HiveObject {
  @HiveField(0)
  final String id; // Unique ID for the shoot

  @HiveField(1)
  final String clientName; // Client's Name

  @HiveField(2)
  final DateTime date; // Date of the shoot

  @HiveField(3)
  final DateTime
      time; // Time of the shoot (can be combined with date or stored separately if only time matters)

  @HiveField(4)
  final String address; // Address of the shoot location

  @HiveField(5)
  final String? comments; // Comments/Description (optional)

  @HiveField(6)
  final bool isPlanned; // True if planned, false if completed

  @HiveField(7)
  final List<String>
      shootReferencesPaths; // Paths to local images for shoot references (XFile.path)

  @HiveField(8)
  final List<String>?
      finalShotsPaths; // Paths to local images for final shots (XFile.path), null for planned

  @HiveField(9)
  final bool?
      notificationsEnabled; // True if notifications are enabled, null for completed shoots

  OmegaShootModel({
    required this.id,
    required this.clientName,
    required this.date,
    required this.time,
    required this.address,
    this.comments,
    required this.isPlanned,
    this.shootReferencesPaths = const [], // Default to empty list
    this.finalShotsPaths,
    this.notificationsEnabled,
  });

  // Helper to create a planned shoot
  factory OmegaShootModel.planned({
    required String id,
    required String clientName,
    required DateTime date,
    required DateTime time,
    required String address,
    String? comments,
    List<String> shootReferencesPaths = const [],
    bool notificationsEnabled = false,
  }) {
    return OmegaShootModel(
      id: id,
      clientName: clientName,
      date: date,
      time: time,
      address: address,
      comments: comments,
      isPlanned: true,
      shootReferencesPaths: shootReferencesPaths,
      notificationsEnabled: notificationsEnabled,
      finalShotsPaths: null, // Planned shoots don't have final shots
    );
  }

  // Helper to create a completed shoot
  factory OmegaShootModel.completed({
    required String id,
    required String clientName,
    required DateTime date,
    required DateTime time,
    required String address,
    required List<String> finalShotsPaths,
    String? comments,
    List<String> shootReferencesPaths = const [],
  }) {
    return OmegaShootModel(
      id: id,
      clientName: clientName,
      date: date,
      time: time,
      address: address,
      comments: comments,
      isPlanned: false,
      shootReferencesPaths: shootReferencesPaths,
      finalShotsPaths: finalShotsPaths,
      notificationsEnabled:
          null, // Completed shoots don't need notifications enabled
    );
  }

  get clientAddress => null;

  // Для удобства при отладке и копировании
  OmegaShootModel copyWith({
    String? id,
    String? clientName,
    DateTime? date,
    DateTime? time,
    String? address,
    String? comments,
    bool? isPlanned,
    List<String>? shootReferencesPaths,
    List<String>? finalShotsPaths,
    bool? notificationsEnabled,
  }) {
    return OmegaShootModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      date: date ?? this.date,
      time: time ?? this.time,
      address: address ?? this.address,
      comments: comments ?? this.comments,
      isPlanned: isPlanned ?? this.isPlanned,
      shootReferencesPaths: shootReferencesPaths ?? this.shootReferencesPaths,
      finalShotsPaths: finalShotsPaths ?? this.finalShotsPaths,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
