import 'package:hive/hive.dart';

part 'combatant.g.dart';

@HiveType(typeId: 1)
class Combatant extends HiveObject {
  int? _id;

  // Hive auto-generates keys
  int get id => _id ?? (key as int);
  set id(int value) => _id = value;

  @HiveField(0)
  late int combatId; // We'll store the combat key here for manual relational mapping

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int initiative;

  @HiveField(3)
  late int hpCurrent;

  @HiveField(4)
  late int hpMax;

  @HiveField(5)
  late bool isPlayer;

  @HiveField(6)
  int armorClass = 10;

  @HiveField(7)
  int hpTemp = 0;

  @HiveField(8)
  List<String> conditions = [];

  @HiveField(9)
  String? characterClass;

  @HiveField(10)
  String combatantType = 'monster'; // 'player', 'monster', 'npc'

  @HiveField(11)
  int deathSaveSuccesses = 0;

  @HiveField(12)
  int deathSaveFailures = 0;

  @HiveField(13)
  int? pendingConcentrationDc;

  bool get isConcentrating =>
      conditions.any((c) => c.toLowerCase().contains('concentra'));
}
