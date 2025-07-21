// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omega_transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OmegaTransactionModelAdapter extends TypeAdapter<OmegaTransactionModel> {
  @override
  final int typeId = 1;

  @override
  OmegaTransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OmegaTransactionModel(
      id: fields[0] as String,
      shootId: fields[1] as String,
      amount: fields[2] as double,
      category: fields[3] as String,
      date: fields[4] as DateTime,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OmegaTransactionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.shootId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OmegaTransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
