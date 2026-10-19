import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/campaign.dart';
import '../../data/models/combat.dart';
import '../../data/models/combatant.dart';
import '../../data/repositories/hive_combat_repository.dart';
import '../../domain/repositories/i_combat_repository.dart';

part 'repository_providers.g.dart';

@riverpod
Future<ICombatRepository> combatRepository(CombatRepositoryRef ref) async {
  final combatBox = Hive.box<Combat>('combats');
  final combatantBox = Hive.box<Combatant>('combatants');
  final campaignBox = Hive.isBoxOpen('campaigns')
      ? Hive.box<Campaign>('campaigns')
      : null;
  return HiveCombatRepository(combatBox, combatantBox, campaignBox);
}
