import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/repositories/i_combat_repository.dart';
import '../models/campaign.dart';
import '../models/combat.dart';
import '../models/combatant.dart';

class HiveCombatRepository implements ICombatRepository {
  final Box<Combat> combatBox;
  final Box<Combatant> combatantBox;
  final Box<Campaign>? campaignBox;

  late final ValueListenable<Box<Combat>> _combatsListenable =
      combatBox.listenable();
  late final ValueListenable<Box<Combatant>> _combatantsListenable =
      combatantBox.listenable();
  late final ValueListenable<Object?> _campaignsListenable =
      (campaignBox?.listenable() as ValueListenable<Object?>?) ??
          ValueNotifier<Object?>(null);

  HiveCombatRepository(
    this.combatBox,
    this.combatantBox, [
    this.campaignBox,
  ]);

  @override
  ValueListenable<Object?> get combatsListenable => _combatsListenable;

  @override
  ValueListenable<Object?> get combatantsListenable => _combatantsListenable;

  @override
  ValueListenable<Object?> get campaignsListenable => _campaignsListenable;

  @override
  List<Combat> getCombatsSync() {
    return combatBox.values.toList();
  }

  @override
  Combat? getCombatSync(int id) {
    return combatBox.get(id);
  }

  @override
  List<Combatant> getCombatantsSync(int combatId) {
    final combatants = combatantBox.values
        .where((c) => c.combatId == combatId)
        .toList();
    combatants.sort((a, b) => b.initiative.compareTo(a.initiative));
    return combatants;
  }

  @override
  List<Campaign> getCampaignsSync() {
    return campaignBox?.values.toList() ?? [];
  }

  @override
  Campaign? getCampaignSync(int id) {
    return campaignBox?.get(id);
  }

  @override
  Future<List<Combat>> getCombats() async {
    return combatBox.values.toList();
  }

  @override
  Stream<List<Combat>> watchCombats() {
    return combatBox
        .watch()
        .map((event) => combatBox.values.toList())
        .startWith(combatBox.values.toList());
  }

  @override
  Stream<Combat?> watchCombat(int id) {
    return combatBox
        .watch(key: id)
        .map((event) => combatBox.get(id))
        .startWith(combatBox.get(id));
  }

  @override
  Future<Combat?> getCombat(int id) async {
    return combatBox.get(id);
  }

  @override
  Future<List<Combatant>> getCombatants(int combatId) async {
    return getCombatantsSync(combatId);
  }

  @override
  Future<void> addCombat(Combat combat) async {
    await combatBox.add(combat);
  }

  @override
  Future<void> updateCombat(Combat combat) async {
    if (combat.isInBox) {
      await combat.save();
    } else {
      await combatBox.put(combat.id, combat);
    }
  }

  @override
  Future<void> deleteCombat(int id) async {
    await combatBox.delete(id);
    final combatantsToDelete = combatantBox.values
        .where((c) => c.combatId == id)
        .map((c) => c.key)
        .toList();
    await combatantBox.deleteAll(combatantsToDelete);
  }

  @override
  Future<void> addCombatant(Combatant combatant) async {
    await combatantBox.add(combatant);
  }

  @override
  Future<void> updateCombatant(Combatant combatant) async {
    if (combatant.isInBox) {
      await combatant.save();
    } else {
      await combatantBox.put(combatant.id, combatant);
    }
  }

  @override
  Future<void> deleteCombatant(int id) async {
    await combatantBox.delete(id);
  }

  @override
  Stream<List<Combatant>> watchCombatants(int combatId) {
    return combatantBox.watch().map((_) => getCombatantsSync(combatId)).startWith(
          getCombatantsSync(combatId),
        );
  }

  @override
  Future<List<Campaign>> getCampaigns() async {
    return getCampaignsSync();
  }

  @override
  Future<void> addCampaign(Campaign campaign) async {
    await campaignBox?.add(campaign);
  }

  @override
  Future<void> updateCampaign(Campaign campaign) async {
    if (campaign.isInBox) {
      await campaign.save();
    } else {
      await campaignBox?.put(campaign.id, campaign);
    }
  }

  @override
  Future<void> deleteCampaign(int id) async {
    await campaignBox?.delete(id);
  }
}

extension StreamStartWith<T> on Stream<T> {
  Stream<T> startWith(T initial) async* {
    yield initial;
    yield* this;
  }
}
