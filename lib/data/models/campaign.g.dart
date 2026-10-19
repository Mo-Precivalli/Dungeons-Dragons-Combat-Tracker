// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CampaignAdapter extends TypeAdapter<Campaign> {
  @override
  final int typeId = 3;

  @override
  Campaign read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Campaign()
      ..name = fields[0] as String
      ..description = (fields[1] as String?) ?? ''
      ..createdAt = fields[2] as DateTime
      ..heroes = (fields[3] as List?)?.cast<PartyHero>() ?? [];
  }

  @override
  void write(BinaryWriter writer, Campaign obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.heroes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CampaignAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PartyHeroAdapter extends TypeAdapter<PartyHero> {
  @override
  final int typeId = 4;

  @override
  PartyHero read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PartyHero(
      id: fields[0] as String,
      name: fields[1] as String,
      characterClass: fields[2] as String,
      hpMax: fields[3] as int,
      armorClass: fields[4] as int,
      initiativeBonus: (fields[5] as int?) ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, PartyHero obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.characterClass)
      ..writeByte(3)
      ..write(obj.hpMax)
      ..writeByte(4)
      ..write(obj.armorClass)
      ..writeByte(5)
      ..write(obj.initiativeBonus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartyHeroAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
