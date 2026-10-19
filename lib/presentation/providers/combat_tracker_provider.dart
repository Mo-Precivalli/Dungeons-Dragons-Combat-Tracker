import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/campaign.dart';
import '../../data/models/combat.dart';
import '../../data/models/combatant.dart';
import '../../data/repositories/hive_combat_repository.dart';
import '../../domain/repositories/i_combat_repository.dart';
import '../../domain/services/combat_undo_manager.dart';

final syncCombatRepositoryProvider = Provider<ICombatRepository>((ref) {
  final combatBox = Hive.box<Combat>('combats');
  final combatantBox = Hive.box<Combatant>('combatants');
  final campaignBox = Hive.box<Campaign>('campaigns');
  return HiveCombatRepository(combatBox, combatantBox, campaignBox);
});

final combatUndoManagerProvider = Provider<CombatUndoManager>((ref) {
  return CombatUndoManager();
});

final combatTrackerServiceProvider = Provider<CombatTrackerService>((ref) {
  final repo = ref.watch(syncCombatRepositoryProvider);
  final undoManager = ref.watch(combatUndoManagerProvider);
  return CombatTrackerService(repo, undoManager);
});

/// Stores the currently selected Campaign filter on Dashboard (`null` = all campaigns)
final selectedCampaignFilterProvider = StateProvider<int?>((ref) => null);

class CombatTrackerService {
  final ICombatRepository repository;
  final CombatUndoManager undoManager;

  CombatTrackerService(this.repository, this.undoManager) {
    _syncExistingCombatPlayersToCampaigns();
  }

  /// Ensures any player already created inside a campaign's combat is saved in that campaign's hero roster.
  void _syncExistingCombatPlayersToCampaigns() {
    final campaigns = repository.getCampaignsSync();
    if (campaigns.isEmpty) return;

    final allCombats = repository.getCombatsSync();
    for (final campaign in campaigns) {
      bool updated = false;
      final campaignCombats =
          allCombats.where((c) => c.campaignId == campaign.id);
      for (final combat in campaignCombats) {
        final combatants = repository.getCombatantsSync(combat.id);
        for (final c in combatants) {
          if (c.isPlayer || c.combatantType == 'player') {
            final exists = campaign.heroes.any(
              (h) => h.name.trim().toLowerCase() == c.name.trim().toLowerCase(),
            );
            if (!exists) {
              campaign.heroes.add(
                PartyHero(
                  id: '${DateTime.now().microsecondsSinceEpoch}_${c.id}',
                  name: c.name.trim(),
                  characterClass: (c.characterClass != null &&
                          c.characterClass!.trim().isNotEmpty)
                      ? c.characterClass!.trim()
                      : 'Guerreiro',
                  hpMax: c.hpMax,
                  armorClass: c.armorClass,
                  initiativeBonus: 0,
                ),
              );
              updated = true;
            }
          }
        }
      }
      if (updated) {
        repository.updateCampaign(campaign);
      }
    }
  }

  Future<void> _syncCombatantPlayerToCampaign(Combatant c) async {
    if (!c.isPlayer && c.combatantType != 'player') return;
    final combat = repository.getCombatSync(c.combatId);
    if (combat?.campaignId == null) return;
    final campaign = repository.getCampaignSync(combat!.campaignId!);
    if (campaign == null) return;

    final normalizedName = c.name.trim().toLowerCase();
    final existingIdx = campaign.heroes.indexWhere(
      (h) => h.name.trim().toLowerCase() == normalizedName,
    );

    final heroClass =
        (c.characterClass != null && c.characterClass!.trim().isNotEmpty)
            ? c.characterClass!.trim()
            : 'Guerreiro';

    if (existingIdx == -1) {
      campaign.heroes.add(
        PartyHero(
          id: '${DateTime.now().microsecondsSinceEpoch}_${c.name.hashCode}',
          name: c.name.trim(),
          characterClass: heroClass,
          hpMax: c.hpMax,
          armorClass: c.armorClass,
          initiativeBonus: 0,
        ),
      );
    } else {
      campaign.heroes[existingIdx] = campaign.heroes[existingIdx].copyWith(
        name: c.name.trim(),
        characterClass: heroClass,
        hpMax: c.hpMax,
        armorClass: c.armorClass,
      );
    }
    await repository.updateCampaign(campaign);
  }

  // Listenables for reactive UI without Hive imports
  ValueListenable<Object?> get combatsListenable => repository.combatsListenable;
  ValueListenable<Object?> get combatantsListenable =>
      repository.combatantsListenable;
  ValueListenable<Object?> get campaignsListenable =>
      repository.campaignsListenable;

  ValueListenable<bool> canUndoListenable(int combatId) =>
      undoManager.canUndoListenable(combatId);

  // --- Campaign Operations ---
  List<Campaign> getCampaigns() => repository.getCampaignsSync();

  Campaign? getCampaign(int id) => repository.getCampaignSync(id);

  Future<Campaign> createCampaign({
    required String name,
    String description = '',
    List<PartyHero>? heroes,
  }) async {
    final campaign = Campaign()
      ..name = name.trim()
      ..description = description.trim()
      ..createdAt = DateTime.now()
      ..heroes = heroes ?? [];
    await repository.addCampaign(campaign);
    return campaign;
  }

  Future<void> updateCampaign(Campaign campaign) async {
    await repository.updateCampaign(campaign);
  }

  Future<void> deleteCampaign(int campaignId) async {
    await repository.deleteCampaign(campaignId);
  }

  // --- Combat Operations ---
  List<Combat> getCombats({int? campaignIdFilter}) {
    final all = repository.getCombatsSync();
    if (campaignIdFilter == null) return all;
    return all.where((c) => c.campaignId == campaignIdFilter).toList();
  }

  Combat? getCombat(int combatId) => repository.getCombatSync(combatId);

  List<Combatant> getCombatants(int combatId) =>
      repository.getCombatantsSync(combatId);

  Future<Combat> createCombat({
    required String name,
    Campaign? campaign,
    Map<String, int>? heroInitiatives,
  }) async {
    final combat = Combat()
      ..name = name.trim()
      ..createdAt = DateTime.now()
      ..status = CombatStatus.active
      ..campaignId = campaign?.id
      ..campaignName = campaign?.name;

    await repository.addCombat(combat);

    if (campaign != null && campaign.heroes.isNotEmpty) {
      for (final hero in campaign.heroes) {
        final init = heroInitiatives?[hero.id] ?? (10 + hero.initiativeBonus);
        final combatant = Combatant()
          ..combatId = combat.id
          ..name = hero.name
          ..initiative = init
          ..hpMax = hero.hpMax
          ..hpCurrent = hero.hpMax
          ..armorClass = hero.armorClass
          ..hpTemp = 0
          ..conditions = []
          ..isPlayer = true
          ..combatantType = 'player'
          ..characterClass = hero.characterClass;
        await repository.addCombatant(combatant);
      }
    }

    return combat;
  }

  Future<void> deleteCombat(int combatId) async {
    undoManager.clear(combatId);
    await repository.deleteCombat(combatId);
  }

  // --- Snapshot & Undo Operations ---
  void recordSnapshot(int combatId) {
    final combat = repository.getCombatSync(combatId);
    if (combat == null) return;
    final combatants = repository.getCombatantsSync(combatId);
    undoManager.pushSnapshot(
      CombatStateSnapshot(
        combatId: combatId,
        roundCount: combat.roundCount,
        currentTurnIndex: combat.currentTurnIndex,
        combatants:
            combatants.map((c) => CombatantSnapshot.fromCombatant(c)).toList(),
      ),
    );
  }

  Future<CombatStateSnapshot?> undoLastAction(int combatId) async {
    final snapshot = undoManager.popSnapshot(combatId);
    if (snapshot == null) return null;

    final combat = repository.getCombatSync(combatId);
    if (combat != null) {
      combat
        ..roundCount = snapshot.roundCount
        ..currentTurnIndex = snapshot.currentTurnIndex;
      await repository.updateCombat(combat);
    }

    // Restore combatants to exact snapshot state
    final currentCombatants = repository.getCombatantsSync(combatId);
    final snapshotIds = snapshot.combatants.map((s) => s.id).toSet();

    // 1. Delete combatants that were added after the snapshot
    for (final existing in currentCombatants) {
      if (!snapshotIds.contains(existing.id)) {
        await repository.deleteCombatant(existing.id);
      }
    }

    // 2. Update or re-insert combatants from the snapshot
    final existingMap = {for (final c in currentCombatants) c.id: c};
    for (final snap in snapshot.combatants) {
      final existing = existingMap[snap.id];
      if (existing != null) {
        existing
          ..name = snap.name
          ..initiative = snap.initiative
          ..hpCurrent = snap.hpCurrent
          ..hpMax = snap.hpMax
          ..hpTemp = snap.hpTemp
          ..armorClass = snap.armorClass
          ..isPlayer = snap.isPlayer
          ..combatantType = snap.combatantType
          ..characterClass = snap.characterClass
          ..conditions = List<String>.from(snap.conditions)
          ..deathSaveSuccesses = snap.deathSaveSuccesses
          ..deathSaveFailures = snap.deathSaveFailures
          ..pendingConcentrationDc = snap.pendingConcentrationDc;
        await repository.updateCombatant(existing);
      } else {
        await repository.updateCombatant(snap.toCombatant());
      }
    }

    return snapshot;
  }

  // --- Turn & Combatant Actions ---
  bool canTakeTurn(Combatant c) {
    if (c.hpCurrent > 0) return true;
    final hasDeathSaves =
        c.isPlayer || c.combatantType == 'player' || c.combatantType == 'npc';
    if (hasDeathSaves && c.deathSaveFailures < 3 && c.deathSaveSuccesses < 3) {
      return true;
    }
    return false;
  }

  ({int turnIndex, int roundCount}) advanceTurn(int combatId) {
    final combat = repository.getCombatSync(combatId);
    if (combat == null) return (turnIndex: 0, roundCount: 1);

    final combatants = repository.getCombatantsSync(combatId);
    if (combatants.isEmpty) {
      return (
        turnIndex: combat.currentTurnIndex,
        roundCount: combat.roundCount
      );
    }

    recordSnapshot(combatId);

    int nextIndex = combat.currentTurnIndex + 1;
    int nextRound = combat.roundCount;
    bool foundNext = false;

    for (int i = nextIndex; i < combatants.length; i++) {
      if (canTakeTurn(combatants[i])) {
        nextIndex = i;
        foundNext = true;
        break;
      }
    }

    if (!foundNext) {
      nextRound++;
      nextIndex = 0;
      for (int i = 0; i < combatants.length; i++) {
        if (canTakeTurn(combatants[i])) {
          nextIndex = i;
          break;
        }
      }
    }

    combat
      ..currentTurnIndex = nextIndex
      ..roundCount = nextRound;
    repository.updateCombat(combat);

    return (turnIndex: nextIndex, roundCount: nextRound);
  }

  Future<void> applyCombatInitiatives(
    int combatId,
    Map<int, int> initiativesByCombatantId,
  ) async {
    recordSnapshot(combatId);
    final combatants = repository.getCombatantsSync(combatId);
    for (final c in combatants) {
      final newInit = initiativesByCombatantId[c.id];
      if (newInit != null) {
        c.initiative = newInit;
        await repository.updateCombatant(c);
      }
    }
    final combat = repository.getCombatSync(combatId);
    if (combat != null) {
      combat.currentTurnIndex = 0;
      await repository.updateCombat(combat);
    }
  }

  void updateHp(Combatant combatant, int amount) {
    recordSnapshot(combatant.combatId);

    int newHpCurrent = combatant.hpCurrent;
    int newHpTemp = combatant.hpTemp;

    if (amount < 0) {
      final int totalDamage = -amount;
      int remainingDamage = totalDamage;
      if (newHpTemp > 0) {
        if (newHpTemp >= remainingDamage) {
          newHpTemp -= remainingDamage;
          remainingDamage = 0;
        } else {
          remainingDamage -= newHpTemp;
          newHpTemp = 0;
        }
      }
      newHpCurrent = (newHpCurrent - remainingDamage).clamp(0, combatant.hpMax);

      // Concentration check rule (D&D 5e):
      // If concentrating and takes damage:
      // - If HP drops to 0, automatically loses concentration.
      // - Otherwise, triggers Concentration Check with DC = max(10, totalDamage ~/ 2).
      if (combatant.isConcentrating && totalDamage > 0) {
        if (newHpCurrent == 0) {
          combatant.conditions
              .removeWhere((c) => c.toLowerCase().contains('concentra'));
          combatant.pendingConcentrationDc = null;
        } else {
          final dc = math.max(10, totalDamage ~/ 2);
          combatant.pendingConcentrationDc = dc;
        }
      }
    } else {
      newHpCurrent = (newHpCurrent + amount).clamp(0, combatant.hpMax);
    }

    combatant
      ..hpCurrent = newHpCurrent
      ..hpTemp = newHpTemp;

    if (newHpCurrent > 0) {
      combatant.deathSaveSuccesses = 0;
      combatant.deathSaveFailures = 0;
    }

    repository.updateCombatant(combatant);
  }

  void resolveConcentration(Combatant combatant, {required bool keepsConcentration}) {
    recordSnapshot(combatant.combatId);
    combatant.pendingConcentrationDc = null;
    if (!keepsConcentration) {
      combatant.conditions
          .removeWhere((c) => c.toLowerCase().contains('concentra'));
    }
    repository.updateCombatant(combatant);
  }

  void updateTempHp(Combatant combatant, int hpTemp) {
    recordSnapshot(combatant.combatId);
    combatant.hpTemp = hpTemp;
    repository.updateCombatant(combatant);
  }

  void updateConditions(Combatant combatant, List<String> conditions) {
    recordSnapshot(combatant.combatId);
    combatant.conditions = List<String>.from(conditions);
    if (!combatant.isConcentrating) {
      combatant.pendingConcentrationDc = null;
    }
    repository.updateCombatant(combatant);
  }

  void updateDeathSaves(Combatant combatant, int successes, int failures) {
    recordSnapshot(combatant.combatId);
    combatant
      ..deathSaveSuccesses = successes.clamp(0, 3)
      ..deathSaveFailures = failures.clamp(0, 3);
    repository.updateCombatant(combatant);
  }

  Future<void> addCombatants(int combatId, List<Combatant> newCombatants) async {
    if (newCombatants.isEmpty) return;
    recordSnapshot(combatId);
    for (final c in newCombatants) {
      await repository.addCombatant(c);
      await _syncCombatantPlayerToCampaign(c);
    }
  }

  Future<void> saveCombatantEdit(Combatant combatant) async {
    if (!combatant.isConcentrating) {
      combatant.pendingConcentrationDc = null;
    }
    await repository.updateCombatant(combatant);
    await _syncCombatantPlayerToCampaign(combatant);
  }

  int deleteCombatant(int combatId, int combatantId, int currentActiveIndex) {
    recordSnapshot(combatId);

    final combatantsBefore = repository.getCombatantsSync(combatId);
    final deletedIndex =
        combatantsBefore.indexWhere((c) => c.id == combatantId);

    repository.deleteCombatant(combatantId);

    final remainingLength =
        combatantsBefore.length - (deletedIndex != -1 ? 1 : 0);
    final combat = repository.getCombatSync(combatId);
    int currentIndex = combat?.currentTurnIndex ?? currentActiveIndex;

    if (remainingLength <= 0) {
      currentIndex = 0;
    } else {
      if (deletedIndex != -1 && deletedIndex < currentIndex) {
        currentIndex -= 1;
      }
      if (currentIndex >= remainingLength) {
        currentIndex = 0;
      }
    }

    if (combat != null) {
      combat.currentTurnIndex = currentIndex;
      repository.updateCombat(combat);
    }
    return currentIndex;
  }
}
