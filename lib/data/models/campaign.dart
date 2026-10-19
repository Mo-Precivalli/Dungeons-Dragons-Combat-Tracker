import 'package:hive/hive.dart';

part 'campaign.g.dart';

@HiveType(typeId: 4)
class PartyHero {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String characterClass;

  @HiveField(3)
  int hpMax;

  @HiveField(4)
  int armorClass;

  @HiveField(5)
  int initiativeBonus;

  PartyHero({
    required this.id,
    required this.name,
    required this.characterClass,
    required this.hpMax,
    required this.armorClass,
    this.initiativeBonus = 0,
  });

  PartyHero copyWith({
    String? id,
    String? name,
    String? characterClass,
    int? hpMax,
    int? armorClass,
    int? initiativeBonus,
  }) {
    return PartyHero(
      id: id ?? this.id,
      name: name ?? this.name,
      characterClass: characterClass ?? this.characterClass,
      hpMax: hpMax ?? this.hpMax,
      armorClass: armorClass ?? this.armorClass,
      initiativeBonus: initiativeBonus ?? this.initiativeBonus,
    );
  }
}

@HiveType(typeId: 3)
class Campaign extends HiveObject {
  int? _id;

  int get id => _id ?? (key as int);
  set id(int value) => _id = value;

  @HiveField(0)
  late String name;

  @HiveField(1)
  String description = '';

  @HiveField(2)
  late DateTime createdAt;

  @HiveField(3)
  List<PartyHero> heroes = [];
}
