import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_combat_tracker/presentation/providers/combat_controller.dart';
import 'package:dnd_combat_tracker/presentation/providers/combat_tracker_provider.dart';
import 'package:dnd_combat_tracker/presentation/providers/repository_providers.dart';
import 'package:dnd_combat_tracker/domain/repositories/i_combat_repository.dart';
import 'package:dnd_combat_tracker/domain/services/combat_undo_manager.dart';
import 'package:dnd_combat_tracker/data/models/campaign.dart';
import 'package:dnd_combat_tracker/data/models/combat.dart';
import 'package:dnd_combat_tracker/data/models/combatant.dart';

class MockCombatRepository extends ICombatRepository {
  final List<Combat> _combats = [];
  final List<Combatant> _combatants = [];
  final List<Campaign> _campaigns = [];

  @override
  List<Combat> getCombatsSync() => List.from(_combats);

  @override
  Combat? getCombatSync(int id) {
    try {
      return _combats.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Combatant> getCombatantsSync(int combatId) {
    final list = _combatants.where((c) => c.combatId == combatId).toList();
    list.sort((a, b) => b.initiative.compareTo(a.initiative));
    return list;
  }

  @override
  List<Campaign> getCampaignsSync() => List.from(_campaigns);

  @override
  Campaign? getCampaignSync(int id) {
    try {
      return _campaigns.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addCombat(Combat combat) async {
    combat.id = _combats.length + 1;
    _combats.add(combat);
  }

  @override
  Future<void> deleteCombat(int id) async {
    _combats.removeWhere((c) => c.id == id);
    _combatants.removeWhere((c) => c.combatId == id);
  }

  @override
  Future<List<Combat>> getCombats() async => _combats;

  @override
  Future<void> updateCombat(Combat combat) async {
    final index = _combats.indexWhere((c) => c.id == combat.id);
    if (index != -1) {
      _combats[index] = combat;
    }
  }

  @override
  Stream<List<Combat>> watchCombats() => Stream.value(_combats);

  @override
  Future<Combat?> getCombat(int id) async => getCombatSync(id);

  @override
  Future<List<Combatant>> getCombatants(int combatId) async =>
      getCombatantsSync(combatId);

  @override
  Future<void> addCombatant(Combatant combatant) async {
    combatant.id = _combatants.length + 1;
    _combatants.add(combatant);
  }

  @override
  Future<void> deleteCombatant(int id) async {
    _combatants.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> updateCombatant(Combatant combatant) async {
    final index = _combatants.indexWhere((c) => c.id == combatant.id);
    if (index != -1) {
      _combatants[index] = combatant;
    } else {
      _combatants.add(combatant);
    }
  }

  @override
  Stream<Combat?> watchCombat(int id) => Stream.value(null);

  @override
  Stream<List<Combatant>> watchCombatants(int combatId) => Stream.value([]);

  @override
  Future<void> addCampaign(Campaign campaign) async {
    campaign.id = _campaigns.length + 1;
    _campaigns.add(campaign);
  }

  @override
  Future<void> updateCampaign(Campaign campaign) async {
    final index = _campaigns.indexWhere((c) => c.id == campaign.id);
    if (index != -1) {
      _campaigns[index] = campaign;
    }
  }

  @override
  Future<void> deleteCampaign(int id) async {
    _campaigns.removeWhere((c) => c.id == id);
  }
}

void main() {
  late ProviderContainer container;
  late MockCombatRepository mockRepository;
  late CombatTrackerService service;

  setUp(() {
    mockRepository = MockCombatRepository();
    service = CombatTrackerService(mockRepository, CombatUndoManager());
    container = ProviderContainer(
      overrides: [
        combatRepositoryProvider.overrideWith((ref) => mockRepository),
        syncCombatRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('addCombat adds a combat to the repository', () async {
    final controller = container.read(combatControllerProvider.notifier);

    await controller.addCombat('Test Combat');

    final combats = await mockRepository.getCombats();
    expect(combats.length, 1);
    expect(combats.first.name, 'Test Combat');
  });

  test('deleteCombat removes a combat', () async {
    final controller = container.read(combatControllerProvider.notifier);
    await controller.addCombat('To Delete');
    final combatsBefore = await mockRepository.getCombats();
    final id = combatsBefore.first.id;

    await controller.deleteCombat(id);

    final combatsAfter = await mockRepository.getCombats();
    expect(combatsAfter.isEmpty, true);
  });

  test('nextTurn increments turn index', () async {
    final controller = container.read(combatControllerProvider.notifier);
    await controller.addCombat('Turn Test');
    final combats = await mockRepository.getCombats();
    final combatId = combats.first.id;

    await mockRepository.addCombatant(Combatant()
      ..combatId = combatId
      ..name = 'C1'
      ..initiative = 10
      ..hpMax = 10
      ..hpCurrent = 10
      ..isPlayer = true);
    await mockRepository.addCombatant(Combatant()
      ..combatId = combatId
      ..name = 'C2'
      ..initiative = 5
      ..hpMax = 10
      ..hpCurrent = 10
      ..isPlayer = false);

    await controller.nextTurn(combatId);

    final updatedCombats = await mockRepository.getCombats();
    expect(updatedCombats.first.currentTurnIndex, 1);
    expect(updatedCombats.first.roundCount, 1);
  });

  test('nextTurn resets turn index and increments round', () async {
    final controller = container.read(combatControllerProvider.notifier);
    await controller.addCombat('Round Test');
    final combats = await mockRepository.getCombats();
    final combatId = combats.first.id;

    await mockRepository.addCombatant(Combatant()
      ..combatId = combatId
      ..name = 'C1'
      ..initiative = 10
      ..hpMax = 10
      ..hpCurrent = 10
      ..isPlayer = true);
    await mockRepository.addCombatant(Combatant()
      ..combatId = combatId
      ..name = 'C2'
      ..initiative = 5
      ..hpMax = 10
      ..hpCurrent = 10
      ..isPlayer = false);

    combats.first.currentTurnIndex = 1;
    await mockRepository.updateCombat(combats.first);

    await controller.nextTurn(combatId);

    final updatedCombats = await mockRepository.getCombats();
    expect(updatedCombats.first.currentTurnIndex, 0);
    expect(updatedCombats.first.roundCount, 2);
  });

  test('Concentration check DC is triggered on damage and resolved cleanly',
      () async {
    final combat = await service.createCombat(name: 'Concentration Test');
    final mage = Combatant()
      ..combatId = combat.id
      ..name = 'Gandalf'
      ..initiative = 15
      ..hpMax = 40
      ..hpCurrent = 40
      ..isPlayer = true
      ..combatantType = 'player'
      ..conditions = ['Concentrando'];
    await mockRepository.addCombatant(mage);

    // 28 damage -> DC should be max(10, 28 ~/ 2) = 14
    service.updateHp(mage, -28);
    expect(mage.hpCurrent, 12);
    expect(mage.pendingConcentrationDc, 14);

    // Lose concentration -> removes 'Concentrando' and clears DC
    service.resolveConcentration(mage, keepsConcentration: false);
    expect(mage.pendingConcentrationDc, isNull);
    expect(mage.conditions.contains('Concentrando'), isFalse);
  });

  test('Undo reverts multiple movements and actions in reverse order',
      () async {
    final campaign = await service.createCampaign(
      name: 'Campanha X',
      heroes: [
        PartyHero(
          id: 'h1',
          name: 'Vax',
          characterClass: 'Ladino',
          hpMax: 30,
          armorClass: 16,
          initiativeBonus: 4,
        ),
      ],
    );
    final combat = await service.createCombat(
      name: 'Luta da Campanha X',
      campaign: campaign,
      heroInitiatives: {'h1': 19},
    );

    final combatants = service.getCombatants(combat.id);
    expect(combatants.length, 1);
    final vax = combatants.first;
    expect(vax.name, 'Vax');
    expect(vax.hpCurrent, 30);

    // Step 1: Damage Vax by 10
    service.updateHp(vax, -10);
    expect(vax.hpCurrent, 20);

    // Step 2: Damage Vax by 5 more
    service.updateHp(vax, -5);
    expect(vax.hpCurrent, 15);

    // Undo Step 2 -> back to 20 HP
    await service.undoLastAction(combat.id);
    expect(service.getCombatants(combat.id).first.hpCurrent, 20);

    // Undo Step 1 -> back to 30 HP
    await service.undoLastAction(combat.id);
    expect(service.getCombatants(combat.id).first.hpCurrent, 30);
  });
}
