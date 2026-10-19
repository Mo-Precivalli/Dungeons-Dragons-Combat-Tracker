// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CombatAdapter extends TypeAdapter<Combat> {
  @override
  final int typeId = 0;

  @override
  Combat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Combat()
      ..name = fields[0] as String
      ..createdAt = fields[1] as DateTime
      ..status = fields[2] as CombatStatus
      ..roundCount = fields[3] as int
      ..currentTurnIndex = fields[4] as int
      ..campaignId = fields[5] as int?
      ..campaignName = fields[6] as String?;
  }

  @override
  void write(BinaryWriter writer, Combat obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.roundCount)
      ..writeByte(4)
      ..write(obj.currentTurnIndex)
      ..writeByte(5)
      ..write(obj.campaignId)
      ..writeByte(6)
      ..write(obj.campaignName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CombatStatusAdapter extends TypeAdapter<CombatStatus> {
  @override
  final int typeId = 2;

  @override
  CombatStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CombatStatus.active;
      case 1:
        return CombatStatus.finished;
      default:
        return CombatStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, CombatStatus obj) {
    switch (obj) {
      case CombatStatus.active:
        writer.writeByte(0);
        break;
      case CombatStatus.finished:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombatStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
