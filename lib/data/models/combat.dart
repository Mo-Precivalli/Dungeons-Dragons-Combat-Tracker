import 'package:hive/hive.dart';

part 'combat.g.dart';

@HiveType(typeId: 0)
class Combat extends HiveObject {
  int? _id;

  // Hive auto-generates keys, so we don't need an explicit Id field for storage,
  // but we can use the key as the ID (or _id in unit tests).
  int get id => _id ?? (key as int);
  set id(int value) => _id = value;

  @HiveField(0)
  late String name;

  @HiveField(1)
  late DateTime createdAt;

  @HiveField(2)
  late CombatStatus status;

  @HiveField(3)
  int roundCount = 1;

  @HiveField(4)
  int currentTurnIndex = 0;
}

@HiveType(typeId: 2)
enum CombatStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  finished,
}
