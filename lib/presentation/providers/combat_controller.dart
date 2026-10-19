import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/combat.dart';
import '../../data/models/combatant.dart';
import 'repository_providers.dart';

part 'combat_controller.g.dart';

@riverpod
class CombatController extends _$CombatController {
  @override
  Stream<List<Combat>> build() async* {
    final repository = await ref.watch(combatRepositoryProvider.future);
    yield* repository.watchCombats();
  }

  Future<void> addCombat(String name) async {
    final repository = await ref.read(combatRepositoryProvider.future);
    final combat = Combat()
      ..name = name
      ..createdAt = DateTime.now()
      ..status = CombatStatus.active;
    await repository.addCombat(combat);
  }

  Future<void> deleteCombat(int id) async {
    final repository = await ref.read(combatRepositoryProvider.future);
    await repository.deleteCombat(id);
  }

  bool _canTakeTurn(Combatant c) {
    if (c.hpCurrent > 0) return true;
    final hasDeathSaves =
        c.isPlayer || c.combatantType == 'player' || c.combatantType == 'npc';
    if (hasDeathSaves && c.deathSaveFailures < 3 && c.deathSaveSuccesses < 3) {
      return true;
    }
    return false;
  }

  Future<void> nextTurn(int combatId) async {
    final repository = await ref.read(combatRepositoryProvider.future);

    final combat = await repository.getCombat(combatId);
    if (combat == null) return;

    final combatants = await repository.getCombatants(combatId);
    if (combatants.isEmpty) return;

    // Sort by initiative descending (matching UI)
    combatants.sort((a, b) => b.initiative.compareTo(a.initiative));

    int nextIndex = combat.currentTurnIndex + 1;
    bool foundNext = false;

    // Search for next active combatant in current round
    for (int i = nextIndex; i < combatants.length; i++) {
      if (_canTakeTurn(combatants[i])) {
        combat.currentTurnIndex = i;
        foundNext = true;
        break;
      }
    }

    // If not found, wrap around to start (next round)
    if (!foundNext) {
      combat.roundCount++;
      combat.currentTurnIndex = 0; // Default to 0 if all dead
      for (int i = 0; i < combatants.length; i++) {
        if (_canTakeTurn(combatants[i])) {
          combat.currentTurnIndex = i;
          break;
        }
      }
    }

    await repository.updateCombat(combat);
  }
}
