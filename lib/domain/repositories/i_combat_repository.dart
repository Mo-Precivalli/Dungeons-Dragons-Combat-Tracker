import 'package:flutter/foundation.dart';
import '../../data/models/campaign.dart';
import '../../data/models/combat.dart';
import '../../data/models/combatant.dart';

abstract class ICombatRepository {
  // Reactive listenables for zero-flicker UI binding without exposing Hive
  ValueListenable<Object?> get combatsListenable => ValueNotifier<Object?>(null);
  ValueListenable<Object?> get combatantsListenable => ValueNotifier<Object?>(null);
  ValueListenable<Object?> get campaignsListenable => ValueNotifier<Object?>(null);

  // Synchronous accessors
  List<Combat> getCombatsSync() => [];
  Combat? getCombatSync(int id) => null;
  List<Combatant> getCombatantsSync(int combatId) => [];
  List<Campaign> getCampaignsSync() => [];
  Campaign? getCampaignSync(int id) => null;

  // Combat CRUD
  Future<List<Combat>> getCombats();
  Stream<List<Combat>> watchCombats();
  Stream<Combat?> watchCombat(int id);
  Future<Combat?> getCombat(int id);
  Future<void> addCombat(Combat combat);
  Future<void> updateCombat(Combat combat);
  Future<void> deleteCombat(int id);

  // Combatant Management
  Future<List<Combatant>> getCombatants(int combatId);
  Future<void> addCombatant(Combatant combatant);
  Future<void> updateCombatant(Combatant combatant);
  Future<void> deleteCombatant(int id);
  Stream<List<Combatant>> watchCombatants(int combatId);

  // Campaign Management
  Future<List<Campaign>> getCampaigns() async => [];
  Future<void> addCampaign(Campaign campaign) async {}
  Future<void> updateCampaign(Campaign campaign) async {}
  Future<void> deleteCampaign(int id) async {}
}
