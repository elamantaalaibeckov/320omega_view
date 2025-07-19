// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omega_shoot_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OmegaShootModelAdapter extends TypeAdapter<OmegaShootModel> {
  @override
  final int typeId = 0;

  // ----------  ДОБАВЬ ЭТО ----------
  /// Принимает либо DateTime, либо строку в ISO‑формате.
  DateTime _toDateTime(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.parse(v);
    throw ArgumentError('Unsupported date value: $v');
  }
  // ---------------------------------

  @override
  OmegaShootModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return OmegaShootModel(
      id: fields[0] as String,
      clientName: fields[1] as String,
      date: _toDateTime(fields[2]), // <‑‑ используем парсер
      time: _toDateTime(fields[3]), // <‑‑
      address: fields[4] as String,
      comments: fields[5] as String?,
      isPlanned: fields[6] as bool,
      shootReferencesPaths: (fields[7] as List).cast<String>(),
      finalShotsPaths: (fields[8] as List?)?.cast<String>(),
      notificationsEnabled: fields[9] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, OmegaShootModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientName)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.comments)
      ..writeByte(6)
      ..write(obj.isPlanned)
      ..writeByte(7)
      ..write(obj.shootReferencesPaths)
      ..writeByte(8)
      ..write(obj.finalShotsPaths)
      ..writeByte(9)
      ..write(obj.notificationsEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OmegaShootModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
