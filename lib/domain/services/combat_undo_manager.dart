import 'package:flutter/foundation.dart';
import '../../data/models/combatant.dart';

class CombatantSnapshot {
  final int id;
  final int combatId;
  final String name;
  final int initiative;
  final int hpCurrent;
  final int hpMax;
  final int hpTemp;
  final int armorClass;
  final bool isPlayer;
  final String combatantType;
  final String? characterClass;
  final List<String> conditions;
  final int deathSaveSuccesses;
  final int deathSaveFailures;
  final int? pendingConcentrationDc;

  CombatantSnapshot({
    required this.id,
    required this.combatId,
    required this.name,
    required this.initiative,
    required this.hpCurrent,
    required this.hpMax,
    required this.hpTemp,
    required this.armorClass,
    required this.isPlayer,
    required this.combatantType,
    required this.characterClass,
    required this.conditions,
    required this.deathSaveSuccesses,
    required this.deathSaveFailures,
    required this.pendingConcentrationDc,
  });

  factory CombatantSnapshot.fromCombatant(Combatant c) {
    return CombatantSnapshot(
      id: c.id,
      combatId: c.combatId,
      name: c.name,
      initiative: c.initiative,
      hpCurrent: c.hpCurrent,
      hpMax: c.hpMax,
      hpTemp: c.hpTemp,
      armorClass: c.armorClass,
      isPlayer: c.isPlayer,
      combatantType: c.combatantType,
      characterClass: c.characterClass,
      conditions: List<String>.from(c.conditions),
      deathSaveSuccesses: c.deathSaveSuccesses,
      deathSaveFailures: c.deathSaveFailures,
      pendingConcentrationDc: c.pendingConcentrationDc,
    );
  }

  Combatant toCombatant() {
    return Combatant()
      ..id = id
      ..combatId = combatId
      ..name = name
      ..initiative = initiative
      ..hpCurrent = hpCurrent
      ..hpMax = hpMax
      ..hpTemp = hpTemp
      ..armorClass = armorClass
      ..isPlayer = isPlayer
      ..combatantType = combatantType
      ..characterClass = characterClass
      ..conditions = List<String>.from(conditions)
      ..deathSaveSuccesses = deathSaveSuccesses
      ..deathSaveFailures = deathSaveFailures
      ..pendingConcentrationDc = pendingConcentrationDc;
  }
}

class CombatStateSnapshot {
  final int combatId;
  final int roundCount;
  final int currentTurnIndex;
  final List<CombatantSnapshot> combatants;

  CombatStateSnapshot({
    required this.combatId,
    required this.roundCount,
    required this.currentTurnIndex,
    required this.combatants,
  });
}

class CombatUndoManager {
  static const int _maxHistory = 50;
  final Map<int, List<CombatStateSnapshot>> _stacks = {};
  final Map<int, ValueNotifier<bool>> _canUndoNotifiers = {};

  ValueListenable<bool> canUndoListenable(int combatId) {
    return _canUndoNotifiers.putIfAbsent(
      combatId,
      () => ValueNotifier<bool>((_stacks[combatId]?.isNotEmpty) ?? false),
    );
  }

  bool canUndo(int combatId) {
    return (_stacks[combatId]?.isNotEmpty) ?? false;
  }

  void pushSnapshot(CombatStateSnapshot snapshot) {
    final stack = _stacks.putIfAbsent(snapshot.combatId, () => []);
    stack.add(snapshot);
    if (stack.length > _maxHistory) {
      stack.removeAt(0);
    }
    _canUndoNotifiers
        .putIfAbsent(snapshot.combatId, () => ValueNotifier<bool>(true))
        .value = stack.isNotEmpty;
  }

  CombatStateSnapshot? popSnapshot(int combatId) {
    final stack = _stacks[combatId];
    if (stack == null || stack.isEmpty) return null;
    final snapshot = stack.removeLast();
    _canUndoNotifiers[combatId]?.value = stack.isNotEmpty;
    return snapshot;
  }

  void clear(int combatId) {
    _stacks.remove(combatId);
    _canUndoNotifiers[combatId]?.value = false;
  }
}
