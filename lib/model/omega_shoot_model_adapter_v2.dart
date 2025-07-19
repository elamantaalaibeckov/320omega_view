import 'package:hive/hive.dart';
import 'omega_shoot_model.dart';

/// «Умный» адаптер, который понимает как DateTime, так и строки‑даты.
/// Дай ему `typeId = 1`, чтобы не конфликтовать с автогенерируемым (0).
class OmegaShootModelV2Adapter extends TypeAdapter<OmegaShootModel> {
  @override
  final int typeId = 2;

  DateTime _parse(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.parse(v);
    throw ArgumentError('Unsupported date/time value: $v');
  }

  @override
  OmegaShootModel read(BinaryReader r) {
    final numOfFields = r.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) r.readByte(): r.read(),
    };

    return OmegaShootModel(
      id: fields[0] as String,
      clientName: fields[1] as String,
      date: _parse(fields[2]),
      time: _parse(fields[3]),
      address: fields[4] as String,
      comments: fields[5] as String?,
      isPlanned: fields[6] as bool,
      shootReferencesPaths: (fields[7] as List).cast<String>(),
      finalShotsPaths: (fields[8] as List?)?.cast<String>(),
      notificationsEnabled: fields[9] as bool?,
    );
  }

  @override
  void write(BinaryWriter w, OmegaShootModel o) {
    w
      ..writeByte(10)
      ..writeByte(0)
      ..write(o.id)
      ..writeByte(1)
      ..write(o.clientName)
      ..writeByte(2)
      ..write(o.date)
      ..writeByte(3)
      ..write(o.time)
      ..writeByte(4)
      ..write(o.address)
      ..writeByte(5)
      ..write(o.comments)
      ..writeByte(6)
      ..write(o.isPlanned)
      ..writeByte(7)
      ..write(o.shootReferencesPaths)
      ..writeByte(8)
      ..write(o.finalShotsPaths)
      ..writeByte(9)
      ..write(o.notificationsEnabled);
  }
}
