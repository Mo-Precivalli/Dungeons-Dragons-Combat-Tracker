import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/combat.dart';
import '../../data/models/combatant.dart';
import '../widgets/add_combatant_dialog.dart';
import '../widgets/combatant_card.dart';
import '../widgets/condition_selector_dialog.dart';
import '../widgets/theme_toggle.dart';
import 'package:dnd_combat_tracker/l10n/app_localizations.dart';

class CombatDetailScreen extends ConsumerStatefulWidget {
  final int combatId;
  final String combatName;

  const CombatDetailScreen({
    super.key,
    required this.combatId,
    required this.combatName,
  });

  @override
  ConsumerState<CombatDetailScreen> createState() => _CombatDetailScreenState();
}

class _CombatDetailScreenState extends ConsumerState<CombatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};

  late final Box<Combat> _combatBox;
  late final Box<Combatant> _combatantBox;
  late final ValueListenable<Box<Combatant>> _combatantListenable;
  late final ValueNotifier<int> _activeTurnNotifier;
  late final ValueNotifier<int> _roundNotifier;

  @override
  void initState() {
    super.initState();
    _combatBox = Hive.box<Combat>('combats');
    _combatantBox = Hive.box<Combatant>('combatants');
    _combatantListenable = _combatantBox.listenable();

    final combat = _combatBox.get(widget.combatId);
    _activeTurnNotifier = ValueNotifier<int>(combat?.currentTurnIndex ?? 0);
    _roundNotifier = ValueNotifier<int>(combat?.roundCount ?? 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _activeTurnNotifier.dispose();
    _roundNotifier.dispose();
    super.dispose();
  }

  GlobalKey _getKeyForIndex(int index) {
    return _itemKeys.putIfAbsent(index, () => GlobalKey());
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

  void _handleNextTurn() {
    final combat = _combatBox.get(widget.combatId);
    if (combat == null) return;

    final combatants = _combatantBox.values
        .where((c) => c.combatId == widget.combatId)
        .toList()
      ..sort((a, b) => b.initiative.compareTo(a.initiative));
    if (combatants.isEmpty) return;

    int nextIndex = combat.currentTurnIndex + 1;
    bool foundNext = false;

    for (int i = nextIndex; i < combatants.length; i++) {
      if (_canTakeTurn(combatants[i])) {
        combat.currentTurnIndex = i;
        foundNext = true;
        break;
      }
    }

    if (!foundNext) {
      combat.roundCount++;
      combat.currentTurnIndex = 0;
      for (int i = 0; i < combatants.length; i++) {
        if (_canTakeTurn(combatants[i])) {
          combat.currentTurnIndex = i;
          break;
        }
      }
    }

    _roundNotifier.value = combat.roundCount;
    _activeTurnNotifier.value = combat.currentTurnIndex;
    _scrollToActiveCombatant(combat.currentTurnIndex);
    combat.save();
  }

  void _scrollToActiveCombatant(int activeIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      // Quando voltar para o primeiro da lista (início da rodada), volta ao topo
      if (activeIndex == 0) {
        if (_scrollController.offset > 0) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        }
        return;
      }

      final key = _itemKeys[activeIndex];
      final cardContext = key?.currentContext;
      if (cardContext == null) return;

      final renderObject = cardContext.findRenderObject();
      if (renderObject == null) return;

      final viewport = RenderAbstractViewport.maybeOf(renderObject);
      if (viewport == null) return;

      final position = _scrollController.position;
      final currentOffset = position.pixels;

      // Offset onde o topo do card fica visível no topo da tela (com pequena margem)
      final offsetToRevealTop =
          viewport.getOffsetToReveal(renderObject, 0.0).offset - 8.0;
      // Offset onde a base inteira do card fica visível na parte de baixo da tela
      final offsetToRevealBottom =
          viewport.getOffsetToReveal(renderObject, 1.0).offset + 12.0;

      double? targetOffset;
      if (currentOffset < offsetToRevealBottom) {
        // Card está cortado na parte de baixo ou abaixo do limite da tela -> desce apenas o necessário
        targetOffset = offsetToRevealBottom;
      } else if (currentOffset > offsetToRevealTop) {
        // Card está acima do limite superior da tela -> sobe apenas o necessário
        targetOffset = offsetToRevealTop;
      }

      if (targetOffset != null) {
        final clamped = targetOffset.clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );
        if ((clamped - currentOffset).abs() > 1.0) {
          _scrollController.animateTo(
            clamped,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<int>(
          valueListenable: _roundNotifier,
          builder: (context, roundCount, _) {
            return Column(
              children: [
                Text(widget.combatName),
                Text(
                  '${l10n.round} $roundCount',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            );
          },
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: ThemeToggle(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<Box<Combatant>>(
              valueListenable: _combatantListenable,
              builder: (context, cbBox, _) {
                final combatants = cbBox.values
                    .where((c) => c.combatId == widget.combatId)
                    .toList()
                  ..sort((a, b) => b.initiative.compareTo(a.initiative));

                if (combatants.isEmpty) {
                  return Center(child: Text(l10n.addCombatantsToStart));
                }

                return Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  thickness: 3.0,
                  radius: const Radius.circular(8),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(right: 4, bottom: 8),
                    child: Column(
                      children: [
                        for (int index = 0; index < combatants.length; index++)
                          KeyedSubtree(
                            key: _getKeyForIndex(index),
                            child: ValueListenableBuilder<int>(
                              valueListenable: _activeTurnNotifier,
                              builder: (context, activeTurnIndex, _) {
                                return CombatantCard(
                                  key: ValueKey(combatants[index].id),
                                  combatant: combatants[index],
                                  isActive: index == activeTurnIndex,
                                  onMinus: (amount) => _updateHp(
                                      ref, combatants[index], -amount),
                                  onPlus: (amount) =>
                                      _updateHp(ref, combatants[index], amount),
                                  onDeathSaveChanged: (successes, failures) =>
                                      _updateDeathSaves(ref, combatants[index],
                                          successes, failures),
                                  onEdit: () => _showCombatantDialog(
                                      context, ref,
                                      combatant: combatants[index]),
                                  onDelete: () => _deleteCombatant(
                                      ref, combatants[index].id),
                                  onConditionTap: () => _showConditionDialog(
                                      context, ref, combatants[index]),
                                  onTempHpTap: () => _showTempHpDialog(
                                      context, ref, combatants[index]),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _showAddCombatantFlow(context, ref),
                      child: const Text(
                        'Adicionar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.amber[800],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _handleNextTurn,
                      child: Text(
                        l10n.nextTurn,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateHp(WidgetRef ref, Combatant combatant, int amount) {
    int newHpCurrent = combatant.hpCurrent;
    int newHpTemp = combatant.hpTemp;

    if (amount < 0) {
      // Damage: Absorb with Temp HP first
      int damage = -amount;
      if (newHpTemp > 0) {
        if (newHpTemp >= damage) {
          newHpTemp -= damage;
          damage = 0;
        } else {
          damage -= newHpTemp;
          newHpTemp = 0;
        }
      }
      newHpCurrent = (newHpCurrent - damage).clamp(0, combatant.hpMax);
    } else {
      // Healing: Apply to HP Current
      newHpCurrent = (newHpCurrent + amount).clamp(0, combatant.hpMax);
    }

    combatant
      ..hpCurrent = newHpCurrent
      ..hpTemp = newHpTemp;

    if (newHpCurrent > 0) {
      combatant.deathSaveSuccesses = 0;
      combatant.deathSaveFailures = 0;
    }

    combatant.save();
  }

  void _updateDeathSaves(
      WidgetRef ref, Combatant combatant, int successes, int failures) {
    combatant
      ..deathSaveSuccesses = successes.clamp(0, 3)
      ..deathSaveFailures = failures.clamp(0, 3);
    combatant.save();
  }

  void _deleteCombatant(WidgetRef ref, int id) {
    final combatantsBefore = _combatantBox.values
        .where((c) => c.combatId == widget.combatId)
        .toList()
      ..sort((a, b) => b.initiative.compareTo(a.initiative));
    final deletedIndex = combatantsBefore.indexWhere((c) => c.id == id);

    _combatantBox.delete(id);

    final remainingLength =
        combatantsBefore.length - (deletedIndex != -1 ? 1 : 0);
    final combat = _combatBox.get(widget.combatId);
    int currentIndex = combat?.currentTurnIndex ?? _activeTurnNotifier.value;

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

    _activeTurnNotifier.value = currentIndex;
    if (combat != null) {
      combat.currentTurnIndex = currentIndex;
      combat.save();
    }
  }

  Future<void> _showTempHpDialog(
      BuildContext context, WidgetRef ref, Combatant combatant) async {
    final hpTempController =
        TextEditingController(text: combatant.hpTemp.toString());
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('HP Temporário: ${combatant.name}'),
        content: TextField(
          controller: hpTempController,
          decoration: const InputDecoration(labelText: 'HP Temp'),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final hpTemp = int.tryParse(hpTempController.text) ?? 0;
              combatant.hpTemp = hpTemp;
              combatant.save();
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _showConditionDialog(
      BuildContext context, WidgetRef ref, Combatant combatant) async {
    final result = await ConditionSelectorDialog.show(
      context,
      title: 'Condições: ${combatant.name}',
      initialConditions: combatant.conditions,
      characterClass: combatant.characterClass,
    );

    if (result != null) {
      combatant.conditions = result;
      combatant.save();
    }
  }

  Future<void> _showAddCombatantFlow(
      BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => AddCombatantDialog(
        combatId: widget.combatId,
        onAddCombatants: (combatants) async {
          for (final c in combatants) {
            await _combatantBox.add(c);
          }
        },
      ),
    );
  }

  Future<void> _showCombatantDialog(BuildContext context, WidgetRef ref,
      {Combatant? combatant}) async {
    final isEditing = combatant != null;
    final nameController = TextEditingController(text: combatant?.name ?? '');
    final initController =
        TextEditingController(text: combatant?.initiative.toString() ?? '');
    final hpCurrentController =
        TextEditingController(text: combatant?.hpCurrent.toString() ?? '');
    final hpController =
        TextEditingController(text: combatant?.hpMax.toString() ?? '');
    final acController =
        TextEditingController(text: combatant?.armorClass.toString() ?? '10');
    final hpTempController =
        TextEditingController(text: combatant?.hpTemp.toString() ?? '0');
    bool isPlayer = combatant?.isPlayer ?? false;
    final l10n = AppLocalizations.of(context)!;
    List<String> conditions = List.from(combatant?.conditions ?? []);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
              isEditing ? l10n.editCombatantTitle : l10n.addCombatantTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.name),
                  autofocus: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                          controller: initController,
                          decoration:
                              InputDecoration(labelText: l10n.initiative),
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                          controller: acController,
                          decoration: const InputDecoration(labelText: 'CA'),
                          keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (isEditing) ...[
                      Expanded(
                        child: TextField(
                            controller: hpCurrentController,
                            decoration:
                                const InputDecoration(labelText: 'PV Atual'),
                            keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: TextField(
                          controller: hpController,
                          decoration: InputDecoration(labelText: l10n.maxHp),
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                          controller: hpTempController,
                          decoration:
                              const InputDecoration(labelText: 'HP Temp'),
                          keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.checklist),
                  label: Text(conditions.isEmpty
                      ? 'Selecionar Condições'
                      : 'Condições Selecionadas (${conditions.length})'),
                  onPressed: () async {
                    final selected = await ConditionSelectorDialog.show(
                      context,
                      title: 'Selecionar Condições',
                      initialConditions: conditions,
                      characterClass: combatant?.characterClass,
                    );
                    if (selected != null) {
                      setState(() {
                        conditions = selected;
                      });
                    }
                  },
                ),
                if (conditions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: conditions
                        .map((c) => Chip(
                              label: Text(c,
                                  style: const TextStyle(fontSize: 12)),
                              visualDensity: VisualDensity.compact,
                              onDeleted: () {
                                setState(() {
                                  conditions.remove(c);
                                });
                              },
                            ))
                        .toList(),
                  ),
                ],
                CheckboxListTile(
                  title: Text(l10n.isPlayer),
                  value: isPlayer,
                  onChanged: (val) => setState(() => isPlayer = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel, textAlign: TextAlign.center)),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final init = int.tryParse(initController.text) ?? 0;
                final hp = int.tryParse(hpController.text) ?? 10;
                final ac = int.tryParse(acController.text) ?? 10;
                final hpTemp = int.tryParse(hpTempController.text) ?? 0;

                if (name.isEmpty) return;

                if (isEditing) {
                  final parsedCurrentHp =
                      int.tryParse(hpCurrentController.text) ??
                          combatant.hpCurrent;
                  final clampedCurrentHp = parsedCurrentHp.clamp(0, hp);

                  combatant
                    ..name = name
                    ..initiative = init
                    ..hpMax = hp
                    ..hpCurrent = clampedCurrentHp
                    ..armorClass = ac
                    ..hpTemp = hpTemp
                    ..conditions = conditions
                    ..isPlayer = isPlayer;

                  if (isPlayer) {
                    combatant.combatantType = 'player';
                  } else if (combatant.combatantType == 'player') {
                    combatant.combatantType = 'monster';
                  }

                  if (clampedCurrentHp > 0) {
                    combatant.deathSaveSuccesses = 0;
                    combatant.deathSaveFailures = 0;
                  }

                  await combatant.save();
                } else {
                  final newCombatant = Combatant()
                    ..combatId = widget.combatId
                    ..name = name
                    ..initiative = init
                    ..hpMax = hp
                    ..hpCurrent = hp
                    ..armorClass = ac
                    ..hpTemp = hpTemp
                    ..conditions = conditions
                    ..isPlayer = isPlayer
                    ..combatantType = isPlayer ? 'player' : 'monster';

                  await _combatantBox.add(newCombatant);
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? l10n.save : l10n.add,
                  textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
