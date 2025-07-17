// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omega_shoot_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OmegaShootModelAdapter extends TypeAdapter<OmegaShootModel> {
  @override
  final int typeId = 0;

  @override
  OmegaShootModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OmegaShootModel(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime,
      location: fields[3] as String,
      description: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OmegaShootModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.description);
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
